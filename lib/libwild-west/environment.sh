#!/usr/bin/env bash
#
#   environment.sh : 
#

[[ -n "${LIBWILDWEST_ENVIRONMENT_SH}" ]] && return
export LIBWILDWEST_ENVIRONMENT_SH=1
: ${LIBWILDWEST?}

for lib in "${LIBWILDWEST}/environment/"*.sh; do
    source "${lib}"
done; unset lib

