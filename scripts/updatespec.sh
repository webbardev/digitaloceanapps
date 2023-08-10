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
echo "Spec: ./$specFolder/$appName.$extension"

if [[ ! $appId =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    echo "App ID could not be found!"
    exit 1
fi

# Update the Spec
# shellcheck disable=SC2086

doctl apps update $appId --spec "./$specFolder/$appName.$extension" --format ID --no-header

attempts=0
max_attempts=10
interval=1

while [[ $attempts -lt $max_attempts ]]; do
    output=$(doctl apps get $appId --format InProgressDeployment.ID)
    active_deployment_id=$(echo "$output" | awk 'NR==2 {print $1}')

    # If we find the active_deployment_id, break out of the loop
    if [[ ! -z "$active_deployment_id" ]]; then
        break
    fi

    # Increment the attempts and sleep
    ((attempts++))
    sleep $interval
done

# Optionally, check if we found the active_deployment_id after max_attempts
if [[ -z "$active_deployment_id" ]]; then
    echo "Failed to fetch active deployment ID after $max_attempts attempts."
    exit 1
fi

active_deployment_id=$(echo "$output" | awk 'NR==2 {print $1}')

echo "Active Deployment ID $active_deployment_id";

symbols=("[.  ]" "[ . ]" "[  .]")
# 10 Minutes timeout
timeout=600
counter=0
echo "Waiting for Deployment Result of: $active_deployment_id ...";

# Check for either success, error or timeout
while true; do

    # Run your command and capture the output
    output=$(doctl apps get-deployment $appId $active_deployment_id --no-header --format ID,Cause,Progress,Updated)

    # Extract current progress and total from the string "x/y", where x is the current progress and y is the total
    progress=$(doctl apps get-deployment $appId $active_deployment_id --format Progress)
    current_progress=${progress%/*}  # Extracts the number before the slash
    total=${progress#*/}            # Extracts the number after the slash

   # Ensure the values are numeric by removing all non-digit characters
   clean_current_progress=${current_progress//[^0-9]/}
   clean_total=${total//[^0-9]/}

   # Ensure we didn't get empty values after cleaning; if we did, there's likely an issue with the inputs
   if [[ -z "$clean_current_progress" || -z "$clean_total" ]]; then
       echo "Error: Invalid values retrieved for progress. Current Progress: '$current_progress', Total: '$total'"
       exit 1
   fi

   # Now, compare the sanitized values
   if [[ $clean_current_progress -ge $clean_total ]]; then
       echo -e "\nUpdate successful!\n"

       echo -e "Retrieving updated App Spec ..."

       # Download the current app spec to update for example secrets
       ./scripts/getspec.sh $authContext $appName

        echo -e "\nDone!\n"
       exit 0
   fi

    # Check if the output contains "error"
    if [[ $output == *"error"* ]]; then
        echo -e "\n##########\nERROR:\n $output"
        break
    fi

    # Increment the counter
    ((counter++))

    # If the counter reaches the timeout value, exit the loop
    if [[ $counter -ge $timeout ]]; then
        echo "\nTimeout after 10 minutes."
        break
    fi

    index=$((counter % 3))

    # Print the updated output on the same line using carriage return
    echo -ne "$output ${symbols[$index]} \r";

    # Wait for one second before the next iteration
    sleep 1
done
