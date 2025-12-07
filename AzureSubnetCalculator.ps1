<#
.SYNOPSIS
    Azure Subnet Calculator for PowerShell

.DESCRIPTION
    This script calculates Azure-compliant subnet details including:
    - Network address
    - Broadcast
    - Subnet mask
    - Usable host range
    - Azure reserved IPs (gateway, reserved .2 and .3)
    - Azure-usable hosts count
    - Optional subnet splitting
    - Optional hosts-to-CIDR recommendation

.VERSION
    1.0.0

.AUTHOR
    Salvatore Cristaudo

.LICENSE
    MIT License

.LAST UPDATED
    2025-12-07

.NOTES
    This script is designed for Azure subnetting rules (5 reserved IPs).
    Works on Windows, Linux, and macOS PowerShell.
#>



param(
    [Parameter(Mandatory = $false)]
    [string]$CIDR,

    [Parameter(Mandatory = $false)]
    [int]$HostsNeeded,

    [Parameter(Mandatory = $false)]
    [int]$SplitSubnets
)

# ANSI Colors (Windows + Linux)
$Red   = "`e[31m"
$Green = "`e[32m"
$White = "`e[97m"
$Reset = "`e[0m"

# -------------------------
# Function: Calculate subnet info
# -------------------------
function Get-SubnetInfo {
    param([string]$CIDR)

    $parts = $CIDR.Split("/")
    $ipString = $parts[0]
    $prefix   = [int]$parts[1]

    $ip = [System.Net.IPAddress]::Parse($ipString).GetAddressBytes()

    # Build subnet mask
    $maskBytes = @(0,0,0,0)
    for ($i = 0; $i -lt 4; $i++) {
        $bits = [Math]::Min([Math]::Max($prefix - ($i * 8), 0), 8)
        if ($bits -eq 0)      { $maskBytes[$i] = 0 }
        elseif ($bits -eq 8) { $maskBytes[$i] = 255 }
        else                 { $maskBytes[$i] = (0xFF -shl (8 - $bits)) -band 0xFF }
    }
    $mask = [System.Net.IPAddress]::new($maskBytes)

    # Network & broadcast
    $networkBytes = for ($i = 0; $i -lt 4; $i++) { $ip[$i] -band $maskBytes[$i] }
    $network = [System.Net.IPAddress]::new($networkBytes)

    $broadcastBytes = for ($i = 0; $i -lt 4; $i++) {
        $networkBytes[$i] -bor ((-bnot $maskBytes[$i]) -band 0xFF)
    }
    $broadcast = [System.Net.IPAddress]::new($broadcastBytes)

    # Total hosts
    $hostBits = 32 - $prefix
    $totalHosts = [math]::Pow(2, $hostBits)

    # Azure usable hosts
    if ($prefix -ge 30) {
        $azureUsableHosts = 0
        $usableRange = "Not usable in Azure (/30, /31, /32)"
    } else {
        $azureUsableHosts = $totalHosts - 5
        $firstIP = $networkBytes.Clone(); $firstIP[3] = 4
        $lastIP  = $broadcastBytes.Clone(); $lastIP[3]--
        $firstUsable = [System.Net.IPAddress]::new($firstIP)
        $lastUsable  = [System.Net.IPAddress]::new($lastIP)
        $usableRange = "$firstUsable - $lastUsable"
    }

    # Azure reserved IPs
    $az1 = [System.Net.IPAddress]::new(($networkBytes[0..2] + @(1)))
    $az2 = [System.Net.IPAddress]::new(($networkBytes[0..2] + @(2)))
    $az3 = [System.Net.IPAddress]::new(($networkBytes[0..2] + @(3)))

    return [PSCustomObject]@{
        NetworkAddress   = $network.IPAddressToString
        BroadcastAddress = $broadcast.IPAddressToString
        SubnetMask       = $mask.IPAddressToString
        Prefix           = $prefix
        TotalHosts       = $totalHosts
        AzureUsableHosts = $azureUsableHosts
        UsableHostRange  = $usableRange
        AzureGatewayIP   = $az1.IPAddressToString
        AzureReservedIP2 = $az2.IPAddressToString
        AzureReservedIP3 = $az3.IPAddressToString
    }
}

