#!/bin/bash

# Create the .do directory if it doesn't exist
mkdir -p .do

# Navigate to the .do directory
cd .do || exit

# Extract the contents from the GitHub repository without checking out the entire repository
git init
git remote add origin https://github.com/webbardev/digitaloceanapps.git
git config core.sparseCheckout true

# Configure sparse checkout to include everything in boilerplate/.do, including hidden files
cat <<EOF > .git/info/sparse-checkout
boilerplate/.do/*
boilerplate/.do/.*
EOF

# Pull the specific path
git pull origin main

# Move the extracted files to the current directory and clean up
mv boilerplate/.do/* . 2>/dev/null
mv boilerplate/.do/.* . 2>/dev/null
rm -rf boilerplate .git

npm install

git add .

echo "Extraction complete, including hidden files like .gitignore!"
