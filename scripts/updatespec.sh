#!/bin/bash

# Check if both arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <appID> <specPath>"
    exit 1
fi

# Assign the first argument to appId and the second to specPath
appId=$1
specPath=$2

npm run doauth

# Update the Spec
# shellcheck disable=SC2086
doctl apps update $appId --spec "$specPath"
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
