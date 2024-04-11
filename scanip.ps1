$subnetPrefix = "172.27.128."  # Replace with the desired subnet prefix
$timeout = 100  # Timeout value in milliseconds

$startIP = [System.Net.IPAddress]::Parse("$($subnetPrefix)1")
$endIP = [IPAddress]::Parse("$($subnetPrefix)254")

$range = @()
$currentIP = $startIP

while ($currentIP -le $endIP) {
    $range += $currentIP.IPAddressToString
    $currentIP = [System.Net.IPAddress]$currentIP.GetAddressBytes()
    [Array]::Reverse($currentIP)
    $currentIP = [System.Net.IPAddress]($currentIP)
    $currentIP = [System.Net.IPAddress]$currentIP.GetAddressBytes()
    [Array]::Reverse($currentIP)
    $currentIP = [System.Net.IPAddress]($currentIP)
    $currentIP += 1
}

foreach ($ip in $range) {
    $ping = New-Object System.Net.NetworkInformation.Ping
    try {
        $reply = $ping.Send($ip, $timeout)
        if ($reply.Status -eq "Success") {
            Write-Host "$ip is online"
        }
    }
    catch {
        Write-Host "$ip is offline"
    }
}