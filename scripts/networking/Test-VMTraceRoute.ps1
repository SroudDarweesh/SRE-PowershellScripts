<#
.SYNOPSIS
    Performs a traceroute from a source VM to a destination.

.DESCRIPTION
    Prompts for a source VM and destination host/IP.
    Runs a traceroute remotely from the source VM to show the path packets take.
#>

$SourceVM      = Read-Host "Enter SOURCE VM hostname"
$Destination   = Read-Host "Enter DESTINATION hostname or IP"

Write-Host "`nPerforming traceroute from $SourceVM to $Destination..." -ForegroundColor Cyan

Invoke-Command -ComputerName $SourceVM -ScriptBlock {
    param($Destination)

    Write-Host "`n=== Traceroute from $env:COMPUTERNAME to $Destination ===" -ForegroundColor Green
    try {
        tracert $Destination
    } catch {
        Write-Host "Traceroute failed: $_" -ForegroundColor Red
    }
    Write-Host "`n=== End of Traceroute ===`n" -ForegroundColor Green
} -ArgumentList $Destination
