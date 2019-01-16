Function Get-FirewallRules {
    <#
    .SYNOPSIS
    Audit Windows Firewall rules
    Author: Jon Rodriguez
    .DESCRIPTION

    .NOTES
    Adapted from this - https://blogs.technet.microsoft.com/jamesone/2009/02/17/how-to-manage-the-windows-firewall-settings-with-powershell/
    .EXAMPLE

    #>

    [CmdletBinding()]
    param (
    )

    # Define the Profile Types
    $FwProfileTypes = @{
        2147483647 = "All"
        1 = "Domain"
        2 = "Private"
        4 = "Public"
    }

    # Define the Actions
    $FwAction = @{
        1 = "Allow"
        0 = "Block"
    }

    # Define the Protocols
    $FwProtocols = @{
        1 = "ICMPv4"
        2 = "IGMP"
        6 = "TCP"
        17 = "UDP"
        41 = "IPv6"
        43 = "IPv6Route"
        44 = "IPv6Frag"
        47 = "GRE"
        58 = "ICMPv6"
        59 = "IPv6NoNxt"
        60 = "IPv6Opts"
        112 = "VRRP"
        113 = "PGM"
        115 ="L2TP"
    }

    # Define the Direction
    $FwDirection = @{
        1 = "Inbound"
        2 = "Outbound"
    } 

    # Get all Firewall Rules
    (New-object –comObject HNetCfg.FwPolicy2).Rules | Select `
        Name, 
        Description, 
        ApplicationName, 
        serviceName,
        @{Name = "Protocol";Expression = {$FwProtocols[$_.Protocol]}},
        LocalPorts,
        RemotePorts,
        LocalAddresses,
        RemoteAddresses,
        IcmpTypesAndCodes,
        @{Name = "Direction";Expression = {$FwDirection[$_.Direction]}},
        Interfaces,
        InterfaceTypes,
        Enabled,
        Grouping,
        @{Name = "Profiles";Expression = {$FwProfileTypes[$_.Profiles]}},
        EdgeTraversal,
        @{Name = "Action";Expression = {$FwAction[$_.Action]}},
        EdgeTraversalOptions,
        LocalAppPackageId,
        LocalUserOwner,
        LocalUserAuthorizedList,
        RemoteUserAuthorizedList,
        RemoteMachineAuthorizedList,
        SecureFlags
}
