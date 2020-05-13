#$AllUsers = Get-AzureADUser -Filter "usertype eq 'member'" -all $true| select userprincipalname,displayname
$AllUsers = import-csv .\exports\MFAMethodsFromSource.csv
$MobileUsers = $AllUsers | ? {$_.PhoneType -eq "Mobile"}
$OtherPhoneUsers = $AllUsers | ? {$_.PhoneType -ne "Mobile"}
$Output = @()
$AllUsersCount = ($AllUsers | measure).count
$i = 0

foreach ($User in $MobileUsers) {

    $OldUPN = $user.userprincipalname
    $NewAlias = $OldUPN.split("@")[0]
    $NewUPN = $NewAlias + "@okdhs.org"


$Percentage =  [math]::Round((($i/$AllUsersCount)*100),1)
Write-Progress -Activity "Import MFA methods (mobile)" -Status "$Percentage% Complete - Working on $NewUPN ($i/$AllUsersCount)" -PercentComplete ($Percentage)

$PhoneNumber =  $user.phonenumber
$PhoneType = $user.phonetype

try {

new-MgUserAuthenticationPhoneMethod -UserId $NewUPN -PhoneNumber $PhoneNumber -PhoneType $PhoneType -WhatIf
}
catch {

}

$i++
}

Write-Host "Imported $i mobile MFA methods" -ForegroundColor Yellow

$i = 0

foreach ($User in $OtherPhoneUsers) {

    $OldUPN = $user.userprincipalname
    $NewAlias = $OldUPN.split("@")[0]
    $NewUPN = $NewAlias + "@okdhs.org"


$Percentage = ($i/$AllUsersCount)*100
Write-Progress -Activity "Import MFA methods (non-mobile)" -Status "$Percentage% Complete - Working on $NewUPN ($i/$AllUsersCount)" -PercentComplete ($Percentage)

$PhoneNumber =  $user.phonenumber
$PhoneType = $user.phonetype


try {
new-MgUserAuthenticationPhoneMethod -UserId $NewUPN -PhoneNumber $PhoneNumber -PhoneType $PhoneType -WhatIf
}
catch {

}

$i++
}

Write-Host "Imported $i non-mobile MFA methods" -ForegroundColor Yellow
