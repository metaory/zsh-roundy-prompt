<div align=center>
    <img alt="logo-of-roundy-theme" src="roundy.png" width="30%"><br><br>
    fast, cute, and-of-course, <i>roundy</i> prompt theme for zsh
</div>

# Preview

![preview-of-roundy-theme](preview.png)

> Using [tokyonight](https://github.com/folke/tokyonight.nvim) and [VictorMono](https://github.com/rubjo/victor-mono)

# Required

- [Nerd-patched](https://github.com/ryanoasis/nerd-fonts)'s Fonts
- Terminal with unicode support.

To check whether your terminal ready to using this theme, use this command :

```sh
echo -e '\ue0b6\ue0b4'
```

if it returns a circle, then we can go to the next step 🥳

# Installation

- zinit

```zsh
zinit light metaory/zsh-roundy-prompt
```

- antigen

```zsh
antigen bundle metaory/zsh-roundy-prompt
```

- zplug

```zsh
zplug metaory/zsh-roundy-prompt, use:roundy.zsh, from:github, as:theme
```

# Options

Options in roundy are configured in a regular variable, you can override it on your `.zshrc`.
Here's Default Options that currently available to override:

```sh
# Icon definition for Command's Exit Status
# Note: If your custom symbol overlaps the background or didn't have enough width,
#       you can add space at the end of your defined symbol.
ROUNDY_EXITSTATUS_OK="●"
# You can also using hex code like this
ROUNDY_EXITSTATUS_NO="✖"

# Icon definition for Time Execution
ROUNDY_TEXC_ICON="▲"
# ROUNDY_TEXC_ICON="ﮫ"

# Minimal time (in ms) for the Time Execution of Command is displayed in prompt
# Set to 0 to disable it
ROUNDY_TEXC_MIN_MS=5

# Overriding username info
ROUNDY_USER_CONTENT_NORMAL=" %n "
ROUNDY_USER_CONTENT_ROOT=" %n "

# Working Directory Info Mode
# Valid choice are : "full", "short", or "dir-only"
# Example Output
#   full     : /etc/httpd/conf/extra
#   short    : /e/h/c/extra
#   dir-only : extra
ROUNDY_DIR_MODE="dir-only"

# Whether drawing a gap between a prompt
ROUNDY_PROMPT_HAS_GAP=true
```

## Colors

By nature of Zsh, colors can be specified using :

- a decimal integer (0-15, or 0-255 if `$TERM` supported)
- alias of the eight colors provided by zsh
- or, as a regular #FFFFFF color hex (if `$TERM` supported, or with the help of `zsh/nearcolor` module)

```sh
# Command Exit Status
ROUNDY_COLORS_BG_EXITSTATUS_OK=4
ROUNDY_COLORS_FG_EXITSTATUS_OK=0

ROUNDY_COLORS_BG_EXITSTATUS_NO=1
ROUNDY_COLORS_FG_EXITSTATUS_NO=0

# Time Execution of Command
ROUNDY_COLORS_BG_TEXC=2
ROUNDY_COLORS_FG_TEXC=0

# User Display
ROUNDY_COLORS_BG_USER=8
ROUNDY_COLORS_FG_USER=255

# Directory Info
ROUNDY_COLORS_BG_DIR=8
ROUNDY_COLORS_FG_DIR=255

# Git Info
ROUNDY_COLORS_BG_GITINFO=5
ROUNDY_COLORS_FG_GITINFO=0
```

# Acknowledgement

- Forked from [nullxception/roundy](https://github.com/nullxception/roundy)
- Inspired by [Harry Elric](https://github.com/owl4ce)'s [Joyful Desktop v3](https://github.com/owl4ce/dotfiles/tree/3.0) prompt
- [ryanoasis](https://github.com/ryanoasis)'s [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) for half-circle and most of the awesome additional glyphs on Nerd Fonts

# License

Copyright © 2023 [metaory](https://github.com/metaory)
