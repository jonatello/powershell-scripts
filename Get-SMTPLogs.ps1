Function Get-SMTPLogs {
    <#
    .SYNOPSIS
    Audit SMTP Logs
    Author: Jon Rodriguez
    .DESCRIPTION
    Get all SMTP logs and parse the fields into PowerShell objects which can then be easily filtered
    
    .PARAMETER Path
    Path to directory to find and get the content of SMTP .log files
    Defaults to $Null so that the default SMTP logging path will be used

    .PARAMETER Start
    Start time for logs to be included
    Defaults to 24 hours ago

    .PARAMETER End
    End time for logs to be included
    Defaults to now

    .PARAMETER Progress
    Progress bar for log parsing status
    Defaults to disabled

    .PARAMETER Summarize
    Summarize parsed logs into a table representing the count of reply codes found
    Defaults to $Null so that parsed logs are output instead

    .NOTES
    Fields used are the default for Microsoft Internet Information Services 8.5 (https://docs.microsoft.com/en-us/windows/desktop/http/w3c-logging):
    Fields: date time c-ip cs-username s-sitename s-computername s-ip s-port cs-method cs-uri-stem cs-uri-query sc-status sc-win32-status sc-bytes cs-bytes time-taken cs-version cs-host cs(User-Agent) cs(Cookie) cs(Referer)

    SMTP Reply codes used with the Summarize parameter are from here - https://www.greenend.org.uk/rjk/tech/smtpreplies.html

    .EXAMPLE
    # Get all SMTP logs from the default log path and parse everything within the last 24 hours
    Get-SMTPLogs

    # Get all SMTP logs from the default log path and parse everything within the last 7 days, only output summary of reply codes
    Get-SMTPLogs -Start ((Get-Date).AddDays(-7)) -Summarize $True

    # Get all SMTP logs from a custom path and parse everything from 3 days ago to today, write progress to screen
    Get-SMTPLogs -Path C:\temp\smtp_logs -Start ((Get-Date).AddDays(-3)) -End (Get-Date) -Progress $True

    # Get all SMTP logs and group by Client IP Address
    Get-SMTPLogs | Format-Table -GroupBy c-ip

    #>

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage="Path to find SMTP Logs (ie c:\temp)"
        )]
        [string]$Path = $Null,

        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage="Start time to include logs (ie 2 days ago)"
        )]
        [datetime]$Start = ((Get-Date).AddDays(-1)),

        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage="End time to include logs (ie Now)"
        )]
        [datetime]$End = (Get-Date),

        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage="Specify `$True to show progress of log parsing"
        )]
        [string]$Progress = $False,

        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage="Specify `$True to only output summary information"
        )]
        [string]$Summarize = $False
    )

    # Set SMTP Logging default path
    $DefaultLogPath = 'C:\WINDOWS\system32\LogFiles\SMTPSVC1'

    # Create an array to store the parsed lines
    $ParsedLog = @()

    # Initiate a counter for progress
    $i = 0

    # Initiate Logs as null
    $Logs = $Null

    Try {
        # Get SMTP Log from $Path if specified
        If ($Path) {
            # Get all potential log files
            $LogFiles = Get-ChildItem -Path $Path -Name *.log

            # Loop through all log files and skip the first 5 informational lines
            ForEach ($LogFile in $LogFiles) {
                $Logs += Get-Content -Path $Path\$LogFile | Select-Object -Skip 5
            }

            If (($Logs.count) -eq 0) {
                Write-Error "No logs found at specified path - $Path"
                Return
            } Else {
                Write-Output "Using path specified for SMTP Log - $Path"
            }

        # Get SMTP Log from Default Path if exists
        } ElseIf (Test-Path -Path $DefaultLogPath) {
            # Get all potential log files
            $LogFiles = Get-ChildItem -Path $DefaultLogPath -Name *.log

            # Loop through all log files and skip the first 5 informational lines
            ForEach ($LogFile in $LogFiles) {
                $Logs += Get-Content -Path $DefaultLogPath\$LogFile | Select-Object -Skip 5
            }

            If (($Logs.count) -eq 0) {
                Write-Error "No logs found at default path - $DefaultLogPath"
                Return
            } Else {
                Write-Output "SMTP Log Found via Default Path - $DefaultLogPath"
            }
        } Else {
            Write-Error "No SMTP Log found"
            Return
        }
    } Catch {
        Write-Error "Unable to retrieve SMTP Log"
        Return
    }

    # Parse each line in the SMTP Log, splitting on new lines
    ForEach ($Line in $Logs -split "\n") {
        
        # If Progress is set to True, write progress
        If ($Progress -eq $True) {
            # Increment counter variable $i by 1 for progress
            $i++

            # Write Progress to screen based on percentage of lines parsed, note this can greatly increase the runtime
            Write-Progress -activity "Parsing line $i" -status "Parsed: $i of $($Logs.Count)" -percentComplete (($i / $($Logs.Count)) * 100)
        }
        
        # Split each line by spaces
        $LineData = $Line.Split(" ")

        # Create a timestamp variable from the date and time fields
        Try {
            $Timestamp = [datetime]($LineData[0] + ' ' + $LineData[1])
        } Catch {
            # If there is no date and time field manually set the timestamp to 10 years ago to exclude it
            $Timestamp = ((Get-Date).AddDays(-3650))
        }


        # If the timestamp variable is between the Start and End times designated, include it in the parsed logs
        If (($Timestamp -gt $Start) -and ($Timestamp -lt $End)) {
            # Create new PS Custom Object and add relevant properties
            $ParsedLine = New-Object PSObject
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "date" -Value $LineData[0]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "time" -Value $LineData[1]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "c-ip" -Value $LineData[2]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "cs-username" -Value $LineData[3]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "s-sitename" -Value $LineData[4]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "s-computername" -Value $LineData[5]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "s-ip" -Value $LineData[6]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "s-port" -Value $LineData[7]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "cs-method" -Value $LineData[8]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "cs-uri-stem" -Value $LineData[9]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "cs-uri-query" -Value $LineData[10]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "sc-status" -Value $LineData[11]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "sc-win32-status" -Value $LineData[12]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "sc-bytes" -Value $LineData[13]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "cs-bytes" -Value $LineData[14]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "time-taken" -Value $LineData[15]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "cs-version" -Value $LineData[16]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "cs-host" -Value $LineData[17]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "cs(User-Agent)" -Value $LineData[18]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "cs(Cookie)" -Value $LineData[19]
            Add-Member -InputObject $ParsedLine -MemberType NoteProperty -Name "cs(Referer)" -Value $LineData[20]

            # Add the parsed line to the parsed log array
            $ParsedLog += $ParsedLine
        }
    }

    # If Summarize is set to True, only output the reply code summary information
    If ($Summarize -eq $True) {
        # Create new PS Custom Object to store summary information and add relevant properties
        $Summary = New-Object PSObject
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "200 - (nonstandard success response, see rfc876)" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "200*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "211 - System status, or system help reply" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "211*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "214 - Help message" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "214*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "220 - <domain> Service ready" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "220*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "221 - <domain> Service closing transmission channel" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "221*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "250 - Requested mail action okay, completed" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "250*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "251 - User not local; will forward to <forward-path>" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "251*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "252 - Cannot VRFY user, but will accept message and attempt delivery" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "252*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "354 - Start mail input; end with <CRLF>.<CRLF>" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "354*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "421 - <domain> Service not available, closing transmission channel" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "421*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "450 - Requested mail action not taken: mailbox unavailable" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "450*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "451 - Requsted action aborted: local error in processing" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "451*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "452 - Requested action not taken: insufficient system storage" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "452*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "500 - Syntax error, command unrecognised" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "500*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "501 - Syntax error in parameters or arguments" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "501*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "502 - Command not implemented" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "502*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "503 - Bad sequence of commands" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "503*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "504 - Command parameter not implemented" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "504*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "521 - <domain> does not accept mail (see rfc1846)" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "521*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "530 - Access denied (???a Sendmailism)" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "521*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "550 - Requsted action not taken: mailbox unavailable" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "550*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "551 - User not local; please try <forward-path>" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "551*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "552 - Requsted mail action aborted: exceeded storage allocation" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "552*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "553 - Requested action not taken: mailbox name not allowed" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "553*" | Measure-Object).Count)
        Add-Member -InputObject $Summary -MemberType NoteProperty -Name "554 - Transaction failed" -Value (($ParsedLog | 
            Where-Object -Property cs-uri-query -like "554*" | Measure-Object).Count)

        # Write the output of the Summary
        Write-Output $Summary

    } Else {
        # Write the output of the Parsed Log
        Write-Output $ParsedLog
    }
}
