import-module activedirectory
# Discover DCs that are not GCs
Write-Verbose “Discover DCs that are not GCs `r”
[array]$DCsnotGC = @()
ForEach ($DC in $DomainControllers)
{  ## OPEN ForEach DC in DomainDCs
TRY
{ ## OPEN TRY Get-ADDomainController $DC
$DCInfo = Get-ADDomainController $DC
IF ($DCInfo.IsGlobalCatalog -eq $False) { [array] $DCsnotGC += $DC }
ELSE { Write-Verbose “$DC is a Global Catalog `r ” }
} ## CLOSE TRY Get-ADDomainController $DC
CATCH
{ Write-Output “An error occured while attempting to get information from the DC $DC – it may be offline or unavailable. `r ” }
}  ## CLOSE ForEach DC in DomainDCs
$DCsnotGCCount = $DCsnotGC.Count
Write-Output “The folling $DCsnotGCCount DCs are not operating as GCs: `r ”
$DCsnotGC