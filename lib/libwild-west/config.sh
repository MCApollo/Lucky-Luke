#!/usr/bin/env bash
#
#   config.sh : 
#

[[ -n "${LIBWILDWEST_CONFIG_SH}" ]] && return
export LIBWILDWEST_CONFIG_SH=1
: ${LIBWILDWEST?}

for lib in "${LIBWILDWEST}/config/"*.sh; do
    source "${lib}"
done; unset lib

