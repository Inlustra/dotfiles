#! /bin/bash


awsGetSession() {
    # Creates an STS session and rotates the access key used for bootstrapping

    if ! [ -x "$(command -v jq)" ]; then
    echo "JQ must be installed to use this script"
    fi

    hash jq 2>/dev/null || { echo >&2 "This script requires jq (https://stedolan.github.io/jq/) but it's not installed. Aborting."; exit 1; }

    account_id=$(aws --profile $AWS_PROFILE configure get account_id)
    iam_user=${AWS_IAM_USER?Please set the AWS_IAM_USER environment variable}
    bootstrap_profile=${AWS_BOOTSTRAP_PROFILE?Please set the AWS_BOOTSTRAP_PROFILE environment variable}
    profile=${AWS_PROFILE?Please set the AWS_PROFILE environment variable}

    mfa_code=${1?MFA code not supplied. Usage: awsGetSession <MFA code>}

    output=$(aws --profile $bootstrap_profile sts get-session-token --serial-number arn:aws:iam::${account_id}:mfa/${iam_user} --output json --token-code $mfa_code)
    aws_access_key_id=$(echo $output | jq -r --exit-status '.Credentials.AccessKeyId')
    aws_secret_access_key=$(echo $output | jq -r --exit-status '.Credentials.SecretAccessKey')
    aws_session_token=$(echo $output | jq -r --exit-status '.Credentials.SessionToken')

    aws configure set profile.$profile.aws_access_key_id $aws_access_key_id
    aws configure set profile.$profile.aws_secret_access_key $aws_secret_access_key
    aws configure set profile.$profile.aws_session_token $aws_session_token

    echo "Created a new STS session. Credentials for the '$profile' profile will be valid for 12 hours."

    just_used_access_key_id=$(aws configure get profile.$bootstrap_profile.aws_access_key_id)

    echo "Deleting old access key $just_used_access_key_id"
    aws --profile $profile iam delete-access-key --access-key-id $just_used_access_key_id

    echo "Creating new access key to replace the deleted one"
    create_access_key_output=$(aws --profile $profile iam create-access-key)

    new_access_key_id=$(echo $create_access_key_output | jq -r --exit-status '.AccessKey.AccessKeyId')
    new_secret_access_key=$(echo $create_access_key_output | jq -r --exit-status '.AccessKey.SecretAccessKey')

    aws configure set profile.$bootstrap_profile.aws_access_key_id $new_access_key_id
    aws configure set profile.$bootstrap_profile.aws_secret_access_key $new_secret_access_key

    echo "Done."
}

awsLogin() {
    hash jq 2>/dev/null || { echo >&2 "This script requires jq (https://stedolan.github.io/jq/) but it's not installed. Aborting."; exit 1; }

    if [ "$1" = '' ] | [ "$2" = '' ] | [ "$3" = '' ]; then
    echo "usage: awsLogin <profile_name> <iam_username> <one_time_password>"
    exit
    fi

    export AWS_IAM_USER=$2
    export AWS_BOOTSTRAP_PROFILE=$1-bootstrap
    export AWS_PROFILE=$1

    awsGetSession "$3"
}