<#
.SYNOPSIS
    Retrieves network configuration details from a remote Windows VM.

.DESCRIPTION
    Prompts the engineer for a target VM name and remotely collects
    network adapter, IP, gateway, and DNS configuration.
    Intended to be run from the shared jump server with admin privileges.

.PARAMETER None
    The script will prompt for the target VM interactively.

.REQUIREMENTS
    - PowerShell Remoting enabled on target VM
    - Administrative privileges
    - Network connectivity from jump server

.EXAMPLE
    PS> .\Get-VMNetworkConfig.ps1
#>

# Prompt for target VM
$TargetVM = Read-Host "Enter the target VM hostname"

Write-Host "`nConnecting to $TargetVM..." -ForegroundColor Cyan

Invoke-Command -ComputerName $TargetVM -ScriptBlock {

    Write-Host "`n===== Network Configuration for $env:COMPUTERNAME =====" -ForegroundColor Green

    $adapters = Get-NetAdapter | Where-Object { $_.Status -ne 'Disabled' }

    foreach ($adapter in $adapters) {

        $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.InterfaceIndex

        Write-Host "`nAdapter Name : $($adapter.Name)"
        Write-Host "Status       : $($adapter.Status)"
        Write-Host "MAC Address  : $($adapter.MacAddress)"

        if ($ipConfig.IPv4Address) {
            Write-Host "IPv4 Address : $($ipConfig.IPv4Address.IPAddress)"
        } else {
            Write-Host "IPv4 Address : None"
        }

        if ($ipConfig.IPv6Address) {
            Write-Host "IPv6 Address : $($ipConfig.IPv6Address.IPAddress)"
        }

        Write-Host "Gateway      : $($ipConfig.IPv4DefaultGateway.NextHop)"
        Write-Host "DNS Servers  : $($ipConfig.DnsServer.ServerAddresses -join ', ')"
    }

    Write-Host "`n===== End of Network Report =====`n" -ForegroundColor Green
}
