#!/usr/bin/env bash
#
#     hash.sh : hash-ing functions
#

[[ -n "${LIBWILDWEST_UTIL_ERROR_SH}" ]] && return
export LIBWILDWEST_UTIL_ERROR_SH=1
: ${LIBWILDWEST?}
wildwest 'util/util'

declare -rx __hash_algos=({md5,sha{1,224,256,384,512},b2})
declare -r __hash_default_find_args="-L"

# hash_catdir:
# $1: directory to list
hash_catdir() {
  local dir="$1"; shift
  local args=(${@:-"${__hash_default_find_args}"})
  [[ ! -d "${dir}" ]] && {
    error "${FUNCNAME[0]}: ${dir} is not a directory!"
    exit ${E_INVALID_OPTION}
  }

  (
    cd "${dir}"
    find -H "${args[@]}" -type l -printf '%p -> %l\n' -o -printf '%p (%U/%G/%#m)\n' | sort
    find -H "${args[@]}" -type f -print0 | sort -z | xargs -0 cat
  )
}

# hash_catfile:
# $1: file to give information about
hash_catfile(){
  local file="$1"
  [[ ! -f "${file}" ]] && {
    error "${FUNCNAME[0]}: ${file} is not a file!"
    exit ${E_INVALID_OPTION}
  }

  cat "${file}"
}

# hash:
# $1: program to use
# $2: target file/directory
# $3: find args
hash(){
 local cmd="${1:+$1"sum"}"
 local target="${2}"
 local args="${3}"

 in_array "${cmd%%sum}" "${__hash_algos[@]}" || {
   error "${FUNCNAME[0]}: '${1}' is not a vaild hash-program."
   exit ${E_INVALID_OPTION}
 }

 {
    local cmdhash='hash_catfile'
    [[ -d "${target}" ]] && cmdhash="hash_catdir"

    ${cmdhash} "${target}"
 }  | ${cmd} | cut -d ' ' -f 1
}
