#!/usr/bin/env bash
#
#   message.sh - colorful colors
#

[[ -n "${LIBWILDWEST_UTIL_MESSAGE_SH}" ]] && return
export LIBWILDWEST_UTIL_MESSAGE_SH=1
: ${LIBWILDWEST?}

if [[ -t 1 ]]; then
  _message_black="$(tput setaf 0)"
  _message_red="$(tput setaf 1)"
  _message_green="$(tput setaf 2)"
  _message_yellow="$(tput setaf 3)"
  _message_blue="$(tput setaf 4)"
  _message_magenta="$(tput setaf 5)"
  _message_cyan="$(tput setaf 6)"
  _message_white="$(tput setaf 7)"

  _message_white_b="$(tput setab 7)"
  _message_cyan_b="$(tput setab 6)"
  _message_gray_b="$(tput setab 240)"

  _message_bold="$(tput bold)"
  _message_underline="$(tput smul)"
  _message_dim="$(tput dim)"

  _message_reset="$(tput sgr0)"
else
  _message_black=""
  _message_red=""
  _message_green=""
  _message_yellow=""
  _message_blue=""
  _message_magenta=""
  _message_cyan=""
  _message_white=""
  _message_bold=""
  _message_underline=""
  _message_dim=""
  _message_reset=""
fi

_message_arrow_b="${message_bold}${_message_blue}==>${_message_reset}"
_message_arrow_g="${message_bold}${_message_green}==>${_message_reset}"

_message_list=(black red green yellow blue magenta cyan white
               white_b cyan_b
               bold underline dim reset arrow_b arrow_gs)

for color in ${_message_list[@]}; do
  declare -r "_message_"${color}
done; unset color

ohai(){
  local title="${_message_bold}${_message_white}${1}"
  local msg="${_message_dim}${_message_bold}${_message_underline}${2}"
  local color
  if [[ -n "${3}" ]]; then
    color="${message_bold}$(tput setaf ${3})==>${_message_reset}"
  else
    color="${_message_arrow_b}"
  fi

  printf -- '%s %s %s\n' "${color}" "${title}" "${_message_reset}"
  if [[ -n "${2}" && "${2}" != '_' ]]; then
    printf -- '    %s %s %s\n' "${msg_fmt}" "${msg}" "${_message_reset}"
  fi
}

oline(){
  local cols="$(tput cols)"
  if [[ -t 1 ]]; then
    local color="${1}"
    [[ -n "${color}" ]] && \
      color="$(tput setab ${color})"; color="${color:-${_message_gray_b}}"
  else
    local color=""
  fi

  printf -- "${color}%${cols}s${_message_reset}\n"
}

ofail(){
  local msg="${_message_bold}${1}"
  local err="${2:-1}"
  local prefix="${_message_bold}${_message_red}|!|${_message_reset}"

  printf -- '%s %s %s\n' "${prefix}" "${msg}" "${_message_reset}"
  exit ${err}
}
