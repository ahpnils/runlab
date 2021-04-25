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
# set -o xtrace
############
# Variables

virsh_bin=$(which virsh)

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
	echo "	 -h		show this help"
	exit 1
}

# Handles virtual networks
# takes an action as an argument,
# in order to start or stop a virtual network
virsh_net() {
  if [ "${action}" == "start" ]; then
		net_arg="net-start"
		wanted_active="yes"
  elif [ "${action}" == "stop" ]; then
		net_arg="net-destroy"
		wanted_active="no"
		net_list=$(echo "${net_list}" | tac -)
  else
	  die "Unknown action."
  fi

  for virt_net in ${net_list}; do
	  "${virsh_bin}" ${net_arg} "${virt_net}"
		target_active=0
		for i in {0..10}
		do
			sleep $((i * 2))
			if [ "$(${virsh_bin} net-info "${virt_net}" | grep ^Active | awk '{print $2}')" == "${wanted_active}" ]; then
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
  if [ "${action}" == "start" ]; then
		dom_arg="start"
		wanted_state="running"
  elif [ "${action}" == "stop" ]; then
		dom_arg="shutdown"
		wanted_state="shut off"
		dom_list=$(echo "${dom_list}" | tac -)
  else
	  die "Unknown action."
  fi

  for virt_dom in ${dom_list}; do
	  "${virsh_bin}" ${dom_arg} "${virt_dom}"
		target_state=0
		for i in {0..10}
		do
			sleep $((i * 2))
			if [ "$(${virsh_bin} domstate "${virt_dom}")" == "${wanted_state}" ]; then
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
# Main

if [ "$(id -u)" != "0" ]; then
	die "CRITICAL : not run as root."
fi

if [[ ${#} -eq 0 ]]; then
	usage
fi

conf_file="/etc/runlabrc"
if [ -r "${conf_file}" ]; then
	# shellcheck source=./runlabrc.example
	source ${conf_file}
else
	die "CRITICAL : config file not found. Ensure you have a ${conf_file} ."
fi

optstring=":skh"
while getopts ${optstring} arg; do
	case "${arg}" in
		s)
			echo "Starting the lab"
			action="start"
			virsh_net "${action}"
			virsh_domain "${action}"
			;;
		k)
			echo "Stopping the lab"
			action="stop"
			virsh_domain "${action}"
			virsh_net "${action}"
			;;
		h)
			usage
			;;
		?)
			echo "Invalid option: -${OPTARG}."
			echo
			usage
			;;
	esac
done

# vim:ts=2:sw=2
