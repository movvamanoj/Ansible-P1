# Path to the XML file
$xmlFilePath = "P:\Impact360\Software\ContactStore\DiskManagerConfig.xml"

# Backup the original file before making any modifications
$backupFilePath = "$xmlFilePath.bak"
Copy-Item -Path $xmlFilePath -Destination $backupFilePath -ErrorAction SilentlyContinue
Write-Host "Backup taken: $backupFilePath"

try {
    # Load the XML content
    [xml]$xmlContent = Get-Content -Path $xmlFilePath

    # Define the namespace for the XML elements
    $namespaceUri = "http://www.witness.com/xmlns/DiskManagerConfig"
    $namespaceManager = New-Object System.Xml.XmlNamespaceManager($xmlContent.NameTable)
    $namespaceManager.AddNamespace("ns", $namespaceUri)

    # Specify the new element to be added
    $newElementName = "MoveCallsToAlternateCallPath"
    $newElementValue = "true"

    # Check if the new element already exists in the specified location
    $existingElement = $xmlContent.SelectSingleNode("//ns:$newElementName", $namespaceManager)

    if ($existingElement -eq $null) {
        # Find the reference element after which the new element needs to be added
        $referenceElementName = "LoadAllDrives"
        $referenceElement = $xmlContent.SelectSingleNode("//ns:$referenceElementName", $namespaceManager)

        # Check if the reference element exists before proceeding
        if ($referenceElement) {
            # Create the new XML element to be added using the parent's namespace
            $newElement = $xmlContent.CreateElement($newElementName, $namespaceUri)
            $newElement.InnerText = $newElementValue

            # Insert the new element before the reference element
            $referenceElement.ParentNode.InsertBefore($newElement, $referenceElement)

            # Save the modified XML back to the file
            $xmlContent.Save($xmlFilePath)

            Write-Host "The XML file was successfully updated."
            Write-Host "Added new element: <$newElementName>$newElementValue</$newElementName>"
            Remove-Item -Path $backupFilePath -ErrorAction SilentlyContinue
            Write-Host "Backup deleted successfully."
        } else {
            Write-Host "Reference element '$referenceElementName' not found. No modifications were made."
        }
    } else {
        Write-Host "The new element '$newElementName' is already present in the specified location. No modifications were made."
    }
} catch {
    # Handle errors and provide appropriate feedback
    Write-Host "An error occurred: $_"
    Write-Host "No modifications were made to the XML file."
} finally {
    # Clean up: Remove the backup only if the operation was successful
    if (Test-Path $backupFilePath) {
        Remove-Item -Path $backupFilePath -ErrorAction SilentlyContinue
    }
}
