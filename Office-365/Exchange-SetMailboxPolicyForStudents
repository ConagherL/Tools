#-----------------------------------------------------------------------------------
# Author: Conagher Lepley
# Blog: https://theitjunkie.com
# Twitter: @conagherL
# Date: 4/25/2018
#-----------------------------------------------------------------------------------
# Apply AddressBook Policy on Student Accounts using a Azure Automation Account
#-----------------------------------------------------------------------------------

$Credentials = Get-AutomationPSCredential -Name 'Azure AD Account'
$AddressBookPolicy = "MAILBOX POLICY NAME"
$Commands = @("Set-Mailbox","Get-Mailbox")
$Session = New-PSSession –ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credentials -Authentication Basic -AllowRedirection
 
Import-PSSession -Session $Session -DisableNameChecking:$true -AllowClobber:$true -CommandName $Commands | Out-Null

$Mailboxes = Get-Mailbox -Filter {CustomAttribute1 -eq "Student" -and AddressBookPolicy -eq $null}
$Mailboxes_UPN = $Mailboxes.UserPrincipalName

foreach ($Mailbox in $Mailboxes_UPN){
   Write-Output "Student AddressBook policy ($AddressBookPolicy) set on $Mailbox"
   Set-Mailbox -Identity "$Mailbox" -AddressBookPolicy $AddressBookPolicy
}

Write-Output "Script Completed!"

# Close Session
Get-PSSession | Remove-PSSession
