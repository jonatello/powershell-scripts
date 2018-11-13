Function Get-MicrosoftLicensing {
    # Get all SoftwareLicensingService objects via WMI
    Try {
        $SoftwareLicensingService = Get-WMIObject -Class SoftwareLicensingService

        If ($($SoftwareLicensingService.Version) -notlike $null) {
            $Version = $($SoftwareLicensingService.Version)
        } Else {
            $Version = 'N/A'
        }

        If ($($SoftwareLicensingService.OA3xOriginalProductKeyDescription) -notlike $null) {
            $OA3xOriginalProductKeyDescription = $($SoftwareLicensingService.OA3xOriginalProductKeyDescription)
        } Else {
            $OA3xOriginalProductKeyDescription = 'N/A'
        }

        If ($($SoftwareLicensingService.OA3xOriginalProductKey) -notlike $null) {
            $OA3xOriginalProductKey = $($SoftwareLicensingService.OA3xOriginalProductKey)
        } Else {
            $OA3xOriginalProductKey = 'N/A'
        }

    } Catch {
        Write-Error "There was an exception querying SoftwareLicensingService: $_"
    }

    # Get all SoftwareLicensingProduct objects via WMI
    Try {
        $SoftwareLicensingProduct = Get-WMIObject -Class SoftwareLicensingProduct | Where-Object {($_.LicenseStatus -ne "0") -and ($_.ApplicationID -ne "55c92734-d682-4d71-983e-d6ec3f16059f") -and ($_.Name -like "*Office*")}

        If ($($SoftwareLicensingProduct.Count) -notlike $null) {
            $Count = $($SoftwareLicensingProduct.Count)
        } Else {
            $Count = 'N/A'
        }

        If ($($SoftwareLicensingProduct.Name) -notlike $null) {
            $Name = $($SoftwareLicensingProduct.Name) | Out-String
        } Else {
            $Name = 'N/A'
        }

        If ($($SoftwareLicensingProduct.ProductKeyChannel) -notlike $null) {
            $ProductKeyChannel = $($SoftwareLicensingProduct.ProductKeyChannel) | Out-String
        } Else {
            $ProductKeyChannel = 'N/A'
        }

        If ($($SoftwareLicensingProduct.LicenseName) -notlike $null) {
            $LicenseName = $($SoftwareLicensingProduct.LicenseName) | Out-String
        } Else {
            $LicenseName = 'N/A'
        }

        If ($($SoftwareLicensingProduct.LicenseDescription) -notlike $null) {
            $LicenseDescription = $($SoftwareLicensingProduct.LicenseDescription) | Out-String
        } Else {
            $LicenseDescription = 'N/A'
        }

        If ($($SoftwareLicensingProduct.LicenseStatus) -notlike $null) {
            $LicenseStatus = $($SoftwareLicensingProduct.LicenseStatus) | Out-String
        } Else {
            $LicenseStatus = 'N/A'
        }

    } Catch {
        Write-Error "There was an exception while querying SoftwareLicensingProduct: $_"
    }

    # Get all Office Activation information via ospp.vbs
    Try {
        $Directory = (Get-ChildItem -Path 'C:\Program Files (x86)\Microsoft Office\*\ospp.vbs').DirectoryName
        $OSPP = cscript $Directory\ospp.vbs /dstatus

        # If no lines with LICENSE are found within OSPP results, mark fields as N/A
        If ($OSPP -match "LICENSE") {
            $LicenseName = ($OSPP | Select-String -Pattern 'LICENSE NAME: ') -replace 'LICENSE NAME: ','' | Out-String
            $LicenseDescription = ($OSPP | Select-String -Pattern 'LICENSE DESCRIPTION: ') -replace 'License Description: ','' | Out-String
            $LicenseStatus = ($OSPP | Select-String -Pattern 'LICENSE STATUS: ') -replace 'License Status: ','' | Out-String
        } Else {
            $LicenseName = 'N/A'
            $LicenseDescription = 'N/A'
            $LicenseStatus = 'N/A'
        }

    } Catch {
        Write-Error "There was an exception while running ospp.vbs: $_"
    }

    # Create a custom object to hold the results
    New-Object -TypeName PSObject -Property @{
        'Operating System Version (WMI)' = $Version
        'Windows Edition (WMI)' = $OA3xOriginalProductKeyDescription
        'Windows Product Key (WMI)' = $OA3xOriginalProductKey
        'Office Product Count (WMI)' = $Count
        'Office Product Name (WMI)' = $Name
        'Office Product Channel (WMI)' = $ProductKeyChannel
        'Office License Name (OSPP)' = $LicenseName
        'Office License Description (OSPP)' = $LicenseDescription
        'Office License Status (OSPP)' = $LicenseStatus
        'License Audit Performed' = (Get-Date -Format g)
    } | Write-Output
}
