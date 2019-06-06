Import-Module WebAdministration
 
 $applicationPools = Get-ChildItem IIS:\AppPools\SecretServer
 $webnodes =  'HACSSAPSSSP03','HACSSAPSSSP05','HACSSAPSSSP04'
 foreach($pool in $applicationPools)
 {
     $pool.processModel.userName = "domain\username"
     $pool.processModel.password = "password"
     $pool.processModel.identityType = 3
     $pool | Set-Item
 }
  
 Write-Host "Application pool passwords updated..." -ForegroundColor Magenta 
 Write-Host "" 
 Read-Host -Prompt "Press Enter to exit"