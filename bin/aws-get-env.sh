#!/bin/env bash

# Get AWS Access Key ID and Secret Access Key to source into ENV

if [[ "$1" == "" ]]; then
  echo "Usage: eval \$( ${0##*/} aws-profile )"
  echo "  This script will emit 'export' statements for the AWS CLI to use from the specified profile."
  echo ""
  echo " export AWS_ACCESS_KEY_ID=.......  AWS_SECRET_ACCESS_KEY=........."
  exit 1
fi

AK=$(aws --profile="$1" configure get aws_access_key_id) || exit 1
SAK=$(aws --profile="$1" configure get aws_secret_access_key) || exit 1

echo "export AWS_ACCESS_KEY_ID=\"$AK\"  AWS_SECRET_ACCESS_KEY=\"$SAK\""
