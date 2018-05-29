$credential = Get-Credential
$Session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -ConfigurationName Microsoft.Exchange -Credential $credential `
    -Authentication Basic -AllowRedirection
Import-PSSession $Session -CommandName Get-CASMailbox, Set-CasMailbox, Get-Casmailboxplan, set-casmailboxplan, Get-OrganizationConfig
Write-Host "Attempting IMAP and POP operations on $((Get-OrganizationConfig).DisplayName)" -ForegroundColor Yellow
     
Write-Host "Disabling IMAP and POP for future mailboxes" -ForegroundColor DarkYellow
Get-CASMailboxPlan -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" } | set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false
$confirmPlans = Get-CASMailboxPlan -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" }
if (!$confirmPlans) {
    Write-Host "IMAP and POP disabled for all future mailboxes" -ForegroundColor Green
}
else {
    Write-Host "IMAP and POP not disabled for all existing mailboxes" -ForegroundColor Red
}
 
Write-Host "Disabling IMAP and POP on all existing mailboxes" -ForegroundColor DarkYellow
Get-CASMailbox -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" } | Select-Object @{n = "Identity"; e = {$_.primarysmtpaddress}} | Set-CASMailbox -ImapEnabled $false -PopEnabled $false
$confirmMailboxes = Get-CASMailbox -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" }
if (!$confirmMailboxes) {
    Write-Host "IMAP and POP disabled on all existing mailboxes`n" -ForegroundColor Green
}
     
Remove-PSSession $Session
