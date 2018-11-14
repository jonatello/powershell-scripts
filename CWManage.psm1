Function Get-CWTicket {
    <#
    .SYNOPSIS
    Retrieves an object formatted ConnectWise Ticket.
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW PublicKey, PrivateKey, and a Ticket ID
    If the ticket exists it will return you all the information
    If it doesnt exist it will return $False.
    .NOTES
    N/A
    .EXAMPLE
    Get-CWTicket -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -TicketId 160
    #>

    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $true,Position = 4)]
        [INT]$TicketId
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/service/tickets/$TicketId"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Company + '+' + $PublicKey + ':' + $PrivateKey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Get-CWTicketList {
    <#
    .SYNOPSIS
    Retrieves an object formatted ConnectWise Ticket List.
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW PublicKey and PrivateKey
    A list of all tickets will be returned.
    .NOTES
    N/A
    .EXAMPLE
    Get-CWTicketList -PublicKey $PublicKey -PrivateKey $PrivateKey -Domain example.com -Site connectwise.example.com -PageSize 25 -Page 1
    #>

    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$publickey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$privatekey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $false,Position = 4)]
        [int]$PageSize = 25,
        [Parameter(Mandatory = $false,Position = 5)]
        [int]$Page = 1
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/service/tickets?pagesize=$PageSize&page=$Page"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Domain + '+' + $publickey + ':' + $privatekey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Get-CWCompany {
    <#
    .SYNOPSIS
    Retrieves an object formatted ConnectWise Company specified by a specific id
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW publickey, privatekey, and a company id
    If the company exists it will return you all the information
    If it doesnt exist it will return $False.
    .NOTES
    N/A
    .EXAMPLE
    Get-CWCompany -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -CompanyId 2712
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $true,Position = 4)]
        [int]$CompanyId
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/company/companies/$CompanyId"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Domain + '+' + $PublicKey + ':' + $PrivateKey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try{
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Get-CWCompanies {
    <#
    .SYNOPSIS
    Retrieves an object formatted list of all ConnectWise Companies
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW PublicKey and PrivateKey and it will return all ConnectWise Companies
    .NOTES
    N/A
    .EXAMPLE
    Get-CWCompanies -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -PageSize 25 -Page 1
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $false,Position = 4)]
        [int]$PageSize = 25,
        [Parameter(Mandatory = $false,Position = 5)]
        [int]$Page = 1
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/company/companies?pagesize=$PageSize&page=$Page"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Company + '+' + $PublicKey + ':' + $PrivateKey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Get-CWCompanyTeams {
    <#
    .SYNOPSIS
    Retrieves an object formatted list of all ConnectWise Company Teams for a specified CompanyId
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW PublicKey, PrivateKey, and CompanyId and it will return all ConnectWise Company Teams
    .NOTES
    N/A
    .EXAMPLE
    Get-CWCompanyTeams -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -CompanyID 2 -PageSize 25 -Page 1
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $true,Position = 4)]
        [int]$CompanyId,
        [Parameter(Mandatory = $false,Position = 5)]
        [int]$PageSize = 25,
        [Parameter(Mandatory = $false,Position = 6)]
        [int]$Page = 1
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/company/companies/$CompanyId/teams?pagesize=$PageSize&page=$Page"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Company + '+' + $PublicKey + ':' + $PrivateKey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Get-CWBoard {
    <#
    .SYNOPSIS
    Retrieves an object formatted ConnectWise Board.
    Author: Jon Rodriguez
    .DESCRIPTION
    This function will return all boards with a name LIKE the name supplied in the $Board parameter
    .NOTES
    N/A
    .EXAMPLE
    Get-CWBoard -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -Board "sys"
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $true,Position = 4)]
        [string]$Board
    )

    [string]$BaseUri     = "https://$Site/v4_6_Release/apis/3.0/service/boards"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring = $Company + '+' + $publickey + ':' + $privatekey


    $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        "Authorization"="Basic $encodedAuth"
    }

    $Body = @{
        "fields" = "id,name"
        "conditions" = "name LIKE '%$Board%'"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Body $Body -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

function New-CWTicket {
    <#
    .SYNOPSIS
    Creates a new ticket
    Author: Jon Rodriguez

    .DESCRIPTION
    Pass this function the CW publickey, privatekey, Summary, Company Id, Initial Description, and Service Board
    It will create a ticket on the designated Service Board under the specified Company Id

    .NOTES
    Fields you can customize on the ticket:
        Summary
        ServiceBoard
        Company

    .EXAMPLE
    New-CWTicket -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -Ticket $Ticket -ServiceBoard $ServiceBoard -CompanyId $CompanyId
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $True,Position = 4)]
        [string]$Summary,
        [Parameter(Mandatory = $True,Position = 5)]
        [INT]$CompanyId,
        [string]$InitialDescription,
        [string]$ServiceBoard,
        [string]$Type,
        [string]$SubType
    )

    [string]$BaseUri     = "https://$Site/v4_6_Release/apis/3.0/service/tickets"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring = $Company + '+' + $publickey + ':' + $privatekey
    $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    #Removing disallowed character " and replacing with ' and setting Summary input to maximum 100 characters
    $Summary = $Summary.Replace('"', "'")
    If ($Summary.Length -gt 100) {
        $Summary = $Summary.substring(0,100)
    }
    $InitialDescription = $InitialDescription.Replace('"', "'")

