<#
.SYNOPSIS
    Retrieves enabled inbound Windows Firewall rules from a remote VM.

.DESCRIPTION
    Prompts for a target VM and remotely collects enabled inbound
    firewall rules, including ports, protocol, and action.
    Used to troubleshoot blocked network traffic.

#>

$TargetVM = Read-Host "Enter target VM hostname"

Write-Host "`nConnecting to $TargetVM..." -ForegroundColor Cyan

Invoke-Command -ComputerName $TargetVM -ScriptBlock {

    Write-Host "`n=== Enabled Inbound Firewall Rules on $env:COMPUTERNAME ===" -ForegroundColor Green

    $rules = Get-NetFirewallRule -Enabled True -Direction Inbound |
        Where-Object { $_.Action -eq 'Allow' } |
        Get-NetFirewallPortFilter |
        Select-Object `
            Name,
            Protocol,
            LocalPort

    if (-not $rules) {
        Write-Host "No enabled inbound firewall rules found." -ForegroundColor Yellow
        return
    }

    $rules |
        Sort-Object LocalPort |
        Format-Table -AutoSize

    Write-Host "`n=== End of Firewall Report ===`n" -ForegroundColor Green
}
