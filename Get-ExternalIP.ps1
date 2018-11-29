Function Get-ExternalIP {
    <#
    .SYNOPSIS
    Get External IP via ipinfo.io
    If no IP is specified, it will check your public IP
    Author: Jon Rodriguez
    .DESCRIPTION
    
    .NOTES
    Requires PowerShell 3.0+
    .EXAMPLE
    Get-ExternalIP -IP 8.8.8.8
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,Position = 0)]
        [string]$IP
    )

    If ($IP -eq $null) {
        Try {
            Invoke-RestMethod -UseBasicParsing https://ipinfo.io/json
        } Catch {
            Write-Error "There was an issue querying ipinfo.io:`n`n$_"
        }
    } Else {
        Try {
            Invoke-RestMethod -UseBasicParsing https://ipinfo.io/$IP
        } Catch {
            Write-Error "There was an issue querying ipinfo.io:`n`n$_"
        }
    }
}
