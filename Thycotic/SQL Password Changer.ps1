$TargetComputer = $args[0]
Write-Debug $TargetComputer
$domain= $args[1]
Write-Debug $domain
$UName= $args[2]
Write-Debug $uname
$PWord= $args[3]
Write-Debug $PWord
$SQLService=$args[4]
Write-Debug $SQLService
$SvcAccntUsr=$args[5]
Write-Debug $SvcAccntUsr
$SvcAcctPWD=$args[6]
Write-Debug $SvcAcctPWD
 
$Spassword = ConvertTo-SecureString $Pword -AsPlainText -Force #Secure PW
$creds = New-Object System.Management.Automation.PSCredential ("$domain\$UName", $Spassword) #Set credentials for PSCredential logon
 
$ScriptBlock= {
param($SQLService,$TargetComputer,$domain,$username,$pword)
"$SQLService,$TargetComputer,$domain,$username,$pword" | out-file test.txt -Append
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null
$SMOWmiserver = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer') # $TargetComputer           
try
{
#Specify the "Name" (from the query above) of the one service whose Service Account you want to change.
$domainuser="$domain\$username"
$ChangeService=$SMOWmiserver.Services | where {$_.displayname -eq $SQLService -or $_.name -eq $SQLService } #Make sure this is what you want changed!
#$ChangeService | out-file c:\temp\test.txt -append  # Remove this line for production for debugging and development only. Requires you create a temp directory on the targetmachine.
$ChangeService.ChangePassword("$pword", "$pword")
$ChangeService.Alter()
}
catch
{
$ErrorMessage = $_.Exception.Message
$FailedItem = $_.Exception.ItemName 
 throw "Error $ErrorMessage : $FailedItem while setting $sqlservice on $targetComputer with $domainuser"
}
}
#1. Modify the invoke command to use the credentials of the new service account for access to the box. - add domain,username,password from the secret
#   Create secure credentials to access the sql box with the invoke-command
Invoke-Command -Authentication Default -ComputerName $TargetComputer -ScriptBlock $ScriptBlock -ArgumentList $SQLService,$TargetComputer,$domain,$SvcAccntUsr,$SvcAcctPWD -Credential $creds