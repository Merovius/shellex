zmodload zsh/regex

PROMPT="shellex> "

function accept-line () {
    if [ "$BUFFER" -regex-match '^\s*$' ]
    then
        exit
    fi

    file=`tempfile`
    cat > $file <<SHELLEX_EOF
rm $file
$BUFFER
SHELLEX_EOF
    BUFFER="zsh $file > /dev/null 2>&1 & disown; exit"
    zle .accept-line
}
zle -N accept-line
unset ZDOTDIR

# ^C should per default exit
trap exit SIGINT

# So should escape (TODO: there has to be an easier way then this…)
function __shellex_exit {
    exit
}
zle -N _shellex_exit __shellex_exit
bindkey '^[' _shellex_exit
