#!/usr/bin/env bash

set -o errexit
set -o pipefail

# getMyRegion returns the region in which the current instance is running,
# based on the availability zone read from the EC2 metadata service.
#
# Parameters:
#     None.
function getMyRegion() {
	local metadata_base_url="http://169.254.169.254/latest/meta-data"
	local this_instance_az

	this_instance_az=$(curl --silent --location ${metadata_base_url}/placement/availability-zone)

	#shellcheck disable=SC2001
	echo "${this_instance_az}" | sed 's/.$//'
}

# getLogGroup returns the value of the tfe:log_group tag on the instance. If the
# tag is not set, the string "None" is returned.
#
# Parameters:
#     $1: the name of the region in which the instance is running.
function getLogGroup() {
	local region=$1
	local metadata_base_url="http://169.254.169.254/latest/meta-data"

	local this_instance_id
	this_instance_id=$(curl --silent --location ${metadata_base_url}/instance-id)

	aws ec2 describe-tags \
		--region "${region}" \
		--filters "Name=resource-type,Values=instance" \
		"Name=resource-id,Values=${this_instance_id}" \
		"Name=key,Values=system:log_group" \
		--query "Tags[0].Value" \
		--output=text
}

function writeJournaldCloudWatchConfig() {
	local path=$1
	local state_path=$2
	local log_group_name=$3

	echo "log_group = \"${log_group_name}\"" | tee "${path}"
	echo "state_file = \"${state_path}\"" | tee -a "${path}"
	echo "log_priority = \"5\"" | tee -a "${path}"
}

function configureJournaldCloudWatch() {
	local path=$1
	local state_path=$2

	local region
	local log_group

	region=$(getMyRegion)
	log_group=$(getLogGroup "${region}")

	if [ "${log_group}" == "None" ] ; then
		log_group="default"
	fi

	writeJournaldCloudWatchConfig "${path}" "${state_path}" "${log_group}"
}

mkdir -p /etc/journald-cloudwatch-logs
configureJournaldCloudWatch "/etc/journald-cloudwatch-logs/journald-cloudwatch-logs.conf" "/srv/journald-cloudwatch-logs/state"