$Body= @"
{
    "summary"   :    "$Summary",
    "initialDescription" : "$InitialDescription",
    "board"     :    {"name": "$ServiceBoard"},
    "status"    :    {"name": "New"},
    "company"   :    {"id": "$CompanyId"},
    "type"      :    {"name": "$Type"},
    "subType"   :    {"name": "$SubType"}
}
"@

    $Headers = @{
        "Authorization"="Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Post -Body $Body
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }

}

function Find-CWTicket {
    <#
    .SYNOPSIS
    Finds a CW ticket
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW PublicKey, PrivateKey, and a SQL formatted search to return all related tickets
    .NOTES
    N/A
    .EXAMPLE
    Find-CWTicket -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -Search "Summary LIKE 'Offline Servers:%' AND closedFlag = False AND status/Name NOT LIKE '%Completed%'"
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $True,Position = 4)]
        [string]$Search,
        [Parameter(Mandatory = $False,Position = 5)]
        [int]$PageSize = 25,
        [Parameter(Mandatory = $false,Position = 6)]
        [int]$Page = 1   
    )

    #Set variables to be properly formatted for a call, including proper encoding of the authstring
    [string]$BaseUri     = "https://$Site/v4_6_Release/apis/3.0/service/tickets/search?pageSize=$PageSize&page=$Page"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring = $Company + '+' + $publickey + ':' + $privatekey
    $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    #Create hash table with the search, convert to JSON format regex to unescape special characters due to encoding
    $Body = @{
        "conditions" = "$Search"
    }
    $JSON = $Body | ConvertTo-Json | ForEach-Object { 
        [System.Text.RegularExpressions.Regex]::Unescape($_) 
    }

    #Create hash table with the authorization string
    $Headers = @{
        "Authorization"="Basic $encodedAuth"
    }

    #Attempt the API call and catch any errors
    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Post -Body $JSON
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Get-CWTicketNotes {
    <#
    .SYNOPSIS
    Retrieves all ticket notes associated with a designated Ticket ID
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW PublicKey, PrivateKey, and a Ticket ID
    If the ticket exists it will return you all the associated notes
    If it doesnt exist it will return $False.
    .NOTES
    N/A
    .EXAMPLE
    Get-CWTicketNotes -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -TicketId 160
    #>

    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $true,Position = 4)]
        [INT]$TicketId,
        [Parameter(Mandatory = $False,Position = 5)]
        [INT]$PageSize = 25
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/service/tickets/$TicketId/notes?pageSize=$PageSize"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Company + '+' + $PublicKey + ':' + $PrivateKey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Get-CWAgreements {
    <#
    .SYNOPSIS
    Retrieves an object formatted list of all ConnectWise Agreements
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW PublicKey and PrivateKey and it will return all ConnectWise Agreements
    .NOTES
    N/A
    .EXAMPLE
    Get-CWAgreements -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -PageSize 25 -Page 1
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $false,Position = 4)]
        [int]$PageSize = 25,
        [Parameter(Mandatory = $false,Position = 5)]
        [int]$Page = 1
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/finance/agreements?pagesize=$PageSize&page=$Page"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Company + '+' + $PublicKey + ':' + $PrivateKey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Get-CWConfiguration {
    <#
    .SYNOPSIS
    Retrieves an object formatted ConnectWise Configuration specified by ID
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW publickey, privatekey, and a configuration id
    If the configuration exists it will return you all the information
    If it doesnt exist it will return $False.
    .NOTES
    N/A
    .EXAMPLE
    Get-CWConfiguration -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -ConfigurationId 2712
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $true,Position = 4)]
        [int]$ConfigurationId
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/company/configurations/$ConfigurationId"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Company + '+' + $PublicKey + ':' + $PrivateKey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    $Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Set-CWConfiguration {
    <#
    .SYNOPSIS
    Update a ConnectWise Configuration specified by ID
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW PublicKey, PrivateKey, Configuration Id, Operation, Path, and Value
    If the configuration exists and the operation is valid, it will return the new configuration settings
    If it doesnt exist it will return $False.
    .NOTES
    N/A
    .EXAMPLE
    Set-CWConfiguration -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -ConfigurationId 2712 -Operation 'replace' -Path 'status/id' -Value '2'
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $true,Position = 4)]
        [int]$ConfigurationId,
        [Parameter(Mandatory = $true,Position = 5)]
        [ValidateSet('add', 'replace', 'remove')]
        [string]$Operation,
        [Parameter(Mandatory = $true,Position = 6)]
        [string]$Path,
        [Parameter(Mandatory = $true,Position = 7)]
        [string]$Value
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/company/configurations/$ConfigurationId"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = "$Company" + '+' + $publickey + ':' + $privatekey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    $Body =@(
        @{
            op = $Operation
            path = $Path
            value = $Value
        }
    )

    $Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -Body $(ConvertTo-Json $Body) -ContentType $ContentType -Method Patch
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Get-CWConfigurationStatuses {
    <#
    .SYNOPSIS
    Retrieves an object formatted list of ConnectWise Configuration Statuses
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW publickey and privatekey
    All configuration statuses will be returned
    .NOTES
    N/A
    .EXAMPLE
    Get-CWConfigurationStatuses -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com 
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/company/configurations/statuses"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Company + '+' + $publickey + ':' + $privatekey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Get-CWTicketConfigurations {
    <#
    .SYNOPSIS
    https://developer.connectwise.com/manage/rest?a=Service&e=Tickets&o=CONFIGURATIONS
    Retrieves an object formatted list of ConnectWise Configurations associated with a specific ticket ID
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW publickey, privatekey, and TicketId
    All configurations will be returned
    .NOTES
    N/A
    .EXAMPLE
    Get-CWTicketConfigurations -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -TicketId $TicketId
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $true,Position = 4)]
        [int]$TicketId        
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/service/tickets/$TicketId/configurations"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Company + '+' + $PublicKey + ':' + $PrivateKey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Get
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}

