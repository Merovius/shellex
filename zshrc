zmodload zsh/regex

PROMPT="shellex> "

function accept-line () {
    if [ "$BUFFER" -regex-match '^\s*$' ]
    then
        exit
    fi

    BUFFER="$BUFFER > /dev/null 2>&1 &; disown; exit"
    zle .accept-line
}
zle -N accept-line
unset ZDOTDIR
