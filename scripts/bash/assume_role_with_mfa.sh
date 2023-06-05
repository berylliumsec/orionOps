#!/bin/bash
if [ -n "$4" ]; then
response="$(aws sts assume-role --no-paginate --role-arn "$1" --role-session-name "$2" --serial-number "$3" --token-code "$4")"
else
response="$(aws sts assume-role --no-paginate --role-arn "$1" --role-session-name "$2" --serial-number "$3")"
fi
SessionToken=$(jq -r '.Credentials.SessionToken' <<< "$response")
AccessKeyId=$(jq -r '.Credentials.AccessKeyId' <<< "$response")
SecretAccessKey=$(jq -r '.Credentials.SecretAccessKey' <<< "$response")
echo "export AWS_ACCESS_KEY_ID=$AccessKeyId"
echo "export AWS_SECRET_ACCESS_KEY=$SecretAccessKey"
echo "export AWS_SESSION_TOKEN=$SessionToken"
export AWS_ACCESS_KEY_ID="$AccessKeyId"
export AWS_SECRET_ACCESS_KEY="$SecretAccessKey"
export AWS_SESSION_TOKEN="$SessionToken"

