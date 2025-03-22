#!/bin/bash

# Natsumi Browser Theme Installer - macOS Version
# This script installs the Natsumi theme for Zen Browser on macOS

# Function to display colored messages
print_message() {
  local message="$1"
  local color="$2"

  case "$color" in
    "green") echo -e "\033[0;32m$message\033[0m" ;;
    "yellow") echo -e "\033[0;33m$message\033[0m" ;;
    "red") echo -e "\033[0;31m$message\033[0m" ;;
    "cyan") echo -e "\033[0;36m$message\033[0m" ;;
    *) echo "$message" ;;
  esac
}

# Display title
print_message "Natsumi Browser Theme Installer for macOS" "cyan"
print_message "=======================================" "cyan"
echo ""

# Folder selection dialog with AppleScript
print_message "Please select the Chrome folder of your Zen Browser profile..." "yellow"
echo "A dialog window will open to select the folder."
echo ""

# Default path for Zen Browser on macOS
DEFAULT_PATH="$HOME/Library/Application Support/zen/Profiles"

# AppleScript for folder selection
CHROME_DIR=$(osascript <<EOF
set defaultPath to "$DEFAULT_PATH"
set dialogText to "Select the Chrome folder of your Zen Browser profile"
set buttonText to "Select"

tell application "System Events"
    if exists folder defaultPath then
        set defaultFolder to defaultPath
    else
        set defaultFolder to path to home folder
    end if
end tell

tell application "Finder"
    activate
    set selectedFolder to POSIX path of (choose folder with prompt dialogText default location defaultFolder with showing package contents)
    return selectedFolder
end tell
EOF
)

# Check if dialog was canceled
if [ -z "$CHROME_DIR" ]; then
    print_message "Folder selection canceled. Installation aborted." "red"
    echo "Press Enter to close this window..."
    read
    exit 1
fi

# Check if the selected folder is named "chrome", if not, add "/chrome"
if [[ ! "$CHROME_DIR" == */chrome ]]; then
    CHROME_PARENT="$CHROME_DIR"
    CHROME_DIR="${CHROME_DIR%/}/chrome"

    # Ask the user if they want to create the chrome subfolder
    print_message "The selected folder is not the 'chrome' folder." "yellow"
    print_message "Do you want to use the folder '$CHROME_DIR'? (y/n)" "yellow"

    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "Installation canceled." "red"
        echo "Press Enter to close this window..."
        read
        exit 1
    fi
fi

print_message "Selected Chrome folder: $CHROME_DIR" "green"
echo ""

# Check if the Chrome directory exists
if [ ! -d "$CHROME_DIR" ]; then
    print_message "Creating Chrome directory: $CHROME_DIR" "yellow"
    mkdir -p "$CHROME_DIR"
fi

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
print_message "Creating temporary directory: $TEMP_DIR" "yellow"
cd "$TEMP_DIR"

# Download repository
print_message "Downloading Natsumi Browser theme files..." "yellow"
curl -L -o natsumi.zip https://github.com/greeeen-dev/natsumi-browser/archive/refs/heads/main.zip

if [ $? -ne 0 ]; then
    print_message "Error downloading files. Please check your internet connection." "red"
    echo "Press Enter to close this window..."
    read
    exit 1
fi

# Extract ZIP file
print_message "Extracting files..." "yellow"
unzip -q natsumi.zip

if [ $? -ne 0 ]; then
    print_message "Error extracting files." "red"
    echo "Press Enter to close this window..."
    read
    exit 1
fi

# Check if userChrome.css already exists
USERCHROME_EXISTS=0
if [ -f "$CHROME_DIR/userChrome.css" ]; then
    USERCHROME_EXISTS=1
    print_message "Existing userChrome.css found." "green"
else
    print_message "No existing userChrome.css found." "yellow"
fi

# Check if userContent.css already exists
USERCONTENT_EXISTS=0
if [ -f "$CHROME_DIR/userContent.css" ]; then
    USERCONTENT_EXISTS=1
    print_message "Existing userContent.css found." "green"
else
    print_message "No existing userContent.css found." "yellow"
fi

# Create natsumi folder in Chrome directory if it doesn't exist
if [ ! -d "$CHROME_DIR/natsumi" ]; then
    print_message "Creating natsumi folder..." "yellow"
    mkdir -p "$CHROME_DIR/natsumi"
fi

# Create natsumi-pages folder in Chrome directory if it doesn't exist
if [ ! -d "$CHROME_DIR/natsumi-pages" ]; then
    print_message "Creating natsumi-pages folder..." "yellow"
    mkdir -p "$CHROME_DIR/natsumi-pages"
fi

