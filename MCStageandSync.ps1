# -------------------------------
# Minecraft Daily Backup Script
# Using 7-Zip compression
# Cron-ready, Linux/PowerShell 7
# -------------------------------

# --- Config ---
$config = get-content -path /home/cloud/config.json | ConvertFrom-json

$sourcePath      = "/home/cloud/docker/minecraft/*"
$destinationBase = "/home/cloud/docker/staging"
$date            = Get-Date -Format "yyyyMMdd"
$dest            = "$destinationBase-$date"

$dockerPath      = "/usr/bin/docker"
$rclonePath      = "/usr/bin/rclone"
$sleepPath       = "/bin/sleep"
$sevenZipPath    = "/usr/bin/7z"   # verify with `which 7z`
$configPath     = "/home/cloud/config.json"

$containerID     = "$config.containerID"
$remoteBase      = "googleDrive:mc-backups"

# Optional: explicitly point to rclone config
$env:RCLONE_CONFIG = "/home/cloud/.config/rclone/rclone.conf"

# --- Logging ---
$logFile = "/home/cloud/logs/mc-backup-$date.log"
Start-Transcript -Path $logFile -Append

Write-Host "=== Minecraft Backup Started: $(Get-Date) ==="

# --- 1. Freeze world ---
Write-Host "Disabling autosave and flushing world..."
& $dockerPath exec $containerID rcon-cli save-off
& $dockerPath exec $containerID rcon-cli save-all
& $sleepPath 10

# --- 2. Prepare staging folder ---
if (-Not (Test-Path $dest)) {
    Write-Host "Creating staging folder: $dest"
    New-Item -ItemType Directory -Path $dest | Out-Null
}

# --- 3. Copy server files ---
Write-Host "Copying Minecraft files to staging folder..."
Copy-Item -Path $sourcePath -Destination $dest -Recurse -Force

# --- 4. Resume world ---
Write-Host "Re-enabling autosave..."
& $dockerPath exec $containerID rcon-cli save-on

# --- 5. Compress staging folder using 7-Zip ---
$archivePath = "$destinationBase/minecraft-backup-$date.7z"
Write-Host "Compressing backup to $archivePath ..."
& $sevenZipPath a -t7z -mx=9 $archivePath "$dest/*"

# --- 6. Push compressed backup to Google Drive ---
Write-Host "Uploading compressed backup to Google Drive..."
& $rclonePath copy $archivePath "$remoteBase/$date" --progress

Write-Host "=== Minecraft Backup Finished: $(Get-Date) ==="

Stop-Transcript
