Function Get-MACVendor {
    <#
    .SYNOPSIS
    Get Vendor from MAC Address via https://api.macvendors.com
    If no MAC Address is specified, it will check your local MAC Address(es)
    Author: Jon Rodriguez
    .DESCRIPTION
    
    .NOTES
    Requires PowerShell 3.0+
    .EXAMPLE
    Get-MACVendor -MAC $MAC
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,Position = 0)]
        [string]$MAC
    )

    # If a MAC address isn't specified, pull all local MAC addresses
    If ($MAC -like $null) {
        # Gather all MAC addresses via WMI
        Try {
            $MACs = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | 
                Select-Object -Property 'MACAddress' | 
                Where-Object 'MACAddress' -ne $null).MACAddress
        } Catch {
            Write-Error "There was an querying WMI for MAC Addresses:`n`n$_"
        }
            
        # Loop through the MAC addresses and resolve via api.macvendors.com
        ForEach ($MAC in $MACs) {
            # Try to resolve the MAC
            Try {
                Invoke-RestMethod -UseBasicParsing https://api.macvendors.com/$MAC
            } Catch {
                Write-Output "Vendor not found"
            }
            
            # Sleep for 1 second between requests to avoid rate limit
            Start-Sleep -Seconds 1
        }    
    } Else {
        Try {
            # Resolve the MAC address via api.macvendors.com
            Invoke-RestMethod -UseBasicParsing https://api.macvendors.com/$MAC
        } Catch {
            Write-Output "Vendor not found"
        }
    }
}
