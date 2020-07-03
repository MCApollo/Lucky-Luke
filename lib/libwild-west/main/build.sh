#!/usr/bin/env bash
# cowboybuild - functions related to build-time

[[ -n "${LIBWILDWEST_MAIN_COWBOYBUILD_SH}" ]] && return
export LIBWILDWEST_MAIN_COWBOYBUILD_SH=1
: ${LIBWILDWEST?}

wildwest 'util/util'
wildwest 'util/parseopts'

# globals
declare -ax PKGNAME=('main')
# => are we the -{dev,foo} or the 'main' package?
#   this lets the user set extra data about subpackages.
declare -rx PKGINFO='PKGINFO'
# => change this variable to change what PKGNAME arrays get called as
declare -xa PKGOPTIONS=()
# => array of compile time options

# get_current_package:
# Return the first member in the array
# if $1; then append to PKGNAME, return
current_package() {
  if (( $# )); then
    local append="${1}"
    in_array "${append}" "${PKGNAME[@]}" &&   \
      warning "${FUNCNAME[0]}: ${append} is already in package list ($(caller))"
    export PKGNAME=("${append//\ }" ${PKGNAME[@]})
    return 0
  fi
  # else
  printf -- "${PKGNAME[@]}"
}

# envp:
# Return information about key from PKGNAME
#   $1: PKGNAME
#   $2: variable
envp() {
  local package="${PKGINFO}_${1}"
  local var="$2"
  local value
  if ! declare -p ${package} &>/dev/null; then
    error "${package} doesn't exist? ($(caller))"
    exit ${E_RUNTIME}
  fi
  [[ -z "${var}" ]] && {
    error "${FUNCNAME[0]}: missing second argument"
    exit ${E_INVALID_OPTION}
  }

  declare -n value=${package}["${var}"]
  [[ -z ${value} ]] && debug "${FUNCNAME[0]}: '${var}' is empty."
  printf -- '%s\n' "${value}"
}

# envp_c:
# Wrapper for envp, but supply $(current_package)
envp_c() {
  envp "$(current_package)" "$@"
}

# Register_value:
# Grab the caller's function name, see if they set a value,
# register it to a global array
register_value() {
  local caller="${FUNCNAME[1]}"
  declare -n value=${caller}  # -n == copy ${!caller}
  [[ "${caller}" == "main" ]] &&  \
    error "${FUNCNAME[0]}: Main called? ($(caller))" ${E_INTERNAL}
  [[ -z "${value}" ]] && \
    warning "${FUNCNAME[0]}: WARNING: No value set for '${FUNCNAME[1]}'."

  is_array ${caller} && value="${value[@]}"
  local current="${PKGINFO}_$(current_package)"
  declare -p ${current} &>/dev/null || declare -Axg ${current}
  eval $(printf -- '%q[%q]=%q' "${current}" "${caller}" "${value}")
  debug "$(caller) | ${caller}"
  # debug "=== $(printf -- '%q' "${value}") | $_ | $(declare -p ${current})"
  # => FIXME: Use of eval because declare refuses to continue with -Axg normaly
}

# is_enable:
# check if option is enable
# $1: option
is_enable() {
  local ret=1
  local arg="${1}"

  in_array "${arg}" "${PKGOPTIONS[@]}" && ret=0
  return ${ret}
}

# options:
# Affect how to build the package
options(){
  local ARGV=(${@})
  local OPT_SHORT=() # not used
  local OPT_LONG=('no-extract' 'no-patch' 'no-checksum'
                  'auto-version')
  # => Parseopts
  local argv0="$0"
  BASH_ARGV0="${FUNCNAME[0]^}"
  # => Change ${0} in bash 5 for parseopts to avoid confusing users.
  if ! parseopts "${OPT_SHORT}" "${OPT_LONG[@]}" -- "$@"; then
    error "${FUNCNAME[0]}: unable to parseopts ($(caller))"
    exit ${E_INVALID_OPTION}
  fi
  set -- "${OPTRET[@]}"
  BASH_ARGV0="${argv0}"
  # Require that option is the first thing to be called
  if declare -p "${PKGINFO}_main" &>/dev/null; then
    warning "${FUNCNAME[0]} requires be called first in the ${BUILDSCRIPT:-buildscript} ($(caller))"
  fi
  # And lastly commit the options to the build-runner
  local arg
  while (( $# )); do
    arg="${1##--}"; [[ -z "${arg}" ]] && break
    # => strip --, if blank (EOF); break

    export PKGOPTIONS+=("${arg}")
    shift
  done
}

#
# START
#

name() {
  declare -g name="${1}"; shift
  pkgname ${@:-${name}}

  register_value
}

# 'private'
#   pkgname - what the debian suffix is called.
#   ex. lucky.luke.foobar
pkgname(){
  declare -g pkgname="${@//\ }"

  register_value
}

version() {
  declare -g version="$1"; shift
  (( $# )) && revision "${@//\ }"

  is_enable "auto-version" && {
    local download="${version:-$(envp_c 'download')}"
    declare -g version=$(
      local result
      local regex="([0-9]{1,}\.)+[0-9]{1,}"
      result="$(printf -- "${download##*/}" | grep -Eo ${regex})"
      [[ -z "${result}" ]] && {
        result="$(printf -- "${download}" | grep -Eo ${regex})"
      } # First try the basename of the url, then the full url if empty.

      printf -- '%s' "${result}"
    )
  }

  register_value
}

# 'private'
#   describe patch-level of the current package.
#   XXX: recompiles are handled by the buildsystem,
#     this means that the format of version will be:
#     <source version>+<patch level (revision)>-<compile version/count>
revision() {
  declare -g revision="${@//\ }"

  register_value
}

section() {
  declare -g section="${@}"

  register_value
}

arches() {
  declare -g arches=(${@})

  register_value
}

license() {
  declare -g license=($@)

  register_value
}

maintainers() {
  declare -g maintainers="${1}"

  register_value
}

# Descripton {
# =================

# desc:
# main function that divides the information put in.
# user can also just manually call these functions
# example
# desc "short descrtion" << EOF
#   long description
#   compiled for arm64
# EOF
desc() {
  local short="$1"; shift
  [[ ! -t 0 ]] && { mapfile -t; set -- "$@" "${MAPFILE[@]}"; }
  # => If there's a pipe, send it to argv
  short_description ${short}
  (( ! $# )) && return
  # long_description $@
  long_description << EOF
  $( while (( $# )); do
      printf -- '%s\n' "${1}"; shift
    done
   )
EOF
# FIXME: Find another way to keep the data __as is__

}

short_description() {
  declare -g short_description="$@"

  register_value
}

long_description() {
  [[ ! -t 0 ]] && { mapfile -t; set -- "$@" "${MAPFILE[@]}"; }
  local line
  declare -gxt long_description=()

  while (( $# )); do
    line="${1}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    (( $# > 1 )) && line=${line}\ $'\n'
    # => strip whitespace, append newline if another line.

    long_description+=("${line}")
    shift
  done

  register_value
}

# =================
# }

homepage() {
  declare -g homepage="${1//\ }"

  register_value
}

build_depends() {
  declare -g build_depends=($@)

  register_value
}

depends() {
  declare -g depends=($@)

  register_value
}

icon() {
  declare -g icon=($@)

  register_value
}

# Download

download(){
  declare -g download=($@)

  register_value
}
