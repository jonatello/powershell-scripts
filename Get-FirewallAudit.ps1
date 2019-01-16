Function Get-FirewallAudit {
    <#
    .SYNOPSIS
    Audit to verify Listening Ports have corresponding Firewall Rules
    Author: Jon Rodriguez
    .DESCRIPTION

    .NOTES
    Used in conjunction with "Get-ListeningPorts.ps1", "Get-FirewallRules.ps1", and "Get-FirewallLog.ps1"
    .EXAMPLE

    #>

    [CmdletBinding()]
    param (
    )

    # Get the current Firewall Configuration
    Get-FirewallConfig
    Write-Output "########################"

    # Get the current Firewall Log
    $FirewallLog = Get-FirewallLog

    # Gather all Listening Ports
    $ListeningPorts = Get-ListeningPorts

    # Gather all Firewall Rules which are Enabled, Inbound, and Allowed
    $FirewallRules = Get-FirewallRules | Where-Object {
        ($_.Enabled -eq 'True') -and ($_.Direction -eq 'Inbound') -and ($_.Action -eq 'Allow')
    }

    # Array to hold 
    $ListenerSummary = @()

    ForEach ($Listener in $ListeningPorts) {
        # Set the Listener variables
        $ProcessPath = $Listener.ProcessPath
        $LocalPort = $Listener.LocalPort
        $Protocol = $Listener.Protocol

        # Search the Firewall Rules for matches to the Listener properties
        $ProcessPathRules = $FirewallRules | Where-Object {
            $_.ApplicationName -Contains "$ProcessPath"
        }
        $ProcessPathRulesCount = ($FirewallRules | Where-Object {
            $_.ApplicationName -Contains "$ProcessPath"
        } | Measure).Count
        $LocalPortRules = $FirewallRules | Where-Object {
            ($_.LocalPorts -Contains "$LocalPort") -And ($_.Protocol -Contains "$Protocol" -Or $_.Protocol -Contains $Null)
        }
        $LocalPortRulesCount = ($FirewallRules | Where-Object {
            ($_.LocalPorts -Contains "$LocalPort") -And ($_.Protocol -Contains "$Protocol" -Or $_.Protocol -Contains $Null)
        } | Measure).Count

        Write-Output "`nRelated Rules for Process Path $ProcessPath and Local Port $LocalPort $Protocol"
        If (($ProcessPathRulesCount -gt 0) -or ($LocalPortRulesCount -gt 0)) {
            Write-Output "$ProcessPathRulesCount Process Path rule(s) found, $LocalPortRulesCount Local Port rule(s) found"
            Write-Output $ProcessPathRules
            Write-Output $LocalPortRules
        } Else {
            Write-Output "No rules found`n"
        }

        If ($Null -ne $FirewallLog) {
            # Get count of relevant Allow event from Firewall Log
            $FirewallAllowEventsCount = ($FirewallLog | Where-Object {
                ($_.Direction -Match 'RECEIVE') -And ($_.'Source IP' -ne '127.0.0.1') -And ($_.'Source IP' -ne $_.'Destination IP')
            } | Where-Object {
                ($_.'Destination Port' -eq $LocalPort) -And ($_.Protocol -eq $Protocol) -And ($_.Action -eq 'ALLOW')
            } | Measure).Count

            # Get count of unique Source IP for relevant Allow event from Firewall Log
            $FirewallAllowEventsIPCount = ($FirewallLog | Where-Object {
                ($_.Direction -Match 'RECEIVE') -And ($_.'Source IP' -ne '127.0.0.1') -And ($_.'Source IP' -ne $_.'Destination IP')
            } | Where-Object {
                ($_.'Destination Port' -eq $LocalPort) -And ($_.Protocol -eq $Protocol) -And ($_.Action -eq 'ALLOW')
            } | Select-Object -Property 'Source IP' -Unique | Measure).Count

            # Get count of relevant Drop event from Firewall Log
            $FirewallDropEventsCount = ($FirewallLog | Where-Object {
                ($_.Direction -Match 'RECEIVE') -And ($_.'Source IP' -ne '127.0.0.1') -And ($_.'Source IP' -ne $_.'Destination IP')
            } | Where-Object {
                ($_.'Destination Port' -eq $LocalPort) -And ($_.Protocol -eq $Protocol) -And ($_.Action -eq 'DROP')
            } | Measure).Count

            # Get count of unique Source IP for relevant Drop event from Firewall Log
            $FirewallDropEventsIPCount = ($FirewallLog | Where-Object {
                ($_.Direction -Match 'RECEIVE') -And ($_.'Source IP' -ne '127.0.0.1') -And ($_.'Source IP' -ne $_.'Destination IP')
            } | Where-Object {
                ($_.'Destination Port' -eq $LocalPort) -And ($_.Protocol -eq $Protocol) -And ($_.Action -eq 'DROP')
            } | Select-Object -Property 'Source IP' -Unique | Measure).Count
        } Else {
            # No Firewall Log found, marking variables as "N/A"
            $FirewallAllowEventsCount = 'N/A'
            $FirewallAllowEventsIPCount = 'N/A'
            $FirewallDropEventsCount = 'N/A'
            $FirewallDropEventsIPCount = 'N/A'
        }


        # Create new PS Custom Object to hold relevant listener properties
        $ListenerObject = New-Object PSCustomObject
        Add-Member -InputObject $ListenerObject -MemberType NoteProperty -Name "Process Path" -Value $ProcessPath
        Add-Member -InputObject $ListenerObject -MemberType NoteProperty -Name "Local Port" -Value $LocalPort
        Add-Member -InputObject $ListenerObject -MemberType NoteProperty -Name "Protocol" -Value $Protocol
        Add-Member -InputObject $ListenerObject -MemberType NoteProperty -Name "Process Path Rule Count" -Value $ProcessPathRulesCount
        Add-Member -InputObject $ListenerObject -MemberType NoteProperty -Name "Local Port Rule Count" -Value $LocalPortRulesCount
        Add-Member -InputObject $ListenerObject -MemberType NoteProperty -Name "Allow Events Count" -Value $FirewallAllowEventsCount
        Add-Member -InputObject $ListenerObject -MemberType NoteProperty -Name "Allow Events Unique Source IP Count" -Value $FirewallAllowEventsIPCount
        Add-Member -InputObject $ListenerObject -MemberType NoteProperty -Name "Drop Events Count" -Value $FirewallDropEventsCount
        Add-Member -InputObject $ListenerObject -MemberType NoteProperty -Name "Drop Events Unique Source IP Count" -Value $FirewallDropEventsIPCount

        # Add $ListenerObject to $ListenerSummary Array
        $ListenerSummary += $ListenerObject
    }

    Write-Output "########################"
    If ($Null -ne $FirewallLog) {
        $LogStart = "$($FirewallLog[1].Date) $($FirewallLog[1].Time)"
        # Trim the unicode "0" values from the start...for reasons
        $LogStart = $LogStart.TrimStart([char]0)
        $LogEnd = "$($FirewallLog[$($FirewallLog.count) -1].Date) $($FirewallLog[$($FirewallLog.count) -1].Time)"
        Write-Output "Firewall Log contains events within this time frame: $LogStart through $LogEnd"
    }
    Write-Output "Listener Summary:`n"
    Write-Output $ListenerSummary
}
