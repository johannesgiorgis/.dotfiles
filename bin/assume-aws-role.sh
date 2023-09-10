#!/usr/bin/env bash

# Assume a role in AWS and print the credentials to stdout.
# https://repost.aws/knowledge-center/iam-assume-role-cli
# https://docs.aws.amazon.com/cli/latest/reference/sts/assume-role.html

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <role_arn> <role_session_name>"
    echo "Example: $0 arn:aws:iam::891067072053:role/UberAgentApply johannes-assuming-uber-agent"
    exit 1
fi

role_arn=$1
role_session_name=$2

resp=$(aws sts assume-role --role-arn "$role_arn" --role-session-name "$role_session_name")

RoleAccessKeyID=$(echo "$resp" | jq -r '.Credentials.AccessKeyId')
RoleSecretKey=$(echo "$resp" | jq -r '.Credentials.SecretAccessKey')
RoleSessionToken=$(echo "$resp" | jq -r '.Credentials.SessionToken')


echo "Assume role $role_arn:
export AWS_ACCESS_KEY_ID=$RoleAccessKeyID
export AWS_SECRET_ACCESS_KEY=$RoleSecretKey
export AWS_SESSION_TOKEN=$RoleSessionToken

--------------------------------------------------
Verify via
aws sts get-caller-identity"
