<#
.SYNOPSIS
    Retrieves listening TCP ports and associated processes from a remote VM.

.DESCRIPTION
    Prompts for a target VM and remotely collects all listening TCP ports,
    the owning process ID, and process name.
    Intended for network and application troubleshooting.

.REQUIREMENTS
    - PowerShell Remoting enabled
    - Administrative privileges on target VM

.EXAMPLE
    PS> .\Get-VMListeningPorts.ps1
#>

$TargetVM = Read-Host "Enter target VM hostname"

Write-Host "`nConnecting to $TargetVM..." -ForegroundColor Cyan

Invoke-Command -ComputerName $TargetVM -ScriptBlock {

    Write-Host "`n=== Listening TCP Ports on $env:COMPUTERNAME ===" -ForegroundColor Green

    $listeningPorts = Get-NetTCPConnection -State Listen |
        Select-Object `
            LocalAddress,
            LocalPort,
            OwningProcess,
            @{Name="ProcessName";Expression={
                (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName
            }}

    if (-not $listeningPorts) {
        Write-Host "No listening TCP ports found." -ForegroundColor Yellow
        return
    }

    $listeningPorts |
        Sort-Object LocalPort |
        Format-Table -AutoSize

    Write-Host "`n=== End of Report ===`n" -ForegroundColor Green
}
