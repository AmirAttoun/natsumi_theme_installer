# Natsumi Browser Theme Installer - PowerShell Version
# Dieses Skript installiert das Natsumi-Theme für den Zen Browser

# Funktion zum Anzeigen von Nachrichten mit Farbe
function Write-ColorMessage {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Titel anzeigen
Write-ColorMessage "Natsumi Browser Theme Installer" -Color "Cyan"
Write-ColorMessage "==============================" -Color "Cyan"
Write-Host ""

# Ordnerauswahldialog anzeigen
Write-ColorMessage "Bitte wählen Sie den Chrome-Ordner Ihres Zen Browser-Profils..." -Color "Yellow"
Write-Host "Ein Dialogfenster wird geöffnet, um den Ordner auszuwählen."
Write-Host ""

# Füge die Windows Forms-Bibliothek hinzu für den Ordnerauswahldialog
Add-Type -AssemblyName System.Windows.Forms

# Erstelle den Ordnerauswahldialog
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$FolderBrowser.Description = "Wählen Sie den Chrome-Ordner Ihres Zen Browser-Profils"
$FolderBrowser.RootFolder = [System.Environment+SpecialFolder]::UserProfile
$FolderBrowser.ShowNewFolderButton = $true

# Standardpfad vorschlagen
$DefaultPath = "C:\Users\$env:USERNAME\AppData\Roaming\zen\Profiles"
if (Test-Path $DefaultPath) {
    $FolderBrowser.SelectedPath = $DefaultPath
}

# Dialog anzeigen und Ergebnis prüfen
$DialogResult = $FolderBrowser.ShowDialog()

if ($DialogResult -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-ColorMessage "Ordnerauswahl abgebrochen. Installation wird beendet." -Color "Red"
    Write-Host "Drücken Sie eine beliebige Taste, um das Fenster zu schließen..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Ausgewählten Pfad verwenden
$ChromeDir = $FolderBrowser.SelectedPath

# Prüfen, ob der ausgewählte Ordner "chrome" heißt, wenn nicht, füge "\chrome" hinzu
if (-not $ChromeDir.EndsWith("\chrome")) {
    $ChromeParent = $ChromeDir
    $ChromeDir = Join-Path -Path $ChromeDir -ChildPath "chrome"
    
    # Frage den Benutzer, ob er den chrome-Unterordner erstellen möchte
    Write-ColorMessage "Der ausgewählte Ordner ist nicht der 'chrome'-Ordner." -Color "Yellow"
    Write-ColorMessage "Möchten Sie den Ordner '$ChromeDir' verwenden?" -Color "Yellow"
    Write-Host "Drücken Sie J für Ja oder N für Nein..."
    
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.Character -ne 'j' -and $key.Character -ne 'J') {
        Write-ColorMessage "Installation abgebrochen." -Color "Red"
        Write-Host "Drücken Sie eine beliebige Taste, um das Fenster zu schließen..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
}

Write-ColorMessage "Ausgewählter Chrome-Ordner: $ChromeDir" -Color "Green"
Write-Host ""

# Prüfen, ob das Chrome-Verzeichnis existiert
if (-not (Test-Path $ChromeDir)) {
    Write-ColorMessage "Chrome-Verzeichnis wird erstellt: $ChromeDir" -Color "Yellow"
    New-Item -Path $ChromeDir -ItemType Directory -Force | Out-Null
}

# Temporäres Verzeichnis für den Download erstellen
$TempDir = [System.IO.Path]::Combine($env:TEMP, "natsumi_temp")
Write-ColorMessage "Temporäres Verzeichnis wird erstellt: $TempDir" -Color "Yellow"
if (Test-Path $TempDir) {
    Remove-Item -Path $TempDir -Recurse -Force
}
New-Item -Path $TempDir -ItemType Directory -Force | Out-Null
Set-Location -Path $TempDir

try {
    # Repository herunterladen
    Write-ColorMessage "Natsumi Browser Theme-Dateien werden heruntergeladen..." -Color "Yellow"
    Invoke-WebRequest -Uri "https://github.com/greeeen-dev/natsumi-browser/archive/refs/heads/main.zip" -OutFile "natsumi.zip"

    # ZIP-Datei extrahieren
    Write-ColorMessage "Dateien werden entpackt..." -Color "Yellow"
    Expand-Archive -Path "natsumi.zip" -DestinationPath "."

    # Prüfen, ob userChrome.css bereits existiert
    $UserChromeExists = Test-Path "$ChromeDir\userChrome.css"
    if ($UserChromeExists) {
        Write-ColorMessage "Vorhandene userChrome.css gefunden." -Color "Green"
    } else {
        Write-ColorMessage "Keine vorhandene userChrome.css gefunden." -Color "Yellow"
    }

    # Prüfen, ob userContent.css bereits existiert
    $UserContentExists = Test-Path "$ChromeDir\userContent.css"
    if ($UserContentExists) {
        Write-ColorMessage "Vorhandene userContent.css gefunden." -Color "Green"
    } else {
        Write-ColorMessage "Keine vorhandene userContent.css gefunden." -Color "Yellow"
    }

    # natsumi-Ordner im Chrome-Verzeichnis erstellen, falls er nicht existiert
    if (-not (Test-Path "$ChromeDir\natsumi")) {
        Write-ColorMessage "natsumi-Ordner wird erstellt..." -Color "Yellow"
        New-Item -Path "$ChromeDir\natsumi" -ItemType Directory -Force | Out-Null
    }

    # natsumi-pages-Ordner im Chrome-Verzeichnis erstellen, falls er nicht existiert
    if (-not (Test-Path "$ChromeDir\natsumi-pages")) {
        Write-ColorMessage "natsumi-pages-Ordner wird erstellt..." -Color "Yellow"
        New-Item -Path "$ChromeDir\natsumi-pages" -ItemType Directory -Force | Out-Null
    }

    # natsumi-config.css in das Chrome-Verzeichnis kopieren
    Write-ColorMessage "natsumi-config.css wird in das Chrome-Verzeichnis kopiert..." -Color "Yellow"
    Copy-Item -Path "$TempDir\natsumi-browser-main\natsumi-config.css" -Destination $ChromeDir -Force

    # natsumi-Ordnerinhalte in das Chrome-Verzeichnis kopieren
    Write-ColorMessage "natsumi-Ordnerinhalte werden in das Chrome-Verzeichnis kopiert..." -Color "Yellow"
    Copy-Item -Path "$TempDir\natsumi-browser-main\natsumi\*" -Destination "$ChromeDir\natsumi\" -Recurse -Force

    # natsumi-pages-Ordnerinhalte in das Chrome-Verzeichnis kopieren
    Write-ColorMessage "natsumi-pages-Ordnerinhalte werden in das Chrome-Verzeichnis kopieren..." -Color "Yellow"
    Copy-Item -Path "$TempDir\natsumi-browser-main\natsumi-pages\*" -Destination "$ChromeDir\natsumi-pages\" -Recurse -Force

    # Import-Zeilen erstellen
    $ImportLine = '@import "natsumi/natsumi.css";'
    $PagesImportLine = '@import "natsumi-pages/natsumi-pages.css";'

    # userChrome.css behandeln, je nachdem, ob sie existiert
    if ($UserChromeExists) {
        # Vorhandene userChrome.css sichern
        Write-ColorMessage "Vorhandene userChrome.css wird gesichert..." -Color "Yellow"
        Copy-Item -Path "$ChromeDir\userChrome.css" -Destination "$ChromeDir\userChrome.css.backup" -Force

        # Prüfen, ob die Import-Zeile bereits in userChrome.css existiert
        $UserChromeContent = Get-Content -Path "$ChromeDir\userChrome.css" -Raw
        if (-not $UserChromeContent.Contains($ImportLine)) {
            # Import-Zeile am Anfang von userChrome.css hinzufügen
            Write-ColorMessage "Import-Zeile wird zur vorhandenen userChrome.css hinzugefügt..." -Color "Yellow"
            $NewContent = "$ImportLine`r`n$UserChromeContent"
            Set-Content -Path "$ChromeDir\userChrome.css" -Value $NewContent -Force
        } else {
            Write-ColorMessage "Import-Zeile existiert bereits in userChrome.css." -Color "Green"
        }
    } else {
        # userChrome.css aus dem Repository kopieren
        Write-ColorMessage "userChrome.css wird in das Chrome-Verzeichnis kopiert..." -Color "Yellow"
        Copy-Item -Path "$TempDir\natsumi-browser-main\userChrome.css" -Destination $ChromeDir -Force
    }

    # userContent.css behandeln, je nachdem, ob sie existiert
    if ($UserContentExists) {
        # Vorhandene userContent.css sichern
        Write-ColorMessage "Vorhandene userContent.css wird gesichert..." -Color "Yellow"
        Copy-Item -Path "$ChromeDir\userContent.css" -Destination "$ChromeDir\userContent.css.backup" -Force

        # Prüfen, ob die Import-Zeile bereits in userContent.css existiert
        $UserContentContent = Get-Content -Path "$ChromeDir\userContent.css" -Raw
        if (-not $UserContentContent.Contains($PagesImportLine)) {
            # Import-Zeile am Anfang von userContent.css hinzufügen
            Write-ColorMessage "Import-Zeile wird zur vorhandenen userContent.css hinzugefügt..." -Color "Yellow"
            $NewContent = "$PagesImportLine`r`n$UserContentContent"
            Set-Content -Path "$ChromeDir\userContent.css" -Value $NewContent -Force
        } else {
            Write-ColorMessage "Import-Zeile existiert bereits in userContent.css." -Color "Green"
        }
    } else {
        # userContent.css aus dem Repository kopieren
        Write-ColorMessage "userContent.css wird in das Chrome-Verzeichnis kopiert..." -Color "Yellow"
        Copy-Item -Path "$TempDir\natsumi-browser-main\userContent.css" -Destination $ChromeDir -Force
    }

    # Temporäres Verzeichnis bereinigen
    Write-ColorMessage "Temporäre Dateien werden bereinigt..." -Color "Yellow"
    Set-Location -Path $env:USERPROFILE
    Remove-Item -Path $TempDir -Recurse -Force

    Write-Host ""
    Write-ColorMessage "Installation abgeschlossen!" -Color "Green"
    Write-ColorMessage "Natsumi Browser Theme wurde installiert in: $ChromeDir" -Color "Green"
    Write-Host ""
    Write-ColorMessage "Bitte starten Sie den Zen Browser neu, um das Theme anzuwenden." -Color "Cyan"
    Write-Host ""

} catch {
    Write-Host ""
    Write-ColorMessage "Ein Fehler ist aufgetreten: $_" -Color "Red"
    Write-ColorMessage "Die Installation wurde möglicherweise nicht vollständig abgeschlossen." -Color "Red"
    Write-ColorMessage "Bitte überprüfen Sie die Fehlermeldungen oben und versuchen Sie es erneut." -Color "Red"
    Write-Host ""
}

# Warten auf Benutzereingabe, bevor das Fenster geschlossen wird
Write-Host "Drücken Sie eine beliebige Taste, um das Fenster zu schließen..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
