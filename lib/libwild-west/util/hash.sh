#!/usr/bin/env bash
#
#     hash.sh : figure out hash-size of files/directories
#

[[ -n "${LIBWILDWEST_UTIL_HASH_SH}" ]] && return
export LIBWILDWEST_UTIL_HASH_SH=1
: ${LIBWILDWEST?}
