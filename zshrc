PROMPT="shellex> "

function accept-line () {
    BUFFER="$BUFFER > /dev/null 2>&1 &; disown; exit"
    zle .accept-line
}
zle -N accept-line
unset ZDOTDIR
