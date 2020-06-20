#!/usr/bin/env bash
# libwildwest - "some people call me the space cowboy"
# this file is meant to be used like:
# . libwildwest.sh

declare -rx LIBWILDWEST=$(
  libpath="$(basename ${BASH_SOURCE[0]%%.sh})"
  printf -- '%s' "$(realpath ${libpath})"
)

wildwest(){
  : ${LIBWILDWEST?}
  source "${LIBWILDWEST}/$@.sh"
}; export -f wildwest

shopt -s extglob nullglob
for file in "${LIBWILDWEST}"/*.sh; do
  source "${file}"

  (( debug )) && printf -- '(debug) %s: sourcing %s\n'  \
    "${LIBWILDWEST##*/}" "${file##*/}"
done; unset file
