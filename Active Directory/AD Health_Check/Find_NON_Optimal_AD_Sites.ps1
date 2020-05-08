Import-module ActiveDirectory

#Varables
$SitesWithNoSubnetsFile = "D:\Report\Non Optimal AD\SitesWithNoSubnets.txt"
$SubnetsWithNoSitesFile = "D:\Report\Non Optimal AD\SubnetsWithNoSites.txt"
$SitesWithNoSiteLinksFile = "D:\Report\Non Optimal AD\SitesWithNoSiteLinks.txt"
$SitesWithNoGCFile = "D:\Report\Non Optimal AD\SitesWithNoGCFile.txt"
$SubnetsNotClassCFile = "D:\Report\Non Optimal AD\SubnetsNotClassC.txt"
$ManualSiteConnectionsCSVReportFile = "D:\Report\Non Optimal AD\ManualSiteConnections.csv"

Write-Output "Gathering AD configuration data... `r " 
        $ADRootDSE = Get-ADRootDSE    
        $ADConfigurationNamingContext = $ADRootDSE.configurationNamingContext  
        Write-Output "Setting AD configuration variables `r " 
        $ADSiteDN = "CN=Sites,$ADConfigurationNamingContext"
        
        # Get AD Site List
        Write-Output "Get AD Site List `r"
        $ADSites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites 
        [int]$ADSitesCount = $ADSites.Count
        Write-Output "There are $ADSitesCount AD Sites in the AD Forest `r"

        # Get List of AD Subnets 
        Write-Output "Discovering Forest-wide subnet data in AD... `r " 
        [array] $ADSubnets = Get-ADObject -Filter { ObjectClass -eq "subnet" } -SearchBase $ADSiteDN  -Properties Name,description,location,siteObject
        [int]$ADSubnetsCount = $ADSubnets.Count
        Write-Output "There are $ADSubnetsCount AD Subnets in the AD Forest  `r"
        Write-Output "  `r "

        # Discover Subnets without sites
        Write-Output "Discovering Subnets without sites... `r "
        IF ($SubnetsWithNoSites) { Clear-Variable SubnetsWithNoSites }
        [array]$SubnetsWithNoSites = $ADSubnets | Where { $_.siteObject -eq $Null }  
        [int]$SubnetsWithNoSitesCount = $SubnetsWithNoSites.Count
        Write-Output "There are $SubnetsWithNoSitesCount AD Subnets with no configured Sites in the AD Forest  `r"    
        Write-Output "  `r "    
        
        # Discover Subnets not configured as Class C
        Write-Output "Discovering Subnets not configured as Class C subnets... `r "
        IF ($SubnetsNotClassC) { Clear-Variable SubnetsNotClassC }
        [array]$SubnetsNotClassC = $ADSubnets | Where { $_.Name -notlike "*24" }  
        [int]$SubnetsNotClassCCount = $SubnetsNotClassC.Count
        Write-Output "There are $SubnetsNotClassCCount AD Subnets not configured as Class C subnets  `r "    
        Write-Output "  `r "

         ForEach ($Site in $ADSites)
            {  ## OPEN ForEach Site in ADSites
                $SiteName = $Site.Name
                [array] $SiteSubnets = $Site.Subnets
                [array] $SiteServers = $Site.Servers
                [array] $SiteAdjacentSites = $Site.AdjacentSites
                [array] $SiteLinks = $Site.SiteLinks
                $SiteInterSiteTopologyGenerator = $Site.InterSiteTopologyGenerator
                
               # Check for missing subnets                      
                IF (!$SiteSubnets)
                    {  ## OPEN IF there are no Site Subnets
                        Write-Output "The site $SiteName does not have a configured subnet. `r "
                        [array] $SitesWithNoSubnets += $SiteName
                        [int] $SitesWithNoSubnetsCount = $SitesWithNoSubnets.Count
                    }  ## OPEN IF there are no Site Subnets
                
                # Check for missing site link 
                IF (!$SiteLinks)
                    {  ## OPEN IF there are no Site Links for this site
                        Write-Output "The site $SiteName does not have an associated site link. `r "
                        [array] $SitesWithNoSiteLinks += $SiteName
                        [int] $SitesWithNoSiteLinksCount = $SitesWithNoSiteLinks.Count
                    }  ## OPEN IF there are no Site Links for this site
                
                # Check for missing ISTG     
                IF (!$SiteInterSiteTopologyGenerator)
                    {  ## OPEN IF there are no ISTG  for this site
                        Write-Output "The site $SiteName does not have a configured InterSite Topology Generator server `r "
                        [array] $SitesWithNoISTG += $SiteName
                        [int] $SitesWithNoISTGCount = $SitesWithNoISTG.Count
                    }  ## OPEN IF there are no ISTG for this site     
                
                # Find AD Sites with no GCs
                $SiteGC = Get-ADDomainController -filter { (Site -eq $Site) -and (IsGlobalCatalog -eq $True) } 
                IF (!$SiteGC)
                    {  ## OPEN IF there are no GCs for this site
                        Write-Output "The site $SiteName does not have a Global Catalog associated with it `r "
                        [array] $SitesWithNoGC += $SiteName
                        [int] $SitesWithNoGCCount = $SitesWithNoGC.Count
                    }  ## OPEN IF there are no GCs for this site      
            }  ## CLOSE ForEach Site in ADSites
               
        IF ($SitesWithNoSubnets)   
          {  ## OPEN IF There are SitesWithNoSubnets
            Write-Output "There are $SitesWithNoSubnetsCount Sites without a configured Subnet. `r "
            Write-Output "This list is saved to the file: $SitesWithNoSubnetsFile `r "
            $SitesWithNoSubnets | out-file $SitesWithNoSubnetsFile 
            Write-Output "  `r "
          }  ## CLOSE IF There are SitesWithNoSubnets
        ELSE { Write-Output "There are no Sites without a configured Subnet. `r " }
        
        IF ($SubnetsWithNoSites)   
          {  ## OPEN IF There are SubnetsWithNoSites
            Write-Output "There are $SubnetsWithNoSitesCount Subnets without a configured Site. `r "
            Write-Output "This list is saved to the file: $SubnetsWithNoSitesFile  `r "
            $SubnetsWithNoSites | out-file $SubnetsWithNoSitesFile 
            Write-Output "  `r "
          }  ## CLOSE IF There are SubnetsWithNoSites
         ELSE { Write-Output "There are no Subnets without a configured Site. `r " }
        
        IF ($SitesWithNoSiteLinks) 
          {  ## OPEN IF There are SitesWithNoSiteLinks
            Write-Output "There are $SitesWithNoSiteLinksCount Sites without a configured Sitelink. `r "
            Write-Output "This list is saved to the file: $SitesWithNoSiteLinksFile  `r "
            $SitesWithNoSiteLinks | out-file $SitesWithNoSiteLinksFile 
            Write-Output "  `r "
          }  ## CLOSE IF There are SitesWithNoSiteLinks 
         ELSE { Write-Output "There are no Sites without a configured Sitelink. `r " }
        
        IF ($SitesWithNoGC) 
          {  ## OPEN IF There are SitesWithNoGC
            Write-Output "There are $SitesWithNoGCCount Sites without a Global Catalog server.  `r "
            Write-Output "This list is saved to the file: $SitesWithNoGCFile  `r "
            $SitesWithNoGC | out-file $SitesWithNoGCFile 
            Write-Output "  `r "
          }  ## CLOSE IF There are SitesWithNoGC  
         ELSE { Write-Output "There are no Sites without a Global Catalog server. `r " }
           
        IF ($SubnetsNotClassC) 
          {  ## OPEN IF There are SubnetsNotClassC
            Write-Output "There are $SubnetsNotClassCCount subnets that are not Class C subnets.  `r "
            Write-Output "This list is saved to the file: $SubnetsNotClassCFile  `r "
            $SubnetsNotClassC | out-file $SubnetsNotClassCFile 
            Write-Output "  `r "
           }  ## CLOSE IF There are SubnetsNotClassC 
         ELSE { Write-Output "There are no subnets that are not Class C subnets.  `r " }    

        ## Find all Sites with manual connections
        $ManualConnections = Get-ADObject -LDAPFilter "(&(ObjectClass = NTDSConnection) (!Options:1.2.840.113556.1.4.804:=1))" `
        -SearchBase $ADConfigurationNamingContext -Property DistinguishedName,FromServer
        
        IF ($FixManualConnections -eq $True) 
           { $ManualConnections | Remove-ADObject -Verbose }
         ELSE
           {  ## OPEN ELSE FixManualConnections = False
              Write-Output "Exporting Manual Site Connections to CSV report file ($ManualSiteConnectionsCSVReportFile)... `r "
              $ManualConnections | Export-CSV $ManualSiteConnectionsCSVReportFile -NoType -Force
           }  ## CLOSE ELSE FixManualConnections = False