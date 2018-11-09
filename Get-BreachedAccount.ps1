Function Get-BreachedAccounts {
    <#
    .SYNOPSIS
    Get email accounts from Office 365 and check whether listed on HaveIBeenPwned.com
    Author: Jon Rodriguez
    .DESCRIPTION
    By default the script will prompt for Office 365 credentials in order to authenticate and get all mailboxes
    All mailboxes will be verified against HaveIBeenPwned's breached accounts and pastes
    Results will be written to the CSV report
    If a user or list of users are specified it will instead only check against those, you can click Cancel to credentials prompt
    If a Microsoft Teams webhook is specified, a message will be sent when completed
    .NOTES

    .EXAMPLE
    PS C:\>Get-BreachedAccounts -Credential (Get-Credential admin@example.com)

    PS C:\>Get-BreachedAccounts -Users "user@example.com"
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,Position = 0)]
        [System.Management.Automation.PSCredential]$Credential = (Get-Credential -Message "Office365 Admin Credentials"),
        [Parameter(Mandatory = $false,Position = 1)]
        [string[]]$User,
        [Parameter(Mandatory = $false,Position = 2)]
        [string]$Destination = 'C:\temp',
        [Parameter(Mandatory = $false,Position = 3)]
        [string]$Webhook
    )

    # If $Users not specified connect to Office 365
    If ($Credential) {
        Try {
            # Create and import Office 365 Session
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
    
            Import-PSSession $Session -DisableNameChecking | Out-Null

            $Users = (Get-Mailbox).UserPrincipalName
        } Catch {
            Write-Error "`nThere was an error while attempting to connect to Office 365:`n`n$_"
        }
    } Else {
        $Users = $User
    }

    # Specify TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    #Initiate counter variable $i at 0 for progress
    $i = 0

    #Loop through each user
    ForEach ($User in $Users) {
        # Increment counter variable $i by 1 for progress
        $i++

        # Write Progress to screen based on percentage of users searched
        Write-Progress -activity "Scanning for $User" -status "Scanned: $i of $($Users.count)" -percentComplete (($i / $($Users.count)) * 100)

        # Query HaveIBeenPwned API for breached account
        Try {
            $BreachedResult = Invoke-RestMethod -Method GET -Uri https://haveibeenpwned.com/api/v2/breachedaccount/$User
        } Catch {
            $BreachedResult = $_.Exception
        }

        # Sleep for 2 second to not exceed HaveIBeenPwned rate limits
        Start-Sleep -Seconds 2

        # Query HaveIBeenPwned API for pasted account
        Try {
            $PasteResult = Invoke-RestMethod -Method GET -Uri https://haveibeenpwned.com/api/v2/pasteaccount/$User
        } Catch {
            $PasteResult = $_.Exception
        }

        # Sleep for 2 second to not exceed HaveIBeenPwned rate limits
        Start-Sleep -Seconds 2

        # Create a custom object to hold the results and export to a CSV
        [PSCustomObject]@{
            'User' = "$User"
            'Breached Result' = ($BreachedResult | Out-String).Trim()
            'Paste Result' = ($PasteResult | Out-String).Trim()
        } | Export-Csv -Path "$Destination\BreachResults.csv" -NoTypeInformation -Append            
    }

    # Remove Office 365 Session
    If ($Session) {Remove-PSSession $Session}

    # Post update to Teams if Webhook is specified
    If ($Webhook) {
        Invoke-RestMethod -Method Post -ContentType 'Application/Json' -Body '{"text":"Get-BreachedAccount has completed"}' -Uri $Webhook
    }

    Read-Host "`nIf everything was successful, results can be found at $Destination\BreachResults.csv`n`n"
}
