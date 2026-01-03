<#
.SYNOPSIS
    Retrieves antivirus exclusions from a remote Windows VM.
.DESCRIPTION
    Prompts for a target server and returns all configured AV exclusions
    (paths, files, and processes) for quick investigation.
.EXAMPLE
    .\Get-AVExclusions.ps1
#>

# Prompt for target server
$targetServer = Read-Host "Enter the target server name"

try {
    $avExclusions = Invoke-Command -ComputerName $targetServer -ScriptBlock {
        # Windows Defender example
        $wd = Get-MpPreference

        [PSCustomObject]@{
            ExclusionPaths     = ($wd.ExclusionPath -join "; ")
            ExclusionProcesses = ($wd.ExclusionProcess -join "; ")
            ExclusionExtensions= ($wd.ExclusionExtension -join "; ")
        }
    }

    Write-Output "Antivirus exclusions on $targetServer:"
    $avExclusions | Format-List
}
catch {
    Write-Error "Failed to retrieve AV exclusions from $targetServer. Error: $_"
}
