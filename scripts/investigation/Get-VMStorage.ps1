<#
.SYNOPSIS
    Retrieves disk usage information from a remote Windows VM.
.DESCRIPTION
    Prompts for a target server and returns a table of all drives with free space, used space, total size, and percent used.
    Also shows total storage used and total capacity across all drives.
.EXAMPLE
    .\Get-VMStorage.ps1
#>

# Prompt for target server
$targetServer = Read-Host "Enter the target server name"

try {
    # Get all logical drives
    $drives = Invoke-Command -ComputerName $targetServer -ScriptBlock {
        Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, @{Name="Used(GB)";Expression={[math]::Round(($_.Used/1GB),2)}}, @{Name="Free(GB)";Expression={[math]::Round(($_.Free/1GB),2)}}, @{Name="Total(GB)";Expression={[math]::Round(($_.Used + $_.Free)/1GB,2)}}, @{Name="PercentUsed";Expression={[math]::Round(($_.Used/($_.Used + $_.Free)*100),2)}} 
    }

    Write-Output "Drive usage on $targetServer:"
    $drives | Format-Table -AutoSize

    # Calculate total usage
    $totalUsed = ($drives | Measure-Object -Property "Used(GB)" -Sum).Sum
    $totalCapacity = ($drives | Measure-Object -Property "Total(GB)" -Sum).Sum
    $percentTotalUsed = [math]::Round(($totalUsed / $totalCapacity * 100),2)

    Write-Output ""
    Write-Output "Total used: $totalUsed GB / Total capacity: $totalCapacity GB ($percentTotalUsed % used)"

} catch {
    Write-Error "Could not retrieve storage info from $targetServer. Error: $_"
}
