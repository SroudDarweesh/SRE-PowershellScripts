<#
.SYNOPSIS
    Retrieves uptime and last reboot time from a remote Windows VM.
.DESCRIPTION
    Prompts for a target server and returns the last boot time and uptime
    in days and hours. Designed for SRE investigations via a jump server.
.EXAMPLE
    .\Get-VMUptime.ps1
#>
# Prompt for target server
$targetServer = Read-Host "Enter the target server name"

try {
    $uptimeInfo = Invoke-Command -ComputerName $targetServer -ScriptBlock {
        $os = Get-CimInstance Win32_OperatingSystem

        $lastBoot = $os.LastBootUpTime
        $uptime = (Get-Date) - $lastBoot

        [PSCustomObject]@{
            Server        = $env:COMPUTERNAME
            LastBootTime  = $lastBoot
            UptimeDays    = [math]::Round($uptime.TotalDays, 2)
            UptimeHours   = [math]::Round($uptime.TotalHours, 2)
        }
    }

    $uptimeInfo | Format-Table -AutoSize
}
catch {
    Write-Error "Failed to retrieve uptime from $targetServer. Error: $_"
}