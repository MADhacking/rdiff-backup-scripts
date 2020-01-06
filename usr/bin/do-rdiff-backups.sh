#! /bin/bash

CONFIG_FILE="${CONFIG_FILE:-/etc/rdiff-backups}"

while read -r line
do
	[[ -z "${line}" || "${line}" == \#* ]] && continue
    # shellcheck disable=SC2206
	declare -a params=(${line})
	[[ -z "${params[1]}" || -z "${params[2]}" || -n "${params[3]}" ]] && echo -e "Can't parse ${line}\n" && exit
done < "${CONFIG_FILE}"

while read -r line
do
	[[ -z "${line}" || "${line}" == \#* ]] && continue
	# shellcheck disable=SC2206
	declare -a params=(${line})
	[[ -z "${first}" ]] && first="no" || echo -e "\n"

	echo -e "Backing up ${params[0]} to ${params[1]} for ${params[2]}\n"
	echo -n "Free space at ${params[1]} before backup : "
	df "${params[1]}" -h | awk '{ print $4 " of " $2 " (" 100 - $5 "%)"}' | tail -n 1
	echo "--------------------------------------------------"
	
	rdiff-backup --remove-older-than "${params[2]}" "${params[1]}"
	rdiff-backup --ssh-no-compression --print-statistics "${params[0]}" "${params[1]}"

	echo -n "Free space at ${params[1]} after backup : "
	df "${params[1]}" -h | awk '{ print $4 " of " $2 " (" 100 - $5 "%)"}' | tail -n 1

done < "${CONFIG_FILE}"
