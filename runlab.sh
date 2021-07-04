#!/bin/bash
# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any function or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR.
set -o nounset
# Catch the error in case cmd1 fails (but cmd2 succeeds) in  `cmd1 | cmd2 `.
set -o pipefail
# Turn on traces, useful while debugging but commentend out by default
#set -o xtrace
############
# Variables

virsh_bin="$(which virsh)"
conf_file="/etc/runlabrc"
action=""

############
# Functions

# For quitting on error
die() {
  echo "${@}" 2>&1
  echo "Quitting..." 2>&1
  exit 1
}

# Explains how the script works
usage() {
	echo "Usage: $(basename "${0}") [-skh]" 2>&1
	echo "	 -s		start the lab"
	echo "	 -k		stop (kill) the lab"
	echo "	 -r		restart (stop then start) the lab"
	echo "	 -h		show this help"
	echo "   -c   define config file (optional - defaults to /etc/runlabrc)"
	echo "Note : only one argument at a time can be used."
	exit 1
}

# Handles virtual networks
# takes an action as an argument,
# in order to start or stop a virtual network
virsh_net() {
  if [ "${1}" == "start" ]; then
		net_arg="net-start"
		wanted_active="yes"
  elif [ "${1}" == "stop" ]; then
		net_arg="net-destroy"
		wanted_active="no"
		net_list=$(echo "${net_list}" | tac -)
  else
	  die "Unknown action."
  fi

  for virt_net in ${net_list}; do
	  "${virsh_bin}" -c "${libvirt_uri}" ${net_arg} "${virt_net}"
		target_active=0
		for i in {0..10}
		do
			sleep $((i * 2))
			if [ "$(${virsh_bin} -c "${libvirt_uri}" net-info "${virt_net}" | grep ^Active | awk '{print $2}')" == "${wanted_active}" ]; then
				target_active=1
				break
			fi
		done
		if [ ${target_active} -eq 0 ]; then
			# just print error or die ?
			echo "error starting or shuting down ${virt_net}"
		fi
  done
}

# Handles virtual machines (domains)
# takes an action as an argument,
# in order to start or stop a domain
virsh_domain() {
  if [ "${1}" == "start" ]; then
		dom_arg="start"
		wanted_state="running"
  elif [ "${1}" == "stop" ]; then
		dom_arg="shutdown"
		wanted_state="shut off"
		dom_list=$(echo "${dom_list}" | tac -)
  else
	  die "Unknown action."
  fi

  for virt_dom in ${dom_list}; do
	  "${virsh_bin}" -c "${libvirt_uri}" ${dom_arg} "${virt_dom}"
		target_state=0
		for i in {0..10}
		do
			sleep $((i * 2))
			if [ "$(${virsh_bin} -c "${libvirt_uri}" domstate "${virt_dom}")" == "${wanted_state}" ]; then
				target_state=1
				break
			fi
		done
		if [ ${target_state} -eq 0 ]; then
			# just print error or die ?
			echo "error starting or shuting down ${virt_dom}"
		fi
  done
}

############
# Mutex

if [ "${FLOCKER:-}" != "$0" ] ; then
  # re-launching itself with a lock
  #
  # -e - exclusive
  # -n - non-block
  # -E - --conflict-exit-code
  # "$0" - lock-file (itself)
  #
  # "$0" - programm to launch (itself)
  # "$@" - with its arguments
  LOCK_FAIL_CODE=66
  # Not an exec, as we want to check if it failed because of the lock, or for
  # an other reason
  env FLOCKER="$0" flock -en -E "$LOCK_FAIL_CODE" "$0" "$0" "$@" || ret="$?"
  if [ "${ret:-}" = "$LOCK_FAIL_CODE" ] ; then
    die "Already running."
  fi
fi

############
# Main

optstring=":c:skrh"
while getopts ${optstring} arg; do
	case "${arg}" in
		s)
			if [ -z "${action}" ]; then action="start"; else usage; fi
			;;
		k)
			if [ -z "${action}" ]; then action="stop"; else usage; fi
			;;
	  r)
			if [ -z "${action}" ]; then action="restart"; else usage; fi
			;;
		c)
			echo "Config file ${OPTARG} used."
			conf_file="${OPTARG}"
			;;
		h)
			usage
			;;
		:)
			die "Option -${OPTARG} requires an argument."
			;; 
		?)
			echo "Invalid option: -${OPTARG}."
			echo
			usage
			;;
	esac
done

# Take options from config file
if [ -r "${conf_file}" ]; then
	# shellcheck source=./runlabrc.example
	source "${conf_file}"
else
	echo "CRITICAL : config file not found. Ensure you have a ${conf_file} ." 2>&1
	echo "Quitting..." 2>&1
	exit 1
fi

case "${action}" in
	start)
		echo "Starting the lab"
		virsh_net "${action}"
		virsh_domain "${action}"
		;;
	stop)
		echo "Stopping the lab"
		virsh_domain "${action}"
		virsh_net "${action}"
		;;
	restart)
		echo "Restarting the lab"
		virsh_domain stop
		virsh_net stop
		virsh_net start
		virsh_domain start
		;;
	*)
		echo "Invalid action: -${action}."
		;;
esac

# vim:ts=2:sw=2
