<#
    NAME: Find-DuplicateSPNs.ps1
    AUTHOR: Sean Metcalf    
    AUTHOR EMAIL: SeanMetcalf@MetcorpConsulting.com
    CREATION DATE: 03/12/2012
    LAST MODIFIED DATE: 03/19/2012
    LAST MODIFIED BY: Sean Metcalf
    INTERNAL VERSION: 01.12.03.19.13
    RELEASE VERSION: 0.1.3
#>

###############################
# Set Environmental Variables #
###############################
# COMMON
write-output "Setting environmental variables... `r "
$DomainDNS = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name #Get AD Domain (lightweight & fast method)
$ADDomain = $DomainDNS 
Write-Debug "Variable $DomainDNS & ADDomain is set to $DomainDNS  `r " 
$TimeVal = get-date -uformat "%Y-%m-%d-%H-%M" 
Write-Debug "Variable TimeVal is set to $TimeVal `r " 
$LogDir = "D:\Report\Logs\"  #Standard location for script logs
Write-Debug "Variable LogDir is set to $LogDir  `r " 
$DateTime = Get-Date #Get date/time
Write-Debug "Variable DateTime is set to $DateTime  `r "
$Separator = "#"  #Create separation line
$Sepline = $Separator * 75  #Create separation line
IF (!(Test-Path $LogDir)) {new-item -type Directory -path $LogDir}  

# Script Specific

# Script Logging
$CSVReportFileName = "DuplicateSPNs-$DomainDNS-$TimeVal.csv"
$CSVReportFile = $LogDir + $CSVReportFileName
Write-Debug "Variable CSVReportFile is set to $CSVReportFile  `r "

################################################
# Import Active Directory Powershell Elements  #
################################################
write-Verbose "Configuring Powershell environment... `r "
Write-Verbose "Importing Active Directory Powershell module `r "
import-module ActiveDirectory

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

###########################
# Discover Duplicate SPNs #
###########################
IF ($AllSPNList) { Clear-Variable AllSPNList ; Clear-Variable DuplicateSPNList }
Write-Output "Discover Local GC  `r "

Write-Output "Discover Local GC running ADWS `r "
$LocalSite = (Get-ADDomainController -Discover).Site
$NewTargetGC = Get-ADDomainController -Discover -Service 6 -SiteName $LocalSite
IF (!$NewTargetGC)
    { $NewTargetGC = Get-ADDomainController -Discover -Service 6 -NextClosestSite }
$LocalGC = $NewTargetGC.HostName + ":3268"

Write-Output "Identify User and Computer Objects with configured Service Principal Names `r " 
$Time = (Measure-Command `
    { $ObjectList = Get-ADObject -Server "INL-DC01" -filter { (ObjectClass -eq "User") -OR (ObjectClass -eq "Computer") } `
     -property name,distinguishedname,ServicePrincipalName | Where-Object { $_.ServicePrincipalName -ne $NULL }
    }).Seconds
$ObjectListCount = $ObjectList.Count
Write-Output "Discovered $ObjectListCount User and Computer Objects with SPNs in $Time Seconds `r " 

Write-Output "Build a list of all SPNs `r "
$Time = (Measure-Command `
  { ForEach ($Item in $ObjectList)
    {  ## OPEN ForEach Item in ObjectList
       ForEach ($Object in $Item.ServicePrincipalName) 
        {  ## OPEN ForEach Object in Item.ServicePrincipalName
            [array]$AllSPNList += $Object
        }  ## CLOSE ForEach Object in Item.ServicePrincipalName
    }  ## CLOSE ForEach Item in ObjectList
  }).Seconds    
Write-Output "SPN List created in $Time Seconds `r "   
  
Write-Output "Find duplicates in the SPN list `r "  
$Time = (Measure-Command `
  { 
    [array]$AllSPNList = $AllSPNList | sort-object
    [array]$UniqueSPNs = $AllSPNList | Select-Object -unique
    [array]$DuplicateSPNs = Compare-Object -ReferenceObject $UniqueSPNs -DifferenceObject $AllSPNList
  }).Seconds  
[int]$UniqueSPNSCount = $UniqueSPNS.Count    
ForEach ($Dup in $DuplicateSPNs)
    {  ## OPEN ForEach Dup in DuplicateSPNs
        [array]$DuplicateSPNList += $Dup.InputObject
    }  ## CLOSE ForEach Dup in DuplicateSPNs
[int]$DuplicateSPNsCount = $DuplicateSPNList.Count  
Write-Output "Discovered $UniqueSPNSCount Unique SPNs in $Time Seconds `r "  
Write-Output "Discovered $DuplicateSPNsCount Duplicate SPNs in $Time Seconds `r "  
Write-Output " `r "

Write-Output "Identifying objects containing the duplicate SPNs... `r "
ForEach ($SPN in $DuplicateSPNList)
    {  ## OPEN ForEach SPN in DuplicateSPNs
        $DupSPNObjects = $ObjectList | Where-Object { $_.ServicePrincipalName -eq $SPN }
        Write-Output " `r "
        Write-Output "The SPN $SPN is configured on the following objects:  `r "
        
        ForEach ($Obj in $DupSPNObjects)
            {  ## OPEN ForEach Obj in DupSPNObjects
              [string]$SPNObjectSPN = $SPN  # $Obj.ServicePrincipalName 
              $SPNObjectName = $Obj.Name
              $SPNObjectClass = $Obj.ObjectClass  
              $SPNObjectDN = $Obj.DistinguishedName 
              
              Write-Output "     *  $SPNObjectName ($SPNObjectClass) has the associated SPN: $SPN [$SPNObjectDN] `r "
              
              Write-Verbose "Creating Inventory Object for $FilePath..."
                $InventoryObject = New-Object -TypeName PSObject
                $InventoryObject | Add-Member -MemberType NoteProperty -Name SPN -Value ($SPN)
                $InventoryObject | Add-Member -MemberType NoteProperty -Name ObjectName -Value $SPNObjectName
                $InventoryObject | Add-Member -MemberType NoteProperty -Name SPNObjectClass -Value $SPNObjectClass
                $InventoryObject | Add-Member -MemberType NoteProperty -Name ObjectDN -Value $SPNObjectDN
                [array]$AllInventory += $InventoryObject
             
            }  ## CLOSE ForEach Obj in DupSPNObjects
    }  ## CLOSE ForEach SPN in DuplicateSPNs

# Create Inventory Object
[int]$AllInventoryCount = $AllInventory.Count
Write-Output "Exporting File Information ($AllInventoryCount records) to CSV Report file ($CSVReportFile)..."
$AllInventory | Export-CSV $CSVReportFile -NoType