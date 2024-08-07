#
# Standarized $0 handling
# https://github.com/zdharma/Zsh-100-Commits-Club/blob/master/Zsh-Plugin-Standard.adoc
#
0=${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}
0=${${(M)0:#/*}:-$PWD/$0}
typeset -gA Roundy
Roundy[root]=${0:A:h}

#
# Options
#

# Color definition for Command's Exit Status
: ${ROUNDY_COLORS_BG_EXITSTATUS_OK:=4}
: ${ROUNDY_COLORS_FG_EXITSTATUS_OK:=0}
: ${ROUNDY_COLORS_BG_EXITSTATUS_NO:=1}
: ${ROUNDY_COLORS_FG_EXITSTATUS_NO:=0}
# Icon definition for Command's Exit Status
: ${ROUNDY_EXITSTATUS_OK:=$'\uf058 '}
: ${ROUNDY_EXITSTATUS_NO:=$'\uf057 '}

# Options and Color definition for Time Execution Command
: ${ROUNDY_COLORS_BG_TEXC:=3}
: ${ROUNDY_COLORS_FG_TEXC:=0}
# Minimal time (in ms) for the Time Execution of Command is displayed in prompt
: ${ROUNDY_TEXC_MIN_S:=4}
: ${ROUNDY_TEXC_ICON:="▲"}

# Color definition for Active user name
: ${ROUNDY_COLORS_BG_USR:=5}
: ${ROUNDY_COLORS_FG_USR:=255}
# Options to override username info
: ${ROUNDY_USR_CONTENT_NORMAL:=" %n "}
: ${ROUNDY_USR_CONTENT_ROOT:=" %n "}
# Color definition for Active directory name
: ${ROUNDY_COLORS_FG_DIR:=255}
: ${ROUNDY_COLORS_BG_DIR:=4}
# Working Directory Info Mode
# Valid choice are : "full", "short", or "dir-only"
: ${ROUNDY_DIR_MODE:="dir-only"}

# Color definition for Git info
: ${ROUNDY_COLORS_BG_GITINFO:=7}
: ${ROUNDY_COLORS_FG_GITINFO:=0}

# Option whether drawing a gap between a prompt
: ${ROUNDY_PROMPT_HAS_GAP:=true}

#
# Get information from active git repo
#
roundy_get_gitinfo() {
  type git &>/dev/null || return

  cd -q "$1"
  local ref=$(git symbolic-ref --quiet HEAD 2>/dev/null) ret=$?

  case $ret in
    128) return ;;  # not a git repo
    0) ;;
    *) ref=$(git rev-parse --short HEAD 2>/dev/null) || return ;; # HEAD is in detached state ?
  esac

  if [[ -n $ref ]]; then
    printf -- '%s' " ${ref#refs/heads/} "
  fi
}

#
# Manage time of command execution
#
roundy_get_texc() {
  (( ROUNDY_TEXC_MIN_S )) && (( ${Roundy[raw_texc]} )) || return
  local duration=$(( EPOCHSECONDS - ${Roundy[raw_texc]} ))
  if (( duration >= ROUNDY_TEXC_MIN_S )); then
    # Time converter from pure
    # https://github.com/sindresorhus/pure/blob/c031f6574af3f8afb43920e32ce02ee6d46ab0e9/pure.zsh#L31-L39
    local moment d h m s

    d=$(( duration / 60 / 60 / 24 ))
    h=$(( duration / 60 / 60 % 24 ))
    m=$(( duration / 60 % 60 ))
    s=$(( duration % 60 ))
    (( d )) && moment+="${d}d"
    (( h )) && moment+="${h}h"
    (( m )) && moment+="${m}m"
    moment+="${s}s"

    printf -- '%s' " ${ROUNDY_TEXC_ICON} ${moment} "
  fi
}

