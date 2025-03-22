#!/bin/bash

# Natsumi Browser Theme Installer - macOS Version
# Dieses Skript installiert das Natsumi-Theme für den Zen Browser auf macOS

# Funktion zum Anzeigen von farbigen Nachrichten
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

# Titel anzeigen
print_message "Natsumi Browser Theme Installer für macOS" "cyan"
print_message "=======================================" "cyan"
echo ""

# Ordnerauswahldialog mit AppleScript
print_message "Bitte wählen Sie den Chrome-Ordner Ihres Zen Browser-Profils..." "yellow"
echo "Ein Dialogfenster wird geöffnet, um den Ordner auszuwählen."
echo ""

# Standardpfad für Zen Browser auf macOS
DEFAULT_PATH="$HOME/Library/Application Support/zen/Profiles"

# AppleScript für Ordnerauswahl
CHROME_DIR=$(osascript <<EOF
set defaultPath to "$DEFAULT_PATH"
set dialogText to "Wählen Sie den Chrome-Ordner Ihres Zen Browser-Profils"
set buttonText to "Auswählen"

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

# Prüfen, ob der Dialog abgebrochen wurde
if [ -z "$CHROME_DIR" ]; then
    print_message "Ordnerauswahl abgebrochen. Installation wird beendet." "red"
    echo "Drücken Sie die Eingabetaste, um das Fenster zu schließen..."
    read
    exit 1
fi

# Prüfen, ob der ausgewählte Ordner "chrome" heißt, wenn nicht, füge "/chrome" hinzu
if [[ ! "$CHROME_DIR" == */chrome ]]; then
    CHROME_PARENT="$CHROME_DIR"
    CHROME_DIR="${CHROME_DIR%/}/chrome"

    # Frage den Benutzer, ob er den chrome-Unterordner erstellen möchte
    print_message "Der ausgewählte Ordner ist nicht der 'chrome'-Ordner." "yellow"
    print_message "Möchten Sie den Ordner '$CHROME_DIR' verwenden? (j/n)" "yellow"

    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Jj]$ ]]; then
        print_message "Installation abgebrochen." "red"
        echo "Drücken Sie die Eingabetaste, um das Fenster zu schließen..."
        read
        exit 1
    fi
fi

print_message "Ausgewählter Chrome-Ordner: $CHROME_DIR" "green"
echo ""

# Prüfen, ob das Chrome-Verzeichnis existiert
if [ ! -d "$CHROME_DIR" ]; then
    print_message "Chrome-Verzeichnis wird erstellt: $CHROME_DIR" "yellow"
    mkdir -p "$CHROME_DIR"
fi

# Temporäres Verzeichnis für den Download erstellen
TEMP_DIR=$(mktemp -d)
print_message "Temporäres Verzeichnis wird erstellt: $TEMP_DIR" "yellow"
cd "$TEMP_DIR"

# Repository herunterladen
print_message "Natsumi Browser Theme-Dateien werden heruntergeladen..." "yellow"
curl -L -o natsumi.zip https://github.com/greeeen-dev/natsumi-browser/archive/refs/heads/main.zip

if [ $? -ne 0 ]; then
    print_message "Fehler beim Herunterladen der Dateien. Bitte überprüfen Sie Ihre Internetverbindung." "red"
    echo "Drücken Sie die Eingabetaste, um das Fenster zu schließen..."
    read
    exit 1
fi

# ZIP-Datei extrahieren
print_message "Dateien werden entpackt..." "yellow"
unzip -q natsumi.zip

if [ $? -ne 0 ]; then
    print_message "Fehler beim Entpacken der Dateien." "red"
    echo "Drücken Sie die Eingabetaste, um das Fenster zu schließen..."
    read
    exit 1
fi

# Prüfen, ob userChrome.css bereits existiert
USERCHROME_EXISTS=0
if [ -f "$CHROME_DIR/userChrome.css" ]; then
    USERCHROME_EXISTS=1
    print_message "Vorhandene userChrome.css gefunden." "green"
else
    print_message "Keine vorhandene userChrome.css gefunden." "yellow"
fi

# Prüfen, ob userContent.css bereits existiert
USERCONTENT_EXISTS=0
if [ -f "$CHROME_DIR/userContent.css" ]; then
    USERCONTENT_EXISTS=1
    print_message "Vorhandene userContent.css gefunden." "green"
else
    print_message "Keine vorhandene userContent.css gefunden." "yellow"
fi

# natsumi-Ordner im Chrome-Verzeichnis erstellen, falls er nicht existiert
if [ ! -d "$CHROME_DIR/natsumi" ]; then
    print_message "natsumi-Ordner wird erstellt..." "yellow"
    mkdir -p "$CHROME_DIR/natsumi"
fi

# natsumi-pages-Ordner im Chrome-Verzeichnis erstellen, falls er nicht existiert
if [ ! -d "$CHROME_DIR/natsumi-pages" ]; then
    print_message "natsumi-pages-Ordner wird erstellt..." "yellow"
    mkdir -p "$CHROME_DIR/natsumi-pages"
fi

# natsumi-config.css in das Chrome-Verzeichnis kopieren
print_message "natsumi-config.css wird in das Chrome-Verzeichnis kopiert..." "yellow"
cp "$TEMP_DIR/natsumi-browser-main/natsumi-config.css" "$CHROME_DIR/"

