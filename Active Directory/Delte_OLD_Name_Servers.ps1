Import-Module ActiveDirectory,DNSServer
$UnknownDNSServer = Read-Host "server.domain.suffix"
$PDCE = Get-ADDomainController -Discover -Service PrimaryDC
$DNSZones = Get-DnsServerZone -ComputerName $PDCE
$DNSZones | ForEach-Object {
Try {$_ | Remove-DNSServerResourceRecord -Name "$UnknownDNSServer" -RRType NS -RecordData $UnknownDNSServer -ComputerName $PDCE -Force}
Catch{[System.Exception] "uh oh error time"}
}