#
# Working Directory Info
#
roundy_get_dir() {
  local dir

  case "$ROUNDY_DIR_MODE" in
    full)
      dir='%~'
      ;;
    short)
      if type sed &>/dev/null; then
        dir=$(print -P '%~' | sed "s#\([^a-z]*[a-z]\)[^/]*/#\1/#g")
      else
        # fallback to full mode when there's no sed
        #
        dir='%~'
      fi
      ;;
    dir-only|*)
      dir='%1~'
      ;;
  esac

  printf -- '%s' " $dir "
}

#
# THE PROMPT
#

roundy_prompt_left() {
  local p
  local char_open=$'\ue0b6'
  local char_close=$'\ue0b4'
  local exit_color_bg="%(?|${ROUNDY_COLORS_BG_EXITSTATUS_OK}|${ROUNDY_COLORS_BG_EXITSTATUS_NO})"
  local exit_color_fg="%(?|${ROUNDY_COLORS_FG_EXITSTATUS_OK}|${ROUNDY_COLORS_FG_EXITSTATUS_NO})"

  p+="%F{${exit_color_bg}} "
  p+="${char_open}"
  p+="%K{${exit_color_bg}}"
  p+="%F{${exit_color_fg}}"
  p+="%{%(?|${ROUNDY_EXITSTATUS_OK}|${ROUNDY_EXITSTATUS_NO})%2G%}"
  if [ -n "${Roundy[data_texc]}" ]; then
    p+="%K{${ROUNDY_COLORS_BG_TEXC}}"
  else
    p+="%K{${ROUNDY_COLORS_BG_DIR}}"
  fi
  p+="%F{${exit_color_bg}}"
  p+="${char_close}"

  if [ -n "${Roundy[data_texc]}" ]; then
    p+="%K{${ROUNDY_COLORS_BG_TEXC}}"
    p+="%F{${ROUNDY_COLORS_FG_TEXC}}"
    p+="${Roundy[data_texc]}"
    p+="%K{${ROUNDY_COLORS_BG_DIR}}"
    p+="%F{${ROUNDY_COLORS_BG_TEXC}}"
    p+="${char_close}"
  fi

  p+="%K{${ROUNDY_COLORS_BG_DIR}}"
  p+="%F{${ROUNDY_COLORS_FG_DIR}}"
  p+="${Roundy[data_dir]}"
  p+="%k"
  p+="%F{${ROUNDY_COLORS_BG_DIR}}"
  p+="${char_close}"
  p+="%f "

  Roundy[lprompt]=$p
  typeset -g PROMPT=${Roundy[lprompt]}
}

roundy_prompt_right() {
  local p cl_close
  local char_open=$'\ue0b6'
  local char_close=$'\ue0b4'

  local exit_color_bg="%(?|${ROUNDY_COLORS_BG_USR}|${ROUNDY_COLORS_BG_EXITSTATUS_NO})"
  local exit_color_fg="%(?|${ROUNDY_COLORS_FG_USR}|${ROUNDY_COLORS_FG_EXITSTATUS_NO})"

  p+="%F{${exit_color_bg}}"
  p+="${char_open}"

  p+="%K{${exit_color_bg}}"
  p+="%F{${exit_color_fg}}"
  p+="%(#.${ROUNDY_USR_CONTENT_ROOT}.${ROUNDY_USR_CONTENT_NORMAL})"
  p+="%(?..:%?)"
  cl_close=${exit_color_bg}

  if [[ -n "${Roundy[data_gitinfo]}" ]]; then
    p+="%K{${exit_color_bg}}"
    p+="%F{${ROUNDY_COLORS_BG_GITINFO}} "
    p+="${char_open}"
    p+="%K{${ROUNDY_COLORS_BG_GITINFO}}"
    p+="%F{${ROUNDY_COLORS_FG_GITINFO}}"
    p+="${Roundy[data_gitinfo]}"
    cl_close=${ROUNDY_COLORS_BG_GITINFO}
  fi

  p+="%k"
  p+="%F{${cl_close}}"
  p+="${char_close}"
  p+="%f"

  Roundy[rprompt]=$p
  typeset -g RPROMPT=${Roundy[rprompt]}
}

