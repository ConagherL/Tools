<#
    .SYNOPSIS
        Script to remove values from MultiValue attribute based on search criteria.
#>
 
PARAM(
    [string]$MultiValueAttribute = 'EmailAlias',
    [ValidateSet("Endswith")]
    [string]$SearchType = 'Endswith',
    [string]$SearchValue = '@yahoo.com',
    [string]$ResourceType = 'Group',
    [string]$FIMServiceURI = 'http://ven-fim:5725'
    )
 
#region Lithnet
if(!(Get-Module -Name LithnetRMA))
{
Import-Module LithnetRMA;
}
 
Set-ResourceManagementClient -BaseAddress $FIMServiceURI;
#endregion Lithnet
 
#Build the query
$XPathQuery = New-XPathQuery -AttributeName $MultiValueAttribute -Operator $SearchType -Value $SearchValue
$XPathExpression = New-XPathExpression -ObjectType $ResourceType -QueryObject $XPathQuery
 
#Get the Objects
$Objects = Search-Resources $XPathExpression -AttributesToGet $MultiValueAttribute
 
#Remove the values from each Object
foreach ($Object in $Objects)
    {
        $ValuesToRemove = @()
        $Values = ($Object.psobject.Properties | ?{$_.Name -eq $MultiValueAttribute}).Value
        switch($SearchType)
            {
                "StartsWith"{$ValuesToRemove = $Values | ?{$_ -like ($SearchValue + '*')}}
                "EndsWith"{$ValuesToRemove = $Values | ?{$_ -like ('*' + $SearchValue)}}
                "Equals"{$ValuesToRemove = $Values | ?{$_ -eq $SearchValue}}
                "Contains'"{$ValuesToRemove = $Values | ?{$_ -eq $SearchValue}}
            }
        foreach($Value in $ValuesToRemove){($Object.psobject.Properties | ?{$_.Name -eq $MultiValueAttribute}).Value.Remove($Value)}
        $Object | Save-Resource
    }