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

# tests if a variable is an array
is_array() {
	local v=$1
	local ret=1

	if [[ ${!v@a} = *a* ]]; then
		ret=0
	fi

	return $ret
}

# test if a variable is an associative array
is_associative() {
	local v=$1
	local ret=1

	if [[ ${!v@a} = *A* ]]; then
		ret=0
	fi

	return $ret
}

have_function() {
	declare -f "$1" >/dev/null
}

grep_function() {
	{ declare -f "$1" || declare -f package; } 2>/dev/null | grep -E "$2"
}
