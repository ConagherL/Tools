#$AllUsers = Get-AzureADUser -Filter "usertype eq 'member'" -all $true| select userprincipalname,displayname
$allusers = import-csv .\exports\AllSourceUsers.csv
#$AllUsers = Get-AzureADUser -SearchString "t12345a@omes.onmicrosoft.com"
$Output = @()
$AllUsersCount = ($AllUsers | measure).count
$i = 0

foreach ($User in $AllUsers) {
$UPN = $user.userprincipalname
$Percentage =  [math]::Round((($i/$AllUsersCount)*100),1)
Write-Progress -Activity "Retrieving MFA methods" -Status "$Percentage% Complete - Working on $UPN ($i/$AllUsersCount)" -PercentComplete ($Percentage)

$PhoneMethods = Get-MgUserAuthenticationPhoneMethod -UserId $User.userprincipalname

foreach ($Method in $PhoneMethods) {

$MethodOutput = new-object -TypeName PSObject -Property @{

    Id = $Mmethod.Id
    PhoneNumber = $method.PhoneNumber
    PhoneType = $Method.PhoneType
    UserPrincipalName = $User.UserPrincipalName
    }

$Output += $MethodOutput

}
$i++
}

$Output | export-csv .\exports\MFAMethodsFromSource.csv -NoTypeInformation
