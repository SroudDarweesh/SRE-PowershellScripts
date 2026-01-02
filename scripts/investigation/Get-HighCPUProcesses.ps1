<#
.SYNOPSIS
    Retrieves the top 5 CPU-consuming processes from a remote Windows VM.
.DESCRIPTION
    Prompts for a target server and returns the top 5 processes sorted by CPU usage.
    Designed for SRE use via a jump server to inspect remote Windows VMs.
.EXAMPLE
    .\Get-HighCPUProcesses.ps1
#>

# Prompt for target server
$targetServer = Read-Host "Enter the target server name"

# Retrieve top 5 CPU processes
try {
    $topProcesses = Invoke-Command -ComputerName $targetServer -ScriptBlock {
        Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table -AutoSize
    }

    Write-Output "Top 5 CPU processes on $targetServer:"
    Write-Output $topProcesses
}
catch {
    Write-Error "Could not retrieve processes from $targetServer. Error: $_"
}
