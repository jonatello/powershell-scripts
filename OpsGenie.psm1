Function Get-OGUser {
    <#
    .SYNOPSIS
    Get user in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email) and all related user information will be returned for OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Get-OGUser -UserId 'user@example.com'

    Get user information associated with 'user@example.com'
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users/$UserId"
    $ContentType = 'application/json'

    # Invoke REST API GET request
    Try {
        Invoke-RestMethod -Uri $URI -Method GET -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to get the user $UserId`n`nError Results:`n`n$_"
    }
}

Function Get-OGUserList {
    <#
    .SYNOPSIS
    Get all users in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Get all users in OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Get-OGUserList -GenieKey $GenieKey

    Get all users in OpsGenie
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users"
    $ContentType = 'application/json'

    # Invoke REST API GET request
    Try {
        Invoke-RestMethod -Uri $URI -Method GET -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to get the user list`n`nError Results:`n`n$_"
    }
}

Function New-OGUser {
    <#
    .SYNOPSIS
    Creates a user in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email), FullName, and Role (owner, admin, user, or custom) and an account will be created in OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>New-OGUser -GenieKey $GenieKey -UserId 'user@example.com' -FullName 'John Smith' -Role 'User'

    New user 'user@example.com' created
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,    
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$FullName,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Role
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users"
    $Body = @{
        "username" = "$UserId"
        "fullName" = "$FullName"
        "role" = @{"name" = "$Role"}
    }
    $JSON = $Body | ConvertTo-Json
    $ContentType = 'application/json'

    # Invoke REST API GET request
    Try {
        Invoke-RestMethod -Uri $URI -Method POST -Headers $Headers -Body $JSON -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to create the user $UserId`n`nError Results:`n`n$_"
    }
}

Function Remove-OGUser {
    <#
    .SYNOPSIS
    Remove user in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email) to remove the user in OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Remove-OGUser -GenieKey $GenieKey -UserId 'user@example.com'

    Remove user 'user@example.com'
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users/$UserId"
    $ContentType = 'application/json'

    # Invoke REST API DELETE request
    Try {
        Invoke-RestMethod -Uri $URI -Method DELETE -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to delete the user $UserId`n`nError Results:`n`n$_"
    }
}

Function Get-OGContact {
    <#
    .SYNOPSIS
    Get contact methods for user in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email) and all related contact methods will be returned for OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Get-OGContact -GenieKey $GenieKey -UserId 'user@example.com'

    Get all contacts associated with 'user@example.com'
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users/$UserId/contacts"
    $ContentType = 'application/json'

    # Invoke REST API GET request
    Try {
        Invoke-RestMethod -Uri $URI -Method GET -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to get the contacts for $UserId`n`nError Results:`n`n$_"
    }
}

Function New-OGContact {
    <#
    .SYNOPSIS
    Create contact in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email), Contact Method (email, sms, or voice), and Contact Value for the given method to create the Contact in OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>New-OGContact -GenieKey $GenieKey -UserId 'user@example.com' -Method 'voice' -Value '1-5555555555'
    
    Create new voice contact for 'user@example.com' with a value of '1-5555555555'
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$Method,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Value
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users/$UserId/contacts"
    $Body = @{
        "method" = "$Method"
        "to" = "$Value"
    }
    $JSON = $Body | ConvertTo-Json
    $ContentType = 'application/json'

    # Invoke REST API POST request
    Try {
        Invoke-RestMethod -Uri $URI -Method POST -Headers $Headers -Body $JSON -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to create the contact for $UserId`n`nError Results:`n`n$_"
    }
}

Function Remove-OGContact {
    <#
    .SYNOPSIS
    Remove contact in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email) and ContactID (use Get-OGContact to identify) to remove the Contact in OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Remove-OGContact -GenieKey $GenieKey -UserId 'user@examlpe.com' -ContactID $ContactId

    Remove contact with ID $ContactId for 'user@example.com'
    .EXAMPLE
    PS C:\>$ContactID = (Get-OGContact -GenieKey $GenieKey -UserId user@example.com | Where-Object Method -eq voice | Select-Object id).id
    PS C:\>Remove-OGContact -GenieKey $GenieKey -UserId 'user@example.com -ContactID $ContactID

    Get voice contact ID for 'user@example.com' and remove
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$ContactID
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users/$UserId/contacts/$ContactID"
    $ContentType = 'application/json'

    # Invoke REST API DELETE request
    Try {
        Invoke-RestMethod -Uri $URI -Method DELETE -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to delete the contact for $UserId`n`nError Results:`n`n$_"
    } 
}

Function Update-OGContact {
    <#
    .SYNOPSIS
    Update contact in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email), ContactID (use Get-OGContact to identify), and Contact Value for the given method to update the Contact in OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Update-OGContact -UserId 'user@example.com' -ContactID $ContactId -Value '1-5555555555'

    Update contact with ID $ContactId with a value of '1-5555555555' for user 'user@example.com'
    .EXAMPLE
    PS C:\>$ContactID = (Get-OGContact -GenieKey $GenieKey -UserId user@example.com | Where-Object Method -eq voice | Select-Object id).id
    PS C:\>Update-OGContact -GenieKey $GenieKey -UserId 'user@example.com -ContactID $ContactID -Value '1-5555555555'

    Get voice contact ID for 'user@example.com' and update with a value of '1-5555555555'
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$ContactID,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$Value
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users/$UserId/contacts/$ContactID"
    $Body = @{
        "to" = "$Value"
    }
    $JSON = $Body | ConvertTo-Json
    $ContentType = 'application/json'

    # Invoke REST API PATCH request
    Try {
        Invoke-RestMethod -Uri $URI -Method PATCH -Headers $Headers -Body $JSON -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to update the contact for $UserId`n`nError Results:`n`n$_"
    }
}

