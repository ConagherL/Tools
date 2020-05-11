<#                                Export All AD Objects Powershell 
#>

#Variables
$OUPath = "OU=MIGRATION,DC=CONTOSO,DC=LOCAL"
$Filepath = "C:\temp"

# AD Computers
Get-ADComputer -Filter * -Searchbase $OUPath -Properties ipv4Address,OperatingSystem,operatingSystemVersion,mS-DS-ConsistencyGuid,LastLogonDate,LastLogonTimeStamp,description,whenCreated,distinguishedName  | 
Select-Object Name, ipv4*, 
OperatingSystem,operatingSystemVersion,mS-DS-ConsistencyGuid,LastLogonDate,Description,@{Name="LastLogonStamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}},WhenCreated,distinguishedName |
 Sort-Object LastLogondate -Descending  | 
Export-csv $Filepath\ADcomputers.csv -NoTypeInformation


# AD Users

                  Import-module activedirectory
                  $DaTA=@(
Get-ADUser  -filter * -Searchbase $OUPath -Properties * |  
                  Select-Object @{Label = "FirstName";Expression = {$_.GivenName}},  
                  @{Name = "LastName";Expression = {$_.Surname}},
                  @{Name = "Full address";Expression = {$_.StreetAddress}},
                  @{Name = "Mail";Expression = {$_.Mail}},
                  @{Name = "Proxy Address";Expression = {$_.proxyaddress}},
                  @{Name = "ObjectSid";Expression = {$_.objectSid}},
                  @{Name = "mS-DS-ConsistencyGuid";Expression = {$_."mS-DS-ConsistencyGuid"}},
                  @{Name = "x500uniqueIdentifier";Expression = {$_."x500uniqueIdentifier"}},
                  @{Name = "Fullname";Expression = {$_.Name}},
                  @{Name = "LogonName";Expression = {$_.Samaccountname}},
                  @{Name = "City";Expression = {$_.City}}, 
                  @{Name = "State";Expression = {$_.st}}, 
                  @{Name = "Post Code";Expression = {$_.PostalCode}}, 
                  @{Name = "Country/Region";Expression ={$_.Country}},
                  @{Name = "MobileNumber";Expression = {$_.mobile}},
                  @{Name = "Phone";Expression = {$_.telephoneNumber}}, 
                  @{Name = "Description";Expression = {$_.Description}},
                  @{name =  "Root_OU";expression={$_.DistinguishedName.split(',')[1].split('=')[1]}},
                  @{name =  "OU_Path";Expression = {$_.DistinguishedName}},
                  @{Name = "Email";Expression = {$_.Mail}},
                  @{Name = "MemberGroups"; Expression ={(($_.MemberOf).split(",") | where-object {$_.contains("CN=")}).replace("CN=","")-join ','}},
                  @{Name = "Primary Group";Expression= {$_.primarygroup  -replace '^CN=|,.*$'}},
                  @{Name = "UserPrincipalName";Expression = {$_.UserPrincipalName}},
                  @{Name = "LastLogonTimeSTamp";Expression = {if(($_.lastLogonTimestamp -like '*1/1/1601*' -or $_.lastLogonTimestamp -eq $null)){'NeverLoggedIn'} Else{[DateTime]::FromFileTime($_.lastLogonTimestamp)}}},
                  @{Name = "Account Status";Expression = {if (($_.Enabled -eq 'TRUE')  ) {'Enabled'} Else {'Disabled'}}},
                  @{Name = "LastLogonDate";Expression = {if(($_.lastlogondate -like '*1/1/1601*' -or $_.lastlogondate -eq $null)){'NeverLoggedIn'} Else{$_.lastlogondate}}},
                  @{Name = "WhenUserWasCreated";Expression = {$_.whenCreated}},
                  @{Name = "accountexpiratondate";Expression = {$_.accountexpiratondate}},
                  @{Name = "PasswordLastSet";Expression = {([DateTime]::FromFileTime($_.pwdLastSet))}},
                  @{Name = "PasswordExpiryDate";Expression={([datetime]::fromfiletime($_."msDS-UserPasswordExpiryTimeComputed")).DateTime}},
                  @{Name = "Password Never";Expression = {$_.passwordneverexpires}},
                  @{Name = "HomeDriveLetter";Expression = {$_.HomeDrive}},
                  @{Name = "HomeFolder";Expression = {$_.HomeDirectory}},
                  @{Name = "scriptpath";Expression = {$_.scriptpath}},
                  @{Name = "HomePage";Expression = {$_.HomePage}},
                  @{Name = "Department";Expression = {$_.Department}},
                  @{Name = "EmployeeID";Expression = {$_.EmployeeID}},
                  @{Name = "Job Title";Expression = {$_.Title}},
                  @{Name = "EmployeeNumber";Expression = {$_.EmployeeNumber}},
                  @{Name = "Manager";Expression={($_.manager -replace 'CN=(.+?),(OU|DC)=.+','$1')}}, 
                  @{Name = "Company";Expression = {$_.Company}},
                  @{Name = "Office";Expression = {$_.OfficeName}}
                  )
                  $DAta | Sort-Object LastLogondate -Descending | 
                  Export-Csv -Path $Filepath\adusers.csv -NoTypeInformation       
        
        
        # AD OrganizationalUnits
        
        Get-ADOrganizationalUnit -filter * -SearchBase $OUPath | Select-Object Name,DistinguishedName,Description | 
        Export-csv -path $Filepath\ADOrganizationalUnits.csv -NoTypeInformation
        
        # AD Contacts
        Get-ADobject  -LDAPfilter "objectClass=contact" -Searchbase $OUPath -Properties mail,Description,Mobile,ipPhone,homePhone,whenCreated,distinguishedName,mail,proxyAddresses | 
        Select-Object name,mail,Description,mobile,ipPhone,homePhone,whenCreated,distinguishedName,mail,proxyAddresses   | 
        Export-csv -path $Filepath\ADcontacts.csv -NoTypeInformation
        
        # AD Groups
        Get-ADgroup -Filter * -searchbase $OUPath -Properties members,whencreated,description,groupscope,mS-DS-ConsistencyGuid,mail,proxyAddresses,distinguishedName | 
        Select-Object name,samaccountname,groupscope,@{Name="Members"; Expression ={(($_.Members).split(",") | 
        where-object {$_.contains("CN=")}).replace("CN=","")-join ','}},whencreated,description,mS-DS-ConsistencyGuid,mail,proxyAddresses,distinguishedName | Sort-Object -Property Name|
         Export-csv -path $Filepath\ADGroups.csv -NoTypeInformation

## get AD users Group membership another way

Get-ADUser -filter * -Searchbase $OUPath -Properties DisplayName,memberof | ForEach-Object {
  New-Object PSObject -Property @{
	UserName = $_.DisplayName
	Groups = ($_.memberof | Get-ADGroup | Select-Object -ExpandProperty Name) -join ","
	}
} | Select-Object UserName,Groups | Export-Csv $Filepath\Groupreport.csv -NTI
