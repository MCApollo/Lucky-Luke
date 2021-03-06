#!/usr/bin/env bash
#
#    safety.sh : fail intolerant functions
#

[[ -n "${LIBWILDWEST_UTIL_SAFETY_SH}" ]] && return
export LIBWILDWEST_UTIL_SAFETY_SH=1
: ${LIBWILDWEST?}

wildwest "util/error"
wildwest "util/message"

cd_safe(){
  local dir="$@"
  if [[ -z "${dir}" ]]; then
    error "(safe_cd): Caller didn't supply argument ($(caller))" \
      "${E_SAFE}"
  fi

  if ! cd "${dir}"; then
    error "(safe_cd): Failed 'cd ${dir}' ($(caller))"  \
      "${E_SAFE}"
  fi
}

source_safe(){
  local shellopts="$(shopt -p extglob)"
  shopt -u extglob

  if ! source "$@"; then
    ofail "(safe_source): Failed 'source $@' ($(caller))" \
      "${E_MISSING_FILE}"
  fi

  eval "${shellopts}"
}
