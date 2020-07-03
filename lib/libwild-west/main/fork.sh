#!/usr/bin/env bash
#
#     fork.sh : tell bash to go fork itself
#

declare -ax __fork_processes=()
declare -x __fork_error=0
# => ("'$PID' '${fd}' '${tempfile}'" "..." "...")
declare -r __fork_mktemp='mktemp -u --suffix=-fork'
declare -r __fork_tail='cat'
# => XXX: grab the config option here

# TRAP
fork_on_exit() {
  # private
  local wait="${1:+1}" # boolean to kill or wait.
  local follow="${2:+2}"
  # local
  local pid=() fd tmp
  local t=0 l=6 s=5 # defaults: { limit, sleep }

  for (( i=0; i < ${#__fork_processes[@]}; i++ )); do
    read -r pid fd tmp < <(printf -- '%s\n' "${__fork_processes[$i]}")

  if (( wait )); then
      if kill -0 "${pid}" 2>/dev/null; then
        if (( QUIET )); then
          QUIET=0 \
          msg "%s: waiting for '%s' to finish, follow with '%s' to see it!"  \
            "${FUNCNAME[1]}" "${pid}" "${__fork_tail} ${tmp}"
          wait "${pid}"
        else
          { # tell the name pipe, or anyone following it
            # printf "\033[H\033[J" # "clear the buffer", so we don't spam the terminal on follow
            tput reset
            warning "%s: this buffer is being read by the main script! (%s)" \
              "${FUNCNAME[1]}" "$$"
          } &> ${tmp}
          # tell main
          msg "%s: following '%s' - waiting for finish" \
            "${FUNCNAME[1]}" "${pid}"
          plainline
          sleep ${s}
          # follow
          ${__fork_tail} 0<>${tmp} &
          wait "${pid}"
          kill $! 2>/dev/null || :
        fi # if (( QUIET ))
      fi # if kill
      continue
  else # if (( wait ))
    # if (( ! ${__fork_error} )); then # error = 0
      while (( t < ${l} )) && kill -0 "${pid}" 2>/dev/null; do
        plainerr "%s: job '${RED}%s${ALL_OFF}'${BOLD} is still running, waiting... %s"  \
          "${FUNCNAME[0]}" "${pid}" "(${t}/${l})"
        (( ++t )); sleep $s
      done; t=0; printf -- '\n'
    # fi # if (( __fork_error ))
  fi # if (( wait ))
    { # Clean Up:
      kill -9 ${pid} || :
      eval "exec ${fd}>&-"  # FIXME: Input checking
      rm -f "${tmp}"
    } 2>/dev/null
    debug "${FUNCNAME[0]}: Killed ${pid}."
  done # for (( ... ))

  declare -ax __fork_processes=() # reset, everything should be clear.
}
# COMM from fork()
__fork_trap_sigusr2(){
  declare -gxr __fork_error=1
}; trap '__fork_trap_sigusr2' USR2

fork_handle_fd() {
  local fd=0
  local fifocmd="$(${__fork_mktemp})"

  while (( ! $( :>&${fd}; echo $? ) )) 2>/dev/null; do
    (( ++fd ))
  done

  printf -- '%s %s\n' "${fd}" "${fifocmd}"
}

fork_wait() {
  # XXX: Check the config/options to auto-follow
  fork_on_exit "my roflcopter goes" "swoiswoiswoiswoiswoiswoi"

  # Let the caller decide what to do,
  #   it would be rude to exit here
  return ${__fork_error}
}

# MAIN
fork() {
  local cmd=($@)
  local fd fifo; read -r fd fifo < <(fork_handle_fd)
  mkfifo -m 600 "${fifo}"

  local p="exec ${fd}<>${fifo}"
  eval "${p}" # ${foo}<> | doesn't get expanded by bash.

  local shopt="$-"; set +e  # for sigusr trap, 'set -e' forces exit on trap
  ( # Fork!
    local ret=0
    local exec

    ${cmd[@]} >&${fd} || ret=$?
    if (( ret )); then
      error "%s: command '%s' exited with %s!"  >&2 \
        "${FUNCNAME[0]}" "${cmd}" "${ret}"
      kill -s USR2 $$
    fi
  ) &
  set ${shopt}
  export __fork_processes+=("$! ${fd} ${fifo}")

  msg "'%s' has forked! use '%s' to see it!" \
    "${cmd}" "${__fork_tail} ${fifo}"
}
