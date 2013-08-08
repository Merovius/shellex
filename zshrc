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
