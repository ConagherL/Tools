#-----------------------------------------------------------------------------------
# Author: Conagher Lepley
# Blog: https://theitjunkie.com
# Twitter: @conagherL
# Date: 4/25/2018
#-----------------------------------------------------------------------------------
# Enable Mailbox Auditing for Office 365 Users using a Azure Automation Account
#-----------------------------------------------------------------------------------


#This script will enable non-owner mailbox access auditing on every mailbox in your tenancy

#Connect to Azure Automation
$Credentials = Get-AutomationPSCredential -Name 'Azure AD Automation'

# Function: Connect to Exchange Online 
function Connect-ExchangeOnline {
    param (
        $Creds
    )
        Write-Output "Connecting to Exchange Online"
        Get-PSSession | Remove-PSSession       
        $Session = New-PSSession –ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Creds -Authentication Basic -AllowRedirection
        $Commands = @("Get-MailboxFolderPermission","Set-MailboxFolderPermission","Set-Mailbox","Get-Mailbox","Set-CalendarProcessing","Add-DistributionGroupMember")
        Import-PSSession -Session $Session -DisableNameChecking:$true -AllowClobber:$true -CommandName $Commands | Out-Null
    }
 
# Connect to Exchange Online
Connect-ExchangeOnline -Creds $Credentials
 
# Enable Mailbox Auditing, set age limit, and Audit Owner for All Users
Write-Output "Enable Mailbox Audit for all Users"
Get-Mailbox -Filter {RecipientTypeDetails -eq "UserMailbox" -and AuditEnabled -eq $False} | Set-Mailbox -AuditEnabled $True -AuditLogAgeLimit 365 -AuditOwner Create,HardDelete,MailboxLogin,MoveToDeletedItems,SoftDelete,Update
 
# Close Session
Get-PSSession | Remove-PSSession
 
Write-Output "Script Completed!"
