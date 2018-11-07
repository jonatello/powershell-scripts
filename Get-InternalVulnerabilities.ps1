Function Get-InternalVulnerabilities {
    <#
    .SYNOPSIS
    Get Internal Vulnerabilities from domain environment
    Author: Jon Rodriguez
    .DESCRIPTION
    This script will run through a number of checks in order to assess a Windows Domain environment for vulnerabilities:
    Runs the Microsoft Baseline Security Analyzer against all devices within the domain using Domain Administrator authentication
    Generates HTML and XML GPO reports then loops through GPO's found for misconfigurations
    Gets all Domain Users, Computers, and Administrators in AD
    Loops through all users and computers found for items to flag such as password set to never expire
    Exports all report information to a CSV to be reviewed
    Compresses all reports into a single .ZIP archive
    If a Microsoft Teams webhook is specified, a message will be sent when completed
    .NOTES
    Requires the following from the workstation it's being run on:
    MBSA - https://www.microsoft.com/en-us/download/details.aspx?id=7558
    WMI connectivity to all devices
    Remote Server Administration Tools - https://www.microsoft.com/en-us/download/details.aspx?id=45520
    Domain Admin credentials
    .EXAMPLE
    PS C:\>Get-InternalVulnerabilities -Credentials (Get-Credential admin) -Domain "example" -DomainController "dc.example.com"
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,Position = 0)]
        [System.Management.Automation.PSCredential]$Credentials = (Get-Credential -Message "Domain Admin Credentials (Ex: Domain\Administrator)"),
        [Parameter(Mandatory = $false,Position = 1)]
        [string]$Domain = (Read-Host "Enter the NetBIOS compatible domain name (Ex: MyDomain) instead of Fully Qualified Domain Name (Ex:Mydomain.com)"),
        [Parameter(Mandatory = $false,Position = 2)]
        [string]$DomainController = (Read-Host "Enter the Fully Qualified Domain Name of the Primary Domain Controller"),
        [Parameter(Mandatory = $false,Position = 3)]
        [string]$Destination = 'C:\temp\InternalScans',
        [Parameter(Mandatory = $false,Position = 4)]
        [string]$Webhook
    )

    # Set date variables
    $30days = ((Get-Date).AddDays(-30))
    $90days = ((Get-Date).AddDays(-90))

    # Get Username and Password from Credentials object
    $Username = $($Credentials.UserName)
    $Password = $($Credentials.GetNetworkCredential().password)

    # Create $Destination folder if it doesn't exist
    If (!(Test-Path $Destination)) {
        New-Item -Path $Destination -ItemType Directory
    }

    # Launch Microsoft Baseline Security Analyzer against domain
    Try {
        Write-Output "`nLaunching Microsoft Baseline Security Analyzer domain scan`n`n"

        & 'C:\Program Files\Microsoft Baseline Security Analyzer 2\mbsacli.exe' /nd /nvc /qt /u $Username /p $Password /d $Domain /rd $Destination > $Destination\MBSA.log
    }
    Catch {
        Write-Error "`nThere was an error while attempting to run the MBSA scans:`n`n$_"
    }

    # Generate HTML and XML GPO reports
    Try {
        Write-Output "`nQuerying Domain Controller for GPO reports`n`n"
        
        Get-GPOReport -All -ReportType HTML -Path $Destination\GPO.html -Server $DomainController
        Get-GPOReport -All -ReportType XML -Path $Destination\GPO.xml -Server $DomainController

        # Store gpo.xml in variable
        $GPOs = [xml](Get-Content -Path $Destination\GPO.xml)
    }
    Catch {
        Write-Error "`nThere was an error while attempting to generate GPO reports:`n`n$_"
    }

    # Identify GPO issues (filter further for these below)
        #Enforce Password history (6 passwords remembered)
        #Maximum password age (90 days)
        #Minimum password age (0 days)
        #Minimum password length (8 characters)
        #Password must meet complexity requirements (Enabled)
        #Store passwords using reversible encryption (Disabled)
        #Account lockout duration (30 minutes)
        #Account lockout threshold (7 invalid logon attempts)
        #Reset account lockout counter after (30 minutes)
        #Password set to never expire (Disabled, configure to expire regularly)
        #Local account password (same complexity rules as domain)
        #Audit user login enabled
        #Screen lock configured

    # Loop through each Account related GPO
    ForEach ($GPO in $($GPOs.report.GPO.Computer.ExtensionData.Extension.Account)) {
        # Only append if the Name is not null
        If ($($GPO.Name) -ne $null) {

            # Create PS Object to store results
            [PSCustomObject]@{
                'Name' = "$($GPO.Name)"
                'Setting Number' = "$($GPO.SettingNumber)"
                'Setting Boolean' = "$($GPO.SettingBoolean)"
            } | 
                # Export the results to a CSV
                Export-Csv -Path $Destination\GPOResults.csv -NoTypeInformation -Append
        }
    }

    # Loop through each SecurityOptions related GPO
    ForEach ($GPO in $($GPOs.report.GPO.Computer.ExtensionData.Extension.SecurityOptions)) {
        # Only append if the KeyName is not null
        If ($($GPO.KeyName) -ne $null) {
            
        [PSCustomObject]@{
            'Name' = "$($GPO.KeyName)"
            'Setting Number' = "$($GPO.SettingNumber)"
            'Setting Boolean' = $null
        } | 
            # Export the results to a CSV
            Export-Csv -Path $Destination\GPOResults.csv -NoTypeInformation -Append
        }
    }

    # Get Active Directory objects
    Try {
        Write-Output "`nQuerying Active Directory for Domain Users`n`n"

        # Get all Domain Users
        $DomainUsers = Get-ADUser -Server $DomainController -Credential $Credentials -Filter {Enabled -eq "true"} -Properties PasswordNeverExpires,PasswordLastSet,LastLogonTimeStamp |
        Select-Object distinguishedName,Enabled,GivenName,name,objectClass,objectGUID,PasswordNeverExpires,PasswordLastSet,SamAccountName,SID,Surname,UserPrincipalName,@{Name="LastLogonTimeStamp"; Expression={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}}

        Write-Output "`nQuerying Active Directory for Domain Computers`n`n"

        # Get all Domain Computers
        $DomainComputers = Get-ADComputer -Server $DomainController -Credential $Credentials -Filter {Enabled -eq "true"} -Properties LastLogonTimeStamp |
        Select-Object distinguishedName,DNSHostName,Enabled,name,objectClass,objectGUID,SamAccountname,SID,@{Name="LastLogonTimeStamp"; Expression={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}}

        Write-Output "`nQuerying Active Directory for Domain Admins`n`n"

        # Get all Domain Admins
        $DomainAdmins = Get-ADGroupMember -Server $DomainController -Credential $Credentials -Identity 'Domain Admins' |
        Select-Object distinguishedName,name,objectClass,objectGUID,SamAccountName,SID
    }
    Catch {
        Write-Error "`nThere was an error while attempting to query Active Directory:`n`n$_"
    }

    # Initiate counter variable $i at 0 for progress
    $i = 0
    # Loop through each Domain User
    ForEach ($Object in $DomainUsers) {
        # Increment counter variable $i by 1 for progress
        $i++

        # Write Progress to screen based on percentage of users searched
        Write-Progress -activity "Scanning for $($Object.Name)" -status "Scanned: $i of $($DomainUsers.Count)" -percentComplete (($i / $($DomainUsers.Count)) * 100)

        # Check if user is Domain Admin
        If ($DomainAdmins.Name -contains $Object.Name) {
            $DomainAdminCheck = "Domain Admin"
        } Else {
            $DomainAdminCheck = "Not Domain Admin"
        }

        # Check if user password is set to never expire
        If ($Object.PasswordNeverExpires -eq "true") {
            $PasswordCheck = "Password set to Never Expire"
        } Else {
            $PasswordCheck = "Password expires"
        }

        # Check LastLogonTimestamp for age
        If ($Object.LastLogonTimeStamp -lt $90days) {
            $LastLogonCheck = "Older than 90 days"
        } ElseIf ($Object.LastLogonTimeStamp -lt $30days) {
            $LastLogonCheck = "Older than 30 days"        
        } Else {
            $LastLogonCheck = "Active"
        }

        [PSCustomObject]@{
            'Distinguished Name' = "$($Object.distinguishedName)"
            'Enabled' = "$($Object.Enabled)"
            'Given Name' = "$($Object.GivenName)"
            'Name' = "$($Object.name)"
            'Object Class' = "$($Object.objectClass)"
            'Object GUID' = "$($Object.objectGUID)"
            'Password Never Expires' = "$($Object.PasswordNeverExpires)"
            'Password Last Set' = "$($Object.PasswordLastSet)"
            'SAM Account Name' = "$($Object.SamAccountName)"
            'SID' = "$($Object.SID)"
            'Surname' = "$($Object.Surname)"
            'User Principal Name' = "$($Object.UserPrincipalName)"
            'Last Logon Time Stamp' = "$($Object.LastLogonTimeStamp)"
            'Domain Admin Check' = "$DomainAdminCheck"
            'Password Check' = "$PasswordCheck"
            'Last Logon Check' = "$LastLogonCheck"
        } | 
            # Export the results to a CSV
            Export-Csv -Path $Destination\UserResults.csv -NoTypeInformation -Append
    }

    # Initiate counter variable $i at 0 for progress
    $i = 0

    # Loop through each Domain Computer
    ForEach ($Object in $DomainComputers) {
        # Increment counter variable $i by 1 for progress
        $i++

        # Write Progress to screen based on percentage of computers searched
        Write-Progress -activity "Scanning for $($Object.Name)" -status "Scanned: $i of $($DomainComputers.Count)" -percentComplete (($i / $($DomainComputers.Count)) * 100)

        # Check LastLogonTimestamp for age
        If ($Object.LastLogonTimeStamp -lt $90days) {
            $LastLogonCheck = "Older than 90 days"
        } ElseIf ($Object.LastLogonTimeStamp -lt $30days) {
            $LastLogonCheck = "Older than 30 days"        
        } Else {
            $LastLogonCheck = "Active"
        }

        [PSCustomObject]@{
            'Distinguished Name' = "$($Object.distinguishedName)"
            'DNS Host Name' = "$($Object.DNSHostName)"
            'Enabled' = "$($Object.Enabled)"
            'Name' = "$($Object.name)"
            'Object Class' = "$($Object.objectClass)"
            'Object GUID' = "$($Object.objectGUID)"
            'SAM Account Name' = "$($Object.SamAccountName)"
            'SID' = "$($Object.SID)"
            'Last Logon Time Stamp' = "$($Object.LastLogonTimeStamp)"
            'Last Logon Check' = "$LastLogonCheck"
        } | 
            # Export the results to a CSV
            Export-Csv -Path $Destination\ComputerResults.csv -NoTypeInformation -Append
    }

    # Compress the results into a zip file
    Try {
        Write-Output "`nCompressing the results`n`n"

        Add-Type -Assembly "system.io.compression.filesystem"
        [io.compression.zipfile]::CreateFromDirectory("$Destination", "$Destination.zip")

        # Remove redundant folder
        Remove-Item -Path $Destination -Recurse
    }
    Catch {
        Write-Error "`nThere was an error while attempting to compress the results:`n`n$_"
    }

    # Post update to Teams if Webhook is specified
    If ($Webhook) {
        Invoke-RestMethod -Method Post -ContentType 'Application/Json' -Body '{"text":"Get-InternalVulnerabilities has completed"}' -Uri $Webhook
    }

    Read-Host "`nIf everything was successful, results can be found at $Destination.zip`n`n"
}
