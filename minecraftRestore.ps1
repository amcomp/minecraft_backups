<# 
Restore Minecraft world from backup, this script will restore the world on the existing server, it should still work on a brand new server
As long as the server is setup the same way as the original server (same folder structure, same server version, etc)
#>

$landingPath = "/home/cloud/docker/minecraftrecovery"
$Landingexists = Test-Path -Path $landingPath
$targetbackup = read-Host "Enter the date of the backup to restore (YYYYMMDD)"
$rclonebackuplocation = "googleDrive:mc-backups"


#Ensure landing folder exists
if ($Landingexists -eq $false) {
Write-Host "Creating recovery landing folder"
new-item -path $landingPath -ItemType "Directory" -Force
} else {
Write-Host "Recovery landing folder already exists"
}

#Download the backup to the landing folder
Write-Host "Downloading backup $targetbackup to recovery landing folder"
rclone copy $rclonebackuplocation/$targetbackup $landingPath


#Extract the backup
Write-Host "Extracting backup $targetbackup to recovery landing folder"
7z x "$landingPath/minecraft-backup-$targetbackup.7z" -o"$landingPath" -y