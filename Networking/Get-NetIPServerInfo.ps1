# .SYNOPSIS
# Get-NetIPServerInfo gets the IP configuration of all domain joined Windows servers.
 
# .DESCRIPTION
# Uses Test-Connection to check if the server is powered on and reachable.
 
# .EXAMPLE
# Get-NetIPServerInfo | Format-Table -AutoSize
 
# .NOTES
 
function Get-NetIPServerInfo {
 
$getc=(Get-ADComputer -Filter 'operatingsystem -like "*server*"-and enabled -eq "true"').Name
$test=Test-Connection -Destination $getc -Count 1 `
-ErrorAction SilentlyContinue
$reach=$test | Select-Object -ExpandProperty Address
$result=@()
 
foreach ($c in $reach)
 
{
$i=Invoke-Command -ComputerName $c -ScriptBlock {
 
Get-NetIPConfiguration |
Select-Object `
-Property InterfaceAlias,Ipv4Address,DNSServer
Get-NetRoute -DestinationPrefix '0.0.0.0/0' |
Select-Object -ExpandProperty NextHop}
 
$result +=New-Object -TypeName PSCustomObject -Property ([ordered]@{
'Server'= $c
'Interface' = $i.InterfaceAlias -join ','
'IPv4Address' = $i.Ipv4Address.IPAddress -join ','
'Gateway' = $i | Select-Object -Last 1
'DNSServer' = ($i.DNSServer |
Select-Object -ExpandProperty ServerAddresses) -join ','
 
})
 
}
$result
}