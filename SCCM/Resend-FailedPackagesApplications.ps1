<#
.Synopsis
   Resends all failed or retrying packages to a specified Distribution Point.
.EXAMPLE
   ResendDPPackages.ps1 -SiteCode "S01" -DistPoint "SERVER01" -Verbose
#>
[cmdletbinding()]
Param(
    [Parameter(Mandatory=$true)]
    [String]
    [ValidateNotNullOrEmpty()]
    $SiteCode,
    [Parameter(Mandatory=$true)]
    [String]
    [ValidateNotNullOrEmpty()]
    $DistPoint
)

$Query = "Select NALPath,Name From SMS_DistributionPointInfo Where ServerName Like '%$DistPoint%'"
$DistributionPoint = @(Get-WmiObject -Namespace "root\SMS\Site_$SiteCode" -Query $Query)
$ServerNalPath = $DistributionPoint.NALPath -replace "([\[])",'[$1]' -replace "(\\)",'\$1'

if($DistributionPoint.Count -ne 1)
{
    Foreach($DistributionPoint in $DistributionPoint)
    {
        Write-Verbose -Message $DistributionPoint.Name
    }
    Write-Error -Message "Found $($DistributionPoint.Count) matching Distribution Points. Please redefine query."
}
else
{
    $Query = "Select PackageID From SMS_PackageStatusDistPointsSummarizer Where ServerNALPath Like '$ServerNALPath' AND (State = 2 OR state = 3)"
    $FailedPackages = Get-WmiObject -Namespace "root\SMS\Site_$SiteCode" -Query $Query
    Foreach($Package in $FailedPackages)
    {
        $Query = "Select * From SMS_DistributionPoint WHERE SiteCode='$SiteCode' AND ServerNALPath Like '$ServerNALPath' AND PackageID = '$($Package.PackageID)'"
        $DistPointPkg = Get-WmiObject -Namespace "root\SMS\Site_$SiteCode" -Query $Query
        Write-Verbose -Message "Refreshing package $($DistPointPkg.PackageID) on $($DistributionPoint.Name)"
        $DistPointPkg.RefreshNow = $true
        [Void]$DistPointPkg.Put()
    }
}
