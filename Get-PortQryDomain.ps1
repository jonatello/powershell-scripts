Function Get-PortQryDomain {
    <#
    .SYNOPSIS
    Function to run PortQry.exe with Domains and Trusts predefined service
    Author: Jon Rodriguez
    .DESCRIPTION
    
    .NOTES
    Requires PortQru V2 to be installed at the default location C:\PortQryV2\PortQry.exe
    https://www.microsoft.com/en-us/download/details.aspx?id=17148
    By default, logs will be written to C:\Windows\Logs\PortQry.log
    .EXAMPLE
    Get-PortQryDomain -IPAddress 10.1.1.3 -LogLocation "C:\temp\port.log"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$IPAddress,
        [Parameter(Mandatory = $false,Position = 1)]
        [string]$LogLocation = "C:\Windows\Logs\PortQry.log",
        [Parameter(Mandatory = $false,Position = 2)]
        [string]$PortQryLocation = "C:\PortQryV2\PortQry.exe"
    )

    If (!(Test-Path -Path $PortQryLocation)) {
        Write-Error "$PortQryLocation not found, exiting"
    }

    Try {
        & $PortQryLocation -v -n $IPAddress -e 135 -p TCP >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 389 -p BOTH >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 636 -p TCP >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 3268 -p TCP >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 3269 -p TCP >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 53 -p BOTH >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 88 -p BOTH >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 445 -p TCP >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 137 -p UDP >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 138 -p UDP >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 139 -p TCP >> $LogLocation
        & $PortQryLocation -v -n $IPAddress -e 42 -p TCP >> $LogLocation

        Write-Output "Log file can be reviewed at $LogLocation"
    } Catch {
        Write-Error "There was an issue running PortQry:`n`n$_"
    }
}
