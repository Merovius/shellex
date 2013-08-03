shellex - Shell-based launcher
==============================

`shellex` is supposed to be a dmenu-style launcher with a lot more features and
a lot simpler design.  It launches a shell (currently `zsh`) and shows it in a
small terminal, wrapping every command with a little bit of extra magic
(redirecting stdout, stderr, disowning and closing the shell) to get more
typical launcher-behaviour.

This gives you a simple launcher with tab-completion and other shell-features,
configurable in shell.

I tried to do this a few years back, then using C and implementing the
terminal-operations myself. This turned out to be a very bad idea, it made the
design overly complex and the state I left it in had regular segfaults and was far
from working. After not much seem to happen in that direction, I decided to
start again, this time using `urxvt` to do the terminal-part, which turned out to
be really easy.

So, this is the early prototype. It is usable and should already work and be
usefull, but much is not working yet. I hope this time I will continue the work
for longer ;)


Architecture
============

`shellex` has three parts:

* [A small shell-script](shellex) that just starts a `urxvt` with some extra
  parameters
* [An urxvt-extension](urxvt_shellex.pl) that manages the terminal/displaying
  part.
* [A zsh-config](zshrc) that does all stuff relating to the functional
  behaviour.


(Planned) Features
==================

Working:
* Launching Applications (yay)
* Commandline parameters
* Basic Tab-completion
* Starting on the right output (configurable, either the output containing the
  currently focused window or the output containing the mousepointer)
* Dynamic resizing of the launcher-window e.g. for multiple lines of
  suggestions for tab-completions (see [doc/autoresize.txt](doc/autoresize.txt))

Planned, but not Implemented yet:
* Buffering/showing some output, for errors etc. We have to think about some
  magic way to determine, wether output is helpfull or the launcher should be
  hidden immediately
* dmenu-like completion, typing part of a command still completing (maybe zsh
  has sometething to do that?)
* .desktop-file integration
* Your ticket here


Installation
============

If you want to try it, you should do the following:
* Change the path in [the shell-script](shellex)
* `cd /path/to/shellex/preload; make`
* `mkdir ~/.urxvt; ln /path/to/shellex/urxvt_shellex.pl ~/.urxvt/shellex`
* `echo "URxvt.perl-lib: $HOME/.urxvt" >> ~/.Xresources`
* `xrdb -merge ~/.Xresources`

or something equivalent.


Configuration
=============

There are two locations for `shellex` configuration: The first one is the
shell-script (following the tradition of window managers like awesome or dwm of
calling the sourcecode "configfile") for the functional part, the other one are
X-resources.

The only X-resource yet defined is `URxvt.shellex.pos`, determining what
criterion `shellex` uses, to position its window. If it is set to `pointer`,
`shellex` will use the output the mouse-pointer is currently on, if it is set
to `focus`, it will take the output that contains most of the currently focused
window (the default).
