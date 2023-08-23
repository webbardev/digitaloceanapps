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

function compare_files {
  local context_lines=1

  echo -e "\n Comparing new and old app spec..."

  if [ $# -ne 2 ]; then
    echo "Usage: compare_files 'string_to_compare' file.txt"
    return 1
  fi

  local string_to_compare="$1"
  local file="$2"

  if [ ! -f "$file" ]; then
    echo "File $file does not exist."
    return 1
  fi

  local result
  if command -v diff &> /dev/null; then
    result=$(echo -e "$string_to_compare" | diff -C $context_lines - "$file")
    if [ $? -eq 0 ]; then
      result="No Changes detected"
    fi
  else
    echo "diff command not found, using PowerShell's Compare-Object as fallback."
    result=$(powershell -Command "
      \$stringContent = @'
$string_to_compare
'@
      \$fileContent = Get-Content -Path '$file'
      \$comparison = Compare-Object \$stringContent \$fileContent | Where-Object { \$_.SideIndicator -ne '==' } | ForEach-Object { \$_.InputObject }
      if (\$comparison -eq \$null) { 'No Changes detected' } else { \$comparison }
    ")
  fi
  echo "$result"
}
