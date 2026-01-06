<#
.SYNOPSIS
    Tests basic network connectivity to a remote Windows VM.

.DESCRIPTION
    Performs DNS resolution, ping tests, and TCP port checks
    from the jump server to a target VM.

.REQUIREMENTS
    - PowerShell 5.1+
    - Network access from jump server

.EXAMPLE
    PS> .\Test-VMConnectivity.ps1
#>

# Prompt for target VM
$TargetVM = Read-Host "Enter target VM hostname"

Write-Host "`n=== Connectivity Test for $TargetVM ===" -ForegroundColor Cyan

# DNS Resolution
Write-Host "`n[DNS Resolution]"
try {
    $dns = Resolve-DnsName -Name $TargetVM -ErrorAction Stop
    Write-Host "Resolved to IP: $($dns.IPAddress)" -ForegroundColor Green
} catch {
    Write-Host "DNS resolution failed" -ForegroundColor Red
}

# Ping Test
Write-Host "`n[Ping Test]"
if (Test-Connection -ComputerName $TargetVM -Count 2 -Quiet) {
    Write-Host "Ping successful" -ForegroundColor Green
} else {
    Write-Host "Ping failed" -ForegroundColor Red
}

# TCP Port Tests
$Ports = @(3389, 443, 80)

Write-Host "`n[TCP Port Checks]"
foreach ($port in $Ports) {
    $result = Test-NetConnection -ComputerName $TargetVM -Port $port -WarningAction SilentlyContinue
    if ($result.TcpTestSucceeded) {
        Write-Host "Port $port : OPEN" -ForegroundColor Green
    } else {
        Write-Host "Port $port : CLOSED" -ForegroundColor Yellow
    }
}

Write-Host "`n=== Test Complete ===`n"
