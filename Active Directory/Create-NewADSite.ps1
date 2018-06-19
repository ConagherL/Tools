<# 
.SYNOPSIS
    NAME: Create-NewADSite.ps1
    This script creates a new Active Directory site along with required components (site subnet & site link). 
        
.DESCRIPTION
    This script creates a new Active Directory site along with required components (site subnet & site link). 

.PARAMETER NewSiteName
    This parameter sets the new site name for creation.
    DEFAULT: N/A
    Example: Create-NewADSite.ps1 -NewSiteName Springfield

.PARAMETER SubnetCIDR  
    This parameter sets the subnet associated with the new site.  
    DEFAULT: N/A
    Example: Create-NewADSite.ps1 -SubnetCIDR "172.17.22.0/24" 
    
.PARAMETER ReplicationSiteName  
    This parameter sets the AD site with which the new AD site will replicate.
    DEFAULT: N/A
    Example: Create-NewADSite.ps1 -ReplicationSiteName "ReplHub"  
    
.PARAMETER SiteCost  
    This parameter sets the AD site link Cost to 100 by default. This controls which site link is used for replication.
    DEFAULT: 100
    Example: Create-NewADSite.ps1 -SiteCost 100
    
.PARAMETER ReplicationInterval  
    This parameter sets the AD site link Replication Interval to 15 by default. This controls how frequently replication occurs.
    DEFAULT: 15 (minutes)
    Example: Create-NewADSite.ps1 -ReplicationInterval 15 

.PARAMETER ChangeExisting  
    This parameter enables Change Notification on all site links.
    Example: Create-NewADSite.ps1 -ChangeExisting
    
.PARAMETER ChangeConfirm 
    This parameter sets the script so it confirms each time it attempts to set change notification on a site link.
    Example: Create-NewADSite.ps1 -ChangeConfirm    
          
.PARAMETER Verbose
    Use this parameter to have the script provide additional detail regarding processing.
    Example: Create-NewADSite.ps1 -Verbose 
	
.PARAMETER Debug
    Use this parameter to have the script provide additional debug detail regarding processing.
    Example: Create-NewADSite.ps1 -Debug 	
	
.EXAMPLE
    Create-NewADSite.ps1 -example 

.NOTES
 	NAME: Create-NewADSite.ps1
 	AUTHOR: Sean Metcalf	
 	AUTHOR EMAIL: SeanMetcalf@MetcorpConsulting.com
 	CREATION DATE: 10/04/2011
    LAST MODIFIED DATE: 10/05/2011
 	LAST MODIFIED BY: Sean Metcalf
 	INTERNAL VERSION: 01.11.10.05.11
    RELEASE VERSION: 0.0.1
#>
# This Powershell script leverages some features only available with Powershell version 2.0.
# As such, there is no guarantee it will work with earlier versions of Powershell.
# Requires -Version 2.0


#####################
# Script Parameters #
#####################  
Param 
    (
	[string] $NewSiteName,
    [string] $SubnetCIDR,
	[string] $ReplicationSiteName,
    [string] $SiteCost = "100",
    [string] $ReplicationInterval = "15",
    [switch] $ChangeExisting,
    [switch] $ChangeConfirm
	)
    
Write-Verbose "Set script variables & environment `r"
Switch ($Verbose) 
	{  ## OPEN Switch Verbose
		$True  { $VerbosePreference = "Continue" ; Write-Output "Script logging is set to verbose. `r " }
		$False  { $VerbosePreference = "SilentlyContinue" ; Write-Output "Script logging is set to normal logging. `r " }
	}  ## OPEN Switch Verbose   
	
