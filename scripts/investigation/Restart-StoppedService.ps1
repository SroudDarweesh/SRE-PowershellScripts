<#
.SYNOPSIS
    Lists stopped services on a remote Windows VM and allows restarting a selected service.
.DESCRIPTION
    Prompts for a target server, displays all stopped services, and allows
    the engineer to select and restart a specific service interactively.
.EXAMPLE
    .\Repair-StoppedService.ps1
#>

# Prompt for target server
$targetServer = Read-Host "Enter the target server name"

try {
    # Get stopped services
    $stoppedServices = Invoke-Command -ComputerName $targetServer -ScriptBlock {
        Get-Service | Where-Object { $_.Status -eq 'Stopped' } |
        Select-Object Name, DisplayName, StartType
    }

    if (-not $stoppedServices) {
        Write-Output "No stopped services found on $targetServer."
        return
    }

    Write-Output "`nStopped services on $targetServer:`n"

    # Display numbered list
    $index = 1
    $stoppedServices | ForEach-Object {
        [PSCustomObject]@{
            Index        = $index++
            Name         = $_.Name
            DisplayName  = $_.DisplayName
            StartType    = $_.StartType
        }
    } | Format-Table -AutoSize

    # Ask if user wants to restart a service
    $selection = Read-Host "`nEnter the INDEX of the service to restart (or press Enter to exit)"

    if ([string]::IsNullOrWhiteSpace($selection)) {
        Write-Output "No service selected. Exiting."
        return
    }

    $selectedService = $stoppedServices[[int]$selection - 1]

    if (-not $selectedService) {
        Write-Error "Invalid selection."
        return
    }

    Write-Output "`nRestarting service '$($selectedService.DisplayName)' on $targetServer..."

    Invoke-Command -ComputerName $targetServer -ScriptBlock {
        param ($serviceName)
        Start-Service -Name $serviceName
    } -ArgumentList $selectedService.Name

    Write-Output "Service '$($selectedService.DisplayName)' restarted successfully."

}
catch {
    Write-Error "Operation failed on $targetServer. Error: $_"
}