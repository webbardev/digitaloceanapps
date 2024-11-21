# Installation

1: Copy install.sh (or install.ps1) to your root directory.
Note: The installation will temporarily create a .git installation and removes it. 
This is for extracting the files from the repository. 
It will run "git add ." in the end of the script to add it to your current repository.
If you don't want this, please remove the last line in the script.

2: The following will install a .do folder with a skeleton structure and demo scripts.

For Shell:
````
chmod +x install.sh && ./install.sh
````

For PowerShell:
```
.\install.ps1
```

3.1: Install doctl
https://docs.digitalocean.com/reference/doctl/how-to/install/

3.1: Create an Auth Context
Create a doctl auth context. Recommend to name it like your current team name in DO.
Note: The Team name is the name on the top-right corner of the DigitalOcean Cloud UI.

3.2: Update the package.json scripts with Auth Context and App Names:
```
"test-get": "./scripts/getspec.sh AUTH-CONTEXT-NAME APP-NAME-IN-DO",
"test-update": "./scripts/updatespec AUTH-CONTEXT-NAME APP-NAME-IN-DO",
```

4.1: Execute GET
This will pull the current app spec to /specs folder
````
npm run test-get
````

4.1: Execute GET
This will compare & update the current app spec and create a backup in /backups folder
Note: Comparing might not work in Powershell.
````
npm run test-update
````

5. Updating the structure
This will pull the newest scripts
```
npm update && npm install
```

## Folder Structure
````
.do
    /scripts    # Read-Only, the scripts
    /backups    # Read-Only, automated backups
    /specs       # App-Specs defined by each instance. Filenames should be App-Names
````


