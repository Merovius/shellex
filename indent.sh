#!/bin/sh

# vim:ft=zsh
# Helper script for CI to auto indent files
# © 2017 Paul Seyfert and contributors (see also: LICENSE)

if [ -f "$1" ]; then
  vim -f +"set softtabstop=2" +"set tabstop=2" +"set shiftwidth=2" +"set expandtab" +"gg=G" +":x" $1
else
  echo "USAGE: $0 <filename>"
  echo "to autoindent file with vim"
fi
exit $?
