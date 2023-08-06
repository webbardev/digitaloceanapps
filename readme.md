## Installation

1: Add Package from public github 
``"digitaloceanapps":"github:webbardev/digitaloceanapps"``

2: run install
``npm install``
Note: If you want to update with ``npm update`` you should run install afterward to trigger postinstall.

3: Add postinstall script and
``
"stageget": "./scripts/getspec.sh <AUTH-CONTEXT> staging",
"stageupdate": "./scripts/updatespec.sh <AUTH-CONTEXT> staging",
"postinstall": "cp -r node_modules/digitaloceanapps/scripts ."
``

4: Execute
``npm run stageget``
 
