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
        $Path = ls 'C:\Program Files (x86)\Microsoft Office\*\ospp.vbs'
        $OSPP = cscript $Path\ospp.vbs /dstatus
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
        'Office License Name (OSPP)' = (($OSPP | Select-String -Pattern 'LICENSE NAME: ').ToString() -replace 'LICENSE NAME: ','')
        'Office License Description (OSPP)' = (($OSPP | Select-String -Pattern 'LICENSE DESCRIPTION: ').ToString() -replace 'License Description: ','')
        'Office License Status (OSPP)' = (($OSPP | Select-String -Pattern 'LICENSE STATUS: ').ToString() -replace 'License Status: ','')
    } | Write-Output
}
