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
* [configfile](conf) that do all stuff relating to the functional behaviour

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

Just do

```sh
$ make
$ make install
```

Configuration
=============

Configuration of `shellex` has two parts: The first one are X-resources (which we will try to eliminate in the future):

Resource           | Values         | Default | Description
 ----------------- | -------------- | ------- | ---
URxvt.shellex.pos  | pointer｜focus | focus   | If pointer, shellex shows the window on the window, the mousepointer is on, else it uses the output, where most of the currently focused window is.
URxvt.shellex.edge | bottom｜top    | top     | On what screenedge to show shellex

The other are small shell-script-snippets. When starting, `shellex` will look
into `$HOME/.shellex` and into `/etc/shellex`. It will then source all the
snippets in either location. If there is an identically named file in both
directories, the one in your home will be preferred.

This makes for a pretty flexible configuration process: Usually there will be a
lot of snippets in `/usr/lib/shellex/conf`, which should be self-contained and
without a lot of side-effects. In `/etc/shellex` there then are some symlinks
to those snippets, making up the default-configuration on this system, together
with administrator-provided additional defaults. Whenever you don't want a
snippet form `/etc/shellex` to be used, just create a symlink of the same name
to `/dev/null` in `$HOME/.shellex`. If you want to create your own snippets,
just put them in `$HOME/.shellex` under a name not used yet and it will be
automatically sourced.
