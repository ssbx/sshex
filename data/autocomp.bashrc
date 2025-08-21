
comp=""
while read l; do
  comp="${comp} $l"
done < $HOME/.local/share/sshe/autocomp.hosts

complete -W "$comp" sshe

export SSHE_AUTOCOMP_LOADED=yes

