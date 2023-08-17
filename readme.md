## Installation

1: Add Package from public github 
````
"digitaloceanapps":"github:webbardev/digitaloceanapps"
````

2: run install
``npm install``
Note: If you want to update with ``npm update`` you should run install afterward to trigger postinstall.

3.1: Create a doctl auth context for the <DO-Team-Name>
Note: The Team name is the name on the top-right corner of the DigitalOcean Cloud UI.

3.2: Add postinstall script and
````
"stage-get": "./scripts/getspec.sh <AUTH-CONTEXT> staging",
"stage-update": "./scripts/updatespec.sh <AUTH-CONTEXT> staging",
"postinstall": "cp -r node_modules/digitaloceanapps/scripts ."
````

4: Execute
````
npm run stage-get
````

## Folder Structure
````
.do
    /scripts    # Read-Only, the scripts
    /backups    # Read-Only, automated backups
    /specs       # App-Specs defined by each instance. Filenames should be App-Names
````

