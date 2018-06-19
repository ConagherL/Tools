<#
NAME: Get-DomainLevelAdmins.ps1
AUTHOR: Sean Metcalf	
AUTHOR EMAIL: SeanMetcalf@MetcorpConsulting.com
CREATION DATE: 3/01/2013
LAST MODIFIED DATE: 03/01/2013
LAST MODIFIED BY: Sean Metcalf
INTERNAL VERSION: 01.13.03.01.21
RELEASE VERSION: 0.1.0
#>


###############################
# Set Environmental Variables #
###############################

$DomainDNS = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name #Get AD Domain (lightweight & fast method)    
$CurrentUserName = $env:UserName
$LogDir = "C:\temp\Logs\"
IF (!(Test-Path $LogDir)) {new-item -type Directory -path $LogDir}  
$LogFileName = "Get-DomainLevelAdmins-$DomainDNS-$TimeVal.log"
$LogFile = $LogDir + $LogFileName

##############################
# Import Powershell Elements #
##############################
import-module ActiveDirectory


##################
# Start Logging  #
##################
# Log all configuration changes shown on the screen during run-time in a transcript file.  This
# inforamtion can be used for troubleshooting if necessary
Write-Verbose "Start Logging to $LogFile  `r "

Start-Transcript $LogFile -force

## Process Start Time
$ProcessStartTime = Get-Date
Write-Verbose " `r "
write-Verbose "Script initialized by $CurrentUserName and started processing at $ProcessStartTime `r "
Write-Verbose " `r "

#############################################
# Get Active Directory Forest & Domain Info #  20120201-15
#############################################
# Get Forest Info
write-output "Gathering Active Directory Forest Information..." `r
Write-Verbose "Running Get-ADForest Powershell command `r"
$ADForestInfo =  Get-ADForest

$ADForestApplicationPartitions = $ADForestInfo.ApplicationPartitions
$ADForestCrossForestReferences = $ADForestInfo.CrossForestReferences
$ADForestDomainNamingMaster = $ADForestInfo.DomainNamingMaster
$ADForestDomains = $ADForestInfo.Domains
$ADForestForestMode = $ADForestInfo.ForestMode
$ADForestGlobalCatalogs = $ADForestInfo.GlobalCatalogs
$ADForestName = $ADForestInfo.Name
$ADForestPartitionsContainer = $ADForestInfo.PartitionsContainer
$ADForestRootDomain = $ADForestInfo.RootDomain
$ADForestSchemaMaster = $ADForestInfo.SchemaMaster
$ADForestSites = $ADForestInfo.Sites
$ADForestSPNSuffixes = $ADForestInfo.SPNSuffixes
$ADForestUPNSuffixes = $ADForestInfo.UPNSuffixes

# Get Domain Info
write-output "Gathering Active Directory Domain Information..." `r
Write-Verbose "Performing Get-ADDomain powershell command `r"
$ADDomainInfo = Get-ADDomain

$ADDomainAllowedDNSSuffixes = $ADDomainInfo.ADDomainAllowedDNSSuffixes
$ADDomainChildDomains = $ADDomainInfo.ChildDomains
$ADDomainComputersContainer = $ADDomainInfo.ComputersContainer
$ADDomainDeletedObjectsContainer = $ADDomainInfo.DeletedObjectsContainer
$ADDomainDistinguishedName = $ADDomainInfo.DistinguishedName
$ADDomainDNSRoot = $ADDomainInfo.DNSRoot
$ADDomainDomainControllersContainer = $ADDomainInfo.DomainControllersContainer
$ADDomainDomainMode = $ADDomainInfo.DomainMode
$ADDomainDomainSID = $ADDomainInfo.DomainSID
$ADDomainForeignSecurityPrincipalsContainer = $ADDomainInfo.ForeignSecurityPrincipalsContainer
$ADDomainForest = $ADDomainInfo.Forest
$ADDomainInfrastructureMaster = $ADDomainInfo.InfrastructureMaster
$ADDomainLastLogonReplicationInterval = $ADDomainInfo.LastLogonReplicationInterval
$ADDomainLinkedGroupPolicyObjects = $ADDomainInfo.LinkedGroupPolicyObjects
$ADDomainLostAndFoundContainer = $ADDomainInfo.LostAndFoundContainer
$ADDomainName = $ADDomainInfo.Name
$ADDomainNetBIOSName = $ADDomainInfo.NetBIOSName
$ADDomainObjectClass = $ADDomainInfo.ObjectClass
$ADDomainObjectGUID = $ADDomainInfo.ObjectGUID
$ADDomainParentDomain = $ADDomainInfo.ParentDomain
$ADDomainPDCEmulator = $ADDomainInfo.PDCEmulator
$ADDomainQuotasContainer = $ADDomainInfo.QuotasContainer
$ADDomainReadOnlyReplicaDirectoryServers = $ADDomainInfo.ReadOnlyReplicaDirectoryServers
$ADDomainReplicaDirectoryServers = $ADDomainInfo.ReplicaDirectoryServers
$ADDomainRIDMaster = $ADDomainInfo.RIDMaster
$ADDomainSubordinateReferences = $ADDomainInfo.SubordinateReferences
$ADDomainSystemsContainer = $ADDomainInfo.SystemsContainer
$ADDomainUsersContainer = $ADDomainInfo.UsersContainer			
$DomainDNS = $ADDomainDNSRoot

