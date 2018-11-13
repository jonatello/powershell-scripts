Function Get-MicrosoftLicensing {
    # Get all SoftwareLicensingService objects via WMI
    Try {
        $SoftwareLicensingService = Get-WMIObject -Class SoftwareLicensingService
    } Catch {
        Write-Error "There was an exception querying SoftwareLicensingService: $_"
    }

    # Get all SoftwareLicensingProduct objects via WMI
    Try {
        $SoftwareLicensingProduct = Get-WMIObject -Class SoftwareLicensingProduct | Where-Object {($_.LicenseStatus -ne "0") -and ($_.ApplicationID -ne "55c92734-d682-4d71-983e-d6ec3f16059f") -and ($_.Name -like "*Office*")}
    } Catch {
        Write-Error "There was an exception while querying SoftwareLicensingProduct: $_"
    }

    # Get all Office Activation information via ospp.vbs
    Try {
        $Directory = (Get-ChildItem -Path 'C:\Program Files (x86)\Microsoft Office\*\ospp.vbs').DirectoryName
        $OSPP = cscript $Directory\ospp.vbs /dstatus

        # If no lines with LICENSE are found within OSPP results, mark fields as N/A
        If ($OSPP -match "LICENSE") {
            $LicenseName = (($OSPP | Select-String -Pattern 'LICENSE NAME: ') -replace 'LICENSE NAME: ','')
            $LicenseDescription = (($OSPP | Select-String -Pattern 'LICENSE DESCRIPTION: ') -replace 'License Description: ','')
            $LicenseStatus = (($OSPP | Select-String -Pattern 'LICENSE STATUS: ') -replace 'License Status: ','')
        } Else {
            $LicenseName = "N/A"
            $LicenseDescription = "N/A"
            $LicenseStatus = "N/A"
        }
    } Catch {
        Write-Error "There was an exception while running ospp.vbs: $_"
    }

    # Create a custom object to hold the results
    [PSCustomObject]@{
        'Operating System Version (WMI)' = $($SoftwareLicensingService.Version)
        'Windows Edition (WMI)' = $($SoftwareLicensingService.OA3xOriginalProductKeyDescription)
        'Windows Product Key (WMI)' = $($SoftwareLicensingService.OA3xOriginalProductKey)
        'Office Product Count (WMI)' = $($SoftwareLicensingProduct.Count)
        'Office Product Name (WMI)' = ($($SoftwareLicensingProduct.Name) | Out-String)
        'Office Product Channel (WMI)' = ($($SoftwareLicensingProduct.ProductKeyChannel) | Out-String)
        'Office License Name (OSPP)' = ($LicenseName | Out-String)
        'Office License Description (OSPP)' = ($LicenseDescription | Out-String)
        'Office License Status (OSPP)' = ($LicenseStatus | Out-String)
    } | Write-Output
}
