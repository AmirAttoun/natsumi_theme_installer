# Natsumi Browser Theme Installer - Combined Instructions

This guide explains how to install the Natsumi theme for Zen Browser on both Windows 11 and macOS platforms.

## Features
- **Dynamic Folder Selection**: Select the Chrome folder of your Zen Browser profile through a graphical dialog
- **Intelligent Path Detection**: The script recognizes whether you have selected the correct "chrome" folder
- **Improved User Guidance**: Colored outputs and clear instructions during installation
- **Comprehensive Error Handling**: Detailed error messages and security prompts

## Common Requirements
- Zen Browser
- Internet connection
- Browser must be closed during installation

## Windows 11 Installation

### Requirements
- Windows 11
- PowerShell (included by default in Windows 11)

### Installation Steps
1. Save the files `Start-Natsumi-Installer-FolderPicker.bat` and `Install-Natsumi-FolderPicker.ps1` on your computer
2. Close the Zen Browser if it is open
3. Double-click on the file `Start-Natsumi-Installer-FolderPicker.bat`
4. A folder selection dialog will appear
5. Navigate to your Zen Browser profile folder and select the "chrome" folder
   - By default, this is located at `C:\Users\[Username]\AppData\Roaming\zen\Profiles\[Profilename]\chrome`
   - If you select a parent folder, the script will ask if it should use the "chrome" subfolder
6. Follow the on-screen instructions
7. After the installation is complete, restart the Zen Browser

## macOS Installation

### Requirements
- macOS
- Terminal access

### Installation Steps
1. Save the file `install_natsumi_macos.sh` on your computer
2. Open Terminal
3. Make the script executable with the command:
   ```
   chmod +x /path/to/install_natsumi_macos.sh
   ```
4. Close the Zen Browser if it is open
5. Run the script:
   ```
   /path/to/install_natsumi_macos.sh
   ```
6. A folder selection dialog will appear
7. Navigate to your Zen Browser profile folder and select the "chrome" folder
   - By default, this is located at `~/Library/Application Support/zen/Profiles/[Profilename]/chrome`
   - If you select a parent folder, the script will ask if it should use the "chrome" subfolder
8. Follow the on-screen instructions
9. After the installation is complete, restart the Zen Browser

### Alternative Execution Method for macOS
You can also run the script directly from Finder:
1. Open Finder and navigate to the location of the script
2. Right-click on the file `install_natsumi_macos.sh`
3. Select "Open with" > "Terminal"

## Notes
- Existing files are backed up before changes (with .backup extension)
- Temporary files are automatically removed after installation
- The script displays colored status messages during installation

## Troubleshooting

### Windows Troubleshooting
- Make sure the Zen Browser is closed during installation
- Ensure you have administrator privileges
- Check your internet connection, as the script needs to download files from GitHub
- If you are unsure which folder to select, choose the parent folder and let the script create the "chrome" subfolder

### macOS Troubleshooting
- Make sure the Zen Browser is closed during installation
- Ensure the script has executable permissions (chmod +x)
- Check your internet connection, as the script needs to download files from GitHub
- If you are unsure which folder to select, choose the parent folder and let the script create the "chrome" subfolder
