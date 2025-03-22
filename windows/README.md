# Natsumi Browser Theme Installer - Instructions for the Version with Folder Selection

This guide explains how to install the Natsumi theme for Zen Browser using the improved version of the installer.

## New Features
- **Dynamic Folder Selection**: Select the Chrome folder of your Zen Browser profile through a graphical dialog
- **Intelligent Path Detection**: The script recognizes whether you have selected the correct "chrome" folder
- **Improved User Guidance**: Colored outputs and clear instructions during installation
- **Comprehensive Error Handling**: Detailed error messages and security prompts

## Requirements
- Windows 11
- Zen Browser
- PowerShell (included by default in Windows 11)
- Internet connection

## Installation
1. Save the files `Start-Natsumi-Installer-FolderPicker.bat` and `Install-Natsumi-FolderPicker.ps1` on your computer
2. Close the Zen Browser if it is open
3. Double-click on the file `Start-Natsumi-Installer-FolderPicker.bat`
4. A folder selection dialog will appear
5. Navigate to your Zen Browser profile folder and select the "chrome" folder
   - By default, this is located at `C:\Users\[Username]\AppData\Roaming\zen\Profiles\[Profilename]\chrome`
   - If you select a parent folder, the script will ask if it should use the "chrome" subfolder
6. Follow the on-screen instructions
7. After the installation is complete, restart the Zen Browser

## Notes
- Existing files are backed up before changes (with .backup extension)
- Temporary files are automatically removed after installation
- The script displays colored status messages during installation

## Troubleshooting
If problems occur:
- Make sure the Zen Browser is closed during installation
- Ensure you have administrator privileges
- Check your internet connection, as the script needs to download files from GitHub
- If you are unsure which folder to select, choose the parent folder and let the script create the "chrome" subfolder