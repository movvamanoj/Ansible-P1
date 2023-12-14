# Set execution policy
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# Specify the disk numbers
$diskNumbers = (Get-Disk).Number

# Create a variable to store allocated disk letters along with their disk numbers
$diskNumbersLetter = @{}

# Function to get the next available drive letter
function Get-NextAvailableDriveLetter {
    $usedDriveLetters = Get-Volume | Select-Object -ExpandProperty DriveLetter
    $alphabetOrder = 'G', 'A', 'B', 'D', 'E', 'F', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'

    foreach ($letter in $alphabetOrder) {
        if ($usedDriveLetters -notcontains $letter) {
            return $letter
        }
    }

    throw "No available drive letters found."
}

# Display disk information before partition creation
foreach ($diskNumber in $diskNumbers) {
    $diskInfo = Get-Disk -Number $diskNumber
    Write-Host "Disk $diskNumber Information:"
    $diskInfo | Format-List
    Write-Host ""
}

# Check if each disk is already initialized and has a drive letter
foreach ($diskNumber in $diskNumbers) {
    # Skip Disk 0 (OS disk)
    if ($diskNumber -eq 0) {
        Write-Host "Skipping initialization for Disk 0 (OS disk)."
        continue
    }

    # Skip if the disk is already initialized or has a drive letter
    if ($diskNumber -in $diskNumbersLetter.Keys) {
        $existingDriveLetters = $disk | Get-Partition | Where-Object { $_.DriveLetter -ne $null } | Select-Object -ExpandProperty DriveLetter -Join ', '
        if ($existingDriveLetters) {
            Write-Host "Disk $($diskNumber) is already initialized $existingDriveLetter. Skipping initialization."
        } else {
            Write-Host "Disk $($diskNumber) is already initialized. Skipping initialization."
        }
        continue
    }

    $disk = Get-Disk -Number $diskNumber

    # Check if the disk is already initialized
    if ($disk.IsOffline -or ($disk.PartitionStyle -eq 'RAW')) {
        Initialize-Disk -Number $diskNumber -PartitionStyle GPT -PassThru
        Write-Host "Disk $diskNumber initialized."
    }
    else {
        $existingDriveLetter = $disk | Get-Partition | Where-Object { $_.DriveLetter -ne $null } | Select-Object -ExpandProperty DriveLetter -Join ', '
        Write-Host "Disk $diskNumber is already initialized $($existingDriveLetter). Skipping initialization."
    }

    # Add the disk number to the diskNumbersLetter with an empty array for drive letters
    $diskNumbersLetter[$diskNumber] = @()
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
        Write-Host "Disk $($diskNumber): Already in Use. Skipping partition $($diskNumber) (Already has a drive letter)."
        continue
    }

    # Check if the drive letter is already in use
    if ($diskNumber -in $diskNumbersLetter.Keys) {
        $existingDriveLetters = $diskNumbersLetter[$diskNumber] -join ', '
        if ($existingDriveLetters -contains $nextAvailableDriveLetter) {
            Write-Host "Drive letter $nextAvailableDriveLetter is already in use for Disk $diskNumber. Skipping partition creation."
            continue
        }
    }

    # Check if the disk already has partitions
    $existingPartitions = Get-Partition -DiskNumber $diskNumber
    if ($existingPartitions.Count -gt 0) {
        $existingDriveLetters = $existingPartitions | Select-Object -ExpandProperty DriveLetter -Join ', '
        Write-Host "Disk $($diskNumber): Already has partitions $($existingDriveLetter). Skipping partition creation."
        continue
    }

    try {
        $newPartition = New-Partition -DiskNumber $diskNumber -AssignDriveLetter -UseMaximumSize -ErrorAction Stop
        $driveLetter = $newPartition.DriveLetter
        Write-Host "Partition on Disk $($newPartition.DiskNumber) created with drive letter $($driveLetter)."
        $diskNumbersLetter[$diskNumber] += $driveLetter
    }
    catch {
        Write-Host "Error creating partition on Disk $($diskNumber). Details: $_"
        Write-Host "Activity ID: $($Error[0].ActivityId)"
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
        $ErrorActionPreference = "SilentlyContinue"
        # Check if the partition exists before formatting
        if (Get-Partition -DiskNumber $diskNumber | Where-Object { $_.DriveLetter -eq $driveLetter }) {
            Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel "SC1CALLS" -AllocationUnitSize 65536 -Confirm:$false
            $ErrorActionPreference = "Continue"

            Write-Host "Formatted volume with drive letter $driveLetter and label SC1CALLS."
             # Display volume information immediately after formatting
             $volumeInfo = Get-Volume -DriveLetter $driveLetter | Format-List | Out-String
             Write-Host $volumeInfo
        }
        else {
            Write-Host "Partition with drive letter $driveLetter not found on Disk $diskNumber. Skipping formatting."
        }
    }
}