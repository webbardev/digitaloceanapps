#!/bin/bash

source ./scripts/functions.sh

# Check if both arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <authContext> <appName>"
    exit 1
fi

# Assign the first argument to appId and the second to specPath
authContext=$1
appName=$2
specFolder="specs"
extension="yml"

doctl auth switch --context "$authContext"

# Get actual App ID
appId=$(getAppId "$appName")
echo "App ID: $appId"

if [[ ! $appId =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    echo "App ID could not be found!"
    exit 1
fi

# Update the Spec
# shellcheck disable=SC2086
doctl apps update $appId --spec "./$specFolder/$appName.$extension" --format ID,Spec.Name
output=$(doctl apps get "$appId")
deployment_id=$(echo "$output" | awk 'NR==2 {print $4}')

# 10 Minutes timeout
timeout=600
counter=0

echo "Waiting for Deployment Result of: $deployment_id ...";

# Check for either success, error or timeout
while true; do
    # Run your command and capture the output
    output=$(doctl apps get-deployment $appId $deployment_id)

    # Check if the output contains "5/5" or "error"
    if [[ $output == *"5/5"* ]]; then
        echo -e "\n##########\nSUCCESS:\n $output"

        # Down the current app spec to update for example secrets
        ./scripts/getspec.sh $authContext $appName;
        exit 0;
        break
    fi

    # Check if the output contains "5/5" or "error"
    if [[ $output == *"error"* ]]; then
        echo -e "\n##########\nERROR:\n $output"
        break
    fi

    # Increment the counter
    ((counter++))

    # If the counter reaches the timeout value, exit the loop
    if [[ $counter -ge $timeout ]]; then
        echo "Timeout after 10 minutes."
        break
    fi

    # Wait for one second before the next iteration
    sleep 1
done

