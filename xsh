#!/usr/bin/bash -l
# next line ignored by tclsh \
exec tclsh "$0" ${1+"$@"}


print_help {} {
  puts "xsh \[SSHE_OPTIONS\] \[SSH_OPTIONS\]"
  puts ""
  puts "Toutes les options ssh sont transmises à l'executable ssh, les options"
  puts "qui commencent par --xsh-* sont retirée avant."
  puts ""
  #puts "OPTIONS reconnues par xsh et transmise à ssh:"
  #puts "  -h  Print help"
  #puts ""
  puts "OPTIONS reconnues par xsh retirées d'argv avant appel a commande ssh"
  puts "  --xsh-bin        Executable ssh à utiliser"
  puts "  --xsh-script     Fichier expect à sourcer apres le login"
  puts "  --xsh-donotclose Ne pas clore le terminal en cas de deconnection"
  puts ""
  exit 0
}


array set opts {h 0 noclose 0 script 0 sshbin ssh prompt ".*#" sshargv {}}
foreach arg $::argv {
  set remaining {}
  switch -regexp -matchvar m $arg {
    "-h"                  { print_help; exit 0 }
    "--xsh-donotclose" ] { set opts(noclose) 1 }
    "--xsh-script=(.*)"  { set opts(script) [lindex $m 1] }
    "--xsh-bin=(.*)"     { set opts(sshbin) [lindex $m 1] }
    "--xsh-prompt=(.*)"  { set opts(prompt) [lindex $m 1] }
    "--xsh(.*)"          { puts stderr "wrong arg [lindex $m 1]"; exit 1 }
    "(.*)"                { lappend remaining [lindex $m 0]}
  }
  set opts(sshargs) $remaining
}
set password [$::env(SSHPASS)]



###############################################################################
package require Expect

match_max -d 5000000

log_user 0
if { $opts(script) == 0 } {
  log_user 1
}

set sshuser [dict get [exec $opts(sshbin) {*}${opts(sshargv)} -G] user]
while {1} {

  spawn $opts(sshbin) {*}${opts(sshargv)}

  set timeout 5

  expect {

    # standard style (cisco)
    -re "^.*password: "  {
      send "$password\r"
    }
    -re "^.*Password: "  {
      send "$password\r"
    }
    # alcatel style
    -re "^.*password.*keyboard-interactive method:"  {
      send "$password\r"
    }
    # allied style
    -re "User Name:" {
      send "$sshuser\r"
      expect {
        -re "Password:" {
          send "$password\r"
        }
        timeout {
          send_user "xsh n'a pas reconnus de prompt password pour cet hote"
          send_user "taper Return pour quiter\n"
          set timeout -1
          expect_user "\n" { exit 1 }
        }
        eof {
          send_user "ssh eof"
          send_user $expect_out(buffer)
          send_user "taper Return pour quiter\n"
          set timeout -1
          expect_user "\n" { exit 1 }
        }
      }
    }

    # timeout
    timeout {
      send_user "xsh n'a pas reconnus de prompt username ou password pour cet hote"
      send_user "taper Return pour quiter\n"
      set timeout -1
      expect_user "\n" { exit 1 }
    }

    # ssh pas lancé erreur
    eof {
      send_user $expect_out(buffer)
      send_user "taper Return pour quiter\n"
      set timeout -1
      expect_user "\n" { exit 1 }
    }
  }

  # on détermine le bon prompt
  expect {
    -re "^.*>" {
      # hp/alcatel prompt
      set opts(prompt) "^.*>"
    }
    -re ".*#" {
      # cisco/allied/dell, déja mis
      set opts(prompt) ".*#"
    }
  }

  if { $opts(script) != 0 } {
    source $opts(script)
    ::script::run
  } else {
    interact
    if { $opts(donotclose) } {
      send_user "\n==> xsh-donotclose RECONNECT(Return) or QUIT(Ctrl-D)? "
      set timeout -1
      expect_user {
        "\n" continue
        \002 exit
      }
    }
  }
  break
}
