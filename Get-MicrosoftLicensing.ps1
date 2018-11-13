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

        If ($($SoftwareLicensingProduct.LicenseFamily) -notlike $null) {
            $LicenseFamily = $($SoftwareLicensingProduct.LicenseFamily) | Out-String
        } Else {
            $LicenseFamily = 'N/A'
        }

        If ($($SoftwareLicensingProduct.Description) -notlike $null) {
            $Description = $($SoftwareLicensingProduct.Description) | Out-String
        } Else {
            $Description = 'N/A'
        }

        If ($($SoftwareLicensingProduct.LicenseStatus) -notlike $null) {
            $LicenseStatus = $($SoftwareLicensingProduct.LicenseStatus)

            # Switch on the LicenseStatus code to be human readable
            $LicenseStatus = switch ($LicenseStatus) {
                0 {'UNLICENSED'}
                1 {'LICENSED'}
                2 {'OOBGRACE'}
                3 {'OOTGrace'}
                4 {'NONGENGRACE'}
                5 {'NOTIFICATION'}
                6 {'EXTENDEDGRACE'}
                default {'LICUNKNOWN'}
            }
            
            $LicenseStatus = $LicenseStatus | Out-String
        } Else {
            $LicenseStatus = 'N/A'
        }

        If ($($SoftwareLicensingProduct.PartialProductKey) -notlike $null) {
            $PartialProductKey = $($SoftwareLicensingProduct.PartialProductKey) | Out-String
        } Else {
            $PartialProductKey = 'N/A'
        }

    } Catch {
        Write-Error "There was an exception while querying SoftwareLicensingProduct: $_"
    }

    # Create a custom object to hold the results
    New-Object -TypeName PSObject -Property @{
        'Operating System Version' = $Version
        'Windows Edition' = $OA3xOriginalProductKeyDescription
        'Windows Product Key' = $OA3xOriginalProductKey
        'Office Product Count' = $Count
        'Office Product Name' = $Name
        'Office Product Channel' = $ProductKeyChannel
        'Office License Family' = $LicenseFamily
        'Office License Description' = $Description
        'Office License Status' = $LicenseStatus
        'Office Partial Product Key' = $PartialProductKey
        'License Audit Performed' = (Get-Date -Format g)
    } | Write-Output
}
