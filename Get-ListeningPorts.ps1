Function Get-ListeningPorts {
    <#
    .SYNOPSIS
    Audit TCP and UDP Listening Ports
    Author: Jon Rodriguez
    .DESCRIPTION

    .NOTES
    Adapted from this - https://gist.github.com/jeffpatton1971/8440245

    Only lists results which meet these conditions:
    Local Address != "127.0.0.1" and "::1"
    State = LISTENING
    Corresponding Process Name is not equal to "svchost", "lsass", "wininit", "services", "LTSVC", or "LTTray"
    .EXAMPLE

    #>

    [CmdletBinding()]
    param (
    )

    $Netstat = netstat -a -n -o -p TCP
    $Netstat += netstat -a -n -o -p UDP
    [regex]$regexTCP = '(?<Protocol>\S+)\s+((?<LAddress>(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?))|(?<LAddress>\[?[0-9a-fA-f]{0,4}(\:([0-9a-fA-f]{0,4})){1,7}\%?\d?\]))\:(?<Lport>\d+)\s+((?<Raddress>(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?))|(?<RAddress>\[?[0-9a-fA-f]{0,4}(\:([0-9a-fA-f]{0,4})){1,7}\%?\d?\]))\:(?<RPort>\d+)\s+(?<State>\w+)\s+(?<PID>\d+$)'
    [regex]$regexUDP = '(?<Protocol>\S+)\s+((?<LAddress>(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?)\.(2[0-4]\d|25[0-5]|[01]?\d\d?))|(?<LAddress>\[?[0-9a-fA-f]{0,4}(\:([0-9a-fA-f]{0,4})){1,7}\%?\d?\]))\:(?<Lport>\d+)\s+(?<RAddress>\*)\:(?<RPort>\*)\s+(?<PID>\d+)'
    $Listening = @()

    # Loop through each line within Netstat query
    ForEach ($Line in $Netstat) {

        # Switch on TCP or UDP
        Switch -regex ($Line.Trim()) {
            $RegexTCP {
                $MyProtocol = $Matches.Protocol
                $MyLocalAddress = $Matches.LAddress
                $MyLocalPort = $Matches.LPort
                $MyRemoteAddress = $Matches.Raddress
                $MyRemotePort = $Matches.RPort
                $MyState = $Matches.State
                $MyPID = $Matches.PID
                $MyProcessName = (Get-Process -Id $Matches.PID -ErrorAction SilentlyContinue).ProcessName
                $MyProcessPath = (Get-Process -Id $Matches.PID -ErrorAction SilentlyContinue).Path
                $MyUser = (Get-WmiObject -Class Win32_Process -Filter ("ProcessId = "+$Matches.PID)).GetOwner().User
            }

            $RegexUDP {
                $MyProtocol = $Matches.Protocol
                $MyLocalAddress = $Matches.LAddress
                $MyLocalPort = $Matches.LPort
                $MyRemoteAddress = $Matches.Raddress
                $MyRemotePort = $Matches.RPort
                $MyState = $Matches.State
                $MyPID = $Matches.PID
                $MyProcessName = (Get-Process -Id $Matches.PID -ErrorAction SilentlyContinue).ProcessName
                $MyProcessPath = (Get-Process -Id $Matches.PID -ErrorAction SilentlyContinue).Path
                $MyUser = (Get-WmiObject -Class Win32_Process -Filter ("ProcessId = "+$Matches.PID)).GetOwner().User
            }
        }

        # Add each Netstat line as a custom PS Object
        $LineItem = New-Object -TypeName PSobject -Property @{
            Protocol = $MyProtocol
            LocalAddress = $MyLocalAddress
            LocalPort = $MyLocalPort
            RemoteAddress = $MyRemoteAddress
            RemotePort = $MyRemotePort
            State = $MyState
            PID = $MyPID
            ProcessName = $MyProcessName
            ProcessPath = $MyProcessPath
            User = $MyUser
            }
        
        # Add the line item to the Listening Array if the following conditions are met
        # If the local address is not "127.0.0.1" or "::1"
        If (($LineItem.LocalAddress -ne "127.0.0.1") -and ($LineItem.LocalAddress -ne "::1")) {
            # If the state is "LISTENING"
            If (($LineItem.State) -and ($LineItem.State.ToUpper() -eq "LISTENING")) {
                # If the ProcessName is NOT "svchost", "lsass", "wininit", "services", "LTSVC", "LTTray" add it to Listening array
                If (($LineItem.ProcessName.ToLower() -ne "svchost") `
                -and ($LineItem.ProcessName.ToLower() -ne "lsass") `
                -and ($LineItem.ProcessName.ToLower() -ne "wininit") `
                -and ($LineItem.ProcessName.ToLower() -ne "services") `
                -and ($LineItem.ProcessName.ToLower() -ne "LTSVC") `
                -and ($LineItem.ProcessName.ToLower() -ne "LTTray")) {
                    $Listening += $LineItem
                }
            }
        }
    }

    # Write the output of all listening results
    Write-Output $Listening
}
