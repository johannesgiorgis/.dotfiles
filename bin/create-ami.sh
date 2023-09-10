#!/usr/bin/env bash

######################################################################
#
# Create AWS AMI Image
# --------------------
#
#
######################################################################

function print_stamp() {
	echo "$(date +"%Y-%m-%d_%H:%M:%S") $*"
}

function print_usage() {
	echo ""
	echo "Usage:"
	echo "    ${0##*/} -i <instance-id> -n <name> -p <aws-profile>"
	echo "    ${0##*/} -i i-06b6a8f70bf703bd9 -n 'opsbox2-backup' -p 'prod_copy.admin'"
	echo ""
}

while getopts ":i:n:p:" opt; do
  case $opt in
    i) instance_id="$OPTARG";;
    n) name="$OPTARG";;
    p) profile="$OPTARG";;
    :) echo "Option -$OPTARG requires an argument." >&2; print_usage; exit 1;;
    \?) echo "Invalid option: -$OPTARG" >&2; print_usage; exit 1;;
  esac
done
shift $((OPTIND-1))


if [[ "$instance_id" == "" ]];
then
	echo "ERROR: No instance id provided! Please specify -i <instance_id>" >&2
	print_usage
	exit 1
fi

if [[ "$name" == "" ]];
then
	echo "ERROR: No name provided! Please specify -n <name>" >&2
	print_usage
	exit 1
fi

if [[ "$profile" == "" ]];
then
	echo "ERROR: No AWS Profile provided! Please specify -p <aws profile>" >&2
	print_usage
	exit 1
fi

##########################################################################

print_stamp "Script $0 Started"

description="${name}-$(date +"%Y-%m-%d_%H:%M:%S")"
echo "Description:'$description'"

aws --profile "$profile" s3 ls
#aws --profile $profile create-image --instance-id $instance-id --name $name --no-reboot

print_stamp "Script $0 Completed"
