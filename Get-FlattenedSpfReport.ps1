[CmdletBinding()]
param(
    [string]$Domain,
    [string[]]$ReliantIncludes,
    [string]$Webhook
)

Function Get-FlattenedSpf {
    <#
    .SYNOPSIS
    Get SPF Records and flatten them to IP Addresses
    Author: Jon Rodriguez
    #>

    [CmdletBinding()]
    param(
        [string]$Domain
    )

    Write-Verbose "Resolving SPF record for: $domain"
    # Get the current SPF record from public DNS
    $currentSPF = Resolve-DnsName -Name $domain -Type TXT -Server 8.8.8.8 |
        Where-Object { $_.strings -like "v=spf1*" } | Select-Object -ExpandProperty Strings
    $currentSPF = $currentSPF -join ""

    # Trim the v=spf1 and all value
    $currentSPF = $currentSPF.TrimStart('v=spf1 ')
    $currentSPF = $currentSPF.TrimEnd(' -+?~all')
    # Split the record by spaces so each line is a specific value
    $currentSPF = $currentSPF.Split(' ')

    # Loop through each line to parse records
    foreach ($record in $currentSPF) {
        $splitRecord = $null
        # Split on ":" as this is always used to separate type/value
        $splitRecord = $record.Split(":")

        $recordType = $splitRecord[0]
        $recordValue = $splitRecord[1]

        # Recursion if an Include is found
        if ($recordType -eq "include") {
            Get-FlattenedSpf $recordValue
        } elseif ($recordType -like "ip*") {
            [PSCustomObject]@{
                RecordType  = $recordType
                RecordValue = $recordValue
            }
        } elseif ($recordType -eq 'a') {
            if ($null -eq $recordValue) {
                $aRecord = (Resolve-DnsName -Name $domain -Type A -Server 8.8.8.8 | Select-Object -Property IPAddress).IPAddress
                [PSCustomObject]@{
                    RecordType  = 'A'
                    RecordValue = $aRecord
                }
            } else {
                try {
                    $aRecord = (Resolve-DnsName -Name $recordValue -Type A -Server 8.8.8.8 -ErrorAction Stop | Select-Object -Property IPAddress).IPAddress

                    [PSCustomObject]@{
                        RecordType  = $recordType
                        RecordValue = $aRecord
                    }
                } catch {
                    $aRecord = $_.exception.message
                    Write-Warning $aRecord
                }
            }
        } elseif ($recordType -eq 'mx') {
            $MXRecords = ((Resolve-DnsName -Name $domain -Type MX -Server 8.8.8.8 | Select-Object -Property NameExchange).NameExchange |
                Resolve-DnsName -Server 8.8.8.8 | Select-Object -Property IPAddress).IPAddress

            foreach ($MXRecord in $MXRecords) {
                [PSCustomObject]@{
                    RecordType  = 'MX'
                    RecordValue = $MXRecord
                }
            }
        } elseif ($null -eq $recordType) {
            Write-Warning "Unknown record type found: $record"
        }
    }
}

# Get all flattened SPF records for the domain to check
$domainToCheck = Get-FlattenedSpf -Domain $domain -Verbose
Write-Verbose "Flattened $domain record to ip4/ip6 with a count of $($domainToCheck.Count)"

$missingRecords = @{}

# Loop through each include to get flattened SPF records
foreach ($include in $reliantIncludes) {
    $flattenedResults = Get-FlattenedSpf -Domain $include -Verbose
    Write-Verbose "Flattened $include record to ip4/ip6 with a count of $($flattenedResults.Count)"

    # Check each flattened SPF record against the domain to check
    foreach ($result in $flattenedResults.RecordValue) {
        if ($domainToCheck.RecordValue -notcontains $result) {
            Write-Verbose "$result not found in domain"

            if ($missingRecords.Contains($include)) {
                $missingRecords[$include] += $result
            } else {
                $missingRecords.Add($include, @($result))
            }
        }
    }
}

# If no missing records are found, do nothing, otherwise send Teams message
if ($missingRecords.count -eq 0) {
    Write-Verbose "All records processed, no missing records found"
} else {
    $facts = @()

    foreach ($record in $missingRecords.Keys) {
        $facts += @{
          name = $record
          value = $missingRecords[$record] -join ', '
        }
      }

      $body = ConvertTo-Json -Depth 4 @{
          title    = "Missing SPF Records found"
          text     = "Action needed: Update SPF Records for $domain"
          sections = @(
              @{
                  title = "Missing Records"
                  facts = $facts
              }
          )
      }

    Write-Warning "Missing records found with $($missingRecords.count) Includes affected"

    Invoke-RestMethod -Uri $webhook -Method Post -Body $body -ContentType 'application/json'
}
