#!/usr/bin/env bash
#
#    util.sh : QoL functions
#

[[ -n "${LIBWILDWEST_UTIL_UTIL_SH}" ]] && return
export LIBWILDWEST_UTIL_UTIL_SH=1
: ${LIBWILDWEST?}

##
#  usage : in_array( $needle, $haystack )
# return : 0 - found
#          1 - not found
##
in_array() {
	local needle=$1; shift
	local item
	for item in "$@"; do
		[[ $item = "$needle" ]] && return 0 # Found
	done
	return 1 # Not Found
}
