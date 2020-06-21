#!/usr/bin/env bash
#
#   main.sh : main functions used by Jolly
#

[[ -n "${LIBWILDWEST_MAIN_SH}" ]] && return
export LIBWILDWEST_MAIN_SH=1
: ${LIBWILDWEST?}

for lib in "${LIBWILDWEST}/main/"*.sh; do
    source "${lib}"
done; unset lib