if [ $? -ne 0 ]; then
    print_message "Fehler beim Kopieren von natsumi-config.css." "red"
    echo "Drücken Sie die Eingabetaste, um das Fenster zu schließen..."
    read
    exit 1
fi

# natsumi-Ordnerinhalte in das Chrome-Verzeichnis kopieren
print_message "natsumi-Ordnerinhalte werden in das Chrome-Verzeichnis kopiert..." "yellow"
cp -R "$TEMP_DIR/natsumi-browser-main/natsumi/"* "$CHROME_DIR/natsumi/"

if [ $? -ne 0 ]; then
    print_message "Fehler beim Kopieren des natsumi-Ordners." "red"
    echo "Drücken Sie die Eingabetaste, um das Fenster zu schließen..."
    read
    exit 1
fi

# natsumi-pages-Ordnerinhalte in das Chrome-Verzeichnis kopieren
print_message "natsumi-pages-Ordnerinhalte werden in das Chrome-Verzeichnis kopiert..." "yellow"
cp -R "$TEMP_DIR/natsumi-browser-main/natsumi-pages/"* "$CHROME_DIR/natsumi-pages/"

if [ $? -ne 0 ]; then
    print_message "Fehler beim Kopieren des natsumi-pages-Ordners." "red"
    echo "Drücken Sie die Eingabetaste, um das Fenster zu schließen..."
    read
    exit 1
fi

# Import-Zeilen erstellen
IMPORT_LINE='@import "natsumi/natsumi.css";'
PAGES_IMPORT_LINE='@import "natsumi-pages/natsumi-pages.css";'

# userChrome.css behandeln, je nachdem, ob sie existiert
if [ $USERCHROME_EXISTS -eq 1 ]; then
    # Vorhandene userChrome.css sichern
    print_message "Vorhandene userChrome.css wird gesichert..." "yellow"
    cp "$CHROME_DIR/userChrome.css" "$CHROME_DIR/userChrome.css.backup"

    # Prüfen, ob die Import-Zeile bereits in userChrome.css existiert
    if ! grep -q "$IMPORT_LINE" "$CHROME_DIR/userChrome.css"; then
        # Import-Zeile am Anfang von userChrome.css hinzufügen
        print_message "Import-Zeile wird zur vorhandenen userChrome.css hinzugefügt..." "yellow"
        echo "$IMPORT_LINE" > "$TEMP_DIR/temp_combined.txt"
        cat "$CHROME_DIR/userChrome.css" >> "$TEMP_DIR/temp_combined.txt"
        mv "$TEMP_DIR/temp_combined.txt" "$CHROME_DIR/userChrome.css"
    else
        print_message "Import-Zeile existiert bereits in userChrome.css." "green"
    fi
else
    # userChrome.css aus dem Repository kopieren
    print_message "userChrome.css wird in das Chrome-Verzeichnis kopiert..." "yellow"
    cp "$TEMP_DIR/natsumi-browser-main/userChrome.css" "$CHROME_DIR/"

    if [ $? -ne 0 ]; then
        print_message "Fehler beim Kopieren von userChrome.css." "red"
        echo "Drücken Sie die Eingabetaste, um das Fenster zu schließen..."
        read
        exit 1
    fi
fi

# userContent.css behandeln, je nachdem, ob sie existiert
if [ $USERCONTENT_EXISTS -eq 1 ]; then
    # Vorhandene userContent.css sichern
    print_message "Vorhandene userContent.css wird gesichert..." "yellow"
    cp "$CHROME_DIR/userContent.css" "$CHROME_DIR/userContent.css.backup"

    # Prüfen, ob die Import-Zeile bereits in userContent.css existiert
    if ! grep -q "$PAGES_IMPORT_LINE" "$CHROME_DIR/userContent.css"; then
        # Import-Zeile am Anfang von userContent.css hinzufügen
        print_message "Import-Zeile wird zur vorhandenen userContent.css hinzugefügt..." "yellow"
        echo "$PAGES_IMPORT_LINE" > "$TEMP_DIR/temp_content_combined.txt"
        cat "$CHROME_DIR/userContent.css" >> "$TEMP_DIR/temp_content_combined.txt"
        mv "$TEMP_DIR/temp_content_combined.txt" "$CHROME_DIR/userContent.css"
    else
        print_message "Import-Zeile existiert bereits in userContent.css." "green"
    fi
else
    # userContent.css aus dem Repository kopieren
    print_message "userContent.css wird in das Chrome-Verzeichnis kopiert..." "yellow"
    cp "$TEMP_DIR/natsumi-browser-main/userContent.css" "$CHROME_DIR/"

    if [ $? -ne 0 ]; then
        print_message "Fehler beim Kopieren von userContent.css." "red"
        echo "Drücken Sie die Eingabetaste, um das Fenster zu schließen..."
        read
        exit 1
    fi
fi

# Temporäres Verzeichnis bereinigen
print_message "Temporäre Dateien werden bereinigt..." "yellow"
rm -rf "$TEMP_DIR"

echo ""
print_message "Installation abgeschlossen!" "green"
print_message "Natsumi Browser Theme wurde installiert in: $CHROME_DIR" "green"
echo ""
print_message "Bitte starten Sie den Zen Browser neu, um das Theme anzuwenden." "cyan"
echo ""

# Warten auf Benutzereingabe, bevor das Fenster geschlossen wird
echo "Drücken Sie die Eingabetaste, um das Fenster zu schliessen..."
read
