Function Get-FirewallLog {
    <#
    .SYNOPSIS
    Audit to parse Windows Firewall log into Custom Object for easy filtering
    Author: Jon Rodriguez
    .DESCRIPTION

    .NOTES

    .EXAMPLE
    Get-FirewallLog
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,Position = 0)]
        [string]$Path = $Null
    )

    # Get Firewall Logging path via Registry key
    $LogRegKey = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging\'
    $LogLocation = (Get-ItemProperty -Path $LogRegKey -Name LogFilePath -ErrorAction SilentlyContinue).LogFilePath
    # Set Firewall Logging default path
    $DefaultLogPath = 'C:\Windows\System32\LogFiles\Firewall\pfirewall.log'
    
    Try {
        # Get Firewall Log from $Path if specified
        If ($Path) {
            $Log = Get-Content -Path $Path | Select-Object -Skip 5
            Write-Output "Using path specified for Firewall Log - $Path"
        # Get Firewall Log from Registry Key location if exists
        } ElseIf (($Null -ne $LogLocation) -and (Test-Path -Path $LogLocation)) {
            # Get the content of the log, skip the first 5 informational lines
            $Log = Get-Content -Path $LogLocation | Select-Object -Skip 5
            Write-Output "Firewall Log Configured and Found via Registry Key"
            If ($Null -eq $Log) {
                Write-Output "Firewall Log Configured but no Log File Found"
            }
        # Get Firewall Log from Default Path if exists
        } ElseIf (Test-Path -Path $DefaultLogPath) {
            # Get the content of the log, skip the first 5 informational lines
            $Log = Get-Content -Path $DefaultLogPath | Select-Object -Skip 5
            Write-Output "Firewall Log Found via Default Path"
        }
    } Catch {
        Write-Error "Unable to retrieve Firewall Log"
        Return
    }

    # Create an array to store the parsed lines
    $ParsedLog = @()

    # Parse each line in the Firewall log, splitting on new lines
    ForEach ($Line in $Log -split "\n") {
        # Split each line by spaces
        $LineData = $Line.Split(" ")

        # Create new PS Custom Object and add relevant properties
        $ParsedLine = New-Object PSObject
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Date" -Value $LineData[0]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Time" -Value $LineData[1]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Action" -Value $LineData[2]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Protocol" -Value $LineData[3]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Source IP" -Value $LineData[4]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Destination IP" -Value $LineData[5]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Source Port" -Value $LineData[6]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Destination Port" -Value $LineData[7]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Size" -Value $LineData[8]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "TCP Flags" -Value $LineData[9]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "TCP SYN" -Value $LineData[10]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "TCP ACK" -Value $LineData[11]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "TCP WIN" -Value $LineData[12]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "ICMP Type" -Value $LineData[13]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "ICMP Code" -Value $LineData[14]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Info" -Value $LineData[15]
        Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "Direction" -Value $LineData[16]

        # Add the parsed line to the parsed log array
        $ParsedLog += $ParsedLine
    }

    # Write the output of the Parsed Log
    Write-Output $ParsedLog
}
