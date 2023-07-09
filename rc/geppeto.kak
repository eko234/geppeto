declare-option str geppetotempprefixorsomething /tmp/kakgeppeto

declare-option -hidden str geppetochatoutfifo
declare-option -hidden str geppetochatinfifo

declare-option str geppetolockfile /tmp/kakgeppeto.lock
declare-option str geppetoprogram geppeto
declare-option bool geppetostarted false

define-command opengpt -hidden -override %{
  try %{
    eval -try-client tools %{
      buffer chatgeppeto
    }
  } catch %{
    eval -try-client tools %{
      edit -fifo %opt{geppetochatoutfifo} chatgeppeto
    }
  }
}

define-command gpt -override -params 0.. %{
  start-geppeto

  nop %sh{
    if [ $(($(printf %s "${kak_selection}" | wc -m))) -gt 1 ]; then
      echo "$@ " "$(printf '%s' "${kak_selection}" | tr '\n' ' ')" > $kak_opt_geppetochatinfifo
    else
      echo "$@" > $kak_opt_geppetochatinfifo
    fi
  }

  opengpt
}

define-command geppetoreifywith -override -params 1 %{
  evaluate-commands %sh{
    printf %s "define-command start-geppeto -override -params 0 %{
      eval %sh{
        if [ \"\$kak_opt_geppetostarted\" = false ]; then
          infifo=\$(mktemp -u \"\${kak_opt_geppetotempprefixorsomething}XXXXXXXX\")
          mkfifo \$infifo
          echo \"set-option global geppetochatinfifo \$infifo\"
          outfifo=\$(mktemp -u \"\${kak_opt_geppetotempprefixorsomething}XXXXXXXX\")
          mkfifo \$outfifo
          echo \"set-option global geppetochatoutfifo \$outfifo\"
          (eval OPENAI_API_KEY=$1 \$kak_opt_geppetoprogram \$infifo \$outfifo 2>&1 & ) > /dev/null 2>&1 < /dev/null
          echo \"set-option global geppetostarted true\"
        fi
      }
    }"
  }
}

# define-command start-geppeto -override -params 0..1 %{
#   eval %sh{
#     if [ "$kak_opt_geppetostarted" = false ]; then
#       infifo=$(mktemp -u "${kak_opt_geppetotempprefixorsomething}XXXXXXXX")
#       mkfifo $infifo
#       echo "set-option global geppetochatinfifo $infifo"

#       outfifo=$(mktemp -u "${kak_opt_geppetotempprefixorsomething}XXXXXXXX")
#       mkfifo $outfifo
#       echo "set-option global geppetochatoutfifo $outfifo"

#       ( eval OPENAI_API_KEY=$1 $kak_opt_geppetoprogram $infifo $outfifo 2>&1 & ) > /dev/null 2>&1 < /dev/null
#       echo "set-option global geppetostarted true"
#     fi
#   }
# }
