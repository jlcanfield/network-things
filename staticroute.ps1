#We has no good DNS internally and I like names and not ip addresses... soo until we can sync DHCP to DNS on the mikrotik, I'm just going to maintain a list of IP addresses and hostnames and use this script to create static routes.

# Define the IP address and hostname combinations
$IpHostnameMap = @(
    @{ "IPAddress" = "172.16.2.100"; "Hostname" = "docker-production" }
    @{ "IPAddress" = "172.16.2.101"; "Hostname" = "docker-testing" }
    # Add more IP and hostname combinations here
)

# Function to add a static route, skipping if it already exists
function Add-StaticRoute {
    param (
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        [Parameter(Mandatory=$true)]
        [string]$Hostname
    )

    $routeCommand = "route add $IPAddress $IPAddress -p"
    $routeExists = $(route print | Select-String -Pattern $IPAddress)

    if (-not $routeExists) {
        try {
            Write-Host "Adding static route for $Hostname ($IPAddress)..."
            Invoke-Expression $routeCommand
            Write-Host "Static route added successfully."
        }
        catch {
            Write-Host "Error adding static route: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Static route for $Hostname ($IPAddress) already exists. Skipping."
    }
}

# Function to update the hosts file, skipping if the entry already exists
function Update-HostsFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        [Parameter(Mandatory=$true)]
        [string]$Hostname
    )

    $hostsFilePath = "$env:windir\System32\drivers\etc\hosts"
    $hostsFileEntry = "$IPAddress`t$Hostname"
    $hostsFileContent = Get-Content -Path $hostsFilePath

    if (-not ($hostsFileContent -contains $hostsFileEntry)) {
        try {
            Write-Host "Updating hosts file with $hostsFileEntry..."
            Add-Content -Path $hostsFilePath -Value $hostsFileEntry -Force
            Write-Host "Hosts file updated successfully."
        }
        catch {
            Write-Host "Error updating hosts file: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Hosts file entry for $Hostname ($IPAddress) already exists. Skipping."
    }
}

# Process each IP address and hostname combination
foreach ($item in $IpHostnameMap) {
    $ipAddress = $item.IPAddress
    $hostname = $item.Hostname

    Add-StaticRoute -IPAddress $ipAddress -Hostname $hostname
    Update-HostsFile -IPAddress $ipAddress -Hostname $hostname
}