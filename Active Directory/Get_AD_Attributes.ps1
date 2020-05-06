Import-Module ActiveDirectory
$Loop = $True
$ClassName = "User"
$ClassArray = [System.Collections.ArrayList]@()
$UserAttributes = [System.Collections.ArrayList]@()
# Retrieve the User class and any parent classes
While ($Loop) {
  $Class = Get-ADObject -SearchBase (Get-ADRootDSE).SchemaNamingContext -Filter { ldapDisplayName -Like $ClassName } -Properties AuxiliaryClass, SystemAuxiliaryClass, mayContain, mustContain, systemMayContain, systemMustContain, subClassOf, ldapDisplayName
  If ($Class.ldapDisplayName -eq $Class.subClassOf) {
    $Loop = $False
  }
  $ClassArray.Add($Class)
  $ClassName = $Class.subClassOf
}
# Loop through all the classes and get all auxiliary class attributes and direct attributes
$ClassArray | % {
  # Get Auxiliary class attributes
  $Aux = $_.AuxiliaryClass | % { Get-ADObject -SearchBase (Get-ADRootDSE).SchemaNamingContext -Filter { ldapDisplayName -like $_ } -Properties mayContain, mustContain, systemMayContain, systemMustContain } |
  Select-Object @{n = "Attributes"; e = { $_.mayContain + $_.mustContain + $_.systemMaycontain + $_.systemMustContain } } |
  Select-Object -ExpandProperty Attributes
  # Get SystemAuxiliary class attributes
  $SysAux = $UserClass.SystemAuxiliaryClass | % { Get-ADObject -SearchBase (Get-ADRootDSE).SchemaNamingContext -Filter { ldapDisplayName -like $_ } -Properties MayContain, SystemMayContain, systemMustContain } |
  Select-Object @{n = "Attributes"; e = { $_.maycontain + $_.systemmaycontain + $_.systemMustContain } } |
  Select-Object -ExpandProperty Attributes
  # Get direct attributes
  $UserAttributes += $Aux + $SysAux + $_.mayContain + $_.mustContain + $_.systemMayContain + $_.systemMustContain
}
$UserAttributes | Sort-Object | Get-Unique
