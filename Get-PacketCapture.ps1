Function Get-PacketCapture {
    <#
    .SYNOPSIS
    Perform a packet capture via PowerShell
    Author: Jon Rodriguez
    .DESCRIPTION
    Perform a packet capture via PowerShell utilizing NetEventSession with the 
    "Microsoft-Windows-TCPIP" provider. Requires PowerShell Version 5.0 or higher
    .NOTES
    By default seconds to capture is 30 and session name is "Session"
    .EXAMPLE
    Get-PacketCapture -Seconds 10
    #>

    param(
        [Parameter(Mandatory = $false,Position = 0)]
        [ValidateRange(1,300)]
        [int]$Seconds = 30,
        [Parameter(Mandatory = $false,Position = 1)]
        [string]$Session = "Session"
    )

    Try {
        # Create a new network event session
        New-NetEventSession -Name $Session | Out-Null

        # Add the Microsoft-Windows-TCPIP provider to the network event session
        Add-NetEventProvider -Name "Microsoft-Windows-TCPIP" -SessionName $Session | Out-Null

        # Start the network trace session
        Start-NetEventSession -Name $Session

        # Notate the location of the ETL
        $ETL = (Get-NetEventSession -Name $Session).LocalFilePath

        # Wait for specified number of seconds
        Start-Sleep -Seconds $Seconds

        # Stop the network trace session
        Stop-NetEventSession -Name $Session

        # Remove the network trace session
        Remove-NetEventSession -Name $Session

        # Display the path to the results
        Write-Output "Path to results: $ETL"
    } Catch {
        Write-Error "There was an error:`n`n$_"
    }
}
