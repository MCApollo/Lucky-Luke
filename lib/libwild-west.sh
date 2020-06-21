#!/hint/bash
#
#   libwild-west - "Some People Call Me the Space Cowboy."
#
#   Copyright (C) 2020 by Mac C. <MCApollo@protonmail.com>
#
#   ** MAKEPKG **
#   Copyright (c) 2006-2020 Pacman Development Team <pacman-dev@archlinux.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# This script is meant to be sourced as so:
# . libwildwest.sh

declare -rx LIBWILDWEST=$(
  libpath="$(realpath ${BASH_SOURCE[0]%%.sh})"
  printf -- '%s' "${libpath}"
)

declare -rx wildwestdebug=0

# => C-like '#include'
wildwest(){
  : ${LIBWILDWEST?}
  source "${LIBWILDWEST}/$@.sh"
}; export -f wildwest

shellopts=$(shopt -p)
shopt -s extglob nullglob
(( wildwestdebug )) && set -x
for file in "${LIBWILDWEST}"/*.sh; do
  source "${file}"

  (( wildwestdebug )) && printf -- '(debug) %s: sourcing %s\n'  \
    "${LIBWILDWEST##*/}" "${file##*/}"
done; unset file
(( wildwestdebug )) && set +x
eval "${shellopts}"; unset shellopts
