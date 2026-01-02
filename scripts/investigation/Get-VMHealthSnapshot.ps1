<#
.SYNOPSIS
    Collects a lightweight health snapshot from a remote Windows VM.

.DESCRIPTION
    This script is designed to be run from a jump server by SREs.
    It prompts the engineer for a target server name, then remotely
    collects core system health information using PowerShell remoting.

    The snapshot focuses on:
      - OS details and uptime
      - CPU load
      - Memory usage
      - Disk usage
      - Windows Defender status (if available)

.EXAMPLE
    PS> .\Get-VMHealthSnapshot.ps1

    Enter target server name: win-app-01

    Returns a structured health snapshot for the specified VM.

.AUTHOR
    SRE Team

.CREATED
    2026-01-01
#>

Write-Host ""
Write-Host "=== VM Health Snapshot ===" -ForegroundColor Cyan
Write-Host ""

# Prompt for target server
$computer = Read-Host "Enter target server name"

if (-not $computer) {
    Write-Error "No server name provided. Exiting."
    return
}

try {
    $snapshot = Invoke-Command -ComputerName $computer -ScriptBlock {

        # OS information
        $system = Get-CimInstance Win32_OperatingSystem |
            Select-Object CSName, Caption, Version, LastBootUpTime

        # CPU information
        $cpu = Get-CimInstance Win32_Processor |
            Select-Object Name, LoadPercentage

        # Memory information
        $memory = Get-CimInstance Win32_OperatingSystem |
            Select-Object TotalVisibleMemorySize, FreePhysicalMemory

        # Disk usage (local disks only)
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
            Select-Object DeviceID, Size, FreeSpace

        # Windows Defender status (if present)
        $defender = if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
            Get-MpComputerStatus |
                Select-Object AMServiceEnabled,
                              AntivirusEnabled,
                              RealTimeProtectionEnabled
        } else {
            $null
        }

        # Return structured snapshot
        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            System       = $system
            CPU          = $cpu
            Memory       = $memory
            Disk         = $disk
            Defender     = $defender
            Timestamp    = Get-Date
        }
    }

    Write-Host ""
    Write-Host "Snapshot collected successfully from $computer" -ForegroundColor Green
    Write-Host ""

    $snapshot

}
catch {
    Write-Error "Failed to collect snapshot from $computer"
    Write-Error $_.Exception.Message
}
