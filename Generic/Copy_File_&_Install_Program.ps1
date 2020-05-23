#Variables
$computername = Get-Content "C:\Users\Desktop\APPSVR.txt"
$sourcefile = "C:\Azure\MARSAgentInstaller.exe"
$destinationFolder = "\\$computer\C$\Temp"
$arg1 = "/q /nu"

#This section will install the software 
foreach ($computer in $computername) 
{
    #Copy $sourcefile to the $destinationfolder. If the folder does not exist it will create it.
    if (!(Test-Path -path $destinationFolder))
    {
        New-Item $destinationFolder -Type Directory
    }
    Copy-Item -Path $sourcefile -Destination $destinationFolder

    ## Install the application
    Invoke-Command -ComputerName $computer -ScriptBlock {& cmd /c $sourcefile $arg1}
}
