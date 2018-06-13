
$filepath = "C:\temp\MFAUsers.csv"
Get-MsolGroupMember -GroupObjectId "94da5047-6314-419a-bafd-a86f6a45124c" -MemberObjectTypes User -All | Get-MsolUser | Where {$_.UserPrincipalName} | Select UserPrincipalName, DisplayName, Country, Department, Title, @{n="MFA"; e={$_.StrongAuthenticationRequirements.State}}, @{n="Methods"; e={($_.StrongAuthenticationMethods).MethodType}}, @{n="Default Method"; e={($_.StrongAuthenticationMethods).IsDefault}} | Export-Csv -Path $filepath
