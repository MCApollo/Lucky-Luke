#!/usr/bin/env bash
#
#   download.sh : set of tools to download tarballs/repos
#

[[ -n "${LIBWILDWEST_DOWNLOAD_SH}" ]] && return
export LIBWILDWEST_DOWNLOAD_SH=1
: ${LIBWILDWEST?}

for lib in "${LIBWILDWEST}/download/"*.sh; do
    source "${lib}"
done; unset lib
