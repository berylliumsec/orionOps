#!/bin/bash
response="$(aws sts assume-role --no-paginate --role-arn "$1" --role-session-name admin --serial-number "$2" --token-code "$3")"
SessionToken=$(jq -r '.Credentials.SessionToken' <<< "$response")
AccessKeyId=$(jq -r '.Credentials.AccessKeyId' <<< "$response")
SecretAccessKey=$(jq -r '.Credentials.SecretAccessKey' <<< "$response")
echo "Session token: $SessionToken"
echo "Access Key Id: $AccessKeyId"
echo "Secret Access Key: $SecretAccessKey"
export AWS_ACCESS_KEY_ID="$SecretAccessKey"
export AWS_SECRET_ACCESS_KEY="$SessionToken"
export AWS_SESSION_TOKEN="$AccessKeyId"
env
