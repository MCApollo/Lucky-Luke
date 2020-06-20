#!/usr/bin/env bash
#
#   util.sh : random-helper functions
#

[[ -n "${LIBWILDWEST_UTIL_SH}" ]] && return
export LIBWILDWEST_UTIL_SH=1
: ${LIBWILDWEST?}

for lib in "${LIBWILDWEST}/util/"*.sh; do
    source "${lib}"
done; unset lib

