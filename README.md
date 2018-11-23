shellex - Shell-based launcher
==============================

`shellex` is supposed to be a dmenu-style launcher with a lot more features and
a lot simpler design.  It launches a shell (currently `zsh`) and shows it in a
small terminal, wrapping every command with a little bit of extra magic
(redirecting stdout, stderr, disowning and closing the shell) to get more
typical launcher-behaviour.

This gives you a simple launcher with tab-completion and other shell-features,
configurable in shell.

See this video for a short demonstration and comparison to another app starter:
![demo](http://virgilio.mib.infn.it/~seyfert/images/shellexdemo.gif)

I tried to do this a few years back, then using C and implementing the
terminal-operations myself. This turned out to be a very bad idea, it made the
design overly complex and the state I left it in had regular segfaults and was far
from working. After not much seem to happen in that direction, I decided to
start again, this time using `urxvt` to do the terminal-part, which turned out to
be really easy.

While this had the label “early prototype”, it has worked in daily use quite
reasonably. A few possible improvements were never apparently important enough
to invest serious amounts of time and work into them. Still, contributions are
welcome.

Architecture
============

`shellex` has three parts:

* [A small shell-script](shellex.in) that just starts a `urxvt` with some extra
  parameters
* [An urxvt-extension](urxvt/shellex.in) that manages the terminal/displaying
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

Planned, but not implemented:
* Buffering/showing some output, for errors etc. We have to think about some
  magic way to determine, whether output is helpful or the launcher should be
  hidden immediately
* dmenu-like completion, typing part of a command still completing (maybe zsh
  has something to do that? possibly [fzf](https://github.com/junegunn/fzf))
* [.desktop-file integration](https://github.com/pseyfert/shellex-desktop)
* Your ticket here


Installation
============

There are packages in

* [debian](http://packages.debian.org/search?keywords=shellex&searchon=names&suite=all&section=all&sourceid=mozilla-search)
* Arch Linux: [Arch User Repository](https://aur.archlinux.org/packages/?SeB=n&K=shellex) ([latest Release](https://aur.archlinux.org/packages/shellex/) and [git-Repository](https://aur.archlinux.org/packages/shellex-git/))
* Gentoo: there is an [Overlay](https://github.com/proxypoke/gentoo-overlay) which contains shellex

If you are on one of these distributions, we encourage you to install `shellex`
via your package manager.

Else, or if you want to help developing, just do

```sh
$ git clone git://github.com/Merovius/shellex.git
$ cd shellex
$ make
$ make install
```

for installing in `$(HOME)/.local`

```sh
$ git clone git://github.com/Merovius/shellex.git
$ cd shellex
$ PREFIX=$HOME/.local make
$ PREFIX=$HOME/.local make install
```

Usage
=====

After installing `shellex` you probably want to bind it to a shortcut - most
likely Alt+F2. How to do this depends on your desktop environment and/or window
manager.

## xbindkeys

If you're running [xbindkeys](http://www.nongnu.org/xbindkeys/xbindkeys.html),
the entry for your `~/.xbindkeysrc` file might look like:

```
"shellex"
    alt + c:68
```

## i3

[i3](i3wm.org) shortcuts can be modified as described in the
[official documentation](https://i3wm.org/docs/userguide.html).

```
bindsym Mod1+F2 exec shellex
```

Contributing
============

`shellex` is a very young project, it would highly profit from your help. The
following is a not comprehensive list of highly appreciated ways to contribute:

1. Test it and make [tickets](https://github.com/Merovius/shellex/issues) for
   *any* problems you stumble upon or ideas you have to make it better.
2. Have a look at a [list of issues](https://github.com/Merovius/shellex/issues)
   and find one to fix. But please announce your intention to fix it, so that
   we can be sure that it will be merged and there is no duplication of effort.
3. Have a look at the [list of packaged dirstributions](https://github.com/Merovius/shellex#installation).
   If your favourite distribution is not on it, please package it. Please
   announce your intent to do so (in a ticket) and treat it as at least a
   mid-term commitment to maintain the package.
4. Customize `shellex` in self-contained, side-effect free config-snippets and
   add them - if you consider them useful to more then just yourself - in a
   pull-request to the conf-dir.
5. Contribute comments and documentation. Consider translating the manpage.
   Again, please announce your intention and again, if you translate to a
   language, that none of the core-developers speak (currently everything but
   English and German) please consider it to be at least a mid-term commitment
   to maintain the translation.


Customizations
==============

Users are invited to publish their customizations. Either as a contribution
(see above) if these are changes that are a sensible default for all users, or
in their own small packages which contain only the customizations. Especially,
when the customization will be useful for many, but not all users.

Existing customization projects are:

* [pseyfert's customizations](https://github.com/pseyfert/shellex-customizations)
* Your project here

Configuration
=============

Configuration of `shellex` has two parts: The first one are X-resources.
Additionally to the urxvt-class, instances run by shellex will also look for
the shellex-class. This makes it possible to customize the appearance of
shellex without interfering with your usual terminals.

There are also two additional resources defined by shellex:


Resource     | Values         | Default | Description
 ----------- | -------------- | ------- | ---
shellex.pos  | pointer｜focus | focus   | If pointer, shellex shows the window on the window, the mousepointer is on, else it uses the output, where most of the currently focused window is (falling back to the pointer-method, if the root-window is focused).
shellex.edge | bottom｜top    | top     | On what screenedge to show shellex

On start, `shellex` assembles a list of snippet basenames by looking at all of
the paths listed below. For each snippet basename, `shellex` loads the first
file it finds when looking through the paths in order:

1. `$XDG_CONFIG_HOME/.shellex`. Typically unset, defaulting to `$HOME/.config/shellex`.
2. `$HOME/.shellex`
3. `/etc/shellex` (shellex defaults, symlinks to `/usr/shellex/conf/`)

To customize shellex, you can do the following things in
`$XDG_CONFIG_HOME/.shellex` or `$HOME/.shellex/`:

1. Overwrite a default by creating a new snippet of the same name
2. Not include a default by creating a symlink to `/dev/null` of the same same
3. Include an example-snippet not used by default, by creating a symlink to `/usr/shellex/snippet`
4. Write you own snippets with a currently unused name

To avoid naming-conflicts in the future, you should add a common suffix to all
your own snippets. Snippets are run in ascending order. By choosing a number
which sorts between/after the existing snippet(s) you can ensure it runs at the
desired time. E.g. if your snippet beeps on errors, name it 15-errorbeep so that
it sorts before 20-nobeep.

Command-line
============

All command-line parameters given to `shellex` are passed directly to `urxvt`,
so if you want to change colors or font, you can do it through the appropriate
`urxvt`-parameters (or by using resources, for persistent configuration). For
example, to get a dark grey background with a slightly yellow font you might
start shellex with

```sh
$ shellex -bg grey15 -fg linen
```
