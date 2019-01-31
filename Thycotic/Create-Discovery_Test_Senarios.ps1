# Create-Discovery_Test_Senario.ps1
# PowerShell Version 2 script to find all empty groups in the domain.
# This will be groups where the member attribute is empty, and also where
# no user or computer has the group designated as their primary group.
# https://granadacoder.wordpress.com/2012/08/02/create-a-com-application-with-powershell/

$myCredentials = Get-Credential
$serviceName = "FAKE_SERVICE_DELETE_ME" 
$serviceDisplayName = "Discovery Demo" 
$serviceDescription = "Secret Server Discovery Example" 
$serviceExecutable = "notepad.exe"
$taskName = "FAKE_TASK_DELETE_ME"
$taskDescription = "This task is an example of Secret Server discovery process"
$taskAction = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument TO BE FILLED
$taskTrigger = New-ScheduledTaskTrigger -Daily -At 9am
$directoryPath = Split-Path $MyInvocation.MyCommand.Path
$binaryPath = $directoryPath + "\" + $serviceExecutable
$appName = "FAKE_APP_POOL"
# $appDescription = "This application pool is an example of Secret Server discovery process"
# $appIISCheck = Get-WindowsFeatures | Where-Object {$_.name -eq 'Web-Server'}
$appUsername = "Please populate username for the application pool/COM+ object. EXAMPLE: Domain\UserName"
$appPassword = "Please populate the password for the user"
$comName = 'FAKE_COM_APPLICATION'



"Installing Demo Configuration......"

# Creating a Windows Service
New-Service -name $serviceName -displayName $serviceDisplayName -binaryPathName $binaryPath -startupType Automatic -Description $serviceDescription -Credential $myCredentials

Start-Service -Name $serviceName

Get-Service $serviceName

# Creating a Scheduled Task
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName $taskName -Description $taskDescription

# Creating a Application Pool

    #check if IIS role is installed
    function Check-IIS {
        [CmdletBinding()]
        param(
            [Parameter(Position=0,Mandatory=$true)] [string]$FeatureName 
        )  
      if((Get-WindowsFeature | Where-Object {$_.name -eq 'Web-Server'}).installstate -eq 'Installed') {
            # IIS Role is Installed. Lets continue on to creating the Application pool
            New-Item -Path IIS:\AppPools\$appName
            # Set configuration on the newly created Application Pool
            Set-ItemProperty -Path IIS:\AppPools\$appName -Name processmodel.identityType -Value 3
            Set-ItemProperty -Path IIS:\AppPools\$appName -Name processmodel.userName -Value $appUsername
            Set-ItemProperty -Path IIS:\AppPools\$appName -Name processmodel.password -Value $appPassword
            Set-ItemProperty -Path IIS:\AppPools\$appName -Name managedRuntimeVersion -Value 'v4.0'
        } else {
            # Install IIS and default features
            Add-WindowsFeature 'Web-Server'
            New-Item -Path IIS:\AppPools\$appName
            # Set configuration on the newly created Application Pool
            Set-ItemProperty -Path IIS:\AppPools\$appName -Name processmodel.identityType -Value 3
            Set-ItemProperty -Path IIS:\AppPools\$appName -Name processmodel.userName -Value $appUsername
            Set-ItemProperty -Path IIS:\AppPools\$appName -Name processmodel.password -Value $appPassword
            Set-ItemProperty -Path IIS:\AppPools\$appName -Name managedRuntimeVersion -Value 'v4.0'
        }
      }

# Creating COM+ Application

$comAdmin = New-Object -comobject COMAdmin.COMAdminCatalog
$apps = $comAdmin.GetCollection(“Applications”)
$apps.Populate();

$newComPackageName = “MyApplicationName”

$appExistCheckApp = $apps | Where-Object {$_.Name -eq $newComPackageName}

if($appExistCheckApp)
{
$appExistCheckAppName = $appExistCheckApp.Value(“Name”)
“This COM+ Application already exists : $appExistCheckAppName”
}
Else
{
$newApp1 = $apps.Add()
$newApp1.Value(“Name”) = $comName
$newApp1.Value(“ApplicationAccessChecksEnabled”) = 0 # Security Tab, Authorization Panel, “Enforce access checks for this application
$newApp1.Value(“Identity”) = “nt authority\localservice”

$saveChangesResult = $apps.SaveChanges()
“Results of the SaveChanges operation : $saveChangesResult”
}

read-host ‘Press enter key to continue . . .’

"installation completed"

Pause
