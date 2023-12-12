# Set execution policy
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# Specify the disk numbers
$diskNumbers = (Get-Disk).Number

# Create a variable to store allocated disk letters along with their disk numbers
$diskNumbersLetter = @{}

# Function to get the next available drive letter
function Get-NextAvailableDriveLetter {
    $usedDriveLetters = Get-Volume | Select-Object -ExpandProperty DriveLetter
    $alphabet = 'G', 'D', 'E', 'F', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'

    foreach ($letter in $alphabet) {
        if ($usedDriveLetters -notcontains $letter) {
            return $letter
        }
    }

    throw "No available drive letters found."
}

# Function to test if a drive letter is in use for a specific disk
function Test-DriveLetterInUse {
    param (
        [int]$DiskNumber,
        [string]$DriveLetter
    )

    $usedDriveLetters = $diskNumbersLetter[$DiskNumber]
    return $usedDriveLetters -contains $DriveLetter
}

# Display information about existing partitions
foreach ($diskNumber in $diskNumbers) {
    $disk = Get-Disk -Number $diskNumber
    $existingPartitions = $disk | Get-Partition | Where-Object { $_.DriveLetter -ne $null } | Select-Object DiskNumber, DriveLetter, FileSystemLabel

    if ($existingPartitions) {
        $existingPartitionsInfo = $existingPartitions | Format-Table -AutoSize | Out-String
        Write-Host "Disk $diskNumber is already initialized with the following partition(s):"
        Write-Host $existingPartitionsInfo
        $diskNumbersLetter[$diskNumber] = $existingPartitions.DriveLetter
    } else {
        Write-Host "Disk $diskNumber is already initialized."
    }
}

# Create a new partition on each disk with specific drive letters
foreach ($diskNumber in $diskNumbers) {
    # Skip Disk 0 (OS disk)
    if ($diskNumber -eq 0) {
        Write-Host "Skipping partition creation for Disk 0 (OS disk)."
        continue
    }

    # Skip if the disk already has a drive letter
    if ($diskNumber -in $diskNumbersLetter.Keys -and $diskNumbersLetter[$diskNumber]) {
        $existingDriveLetter = $diskNumbersLetter[$diskNumber] -join ', '
        Write-Host "Disk $diskNumber is already initialized with drive letter(s) $existingDriveLetter. Skipping partition creation."
        continue
    }

    $nextAvailableDriveLetter = Get-NextAvailableDriveLetter

    # Check if the drive letter is already in use
    if ($diskNumber -in $diskNumbersLetter.Keys -and $nextAvailableDriveLetter -in $diskNumbersLetter[$diskNumber]) {
        Write-Host "Drive letter $nextAvailableDriveLetter is already in use for Disk $diskNumber. Skipping partition creation."
    }
    else {
        $newPartition = New-Partition -DiskNumber $diskNumber -AssignDriveLetter -UseMaximumSize
        $driveLetter = $newPartition.DriveLetter
        Write-Host "Partition on Disk $diskNumber created with drive letter $driveLetter."
        $diskNumbersLetter[$diskNumber] += $driveLetter
        Start-Sleep -Seconds 1  # Add a short delay to ensure that the information is updated
    }
}

# Format the volumes with NTFS file system and specific label
foreach ($diskNumber in $diskNumbers) {
    # Skip Disk 0 (OS disk)
    if ($diskNumber -eq 0) {
        Write-Host "Skipping formatting for Disk 0 (OS disk)."
        continue
    }

    foreach ($driveLetter in $diskNumbersLetter[$diskNumber]) {
        # Check if the partition exists before formatting
        if (Get-Partition -DiskNumber $diskNumber | Where-Object { $_.DriveLetter -eq $driveLetter }) {
            Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel "SC1CALLS" -AllocationUnitSize 65536 -Confirm:$false
            Write-Host "Formatted volume with drive letter $driveLetter and label SC1CALLS."
        }
        else {
            Write-Host "Partition with drive letter $driveLetter not found on Disk $diskNumber. Skipping formatting."
        }
    }
}
