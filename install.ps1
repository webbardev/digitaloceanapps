# Create the .do directory if it doesn't exist
New-Item -ItemType Directory -Path ".do" -Force | Out-Null

# Navigate to the .do directory
Set-Location -Path ".do"

# Initialize a new Git repository
git init

# Add the remote repository
git remote add origin https://github.com/webbardev/digitaloceanapps.git

# Enable sparse checkout
git config core.sparseCheckout true

# Configure sparse checkout to include everything in boilerplate/.do, including hidden files
@"
boilerplate/.do/*
boilerplate/.do/.*
"@ | Set-Content .git\info\sparse-checkout

# Pull the specific path
git pull origin main

# Move the extracted files (including hidden files) to the current directory
Get-ChildItem -Path "boilerplate\.do" -File -Recurse -Force | ForEach-Object {
    Move-Item -Path $_.FullName -Destination (Join-Path -Path $PWD -ChildPath $_.Name) -Force
}

# Remove the temporary files and folders
Remove-Item -Recurse -Force "boilerplate", ".git"

# Confirm completion
Write-Host "Extraction complete, including hidden files like .gitignore!"
