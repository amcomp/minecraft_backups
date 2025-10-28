# Load configuration
$config = Get-Content ./config.json | ConvertFrom-Json

# Get JSON list of files/directories
$files = rclone lsjson $config.rclonePath | ConvertFrom-Json

Write-Output "Found $($files.Count) items in $($config.rclonePath)."

if ($files.Count -gt 10) {
    Write-Output "More than 10 items found. Initiating cleanup..."
    $delete = $true
} else {
    Write-Output "10 or fewer items found. No cleanup needed."
    $delete = $false
}

if ($delete) {
    # Sort oldest first and select everything beyond the newest 5
    $filesToDelete = $files | Sort-Object modtime | Select-Object -First ($files.Count - 5)

    foreach ($item in $filesToDelete) {
        $target = "$($config.rclonePath)/$($item.Path)"
        Write-Output "Deleting directory: $target"
        rclone delete $target
    }

    Write-Output "Cleanup complete. Kept 10 newest directories."
}
