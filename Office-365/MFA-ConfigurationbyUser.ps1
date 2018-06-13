#-----------------------------------------------------------------------------------
# Author: Conagher Lepley
# Blog: https://theitjunkie.com
# Twitter: @conagherL
# Date: 6/13/2018
#-----------------------------------------------------------------------------------
# Export MFA configuration of each user. MFA column may be blank if condtional access is used instead of turing on MFA directly in Azure
#-----------------------------------------------------------------------------------

#Connect to Azure AD
$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential

#Set file export path
$filepath = "C:\temp\MFAUsers.csv"

#Queries Azure AD for a sepcific group ID, colelcts the information, and exports to a file
Get-MsolGroupMember -GroupObjectId "Populate group GUID ID Here" -MemberObjectTypes User -All | Get-MsolUser | Where {$_.UserPrincipalName} | Select UserPrincipalName, DisplayName, Country, Department, Title, @{n="MFA"; e={$_.StrongAuthenticationRequirements.State}}, @{n="Methods"; e={($_.StrongAuthenticationMethods).MethodType}}, @{n="Default Method"; e={($_.StrongAuthenticationMethods).IsDefault}} | Export-Csv -Path $filepath
