#!/usr/bin/env bash

. libwild-west.sh

. ${HOME}/Lucky-Luke/data/example-readline/COWBOY

# echo ${!PKGINFO_main[@]}
declare -p PKGINFO_main
for KEY in "${!PKGINFO_main[@]}"; do
  # Print the KEY value
  echo "KEY => ${KEY} ====="
  # Print the VALUE attached to that KEY
  echo "Value: ${PKGINFO_main[$KEY]}"
done
echo "&&& ${PKGNAME[@]}"


echo "envp"
envp_c 'name'
envp 'main' 'name'

declare -p ${PKGINFO}_${PKGNAME}
# declare -f | grep package_
