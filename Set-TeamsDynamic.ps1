Function Set-TeamsDynamic {
    <#
    .SYNOPSIS
    Set Microsoft Teams members dynamically from Azure AD Security Groups
    Use the $Groups hashtable to specify Azure AD and Teams ID's appropriately via ObjectID
    Author: Jon Rodriguez
    .DESCRIPTION

    .NOTES

    .EXAMPLE
    Set-TeamsDynamic
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [System.Management.Automation.PSCredential]$Credential
    )

    # Initialize hashtable to define each Team and the associated Azure AD Group ID and Microsoft Teams Team ID
    $Groups = @{
        'Example Team' = @{
            GroupId = '79d3adab-e159-4b6f-a666-2e9ae47ba59b'
            TeamId = 'f92d1f06-97f5-410d-a666-d76ad8559f30'
        }
    }

    # Hashtable for logging all actions
    $Results = @{}

    # Connect to Microsoft Teams and Azure AD
    Try {
        Connect-MicrosoftTeams -Credential $Credential | Out-Null
    } Catch {
        Write-Error "There was an error while attempting to connect to Microsoft Teams:`n`n$_"
        Exit
    }
    Try {
        Connect-AzureAD -Credential $Credential | Out-Null
    } Catch {
        Write-Error "There was an error while attempting to connect to Azure Active Directory:`n`n$_"
        Exit
    }

    # Loop through each group in the Groups hashtable
    ForEach ($Group in $Groups.keys) {
        # Set GroupId and TeamId variables from $Groups hashtable
        $GroupId = $Groups.$Group.GroupId
        $TeamId = $Groups.$Group.TeamId
        
        # Get members to add via existing Security Group, recursively get members of subgroups
        $Members = Get-AzureADGroupMember -ObjectID $GroupId
        $MembersToAdd = $Members | Where-Object -Property 'ObjectType' -eq 'User'
        $SubGroups = $Members | Where-Object -Property 'ObjectType' -eq 'Group'
        
        # Loop through each SubGroup for members to add and additional subgroups to loop through
        ForEach ($SubGroup in $SubGroups) {
            $SubGroup = Get-AzureADGroupMember -ObjectID $SubGroup.ObjectId
            $MembersToAdd += $SubGroup | Where-Object -Property 'ObjectType' -eq 'User'
            $SubSubGroups = $SubGroup | Where-Object -Property 'ObjectType' -eq 'Group'

            # Loop through each SubSubGroup for members to add
            ForEach ($SubGroup in $SubSubGroups) {
                $SubGroup = Get-AzureADGroupMember -ObjectID $SubGroup.ObjectId
                $MembersToAdd += $SubGroup | Where-Object -Property 'ObjectType' -eq 'User'
            }
        }

        # Remove all duplicate users from MembersToAdd
        $MembersToAdd = $MembersToAdd | Select-Object -Unique
        
        # Get existing Teams members
        $MembersExisting = Get-TeamUser -GroupId $TeamId

        # Add users that exist in Security Group but not Team
        ForEach ($User in $MembersToAdd) {
            If ($MembersExisting.User -notcontains $User.UserPrincipalName) {
                Write-Output "$($User.UserPrincipalName) exists in Security Group but not in Team"
                Try {
                    Add-TeamUser -GroupId $TeamId -User $User.UserPrincipalName
                    Write-Output "$($User.UserPrincipalName) Added Successfully to $TeamId"
                    $Results.Add("$($User.UserPrincipalName) $GroupId $TeamId", "Added Successfully")
                } Catch {
                    Write-Error "There was an error while attempting to add $($User.UserPrincipalName) to Team $TeamId`n`n$_"
                    $Results.Add("$($User.UserPrincipalName) $GroupId $TeamId","Error while Adding: $_")
                }
            }
        }

        # Remove users that exist in Team but not Security Group
        ForEach ($User in $MembersExisting) {
            If ($MembersToAdd.UserPrincipalName -notcontains $User.User) {
                Write-Output "$($User.User) exists in Team but not in Security Group"
                Try {
                    Remove-TeamUser -GroupId $TeamId -User $User.User
                    Write-Output "$($User.User) Removed Successfully from $TeamId"
                    $Results.Add("$($User.User) $TeamId","Removed Sucessfully")
                } Catch {
                    Write-Output "There was an error while attempting to remove $($User.User) from Team $TeamId`n`n$_"
                    $Results.Add("$($User.User) $TeamId","Error while Removing: $_")
                }
            }
        }
    }

    # Disconnect from Microsoft Teams and Azure AD
    Disconnect-MicrosoftTeams
    Disconnect-AzureAD

    # Export logged results to a CSV
    If ($Null -ne $Results) {
        $Results.GetEnumerator() | Export-CSV -Path C:\temp\TeamDynamicResults.csv -NoTypeInformation
    } Else {
        Write-Output "No changes made, all Teams consistent with Azure AD Security Groups"
    }
}
