Function Get-AzureVMBackupStatus {
    <#
    .SYNOPSIS
    Get Azure VM Backup Status information
    Author: Jon Rodriguez
    .DESCRIPTION
    Connect to Azure Resource Manager and loop through the Subscriptions, Vaults, and Containers
    Check for all AzureVM Backup Items and output the relevant details
    .NOTES

    .EXAMPLE
    PS C:\> Get-AzureVMBackupStatus
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [System.Management.Automation.PSCredential]$Credential
    )
    
    begin {
        # Connect to Azure Resource Manager
        Connect-AzureRmAccount -Credential $Credential | Out-Null
    }

    process {
        # Get Azure RM Subscription
        $Subscriptions = Get-AzureRmSubscription
            # Name might be a useful property to store...

        # Loop through each Subscription
        ForEach ($Subscription in $Subscriptions) {
            Select-AzureRmSubscription -SubscriptionObject $Subscription | Out-Null

            # Get the Vaults
            $Vaults = Get-AzureRmRecoveryServicesVault

            # Loop through each Vault
            ForEach ($Vault in $Vaults) {
                # Set the context
                Set-AzureRmRecoveryServicesVaultContext -Vault $Vault

                # Get the Backup Containers and set to a variable
                $Containers = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM

                # Loop through each Container
                ForEach ($Container in $Containers) {
                    # Get all Backup Items within the container
                    $BackupItem = Get-AzureRmRecoveryServicesBackupItem -Container $Container -WorkloadType AzureVM

                    [pscustomobject]@{
                        'Subscription' = $($Subscription.Name)
                        'Vault' = $($Vault.Name)
                        #'Vault Resource Group' = $($Vault.ResourceGroupName)
                        #'Container' = $($Container.Name)
                        #'Container Resource Group' = $($Container.ResourceGroupName)
                        'Resource Group' = (($BackupItem.ContainerName).Split(';')[1])
                        'VM Name' = (($BackupItem.ContainerName).Split(';')[2])
                        'Protection Status' = $($BackupItem.ProtectionStatus)
                        'Protection State' = $($BackupItem.ProtectionState)
                        'Last Backup Status' = $($BackupItem.LastBackupStatus)
                        'Last Backup Time' = $($BackupItem.LastBackupTime)
                        'Protection Policy Name' = $($BackupItem.ProtectionPolicyName)
                        'Latest Recovery Point' = $($BackupItem.LatestRecoveryPoint)
                    } | Write-Output
                }
            }
        }
    }

    end {
        # Disconnect Azure Resource Manager
        Disconnect-AzureRmAccount | Out-Null
    }
}
