#!/bin/bash

# Check if both arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <appID> <specFilename>"
    exit 1
fi

# Definitions
appId=$1
specFilename=$2
backupsFolder="backups"
specFolder="specs"
current_date=$(date '+%d_%m_%Y_%H_%M_%S')

npm run doauth

extension="${specFilename##*.}"  # Extract the file extension (assumed to be 'yml' based on your description)
base_filename="${specFilename%.*}"  # Get the filename without extension

# Backup the current file
if [ ! -d "$backupsFolder" ]; then
    echo "Creating /$backupsFolder folder";
    mkdir "backups";
fi

# Construct backup filename
backup_filename="${base_filename}_bak_${current_date}.$extension"

# Copy the file
#cp "$specFilename" "$backup_filename" 2> /dev/null
cp "./$specFolder/$specFilename" "./$backupsFolder/$backup_filename"

# Check if the copy command was successful
if [ $? -eq 0 ]; then
  echo "App Spec backed up: $backup_filename"
else
    echo "Error occurred while creating backup: $backup_filename"
    exit 3
fi

# Commit the Backup
git add "./backups/$backup_filename"

# Get latest version
doctl apps spec get "$appId" > "/specs/$specFilename"




