 # Specify the disk numbers
 $diskNumbers = (Get-Disk).Number

 # Create a variable to store allocated disk letters along with their disk numbers
 $diskNumbersLetter = @{}

 # Function to get the next available drive letter
 function Get-NextAvailableDriveLetter {
     $usedDriveLetters = Get-Volume | Select-Object -ExpandProperty DriveLetter
     $alphabetOrder = 'G', 'A', 'B', 'C', 'D', 'E', 'F', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'

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
         Write-Host "Disk $diskNumber is already initialized. Skipping initialization."

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
        # Write-Host "Skipping partition creation for Disk $diskNumber (Already has a drive letter)."
        Write-Host "Disk $($diskNumber): Already in Use. Skipping partition On $($diskNumber) (Already has a drive letter)."
        continue
    }

    $nextAvailableDriveLetter = Get-NextAvailableDriveLetter

    # Check if the drive letter is already in use
    if ($diskNumber -in $diskNumbersLetter.Keys -and $nextAvailableDriveLetter -in $diskNumbersLetter[$diskNumber]) {
        Write-Host "Drive letter $nextAvailableDriveLetter is already in use for Disk $diskNumber. Skipping partition creation."
    }
    else {
        New-Partition -DiskNumber $diskNumber -UseMaximumSize -DriveLetter $nextAvailableDriveLetter
        Write-Host "Partition on Disk $diskNumber created Successfully."
        $diskNumbersLetter[$diskNumber] += $nextAvailableDriveLetter
    }
}
foreach ($diskNumber in $diskNumbers) {
    # Skip Disk 0 (OS disk)
    if ($diskNumber -eq 0) {
        Write-Host "Skipping formatting for Disk 0 (OS disk)."
        continue
    }

    foreach ($driveLetter in $diskNumbersLetter[$diskNumber]) {
        $partition = Get-Partition -DiskNumber $diskNumber | Where-Object { $_.DriveLetter -eq $driveLetter }

        # Check if the partition exists before formatting
        if ($partition) {
            Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel "SC1CALLS" -AllocationUnitSize 65536 -Confirm:$false -Force
            Write-Host "Formatted volume with drive letter $driveLetter and label SC1CALLS."

            $volumeInfo = Get-Volume -DriveLetter $driveLetter | Format-List
            Write-Host $volumeInfo
        }
        else {
            Write-Host "No partition found on Disk $diskNumber with Drive Letter $driveLetter. Skipping formatting."
        }
    }
}


# # Format the volumes with NTFS file system and specific label
#  foreach ($diskNumber in $diskNumbers) {
#         # Skip Disk 0 (OS disk)
#         if ($diskNumber -eq 0) {
#             Write-Host "Skipping formatting for Disk 0 (OS disk)."
#             continue
#         }
   
#         foreach ($driveLetter in $diskNumbersLetter[$diskNumber]) {
#             # Check if the partition exists before formatting
#             if (Get-Partition -DiskNumber $diskNumber | Where-Object { $_.DriveLetter -eq $driveLetter }) {
#                 Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel "SC1CALLS" -AllocationUnitSize 65536 -Confirm:$false
#                 Write-Host "Formatted volume with drive letter $driveLetter and label SC1CALLS."
#                  $volumeInfo = Get-Volume -DriveLetter $driveLetter | Format-List | Out-String
#                  Write-Host $volumeInfo
#             }
#             else {
#                 Write-Host "Partition Already Done On Disk $diskNumber with Disk Letter . Skipping formatting."
#             }
#         }
#     }