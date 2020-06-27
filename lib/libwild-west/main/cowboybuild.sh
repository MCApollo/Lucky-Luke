#!/usr/bin/env bash

wildwest 'util/util'

# globals
declare -ax PKGNAME=('main')
# => are we the -{dev,foo} or the 'main' package?

# get_current_package:
# Return the first member in the array
# if $1; then append to PKGNAME, return
current_package(){
  local append="${1}"
  if (( $# )); then
    in_array "${append}" "${PKGNAME[@]}" &&   \
      warning "${FUNCNAME[0]}: ${append} is already in package list ($(caller))"
    export PKGNAME=("${append//\ }" ${PKGNAME[@]})
    return 0
  fi
  printf -- "${PKGNAME[@]}"
}

# Register_value:
# Grab the caller's function name, see if they set a value,
# register it to a global array
register_value() {
  local caller="${FUNCNAME[1]}"
  local value; declare -n value="${caller}"
  [[ "${caller}" == "main" ]] &&  \
    error "${FUNCNAME[0]}: Main called? ($(caller))" ${E_INTERNAL}
  [[ -z "${value+x}" ]] && \
    warning "${FUNCNAME[0]}: WARNING: No value set for '${FUNCNAME[1]}'."

  echo $(current_package)
}

# START
name() {
  name=""

  register_value
}

version() {

  register_value
}

revision() {
:
}

section() {
:
}

arches() {
:
}

license() {
:
}

maintainers() {
:
}

description() {
:
}

long_description() {
  (( ! $# )) && { mapfile -t; set -- "${MAPFILE[@]}"; } # EOF support
  local line
  declare -g long_description=()

  while (( $# )); do
    line="${1}"
    # strip whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    # append
    long_description+=("${line}")
    shift
  done

  register_value
}

homepage() {
:
}

build_depends() {
:
}

depends() {
:
}