# Copy natsumi-config.css to Chrome directory
print_message "Copying natsumi-config.css to Chrome directory..." "yellow"
cp "$TEMP_DIR/natsumi-browser-main/natsumi-config.css" "$CHROME_DIR/"

if [ $? -ne 0 ]; then
    print_message "Error copying natsumi-config.css." "red"
    echo "Press Enter to close this window..."
    read
    exit 1
fi

# Copy natsumi folder contents to Chrome directory
print_message "Copying natsumi folder contents to Chrome directory..." "yellow"
cp -R "$TEMP_DIR/natsumi-browser-main/natsumi/"* "$CHROME_DIR/natsumi/"

if [ $? -ne 0 ]; then
    print_message "Error copying natsumi folder." "red"
    echo "Press Enter to close this window..."
    read
    exit 1
fi

# Copy natsumi-pages folder contents to Chrome directory
print_message "Copying natsumi-pages folder contents to Chrome directory..." "yellow"
cp -R "$TEMP_DIR/natsumi-browser-main/natsumi-pages/"* "$CHROME_DIR/natsumi-pages/"

if [ $? -ne 0 ]; then
    print_message "Error copying natsumi-pages folder." "red"
    echo "Press Enter to close this window..."
    read
    exit 1
fi

# Create import lines
IMPORT_LINE='@import "natsumi/natsumi.css";'
PAGES_IMPORT_LINE='@import "natsumi-pages/natsumi-pages.css";'

# Handle userChrome.css based on whether it exists
if [ $USERCHROME_EXISTS -eq 1 ]; then
    # Backup existing userChrome.css
    print_message "Backing up existing userChrome.css..." "yellow"
    cp "$CHROME_DIR/userChrome.css" "$CHROME_DIR/userChrome.css.backup"

    # Check if the import line already exists in userChrome.css
    if ! grep -q "$IMPORT_LINE" "$CHROME_DIR/userChrome.css"; then
        # Add import line to the beginning of userChrome.css
        print_message "Adding import line to existing userChrome.css..." "yellow"
        echo "$IMPORT_LINE" > "$TEMP_DIR/temp_combined.txt"
        cat "$CHROME_DIR/userChrome.css" >> "$TEMP_DIR/temp_combined.txt"
        mv "$TEMP_DIR/temp_combined.txt" "$CHROME_DIR/userChrome.css"
    else
        print_message "Import line already exists in userChrome.css." "green"
    fi
else
    # Copy userChrome.css from the repository
    print_message "Copying userChrome.css to Chrome directory..." "yellow"
    cp "$TEMP_DIR/natsumi-browser-main/userChrome.css" "$CHROME_DIR/"

    if [ $? -ne 0 ]; then
        print_message "Error copying userChrome.css." "red"
        echo "Press Enter to close this window..."
        read
        exit 1
    fi
fi

# Handle userContent.css based on whether it exists
if [ $USERCONTENT_EXISTS -eq 1 ]; then
    # Backup existing userContent.css
    print_message "Backing up existing userContent.css..." "yellow"
    cp "$CHROME_DIR/userContent.css" "$CHROME_DIR/userContent.css.backup"

    # Check if the import line already exists in userContent.css
    if ! grep -q "$PAGES_IMPORT_LINE" "$CHROME_DIR/userContent.css"; then
        # Add import line to the beginning of userContent.css
        print_message "Adding import line to existing userContent.css..." "yellow"
        echo "$PAGES_IMPORT_LINE" > "$TEMP_DIR/temp_content_combined.txt"
        cat "$CHROME_DIR/userContent.css" >> "$TEMP_DIR/temp_content_combined.txt"
        mv "$TEMP_DIR/temp_content_combined.txt" "$CHROME_DIR/userContent.css"
    else
        print_message "Import line already exists in userContent.css." "green"
    fi
else
    # Copy userContent.css from the repository
    print_message "Copying userContent.css to Chrome directory..." "yellow"
    cp "$TEMP_DIR/natsumi-browser-main/userContent.css" "$CHROME_DIR/"

    if [ $? -ne 0 ]; then
        print_message "Error copying userContent.css." "red"
        echo "Press Enter to close this window..."
        read
        exit 1
    fi
fi

# Clean up temporary directory
print_message "Cleaning up temporary files..." "yellow"
rm -rf "$TEMP_DIR"

echo ""
print_message "Installation complete!" "green"
print_message "Natsumi Browser theme has been installed to: $CHROME_DIR" "green"
echo ""
print_message "Please restart Zen Browser to apply the theme." "cyan"
echo ""

# Wait for user input before closing the window
echo "Press Enter to close this window..."
read
