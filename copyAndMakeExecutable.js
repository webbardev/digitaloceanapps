const fs = require("fs-extra");
const shell = require("shelljs");
const path = require("path");

async function copyFolderAndMakeFilesExecutable(src, dest) {
  try {
    // Copy the entire folder
    await fs.copy(src, dest);

    // Iterate through the files in the folder and make them executable
    const files = fs.readdirSync(dest);
    for (let file of files) {
      const filePath = path.join(dest, file);
      if (fs.statSync(filePath).isFile()) {
        shell.chmod("+x", filePath);
      }
    }

    console.log(`Folder copied and files made executable: ${dest}`);
  } catch (err) {
    console.error("Error:", err);
  }
}

// Example Usage
const sourcePath = "./node_modules/digitaloceanapps/scripts";
const destPath = "./scripts";
copyFolderAndMakeFilesExecutable(sourcePath, destPath);
