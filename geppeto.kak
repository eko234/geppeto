declare-option str geppetochatinfifo
declare-option str geppetochatoutfifo
declare-option str geppetolockfile "/tmp/kakgeppeto.lock"
declare-option bool geppetoownslock

define-command opengpt %{
  eval -try-client tools %{
    edit -fifo %opt{geppetochatoutfifo} chat
  }
}

define-command gpt -override -params 0.. %{
  evaluate-commands %sh{
    if [ $(($(printf %s "${kak_selection}" | wc -m))) -gt 1 ]; then
      echo "$@ " "$(printf '%s' "${kak_selection}" | tr '\n' ' ')" > $kak_opt_geppetochatinfifo
    else
      echo "$@" > $kak_opt_geppetochatinfifo
    fi
  }
  eval -try-client tools %{
    buffer chat
  }
}

define-command start-geppeto %{
  nop %sh{
    if [ ! -p "$kak_opt_geppetochatinfifo" ]; then
        mkfifo "$kak_opt_geppetochatinfifo"
    fi

    if [ ! -p "$kak_opt_geppetochatoutfifo" ]; then
        mkfifo "$kak_opt_geppetochatoutfifo"
    fi

    if [ -f "$kak_opt_geppetolockfile" ]; then
        echo "The program is already running."
        exit 1
    else
        # Create kak_opt_geppetolockfile
        touch "$kak_opt_geppetolockfile"
        OPENAI_API_KEY=<YOUR API KEY> geppeto $kak_opt_geppetochatinfifo $kak_opt_geppetochatoutfifo &
        rm "$kak_opt_geppetolockfile"
    fi
  }
}


# This will kill all instances of geppeto in your machine, if you are using it outside of kakoune
# this might not always be a good idea, I haven't found a better way to handle this
define-command kill-geppeto-smh %{
    nop %sh{
      pgrep geppeto | xargs kill -9
    }
}
