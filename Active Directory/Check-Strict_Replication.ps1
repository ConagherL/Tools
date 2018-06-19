import-module activedirectory
$ADDomainDistinguishedName = (Get-ADDomain).DistinguishedName
Write-Verbose "Check if Strict Replication Consistency is Enabled `r"
$ADSRCheck = Test-Path "AD:CN=94fdebc6-8eeb-4640-80de-ec52b9ca17fa,CN=Operations,CN=Forestupdates,CN=Configuration,$ADDomainDistinguishedName"
IF ($ADSRCheck -eq $True) {$ADSRC = "Enabled"}
ELSE {$ADSRC = "Disabled"}
Write-output "AD Strict Replication Consistency is $ADSRC `r"