# -------------------------
# Function: Recommend CIDR from host count
# -------------------------
function Recommend-CIDR {
    param([int]$HostsNeeded)

    $totalNeeded = $HostsNeeded + 5   # Azure reserves 5 IPs
    for ($prefix = 32; $prefix -ge 0; $prefix--) {
        $hosts = [math]::Pow(2, 32 - $prefix)
        if ($hosts -ge $totalNeeded) {
            return $prefix
        }
    }
}

# -------------------------
# Function: Split subnet
# -------------------------
function Split-Subnet {
    param([string]$CIDR, [int]$NumberOfSubnets)

    $original = Get-SubnetInfo -CIDR $CIDR
    $prefix = $original.Prefix
    $ipBytes = [System.Net.IPAddress]::Parse($original.NetworkAddress).GetAddressBytes()
    $subnetBits = [math]::Ceiling([math]::Log($NumberOfSubnets,2))
    $newPrefix = $prefix + $subnetBits
    $subnetSize = [math]::Pow(2, 32 - $newPrefix)

    $subnets = @()
    for ($i = 0; $i -lt $NumberOfSubnets; $i++) {
        $start = $i * $subnetSize
        $networkBytes = $ipBytes.Clone()
        $networkBytes[3] = [math]::Floor($start % 256)
        $networkBytes[2] += [math]::Floor($start / 256)
        $subnetCIDR = "$($networkBytes[0]).$($networkBytes[1]).$($networkBytes[2]).$($networkBytes[3])/$newPrefix"
        $subnets += Get-SubnetInfo -CIDR $subnetCIDR
    }
    return $subnets
}

# -------------------------
# Main Logic
# -------------------------

# If HostsNeeded provided, recommend CIDR
if ($HostsNeeded) {
    $recommendedPrefix = Recommend-CIDR -HostsNeeded $HostsNeeded
    Write-Host ""
    Write-Host "${White}CIDR Recommendation:${Reset} /$recommendedPrefix for $HostsNeeded hosts"
    $recommendedCIDR = "10.0.0.0/$recommendedPrefix"
    $data = Get-SubnetInfo -CIDR $recommendedCIDR
}

# If CIDR provided without HostsNeeded
elseif ($CIDR) {
    $data = Get-SubnetInfo -CIDR $CIDR
}

# Display main subnet info
if ($data) {
    Write-Host ""
    Write-Host "${White}================ Azure Subnet Calculator ================${Reset}"
    Write-Host ""
    Write-Host "${White}Network Address:   ${Reset}$($data.NetworkAddress)"
    Write-Host "${White}Broadcast Address: ${Reset}$($data.BroadcastAddress)"
    Write-Host "${White}Subnet Mask:       ${Reset}$($data.SubnetMask)"
    Write-Host "${White}Prefix:            ${Reset}/$($data.Prefix)"
    Write-Host ""
    Write-Host "${White}Azure Reserved IPs:${Reset}"
    Write-Host "  ${Red}Gateway (.1):        $($data.AzureGatewayIP)${Reset}"
    Write-Host "  ${Red}Reserved (.2):       $($data.AzureReservedIP2)${Reset}"
    Write-Host "  ${Red}Reserved (.3):       $($data.AzureReservedIP3)${Reset}"
    Write-Host ""
    Write-Host "Usable Host Range: ${Green}$($data.UsableHostRange)${Reset}"
    Write-Host "Azure Usable Hosts: ${Green}$($data.AzureUsableHosts)${Reset}"
    Write-Host ""
    Write-Host "${White}Total Hosts (raw): $($data.TotalHosts)${Reset}"
    Write-Host ""
    Write-Host "${White}===========================================================${Reset}"
}

# If SplitSubnets provided, split the subnet
if ($SplitSubnets -and $data) {
    Write-Host ""
    Write-Host "${White}Splitting subnet $CIDR into $SplitSubnets subnets:${Reset}"
    $subnets = Split-Subnet -CIDR $CIDR -NumberOfSubnets $SplitSubnets
    $count = 1
foreach ($s in $subnets) {
    Write-Host ""
    Write-Host "${White}Subnet #${count}: $($s.NetworkAddress)/$($s.Prefix)${Reset}"
    Write-Host "  ${Red}Reserved IPs: $($s.AzureGatewayIP), $($s.AzureReservedIP2), $($s.AzureReservedIP3)${Reset}"
    Write-Host "  Usable Host Range: ${Green}$($s.UsableHostRange)${Reset}"
    Write-Host "  Azure Usable Hosts: ${Green}$($s.AzureUsableHosts)${Reset}"
    $count++
}
}