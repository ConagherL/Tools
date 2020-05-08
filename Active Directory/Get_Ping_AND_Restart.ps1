$OUPath = "DC=CONTOSO,DC=LOCAL"
(Get-ADComputer -Searchbase $OUPath -Filter 'operatingsystem -notlike "*server*"').Name | Out-File C:\Temp\workstations.txt
$Computers = Get-Content "C:\temp\workstations.txt"


    foreach ($Computer in $Computers){
        if (Test-Connection -ComputerName $Computer -Count 1 -ErrorAction SilentlyContinue)
        {
            Restart-Computer -ComputerName $Computer -ErrorAction SilentlyContinue -Force
            Write-Host "$Computer has been restarted" -ForegroundColor Green >> C:\temp\Up_Computers.txt
        }
  else{
    Write-Host "$Computer is not pingable" -ForegroundColor RED >> C:\temp\Down_Computers.txt
      }
 }