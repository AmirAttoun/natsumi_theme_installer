# Natsumi Browser Theme Installer - PowerShell Version
# This script installs the Natsumi theme for Zen Browser

# Function to display colored messages
function Write-ColorMessage {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Display title
Write-ColorMessage "Natsumi Browser Theme Installer" -Color "Cyan"
Write-ColorMessage "==============================" -Color "Cyan"
Write-Host ""

# Display folder selection dialog
Write-ColorMessage "Please select the Chrome folder of your Zen Browser profile..." -Color "Yellow"
Write-Host "A dialog window will open to select the folder."
Write-Host ""

# Add Windows Forms library for folder selection dialog
Add-Type -AssemblyName System.Windows.Forms

# Create folder selection dialog
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$FolderBrowser.Description = "Select the Chrome folder of your Zen Browser profile"
$FolderBrowser.RootFolder = [System.Environment+SpecialFolder]::UserProfile
$FolderBrowser.ShowNewFolderButton = $true

# Suggest default path
$DefaultPath = "C:\Users\$env:USERNAME\AppData\Roaming\zen\Profiles"
if (Test-Path $DefaultPath) {
    $FolderBrowser.SelectedPath = $DefaultPath
}

# Display dialog and check result
$DialogResult = $FolderBrowser.ShowDialog()

if ($DialogResult -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-ColorMessage "Folder selection canceled. Installation aborted." -Color "Red"
    Write-Host "Press any key to close this window..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Use selected path
$ChromeDir = $FolderBrowser.SelectedPath

# Check if the selected folder is named "chrome", if not, add "\chrome"
if (-not $ChromeDir.EndsWith("\chrome")) {
    $ChromeParent = $ChromeDir
    $ChromeDir = Join-Path -Path $ChromeDir -ChildPath "chrome"

    # Ask the user if they want to create the chrome subfolder
    Write-ColorMessage "The selected folder is not the 'chrome' folder." -Color "Yellow"
    Write-ColorMessage "Do you want to use the folder '$ChromeDir'?" -Color "Yellow"
    Write-Host "Press Y for Yes or N for No..."

    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.Character -ne 'y' -and $key.Character -ne 'Y') {
        Write-ColorMessage "Installation canceled." -Color "Red"
        Write-Host "Press any key to close this window..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
}

Write-ColorMessage "Selected Chrome folder: $ChromeDir" -Color "Green"
Write-Host ""

# Check if the Chrome directory exists
if (-not (Test-Path $ChromeDir)) {
    Write-ColorMessage "Creating Chrome directory: $ChromeDir" -Color "Yellow"
    New-Item -Path $ChromeDir -ItemType Directory -Force | Out-Null
}

# Create temporary directory for download
$TempDir = [System.IO.Path]::Combine($env:TEMP, "natsumi_temp")
Write-ColorMessage "Creating temporary directory: $TempDir" -Color "Yellow"
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}
New-Item -Path $TempDir -ItemType Directory -Force | Out-Null
Set-Location -Path $TempDir

try {
    # Download repository
    Write-ColorMessage "Downloading Natsumi Browser theme files..." -Color "Yellow"
    Invoke-WebRequest -Uri "https://github.com/greeeen-dev/natsumi-browser/archive/refs/heads/main.zip" -OutFile "natsumi.zip"

    # Extract ZIP file
    Write-ColorMessage "Extracting files..." -Color "Yellow"
    Expand-Archive -Path "natsumi.zip" -DestinationPath "."

    # Check if userChrome.css already exists
    $UserChromeExists = Test-Path "$ChromeDir\userChrome.css"
    if ($UserChromeExists) {
        Write-ColorMessage "Existing userChrome.css found." -Color "Green"
    } else {
        Write-ColorMessage "No existing userChrome.css found." -Color "Yellow"
    }

    # Check if userContent.css already exists
    $UserContentExists = Test-Path "$ChromeDir\userContent.css"
    if ($UserContentExists) {
        Write-ColorMessage "Existing userContent.css found." -Color "Green"
    } else {
        Write-ColorMessage "No existing userContent.css found." -Color "Yellow"
    }

    # Create natsumi folder in Chrome directory if it doesn't exist
    if (-not (Test-Path "$ChromeDir\natsumi")) {
        Write-ColorMessage "Creating natsumi folder..." -Color "Yellow"
        New-Item -Path "$ChromeDir\natsumi" -ItemType Directory -Force | Out-Null
    }

    # Create natsumi-pages folder in Chrome directory if it doesn't exist
    if (-not (Test-Path "$ChromeDir\natsumi-pages")) {
        Write-ColorMessage "Creating natsumi-pages folder..." -Color "Yellow"
        New-Item -Path "$ChromeDir\natsumi-pages" -ItemType Directory -Force | Out-Null
    }

    # Copy natsumi-config.css to Chrome directory
    Write-ColorMessage "Copying natsumi-config.css to Chrome directory..." -Color "Yellow"
    Copy-Item -Path "$TempDir\natsumi-browser-main\natsumi-config.css" -Destination $ChromeDir -Force

    # Copy natsumi folder contents to Chrome directory
    Write-ColorMessage "Copying natsumi folder contents to Chrome directory..." -Color "Yellow"
    Copy-Item -Path "$TempDir\natsumi-browser-main\natsumi\*" -Destination "$ChromeDir\natsumi\" -Recurse -Force

    # Copy natsumi-pages folder contents to Chrome directory
    Write-ColorMessage "Copying natsumi-pages folder contents to Chrome directory..." -Color "Yellow"
    Copy-Item -Path "$TempDir\natsumi-browser-main\natsumi-pages\*" -Destination "$ChromeDir\natsumi-pages\" -Recurse -Force

    # Create import lines
    $ImportLine = '@import "natsumi/natsumi.css";'
    $PagesImportLine = '@import "natsumi-pages/natsumi-pages.css";'

    # Handle userChrome.css based on whether it exists
    if ($UserChromeExists) {
        # Backup existing userChrome.css
        Write-ColorMessage "Backing up existing userChrome.css..." -Color "Yellow"
        Copy-Item -Path "$ChromeDir\userChrome.css" -Destination "$ChromeDir\userChrome.css.backup" -Force

        # Check if the import line already exists in userChrome.css
        $UserChromeContent = Get-Content -Path "$ChromeDir\userChrome.css" -Raw
        if (-not $UserChromeContent.Contains($ImportLine)) {
            # Add import line to the beginning of userChrome.css
            Write-ColorMessage "Adding import line to existing userChrome.css..." -Color "Yellow"
            $NewContent = "$ImportLine`r`n$UserChromeContent"
            Set-Content -Path "$ChromeDir\userChrome.css" -Value $NewContent -Force
        } else {
            Write-ColorMessage "Import line already exists in userChrome.css." -Color "Green"
        }
    } else {
        # Copy userChrome.css from the repository
        Write-ColorMessage "Copying userChrome.css to Chrome directory..." -Color "Yellow"
        Copy-Item -Path "$TempDir\natsumi-browser-main\userChrome.css" -Destination $ChromeDir -Force
    }

    # Handle userContent.css based on whether it exists
    if ($UserContentExists) {
        # Backup existing userContent.css
        Write-ColorMessage "Backing up existing userContent.css..." -Color "Yellow"
        Copy-Item -Path "$ChromeDir\userContent.css" -Destination "$ChromeDir\userContent.css.backup" -Force

        # Check if the import line already exists in userContent.css
        $UserContentContent = Get-Content -Path "$ChromeDir\userContent.css" -Raw
        if (-not $UserContentContent.Contains($PagesImportLine)) {
            # Add import line to the beginning of userContent.css
            Write-ColorMessage "Adding import line to existing userContent.css..." -Color "Yellow"
            $NewContent = "$PagesImportLine`r`n$UserContentContent"
            Set-Content -Path "$ChromeDir\userContent.css" -Value $NewContent -Force
        } else {
            Write-ColorMessage "Import line already exists in userContent.css." -Color "Green"
        }
    } else {
        # Copy userContent.css from the repository
        Write-ColorMessage "Copying userContent.css to Chrome directory..." -Color "Yellow"
        Copy-Item -Path "$TempDir\natsumi-browser-main\userContent.css" -Destination $ChromeDir -Force
    }

    # Clean up temporary directory
    Write-ColorMessage "Cleaning up temporary files..." -Color "Yellow"
    Set-Location -Path $env:USERPROFILE
    Remove-Item -Path $TempDir -Recurse -Force

    Write-Host ""
    Write-ColorMessage "Installation complete!" -Color "Green"
    Write-ColorMessage "Natsumi Browser theme has been installed to: $ChromeDir" -Color "Green"
    Write-Host ""
    Write-ColorMessage "Please restart Zen Browser to apply the theme." -Color "Cyan"
    Write-Host ""

} catch {
    Write-Host ""
    Write-ColorMessage "An error occurred: $_" -Color "Red"
    Write-ColorMessage "The installation may not have been completed successfully." -Color "Red"
    Write-ColorMessage "Please check the error messages above and try again." -Color "Red"
    Write-Host ""
}

# Wait for user input before closing the window
Write-Host "Press any key to close this window..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
