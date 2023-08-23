const https = require('https');
const fs = require('fs');
const path = require('path');

const REMOTE_FILE_URL = 'https://raw.githubusercontent.com/webbardev/digitaloceanapps/main/package.json';
const LOCAL_FILE_PATH = path.join(__dirname, "..",'node_modules', 'digitaloceanapps', 'package.json');

https.get(REMOTE_FILE_URL, (response) => {
    let data = '';

    response.on('data', (chunk) => {
        data += chunk;
    });

    response.on('end', () => {
        const remoteVersion = JSON.parse(data).version;

        fs.readFile(LOCAL_FILE_PATH, 'utf8', (err, localData) => {
            if (err) {
                console.error('Error reading local file:', err);
                return;
            }

            const localVersion = JSON.parse(localData).version;

            if (remoteVersion !== localVersion) {
                console.log("Please update the DigitalOceanApps repo with npm update && npm install");
                process.exit(1);
            } else {
                console.log("DigitalOceanApps up-to-date!");
            }
        });
    });
}).on('error', (err) => {
    console.error('Error fetching remote file:', err);
});
