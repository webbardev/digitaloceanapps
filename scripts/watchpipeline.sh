#!/bin/bash

source ./scripts/functions.sh

# Check if both arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <authContext> <appName>"
    exit 1
fi

authContext=$1
appName=$2
specFolder="specs"
extension="yml"
specPathName="$specFolder/$appName.$extension"

doctl auth switch --context "$authContext"

RED='\033[0;31m'
GREEN='\033[0;32m'
GRAY='\033[0;37m'
NC='\033[0m'

#### Version Check
versionCheck=$(node ./scripts/versions.js)
echo "$versionCheck";
if [ ! "$versionCheck" = "DigitalOceanApps up-to-date!" ]; then
  exit;
fi

# Get actual App ID
appId=$(getAppId "$appName")
echo "App ID: $appId"
echo "Spec: ./$specPathName"

if [[ ! $appId =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    echo "App ID could not be found!"
    exit 1
fi

## Link to App
echo "DO Link >> https://cloud.digitalocean.com/apps/$appId/overview"

# Monitoring active deployment
while : ; do
    output=$(doctl apps get $appId --format InProgressDeployment.ID)
    active_deployment_id=$(echo "$output" | awk 'NR==2 {print $1}')

    if [[ -n "$active_deployment_id" ]]; then
        echo -ne "${GRAY}♻️> Current deployment is running...${NC}\r"

        deployment_output=$(doctl apps get-deployment $appId $active_deployment_id --no-header --format ID,Cause,Progress,Updated)

        if [[ $deployment_output == *"error"* ]]; then
            echo -e "${RED}❌> Deployment encountered an error:${NC} $deployment_output"
            tput bel

            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                # Linux
                echo "Deployment failed" | espeak
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                say "Deployment failed"
            elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                # Windows
                powershell -c "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak('Deployment failed');"
            fi
        fi

    else
        echo -ne "${GREEN}✅> Success! Deployment is done.${NC}\r"
    fi

    sleep 30
done



