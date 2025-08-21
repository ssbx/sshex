

namespace eval script {

  proc fail {info_msg payload}  {
    global expect_out
    global buffer
    global opts

    send_user "erreur $info_msg\n"
    send_user "$payload"
    exit 1
  }

  proc run {} {
    global expect_out
    global buffer
    global opts

    match_max -d 5000000
    log_user 1
    send "terminal length 0\r"
    expect {
      -re $opts(prompt) {}
      eof     { fail "EOF" $expect_out(buffer) }
      timeout { fail "timeout wait promt" $expect_out(buffer) }
    }

    send "show running-config brief\r"
    expect {
      -re "\r\nCurrent configuration : .* bytes\r\n" {}
      eof { fail "EOF" $expect_out(buffer) }
      timeout { fail "timeout" $expect_out(buffer) }
    }

    expect {
        -re "\r\n!\r\nend\r\n\r\n" { send_user $expect_out(buffer) }
        timeout { fail "timeout" $expect_out(buffer) }
        eof { fail "EOF" $expect_out(buffer) }
    }
  }
}