$ForestDNSZoneNC = $ADForestApplicationPartitions[0]
$DomainDNSZoneNC = $ADForestApplicationPartitions[0]
$SchemaNC = "CN=Schema,CN=Configuration,$ADDomainDistinguishedName"
$ConfigurationNC = "CN=Configuration,$ADDomainDistinguishedName"

##############
# DLA Detail #
##############
Write-Output " `r "
Write-Output "DOMAIN-LEVEL ADMINS: `r "
Write-Output "==================== `r "
$AdministratorsGroupSID = 'S-1-5-32-544'
$DLAAdmins = Get-ADGroupMember -Identity $AdministratorsGroupSID -Recursive
$DLAAdminsCount = $DLAAdmins.Count
$DLAAdminGroups = Get-ADGroupMember -Identity $AdministratorsGroupSID | Where { $_.ObjectClass -eq "group" }
[array]$DLAAdminGroupList = $AdministratorsGroupSID
ForEach ($DLAAdminGroupsItem in $DLAAdminGroups) { [array]$DLAAdminGroupList += $DLAAdminGroupsItem.DistinguishedName }
[int]$DLAAdminGroupListCount = $DLAAdminGroupList.Count
$DLAAdminGroupList = $DLAAdminGroupList | Sort-Object Name
        
Write-Output "Discovered $DLAAdminsCount Total Domain-Level Admins (DLAs) with admin rights provided by $DLAAdminGroupListCount groups: `r "
Write-Output " `r "
        
ForEach ($DLAAdminGroupListItem in $DLAAdminGroupList)
    {  ## OPEN ForEach ($DLAAdminGroupListItem in $DLAAdminGroupList)
        IF ($AdminGroupMembers) { Clear-Variable AdminGroupMembers }
        Write-Verbose "Processing the DLA Group $DLAAdminGroupListItem `r "
        $AdminGroupMembership = Get-ADGroupMember -Identity $DLAAdminGroupListItem
        $AdminGroupMembership = $AdminGroupMembership | Sort-Object Name
        [int]$AdminGroupMembershipCount = $AdminGroupMembership.Count
        $DLAAdminGroupListItemInfo = Get-ADGroup -Identity $DLAAdminGroupListItem -property Name,DisplayName
        $DLAAdminGroupListItemInfoName = $DLAAdminGroupListItemInfo.Name
                        
        IF ($AdminGroupMembershipCount -ge 1)
            {  ## OPEN IF ($AdminGroupMembershipCount -ge 1)
                Write-Output "$DLAAdminGroupListItemInfoName Membership ($AdminGroupMembershipCount Members): `r "
                Write-Output "----------------------------------------- `r "
                        
                ForEach ($AdminGroupMembershipItem in $AdminGroupMembership)
                    {  ## OPEN ForEach ($AdminGroupMembershipItem in $AdminGroupMembership)
                        Write-Verbose "Processing account $AdminGroupMembershipItem in the DLA group $DLAAdminGroupListItem `r " 
                        $AdminGroupMembershipItemInfo = Get-ADObject -Identity $AdminGroupMembershipItem -property Name,DisplayName,SAMAccountName,DistinguishedName
                        $AdminGroupMembershipItemInfoDistinguishedName = $AdminGroupMembershipItemInfo.DistinguishedName
                        $AdminGroupMembershipItemInfoDisplayName = $AdminGroupMembershipItemInfo.DisplayName
                        IF (!$AdminGroupMembershipItemInfoDisplayName) {$AdminGroupMembershipItemInfoDisplayName = $AdminGroupMembershipItemInfo.Name}
                        IF ($AdminGroupMembershipItemInfo.ObjectClass -eq "group")  
                            { $AdminGroupMembershipItemInfoDisplayName = "GROUP: $AdminGroupMembershipItemInfoDisplayName ($AdminGroupMembershipItemInfoDistinguishedName)" }
                          ELSE { $AdminGroupMembershipItemInfoDisplayName = "$AdminGroupMembershipItemInfoDisplayName ($AdminGroupMembershipItemInfoDistinguishedName)" }
                        [array]$AdminGroupMembers += $AdminGroupMembershipItemInfoDisplayName
                    }  ## CLOSE ForEach ($AdminGroupMembershipItem in $AdminGroupMembership)
                $AdminGroupMembers = $AdminGroupMembers | sort-object
                $AdminGroupMembers
                Write-Output " `r "
            }  ## CLOSE IF ($AdminGroupMembershipCount -ge 1)
                
            ELSE 
                { 
                    Write-Output "$DLAAdminGroupListItemInfoName Membership ($AdminGroupMembershipCount Members): `r "
                    Write-Output "----------------------------------------- `r "
                    Write-Output "No members `r " 
                    Write-Output " `r " 
                }
        
    }  ## CLOSE ForEach ($DLAAdminGroupListItem in $DLAAdminGroupList)

Write-Output " `r " 

########################################
# Provide Script Processing Statistics #
########################################
$ProcessEndTime = Get-Date
Write-output "Script started processing at $ProcessStartTime and completed at $ProcessEndTime." `r 
# $TotalProcessTimeCalc = $ProcessEndTime - $ProcessStartTime
# $TotalProcessTime = "{0:HH:mm}"            -f $TotalProcessTimeCalc
# Write-output "" `r 
# Write-output "The script completed in $TotalProcessTime." `r
# Write-Output " `r "

#################
# Stop Logging  #
#################

#Stop logging the configuration changes in a transript file
Stop-Transcript

Write-output "Review the logfile $LogFile for script operation information." `r  