roundy_draw_prompts() {
  Roundy[data_dir]=$(roundy_get_dir)

  roundy_prompt_left
  roundy_prompt_right
}

roundy_draw_gap() {
  [[ -n ${Roundy[draw_gap]} ]] && print
  [[ $ROUNDY_PROMPT_HAS_GAP == true ]] && Roundy[draw_gap]=1
}


# Callback functions for async worker
roundy_async_callback() {
  # Set output ($3) callback based on method name ($1)
  Roundy[data_${1/roundy_get_/}]=$3

  we needs to redraw the whole prompts :(
  roundy_draw_prompts
  zle && zle reset-prompt
}

roundy_preexec() {
  # disable gap when clearing term
  [[ "$1" == (clear|reset) ]] && Roundy[draw_gap]=

  # Record Time of execution for roundy_get_texc
  Roundy[raw_texc]=$EPOCHSECONDS
}

roundy_precmd() {
  Roundy[data_texc]=$(roundy_get_texc)
  Roundy[data_gitinfo]=$(roundy_get_gitinfo "$PWD")

  roundy_draw_gap
  roundy_draw_prompts

  # Force-reset raw time execution command
  Roundy[raw_texc]=0
}

#
# Main Setup
#
roundy_main() {
  # Save stuff that will be overrided by the theme
  Roundy[saved_lprompt]=$PROMPT
  Roundy[saved_rprompt]=$RPROMPT
  Roundy[saved_promptsubst]=${options[promptsubst]}
  Roundy[saved_promptbang]=${options[promptbang]}

  # Enable required options and fpath's functions
  setopt prompt_subst
  autoload -Uz add-zsh-hook

  # Needed for showing command time execution
  (( $+EPOCHSECONDS )) || zmodload zsh/datetime

  # Setup hooks
  add-zsh-hook preexec roundy_preexec
  add-zsh-hook precmd roundy_precmd
}

#
# Unload function
# https://github.com/zdharma/Zsh-100-Commits-Club/blob/master/Zsh-Plugin-Standard.adoc#unload-fun
#
roundy_plugin_unload() {
  [[ ${Roundy[saved_promptsubst]} == 'off' ]] && unsetopt prompt_subst
  [[ ${Roundy[saved_promptbang]} == 'on' ]] && setopt prompt_bang

  PROMPT=${Roundy[saved_lprompt]}
  RPROMPT=${Roundy[saved_rprompt]}

  add-zsh-hook -D preexec roundy_preexec
  add-zsh-hook -D precmd roundy_precmd

  unfunction \
    roundy_async_callback \
    roundy_draw_gap \
    roundy_draw_prompts \
    roundy_prompt_left \
    roundy_prompt_right \
    roundy_get_dir \
    roundy_get_gitinfo \
    roundy_get_texc \
    roundy_precmd \
    roundy_preexec \
    roundy_main

    # roundy_get_txec \

  unset \
    ROUNDY_COLORS_BG_DIR \
    ROUNDY_COLORS_FG_DIR \
    ROUNDY_COLORS_BG_GITINFO \
    ROUNDY_COLORS_FG_GITINFO \
    ROUNDY_COLORS_BG_TEXC \
    ROUNDY_COLORS_FG_TEXC \
    ROUNDY_COLORS_BG_USR \
    ROUNDY_COLORS_FG_USR \
    ROUNDY_EXITSTATUS_OK \
    ROUNDY_EXITSTATUS_NO \
    ROUNDY_COLORS_BG_EXITSTATUS_OK \
    ROUNDY_COLORS_FG_EXITSTATUS_OK \
    ROUNDY_COLORS_BG_EXITSTATUS_NO \
    ROUNDY_COLORS_FG_EXITSTATUS_NO \
    ROUNDY_EXITSTATUS_ICONFIX \
    ROUNDY_PROMPT_HAS_GAP \
    ROUNDY_TEXC_MIN_S \
    ROUNDY_USR_CONTENT_NORMAL \
    ROUNDY_USR_CONTENT_ROOT \
    Roundy

  unfunction $0
}

roundy_main "$@"

