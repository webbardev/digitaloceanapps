#!/bin/bash

source ./scripts/functions.sh

# Check if both arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <authContext> <appName>"
    exit 1
fi

# Definitions
authContext=$1
appName=$2
backupsFolder="backups"
specFolder="specs"
current_date=$(date '+%d_%m_%Y_%H_%M_%S')
extension="yml"

# Switch Auth Context
doctl auth switch --context "$authContext"

# Get actual App ID
appId=$(getAppId "$appName")
echo "App ID: $appId"

if [[ ! $appId =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    echo "App ID could not be found!"
    exit 1
fi

# Backup the current file
if [ ! -d "$backupsFolder" ]; then
    echo "Creating /$backupsFolder folder";
    mkdir "backups";
fi

# Construct backup filename
backup_filename="${appName}_bak_${current_date}.$extension"

# Copy the file
if [ -f "./$specFolder/$appName.$extension" ]; then
  cp "./$specFolder/$appName.$extension" "./$backupsFolder/$backup_filename"

  # Check if the copy command was successful
  if [ $? -eq 0 ]; then
    echo "App Spec backed up: $backup_filename"
    # Commit the Backup
    git add -f "./backups/$backup_filename"
  else
      echo "Error occurred while creating backup: $backup_filename"
      exit 3
  fi
fi

# Create the spec folder, if not existing
if [ ! -d "$specFolder" ]; then
    mkdir -p "$specFolder"
fi

# Get latest app spec version
doctl apps spec get "$appId" > "./$specFolder/$appName.$extension"

git add -f "./$specFolder/$appName.$extension"
