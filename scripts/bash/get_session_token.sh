#!/bin/bash
response="$(aws sts get-session-token --serial-number "$1" --token-code "$2")"

SessionToken=$(jq -r '.Credentials.SessionToken' <<< "$response")
AccessKeyId=$(jq -r '.Credentials.AccessKeyId' <<< "$response")
SecretAccessKey=$(jq -r '.Credentials.SecretAccessKey' <<< "$response")
echo "export AWS_ACCESS_KEY_ID=$AccessKeyId"
echo "export AWS_SECRET_ACCESS_KEY=$SecretAccessKey"
echo "export AWS_SESSION_TOKEN=$SessionToken"
export AWS_ACCESS_KEY_ID="$AccessKeyId"
export AWS_SECRET_ACCESS_KEY="$SecretAccessKey"
export AWS_SESSION_TOKEN="$SessionToken"