Function Get-OGNotificationRule {
    <#
    .SYNOPSIS
    Get notification rule for user in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email) and RuleId and all related settings will be returned for OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Get-OGNotificationRule -GenieKey $GenieKey -UserId 'user@example.com' -RuleId $RuleId

    Get specified notification rule settings for 'user@example.com'
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$RuleId
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users/$UserId/notification-rules/$RuleId"
    $ContentType = 'application/json'

    # Invoke REST API GET request
    Try {
        Invoke-RestMethod -Uri $URI -Method GET -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to get the notification rule for $UserId`n`nError Results:`n`n$_"
    }
}

Function Get-OGNotificationRuleList {
    <#
    .SYNOPSIS
    Get notification rule list for user in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email) and all related notification rules will be returned for OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Get-OGNotificationRuleList -GenieKey $GenieKey -UserId 'user@example.com'

    Get notification rule list for 'user@example.com'
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users/$UserId/notification-rules"
    $ContentType = 'application/json'

    # Invoke REST API GET request
    Try {
        Invoke-RestMethod -Uri $URI -Method GET -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to get the notification rule list for $UserId`n`nError Results:`n`n$_"
    }
}

Function Get-OGNotificationRuleStep {
    <#
    .SYNOPSIS
    Get notification rule step for user in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email), RuleId, and StepId and all related settings will be returned for OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Get-OGNotificationRuleStep -GenieKey $GenieKey -UserId 'user@example.com' -RuleId $RuleId -StepId $StepId

    Get specified notification rule step settings for 'user@example.com'
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$RuleId,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$StepId
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users/$UserId/notification-rules/$RuleId/steps/$StepId"
    $ContentType = 'application/json'

    # Invoke REST API GET request and store in variable
    Try {
        Invoke-RestMethod -Uri $URI -Method GET -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to get the notification rule step for $UserId`n`nError Results:`n`n$_"
    }
}

Function Set-OGNotificationRuleStep {
    <#
    .SYNOPSIS
    Set notification rule step for user in OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a UserId (email), RuleId, StepId, enabled value, and sendAfter value to update the related settings for OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Set-OGNotificationRuleStep -GenieKey $GenieKey -UserId 'user@example.com' -RuleId $RuleId -StepId $StepId -Enabled 'True' -SendAfter '0'

    Get specified notification rule step settings for 'user@example.com'
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$UserId,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$RuleId,
        [Parameter(Mandatory = $true,Position = 3)]
        [string]$StepId,
        [Parameter(Mandatory = $true,Position = 4)]
        [string]$Enabled,
        [Parameter(Mandatory = $true,Position = 5)]
        [string]$SendAfter
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/users/$UserId/notification-rules/$RuleId/steps/$StepId"
    $Body = @{
        "enabled" = "$Enabled"
        "sendAfter" = @{"timeAmount" = "$SendAfter"}
    }
    $JSON = $Body | ConvertTo-Json
    $ContentType = 'application/json'

    # Invoke REST API GET request
    Try {
        Invoke-RestMethod -Uri $URI -Method PATCH -Headers $Headers -Body $JSON -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to set the notification rule step for $UserId`n`nError Results:`n`n$_"
    }
}

Function Get-OGAlert {
    <#
    .SYNOPSIS
    Get a specified alert for OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Get a specified alert for OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Get-OGAlert -GenieKey $GenieKey -AlertId $AlertId

    Get specified alert
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$AlertId
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/alerts/$AlertId"
    $ContentType = 'application/json'

    # Invoke REST API GET request and store in variable
    Try {
        Invoke-RestMethod -Uri $URI -Method GET -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to get the alert`n`nError Results:`n`n$_"
    }
}

Function Get-OGAlertList {
    <#
    .SYNOPSIS
    Get all alerts for OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Get all alerts for OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Get-OGAlertList -GenieKey $GenieKey

    Get alert list
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/alerts"
    $ContentType = 'application/json'

    # Invoke REST API GET request
    Try {
        Invoke-RestMethod -Uri $URI -Method GET -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to get the alert list`n`nError Results:`n`n$_"
    }
}

Function Update-OGAlert {
    <#
    .SYNOPSIS
    Update a specified alert as closed for OpsGenie via the REST API
    Author: Jon Rodriguez
    .DESCRIPTION
    Update a specified alert as closed for OpsGenie via the REST API
    .NOTES
    N/A
    .EXAMPLE
    PS C:\>Update-OGAlert -GenieKey $GenieKey -AlertId $AlertId

    Update alert as closed
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$GenieKey,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$AlertId
    )

    # Create properly formatted REST API variables
    $Headers = @{
        Authorization = "GenieKey $GenieKey"
    } 
    $URI = "https://api.opsgenie.com/v2/alerts/$AlertId/close"
    $ContentType = 'application/json'

    # Invoke REST API GET request
    Try {
        Invoke-RestMethod -Uri $URI -Method GET -Headers $Headers -ContentType $ContentType
    } Catch {
        Write-Error "There was an error when attempting to close the alert`n`nError Results:`n`n$_"
    }
}
