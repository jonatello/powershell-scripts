Function New-WRAccessToken {
    <#
    .SYNOPSIS
    Get Webroot Unity API access token by providing Username, Password, ClientID, and ClientSecret, response will contain access token
    Author: Jon Rodriguez
    .DESCRIPTION
    Response contains "access_token" property which can subsequently be used for Unity API requests
    .NOTES
    Scope is set to "*" by default
    .EXAMPLE
    $Token = New-WRAccessToken -ClientId $ClientId -ClientSecret $ClientSecret -Username user@example.com -Password $Password
    #>

    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$ClientId,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$ClientSecret,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Username,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Password,
        [Parameter(Mandatory = $false,Position = 4)]
        [string]$Scope = "*"
    )

    [string]$BaseUri     = "https://unityapi.webrootcloudav.com" + "/auth/token"
    [string]$ContentType = "application/x-www-form-urlencoded"
    [string]$Body = "username=$($Username)&password=$($Password)&grant_type=password&scope=$($Scope)"
    [string]$Authstring  = $ClientId + ':' + $ClientSecret
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));
    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -Body $Body -ContentType $ContentType -Method POST
    } Catch {
        Write-Error "There was an issue when attempting to query the Webroot API:`n$_"
    }
}

Function Get-WRRefreshToken {
    <#
    .SYNOPSIS
    Refresh Webroot Unity API access token by providing ClientID, ClientSecret, and RefreshToken, response will contain refreshed access token
    Author: Jon Rodriguez
    .DESCRIPTION
    Response contains "access_token" property which can subsequently be used for Unity API requests
    .NOTES
    Scope is set to "*" by default
    .EXAMPLE
    $Response = Get-WRRefreshToken -ClientId $ClientId -ClientSecret $ClientSecret -RefreshToken $RefreshToken
    #>

    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$ClientId,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$ClientSecret,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$RefreshToken,
        [Parameter(Mandatory = $false,Position = 3)]
        [string]$Scope = "*"
    )

    [string]$BaseUri     = "https://unityapi.webrootcloudav.com" + "/auth/token"
    [string]$ContentType = "application/x-www-form-urlencoded"
    [string]$Body = "refresh_token=$RefreshToken&grant_type=refresh_token&scope=$($Scope)"
    [string]$Authstring  = $ClientId + ':' + $ClientSecret
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));
    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -Body $Body -ContentType $ContentType -Method POST
    } Catch {
        Write-Error "There was an issue when attempting to query the Webroot API:`n$_"
    }
}

Function Get-WRGSMConsole {
    <#
    .SYNOPSIS
    Get Webroot GSM Console information for a specific GSM Key
    Author: Jon Rodriguez
    .DESCRIPTION
    Response contains GSM Console information for a given GSM Key
    .NOTES
    It is necessary to first obtain an Access Token via Get-WRAccessToken
    .EXAMPLE
    Get-WRGSMConsole -Token $Token -GSMKey $GSMKey
    #>

    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$Token,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$GSMKey
    )

    [string]$BaseUri     = "https://unityapi.webrootcloudav.com" + "/service/api/console/gsm/$GSMKey"
    [string]$ContentType = "application/json"
    $Headers = @{
        Authorization = "Bearer $Token"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method GET
    } Catch {
        Write-Error "There was an issue when attempting to query the Webroot API:`n$_"
    }
}

Function Get-WRGSMSite {
    <#
    .SYNOPSIS
    Get Webroot GSM Site information for a specific Site KeyCode
    Author: Jon Rodriguez
    .DESCRIPTION
    Response contains GSM Site information for a given Site KeyCode
    .NOTES
    It is necessary to first obtain an Access Token via Get-WRAccessToken
    .EXAMPLE
    Get-WRGSMSite -Token $Token -GSMKey $GSMKey -SiteKeyCode $SiteKeyCode
    #>

    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$Token,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$GSMKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$SiteKeyCode
    )

    [string]$BaseUri     = "https://unityapi.webrootcloudav.com" + "/service/api/console/gsm/$GSMKey/lookupsite/$SiteKeyCode"
    [string]$ContentType = "application/json"
    $Headers = @{
        Authorization = "Bearer $Token"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method GET
    } Catch {
        Write-Error "There was an issue when attempting to query the Webroot API:`n$_"
    }
}

Function Get-WREndpointStatus {
    <#
    .SYNOPSIS
    Author: Jon Rodriguez
    .DESCRIPTION
    
    .NOTES
    
    .EXAMPLE
    
    #>

    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$Token,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$SiteKeyCode
    )

    [string]$BaseUri     = "https://unityapi.webrootcloudav.com" + "/service/api/status/site/$SiteKeyCode"
    [string]$ContentType = "application/json"
    $Headers = @{
        Authorization = "Bearer $Token"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method GET
    } Catch {
        Write-Error "There was an issue when attempting to query the Webroot API:`n$_"
    }
}

Function Get-WREndpointStatusGSM {
    <#
    .SYNOPSIS
    Author: Jon Rodriguez
    .DESCRIPTION
    
    .NOTES
    
    .EXAMPLE
    
    #>

    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$Token,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$SiteKeyCode
    )

    [string]$BaseUri     = "https://unityapi.webrootcloudav.com" + "/service/api/status/gsm/$SiteKeyCode"
    [string]$ContentType = "application/json"
    $Headers = @{
        Authorization = "Bearer $Token"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method GET
    } Catch {
        Write-Error "There was an issue when attempting to query the Webroot API:`n$_"
    }
}

Function Get-WRThreatHistory {
    <#
    .SYNOPSIS
    Author: Jon Rodriguez
    .DESCRIPTION
    
    .NOTES
    The only acceptable ReturnedInfo is "ExtendedInfo"
    .EXAMPLE
    
    #>

    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$Token,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$GSMKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$SiteID,
        [Parameter(Mandatory = $false,Position = 3)]
        [string]$StartDate = ((Get-Date).AddDays(-1)),
        [Parameter(Mandatory = $false,Position = 4)]
        [string]$EndDate = (Get-Date),
        [Parameter(Mandatory = $false,Position = 5)]
        [string]$ReturnedInfo = $null,
        [Parameter(Mandatory = $false,Position = 6)]
        [INT]$PageSize = 50,
        [Parameter(Mandatory = $false,Position = 7)]
        [INT]$PageNr = 1
    )

    [string]$BaseUri     = "https://unityapi.webrootcloudav.com" + "/service/api/console/gsm/$GSMKey/sites/$SiteID/threathistory"
    [string]$Parameters  = "?startDate=$StartDate&endDate=$EndDate&pageSize=$PageSize&pageNr=$PageNr"
    If ($ReturnedInfo -eq 'ExtendedInfo') {$Parameters+="&returnedInfo=$ReturnedInfo"}
    [string]$ContentType = "application/json"
    $Headers = @{
        Authorization = "Bearer $Token"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method GET
    } Catch {
        Write-Error "There was an issue when attempting to query the Webroot API:`n$_"
    }
}