Function Add-CWTicketConfiguration {
    <#
    .SYNOPSIS
    https://developer.connectwise.com/manage/rest?a=Service&e=Tickets&o=CREATECONFIGURATIONS
    Adds a specified ConfigurationID to a designated TicketId
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function the CW publickey, privatekey, TicketId, and ConfigurationID to add
    All configurations will be returned
    .NOTES
    N/A
    .EXAMPLE
    Add-CWTicketConfiguration -PublicKey $PublicKey -PrivateKey $PrivateKey -Company example.com -Site connectwise.example.com -TicketId $TicketId -ConfigurationId $ConfigurationId
    #>

    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PublicKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$PrivateKey,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Company,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Site,
        [Parameter(Mandatory = $true,Position = 4)]
        [int]$TicketId,
        [Parameter(Mandatory = $true,Position = 5)]
        [int]$ConfigurationId
    )

    [string]$BaseUri     = "https://$Site/" + "v4_6_Release/apis/3.0/service/tickets/$TicketId/configurations"
    [string]$Accept      = "application/json"
    [string]$ContentType = "application/json"
    [string]$Authstring  = $Company + '+' + $PublicKey + ':' + $PrivateKey
    $encodedAuth         = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers = @{
        Authorization = "Basic $encodedAuth"
    }

    $Body =@(
        @{
            ConfigurationReference = "https://$Site/v4_6_release/apis/3.0/company/configurations/" + $ConfigurationId
        }
    )

    Try {
        Invoke-RestMethod -URI $BaseURI -Headers $Headers -Body (ConvertTo-Json $Body) -ContentType $ContentType -Method POST
    } Catch {
        Write-Error "There was an issue when attempting to query the ConnectWise Manage API:`n$_"
    }
}
