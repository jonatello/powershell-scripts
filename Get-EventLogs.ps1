Function Get-EventLogs {
    <#
    .SYNOPSIS
    Get Windows Event Logs
    Author: Jon Rodriguez
    .DESCRIPTION
    
    .NOTES
    N/A
    .EXAMPLE
    Get-EventLogs
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,Position = 0)]
        [string[]]$LogNames = @("Application","Security","Setup","System"),
        [Parameter(Mandatory = $false,Position = 1)]
        [string]$Destination = "C:\temp\eventlogs"
    )

    #Create EventLogs folder if it doesn't already exist
    If (!(Test-Path $Destination)) {
        New-Item -ItemType Directory $Destination
    }

    # Loop through each type of log and create evtx export
    ForEach ($Log in $LogNames) {
        wevtutil export-log $Log $Destination\$Log.evtx
    }

    # Compress the EventLogs directory to a zip file
    Add-Type -Assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($Destination, "$Destination.zip")

    # Clean up
    Remove-Item $Destination -Recurse
}
