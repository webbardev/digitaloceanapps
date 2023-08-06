#!/bin/bash

function getAppId {
  local appName="$1"

  if [ -z "$appName" ]; then
      echo "Usage: getAppId <appName>"
      return 1
  fi

  local output=$(doctl apps ls --format ID,Spec.Name | awk -v app="$appName" '$2 == app {print $1}')

  echo "$output"
}
