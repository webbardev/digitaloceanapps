#!/bin/bash

source ./scripts/functions.sh

# Check if both arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "\033[41;97mUsage: $0 <authContext> <appName>\033[0m"
    exit 1
fi

authContext=$1
appName=$2
specFolder="specs"
extension="yml"
specPathName="$specFolder/$appName.$extension"

doctl auth switch --context "$authContext"

GREEN_BG='\033[42;97m'
RED_BG='\033[41;97m'
GRAY_BG='\033[48;5;243;97m'
NC='\033[0m'

#### Version Check
versionCheck=$(node ./scripts/versions.js)
echo -e "$versionCheck"
if [ ! "$versionCheck" = "DigitalOceanApps up-to-date!" ]; then
  exit;
fi

# Get actual App ID
appId=$(getAppId "$appName")
echo -e "App ID: $appId"
echo -e "Spec: ./$specPathName"

if [[ ! $appId =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    echo -e "${RED_BG}App ID could not be found!${NC}"
    exit 1
fi

## Link to App
echo -e "DO Link >> https://cloud.digitalocean.com/apps/$appId/overview"

# Monitoring active deployment
while : ; do
    output=$(doctl apps get $appId --format InProgressDeployment.ID)
    active_deployment_id=$(echo "$output" | awk 'NR==2 {print $1}')

    if [[ -n "$active_deployment_id" ]]; then
        echo -ne "${GRAY_BG}♻️  > Pipeline is RUNNING....${NC}\r"

        deployment_output=$(doctl apps get-deployment $appId $active_deployment_id --no-header --format ID,Cause,Progress,Updated)

        if [[ $deployment_output == *"error"* ]]; then
            echo -e "${RED_BG}❌  > Pipeline is RED:${NC} $deployment_output"
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
        echo -ne "${GREEN_BG}✅  > Pipeline is GREEN.${NC}\r"
    fi

    sleep 2
done
