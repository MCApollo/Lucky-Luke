#!/usr/bin/env bash
#
#     buildenv.sh : set special compiler flags
#

[[ -n "${LIBWILDWEST_ENVIRONMENT_BUILDENV_SH}" ]] && return
export LIBWILDWEST_ENVIRONMENT_BUILDENV_SH=1
: ${LIBWILDWEST?}
