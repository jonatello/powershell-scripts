Function Get-ExternalVulnerabilities {
    <#
    .SYNOPSIS
    Get External Vulnerabilities from domain environment
    Author: Jon Rodriguez
    .DESCRIPTION
    This script will run through a number of checks in order to assess an environment for external vulnerabilities
    If a Microsoft Teams webhook is specified, a message will be sent when completed
    .NOTES
    Requires the following from the workstation it's being run on:
    NMAP - https://nmap.org/download.html
    .EXAMPLE
    PS C:\>Get-ExternalVulnerabilities -IPs (Get-Content c:\temp\list.txt) -ShodanAPIKey "xxxx"
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$IPs,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$ShodanAPIKey,
        [Parameter(Mandatory = $false,Position = 2)]
        [string]$Destination = 'C:\temp\ExternalScans',
        [Parameter(Mandatory = $false,Position = 3)]
        [string]$Webhook
    )

    # Create $Destination if it doesn't exist
    If (!(Test-Path "$Destination")) {
        New-Item -Path "$Destination" -ItemType Directory
    }

    #Initiate counter variable $i at 0 for progress
    $i = 0

    # Loop through each IP or Hostname
    ForEach ($IP in $IPs) {
        # Increment counter variable $i by 1 for progress
        $i++

        # Create directory to hold scans
        New-Item -Path "$Destination\$IP" -ItemType Directory

        # Write Progress to screen based on percentage of IPs searched
        Write-Progress -activity "Scanning for $IP" -status "Scanned: $i of $($IPs.Count)" -percentComplete (($i / $($IPs.Count)) * 100)

        # Check for an existing TXT record starting with "v=spf1"
        $SPFRecord = (Resolve-DnsName -Name $IP -Server 8.8.8.8 -Type TXT | Where-Object Strings -like "v=spf1*").Strings
        # If there's no result, notate accordingly
        If (!$SPFRecord) {$SPFRecord = "TXT starting with 'v=spf1' record not found"}
        
        # Check for a DKIM Selector1 record
        $DKIMSelector1Record = (Resolve-DnsName -Name selector1._domainkey.$IP -Server 8.8.8.8 -Type TXT -ErrorAction SilentlyContinue).Strings
        # If there's no result, notate accordingly
        If (!$DKIMSelector1Record) {$DKIMSelector1Record = "Standard DKIM selector1._domainkey.$IP record not found"}
        
        # Check for a DKIM Selector2 record
        $DKIMSelector2Record = (Resolve-DnsName -Name selector2._domainkey.$IP -Server 8.8.8.8 -Type TXT -ErrorAction SilentlyContinue).Strings
        # If there's no result, notate accordingly
        If (!$DKIMSelector2Record) {$DKIMSelector2Record = "Standard DKIM selector2._domainkey.$IP record not found"}
        
        # Check for a DMARC record
        $DMARCRecord = (Resolve-DnsName -Name _dmarc.$IP -Server 8.8.8.8 -Type TXT -ErrorAction SilentlyContinue).Strings
        # If there's no result, notate accordingly
        If (!$DMARCRecord) {$DMARCRecord = "Standard DMARC _dmarc.$IP record not found"}

        #Use Shodan to resolve the domain to an IP
        $ResolvedIP = (Invoke-RestMethod -Method GET -Uri https://api.shodan.io/dns/resolve?hostnames=$IP"&"key=$ShodanAPIKey).$IP
        #Search for related breaches and store in Results
        Try {
            $ShodanResults = Invoke-RestMethod -Method GET -Uri https://api.shodan.io/shodan/host/"$ResolvedIP"?key=$ShodanAPIKey
            $ShodanResults | Out-File -FilePath "$Destination\$IP\shodan.txt"
        } Catch {
            $ShodanResults = $_.Exception
        }

        # Check for vulnerabilities with NMAP
        $NMAPScan = nmap -sV --script vuln $IP -oX "$Destination\$IP\vuln.xml"

        # Check SSL certificate and enumerate ciphers
        $NMAPSsl = nmap -sV --script "ssl-*" -p 443 $IP -oX "$Destination\$IP\ssl.xml"

        # Check for name on spamlists
        $NMAPDns = nmap -sn $IP --script dns-blacklist -oX "$Destination\$IP\dns.xml"

        # Add some grep / filtering to add additional columns of particular interest
        # Specific ports per IP
            
        # Create a custom object to hold the results
        [PSCustomObject]@{
            'IP or Hostname' = $IP
            'SPF Record' = $SPFRecord
            'DKIM Selector1 Record' = $DKIMSelector1Record
            'DKIM Selector2 Record' = $DKIMSelector2Record
            'DMARC Record' = $DMARCRecord
            'Shodan Results' = "Review \Scans\$IP\shodan.txt"
            'NMAP Scan Results' = "Review \Scans\$IP\vuln.xml"
            'NMAP SSL Scan' = "Review \Scans\$IP\ssl.xml"
            'NMAP DNS Scan' = "Review \Scans\$IP\dns.xml"
        } | 
        # Export the results to a CSV
        Export-Csv -Path "$Destination\ScanResults.csv" -NoTypeInformation -Append
    }

    # Compress the results into a zip file
    Try {
        Write-Output "`nCompressing the results`n`n"

        Add-Type -Assembly "system.io.compression.filesystem"
        [io.compression.zipfile]::CreateFromDirectory("$Destination", "$Destination.zip")

        # Remove redundant folder
        Remove-Item -Path "$Destination" -Recurse
    }
    Catch {
        Write-Error "`nThere was an error while attempting to compress the results:`n`n$_"
    }

    # Post update to Teams if Webhook is specified
    If ($Webhook) {
        Invoke-RestMethod -Method Post -ContentType 'Application/Json' -Body '{"text":"Get-ExternalVulnerabilities has completed"}' -Uri $Webhook
    }

    Read-Host "`nIf everything was successful, results can be found at $Destination.zip`n`n"
}