Switch ($Debug) 
	{  ## OPEN Switch Debug
		$True  { $DebugPreference = "Continue" ; Write-Output "Script Debug logging is enabled. `r" }
		$False  { $DebugPreference = "SilentlyContinue" ; Write-Output "" `r }
	}  ## OPEN Switch Debug  

IF ($ChangeExisting -eq $True) { $Mode = "Change" }
  ELSE { $Mode = "CreateSite" }

###############################
# Set Environmental Variables #
###############################
# COMMON
write-host "Setting environmental variables..." `r
$DomainDNS = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name #Get AD Domain (lightweight & fast method)
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

# SCRIPT
$ExistingSite = $False
[Array] $ADSiteList = @()
[Array] $ADSiteLinksList = @()

################################################
# Import Active Directory Powershell Elements  #
################################################
write-output "Configuring Powershell environment..." `r
Write-Verbose "Importing Active Directory Powershell module `r"
import-module ActiveDirectory

########################
# Get AD and Site Info # 
########################
Write-Verbose "Get AD data necessary to create site `r "
$ADRootDSE = Get-ADRootDSE	
$ADConfigurationNamingContext = $ADRootDSE.configurationNamingContext  
Write-Verbose "Setting AD configuration variables `r " 
$ADSiteDN = "CN=Sites,$ADConfigurationNamingContext"
$SubnetsDN = "CN=Subnets,$ADSiteDN"
$ADSiteLinksDN = "CN=IP,CN=Inter-Site Transports,$ADSiteDN" 
   
####################
# Get AD Site List # 
####################
Write-Verbose "Get AD Site List `r"
[array] $ADSites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites 
$ADSitesCount = $ADSites.Count
Write-Output "There are $ADSitesCount AD Sites in $DomainDNS `r"

ForEach ($Site in $ADSites)
	{  ## OPEN ForEach Site in ADSites
		[Array] $ADSiteList += $Site.Name
	}  ## CLOSE ForEach Site in ADSites
    
Write-Output $ADSiteList `r
Write-Output " `r "

#############################
# Get List of AD Site Links # 
#############################
Write-Verbose "Get List of AD Site Links `r"
[array] $ADSiteLinks = Get-ADObject -Filter { ObjectClass -eq "sitelink" } -SearchBase $ADSiteDN  
$ADSiteLinksCount = $ADSiteLinks.Count
Write-Output "There are $ADSiteLinksCount AD Site Links in $DomainDNS `r"

ForEach ($Site in $ADSiteLinks)
	{  ## OPEN ForEach Site in ADSites
		[Array] $ADSiteLinksList += $Site.Name
	}  ## CLOSE ForEach Site in ADSites
    
Write-Output $ADSiteLinksList `r
Write-Output " `r "

######################
IF ($Mode -eq "CreateSite")
    {  ## OPEN IF Run mode is CreateSite
    
############################################
# Check New AD Site Against Existing Sites # 
############################################
Write-Verbose "Ensure new site name doesn't already exist `r "
ForEach ($Site in $ADSiteList)
	{  ## OPEN ForEach Site in ADSiteList
		IF ($NewSiteName -eq $Site) { $ExistingSite = $True }
	}  ## CLOSE ForEach Site in ADSiteList

IF ($ExistingSite -eq $True )
	{  ## OPEN IF New Site Name already exists in AD 
		Write-Warning "The AD Site Name is already in use. `r " 
		Write-Verbose "Prompt for new AD Site Name `r "
		$NewSiteName = [Microsoft.VisualBasic.Interaction]::InputBox("The previously entered site name ($NewSiteName) already exists, please enter a new AD Site Name",`
            "Enter New Site Name","")
        Write-Verbose "New AD Site Name changed to $NewSiteName `r "
	}  ## CLOSE IF New Site Name already exists in AD 
 ELSE
    { Write-Verbose "New site name ($NewSiteName) is unique in Active Directory. Continuing... `r " }

IF (!$ReplicationSiteName)
	{  ## OPEN IF No Replication Site Name was specified
		Write-Warning "No Replication Site Name was specified. `r " 
		Write-Verbose "Prompt for an AD Site Name for the new AD Site to Replicate with. `r "
		$NewSiteName = [Microsoft.VisualBasic.Interaction]::InputBox("No Replication Site Name was specified for $NewSiteName to replicate with, please enter a new AD Replication Site Name",`
            "Enter New Site Name","")
        Write-Verbose "Replication Site Name changed to $ReplicationSiteName `r "
	}  ## CLOSE IF No Replication Site Name was specified 
               
##########################
# Get Set Site Variables # 
##########################
Write-Verbose "Set necessary site variables `r "
$NewADSiteDN = "CN=$NewSiteName,$ADSiteDN"

Write-Verbose "Get Replication Site Info `r "   
TRY
    {  ## OPEN TRY Get Replication Site Info
        $ReplicationSiteInfo = Get-ADObject -Filter { ObjectClass -eq "site" -and CN -eq $ReplicationSiteName } -SearchBase $ADSiteDN  
        $ReplicationSiteDN = $ReplicationSiteInfo.DistinguishedName
    }  ## CLOSE TRY Get Replication Site Info
 CATCH
    { Write-Warning "An error occured while attempting to Get Replication Site Info. Site Link will not be successfully created. `r " }    
    
###################
# Create New Site # 
###################
Write-Verbose "Create New Site Object `r "
TRY
    { New-ADObject -Name $NewSiteName -Path $ADSiteDN -Type Site }
CATCH
    { Write-Warning "An error occured while attempting to create the new site $NewSiteName in the AD Site Path: $ADSiteDN `r "  }

$SiteCreationCheck = Test-Path AD:$NewADSiteDN 

IF ($SiteCreationCheck -eq $False)
    { Write-Warning "Failed to create the new site $NewSiteName `r " }
ELSE
    {  ## OPEN ELSE Site Object created successfully
        Write-Verbose "Create New Site Object Child Objects (NTDS Site Settings & Servers Container) `r "
        TRY
            {  ## OPEN TRY Create New Site Object Child Objects (NTDS Site Settings & Servers Container)
                New-ADObject -Name "NTDS Site Settings" -Path $NewADSiteDN -Type NTDSSiteSettings
                New-ADObject -Name "Servers" -Path $NewADSiteDN -Type serversContainer

                Write-Verbose "Get New AD Site as variable `r "
                $NewADSiteInfo = Get-ADObject $NewADSiteDN
            }  ## CLOSE TRY Create New Site Object Child Objects (NTDS Site Settings & Servers Container)
         CATCH
            { Write-Warning "An error occured while attempting to create site $NewSiteName child objects in the AD Site Path: $NewADSiteDN `r "  }
     }  ## CLOSE ELSE Site Object created successfully
     
######################
# Create Site Subnet # 
######################
Write-Verbose "Create new Site Subnet ($SubnetCIDR) for $NewSiteName `r "    
[array] $ADSubnets = Get-ADObject -Filter { objectclass -eq "subnet" } -SearchBase $ADConfigurationNamingContext
$ADSubnetFirst = $ADSubnets[0]
$SubnetTemplate = get-adobject -Identity "$ADSubnetFirst" -properties description,location

TRY
    {  ## OPEN TRY Create new Site Subnet ($SubnetCIDR) for $NewSiteName 
        New-ADObject -instance $subnetTemplate -name "$SubnetCIDR" -type subnet -path $SubnetsDN `
          -OtherAttributes @{ siteObject=$NewADSiteDN }  
    }  ## CLOSE TRY Create new Site Subnet ($SubnetCIDR) for $NewSiteName 
CATCH
    { Write-Warning "An error occured while attempting to Create new Site Subnet ($SubnetCIDR) for $NewSiteName `r " }

####################
# Create Site Link # 
####################
Write-Verbose "Create new Site Link for $NewSiteName & $ReplicationSiteName `r "
TRY
    {  ## OPEN TRY Create new Site Link for $NewSiteName & $ReplicationSiteName
        $NewSiteLinkName = "[$NewSiteName] [$ReplicationSiteName]"
        New-ADObject -name $NewSiteLinkName -type siteLink -path $ADSiteLinksDN `
          -OtherAttributes @{ siteList=$ReplicationSiteDN,$NewADSiteDN;replInterval=$ReplicationInterval;cost=$SiteCost;options=1 }              
    }  ## CLOSE TRY Create new Site Link for $NewSiteName & $ReplicationSiteName
CATCH
    { Write-Warning "An error occured while attempting to Create new Site Link for $NewSiteName & $ReplicationSiteName `r "  }

    }  ## CLOSE IF Run mode is CreateSite
    
###########################################
# Enable Change Notification on All Sites # 
###########################################
IF ($Mode -eq "Change")
    {  ## OPEN IF Run mode is Change
        IF ($ChangeConfirm -eq $True)
            {  ## OPEN IF ChangeConfirm
                Write-Output "Configuring Change Notification on all Site Links `r "
                ForEach ($SiteLink in $ADSiteLinksList)
            	{  ## OPEN ForEach SiteLink in ADSiteLinksList
            		Write-Verbose "Configuring Change Notification on Site Link: $SiteLink `r "
                    $RequestConfirm = "Do you want to enable Change Notification on site link $SiteLink? [Yes/No]"
            		$Confirm = read-host $RequestConfirm
            		IF ($Confirm -eq "Y") { $Confirm = "Yes" }

                    IF ($Confirm -eq "Yes" ) 
                        {  ## OPEN IF Confirm Yes
                            TRY
                                { Get-adobject –filter { (ObjectClass -eq "sitelink") -and (Name -eq $SiteLink) } –searchbase $ADConfigurationNamingContext  -properties options | `
                                    set-adobject –replace @{ options='1' }  }
                            CATCH
                                { Write-Warning "An error occured while attempting to configure Change Notification on Site Link: $SiteLink. `r " } 
                    	}  ## CLOSE IF Confirm Yes
                }  ## CLOSE ForEach SiteLink in ADSiteLinksList
                Write-Output "Finished configuring Change Notification on all Site Links `r "
             }  ## CLOSE IF ChangeConfirm
          
          ELSE
            {  ## OPEN ELSE NOT ChangeConfirm
                Write-Output "Configuring Change Notification on all Site Links `r "
                ForEach ($SiteLink in $ADSiteLinksList)
            	{  ## OPEN ForEach SiteLink in ADSiteLinksList
            		Write-Verbose "Configuring Change Notification on Site Link: $SiteLink `r "
                    TRY
                        { Get-adobject –filter { (ObjectClass -eq "sitelink") -and (Name -eq $SiteLink) } –searchbase $ADConfigurationNamingContext  -properties options | `
                            set-adobject –replace @{options='1' }  }
                    CATCH
                        { Write-Warning "An error occured while attempting to configure Change Notification on Site Link: $SiteLink. `r " } 
            	}  ## CLOSE ForEach SiteLink in ADSiteLinksList
                Write-Output "Finished configuring Change Notification on all Site Links `r "
             }  ## CLOSE ELSE NOT ChangeConfirm
             
    }  ## CLOSE IF Run mode is Change