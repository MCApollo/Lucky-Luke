#!/usr/bin/env bash
#
#     error.sh : list of error codes
#

[[ -n "${LIBWILDWEST_UTIL_ERROR_SH}" ]] && return
export LIBWILDWEST_UTIL_ERROR_SH=1
: ${LIBWILDWEST?}

E_OK=0
E_FAIL=1
E_MISSING_FILE=2
E_INVALID_OPTION=3

E_RUNTIME=9
E_PACKAGE=10
E_BUILD=11
# libwildwest
E_SAFE=20
