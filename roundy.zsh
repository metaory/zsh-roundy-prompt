# roundy.zsh - minimal path-aware zsh prompt
# version: 1.0.0

# Core state
RR_TEXC=0
RR_STATUS=0
RR_TIME=""
RR_GIT=""
RR_DIR=""

# Default theme
typeset -gA RT=(
  bg_ok 4    fg_ok 6    icon_ok •
  bg_err 1   fg_err 0   icon_err ×
  bg_dir 7   fg_dir 13  icon_time ⟳
  bg_usr 4   fg_usr 13
  bg_git 13  fg_git 7
  bg_time 3  fg_time 7
)

# Options
: ${R_MODE:=dir-only}  # full, short, dir-only
: ${R_CODE:=0}         # show exit code in right prompt
: ${R_MIN:=4}          # show time for commands longer than 4s
: ${R_USR:=%n}         # username format

# Powerline chars
R_LEFT=$'\ue0b6' R_RIGHT=$'\ue0b4'

# Helpers
seg() { echo "%F{$1}%K{${2:-default}}$R_RIGHT${3:-}" }
seg_s() { echo " %k%F{$1}$R_LEFT%K{$1}%F{$2}${3:-}" }
seg_e() { echo "%F{$1}%k$R_RIGHT%f" }
status_color() { echo "%(?.${1}.%130(?.${1}.${2}))" }

get_time() {
  (( R_MIN && RR_TEXC )) || return
  local d=$(( EPOCHSECONDS - RR_TEXC ))
  (( d < R_MIN )) && return
  local t
  (( d >= 86400 )) && t+="$((d/86400))d " && d=$((d%86400))
  (( d >= 3600 )) && t+="$((d/3600))h " && d=$((d%3600))
  (( d >= 60 )) && t+="$((d/60))m " && d=$((d%60))
  t+="${d}s"
  RR_TEXC=0  # Reset execution time after showing
  echo "${RT[icon_time]} $t"
}

get_dir() {
  case "$R_MODE" in
    full)  echo ' %~';;
    short) echo ' %2~' | sed 's:\([^/]\)[^/]*/:\1/:g';;
    *)     echo ' %1~';;
  esac
}

get_git() {
  local branch
  branch=${$(git symbolic-ref HEAD 2>/dev/null)#refs/heads/}
  [[ -n $branch ]] && echo " $branch"
}

# Right prompt segments
r_usr() {
  local s="$(seg_s ${RT[bg_usr]} ${RT[fg_usr]} $R_USR)"
  [[ -z $RR_GIT ]] && s+="$(seg_e ${RT[bg_usr]})"
  echo $s
}

r_git() {
  [[ -z $RR_GIT ]] && return
  echo "$(seg ${RT[bg_usr]} ${RT[bg_git]} "%F{${RT[fg_git]}}$RR_GIT")$(seg_e ${RT[bg_git]})"
}

r_err() {
  (( R_CODE && RR_STATUS != 0 && RR_STATUS != 130 )) || return
  local bg=${RR_GIT:+${RT[bg_git]}}
  bg=${bg:-${RT[bg_usr]}}
  echo " %F{${RT[bg_err]}}%k$R_LEFT%K{${RT[bg_err]}}%F{${RT[fg_err]}}%?%k%F{${RT[bg_err]}}$R_RIGHT"
}

# Left prompt segments
l_status() {
  local bg=$(status_color ${RT[bg_ok]} ${RT[bg_err]})
  local fg=$(status_color ${RT[fg_ok]} ${RT[fg_err]})
  local icon=$(status_color ${RT[icon_ok]} ${RT[icon_err]})
  seg_s "$bg" "$fg" "$icon"
}

l_time() {
  local bg=$(status_color ${RT[bg_ok]} ${RT[bg_err]})
  [[ -z $RR_TIME ]] && echo "$(seg "$bg" ${RT[bg_dir]})" && return
  echo "$(seg "$bg" ${RT[bg_time]} "%F{${RT[fg_time]}}$RR_TIME")$(seg ${RT[bg_time]} ${RT[bg_dir]})"
}

l_dir() {
  echo "%F{${RT[fg_dir]}}$RR_DIR$(seg_e ${RT[bg_dir]}) "
}

# Hooks and setup
preexec() {
  # Reset previous time state
  RR_TIME=""
  RR_TEXC=$EPOCHSECONDS
  # Set terminal title
  print -Pn "\e]0;${1}\a"
}

precmd() {
  RR_STATUS=$?
  RR_TIME=$(get_time)
  RR_GIT=$(get_git)
  RR_DIR=$(get_dir)
  PROMPT="$(l_status)$(l_time)$(l_dir)"
  RPROMPT="$(r_usr)$(r_git)$(r_err)%f"
  # Reset terminal title
  print -Pn "\e]0;%~\a"
}

# Plugin unload
roundy_unload() {
  add-zsh-hook -D preexec preexec
  add-zsh-hook -D precmd precmd
  unset -m 'RR_*' 'RT' 'R_*'
  unfunction -m 'roundy_*' 'seg*' 'status_color' 'get_*' '[lr]_*'
}

# Main
main() {
  emulate -L zsh
  setopt prompt_subst no_prompt_bang prompt_percent
  autoload -Uz add-zsh-hook
  (( $+EPOCHSECONDS )) || zmodload zsh/datetime
  PROMPT_EOL_MARK=$'\n%{\r%}'
  add-zsh-hook preexec preexec
  add-zsh-hook precmd precmd
}

main "$@"

