Changelog
=========

0.3 - 2018-12-10
----------------
• Miscellaneous maintenance changes
• Updated empty-line treatment
• Changed xrandr parseing
• Cleanup of unused perl modules
• Bugfix: allow symlinks in user .shellex directories
• Use configuration from `$XDG_CONFIG_HOME`
• Enable compinit by default, add ctrl-x r for recent file completion

The slight change in the default completion behaviour is very likely desirable.
In the unlikely chance that a user does not appreciate the change, refer to the
README about how to disable the snippet `20-completion`.

0.2 - 2016-12-27
----------------
• Added optional sudo configuration
• Bugfix: flashing window with large completion lists
• Moved config handling from perl to shell
• Disable beeping
• Improved history file handling
• Avoid using temporary files for configuration parsing
• Avoid using temporary files for command execution

0.1 - 2013-09-03
----------------
• History support (default)
• Pass command-line to urxvt (support colors)
• Bugfix: Correct pointer-based positioning
• Bugfix: Correct focus-based positioning
• Bugfix: Correctly predict terminal size, when adding strings


0.0 - 2013-08-31
----------------
• Initial release
