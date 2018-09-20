#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#          Connect to office 365 and exchange online using a script
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Use at your own risk 

$Loop = $true
While ($Loop)
{
write-host 
write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write-host       Connect to Office 365 and Exchange online    -foregroundcolor green
write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write-host 
write-host '    Connect PowerShell session to Office 365 and Exchange on-line' -ForegroundColor green
write-host '    ---------------------------------------------------------------' -ForegroundColor green
write-host '1)  Login using your Office365 Administrator credentials' -ForegroundColor Yellow
write-host
write-host
write-host "2)  Disconnect from the Remote PowerShell session" -ForegroundColor Red
write-host
write-host "3)  Exit" -ForegroundColor Red
write-host

$opt = Read-Host "Select an option [1-3]"
write-host $opt
switch ($opt)



{


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Step -00 connect PowerShell session to Office 365 and Exchange online
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



1{

#  administrative user credentials 

$user = “POPULATE”

# Display authentication pop out windows

$cred = Get-Credential -Credential $user

#——– Import office 365 Cmdlets  ———–

Import-Module MSOnline

#———— Establish an Remote PowerShell Session to office 365 ———————

Connect-MsolService -Credential $cred

#———— Establish an Remote PowerShell Session to Exchange Online ———————

$msoExchangeURL = “https://ps.outlook.com/powershell/”

$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $cred -Authentication Basic -AllowRedirection 

#——– Import SharePoint 365 Cmdlets  ———–

Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

#———— Establish an Remote PowerShell Session to SharePoint 365 ———————

Connect-SPOService -Url https://ecacolleges-admin.sharepoint.com -credential $cred

#——– Import Skype 365 Cmdlets  ———–

Import-Module SkypeOnlineConnector

#———— Establish an Remote PowerShell Session to Skype 365 ———————

$sfboSession = New-CsOnlineSession -Credential $cred

#———— Establish an Remote PowerShell Session to Security & Compliance Center ———————

$ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection

#———— This command that we use for implicit remoting feature of PowerShell 2.0 ———————


Import-PSSession $session
Import-PSSession $sfboSession
Import-PSSession $ccSession -AllowClobber -DisableNameChecking

#———— Indication ———————
write-host 
if ($lastexitcode -eq 1)
{
	
	
	
	write-host "The command Failed :-(" -ForegroundColor red
	write-host "Try to connect again and check your credentials" -ForegroundColor red
	
	
}
else

{
	
	clear-host

	write-host
    write-host  -ForegroundColor green	ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                        
                                                     
    write-host  -ForegroundColor white  	"The command complete successfully !" 
	write-host  -ForegroundColor white  	"You are now connected to Office 365, Exchnage online, Skype, SharePoint, and Security Center"
	write-host  -ForegroundColor white  	"You can chose the option “3” to leave the menu screen and start managing: "
	write-host  -ForegroundColor white  	"Office 365 + Exchange online environments"
	write-host  -ForegroundColor white	    --------------------------------------------------------------------   
	write-host  -ForegroundColor white  	"Test the connection to Exchange online by using the command  Get-mailbox"
	write-host  -ForegroundColor white  	"Test the connection to Office 365 by using the command  Get-Msoluser".
	
	write-host  -ForegroundColor green	ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo                                         
	write-host
    write-host
	
	
	
	write-host  -ForegroundColor Yellow
	write-host  -ForegroundColor Yellow
}

#———— End of Indication ———————

}





 
 
#+++++++++++++++++++
#  Finish  
##++++++++++++++++++
 
 
2{

##########################################
# Disconnect PowerShell session  
##########################################


Get-PSsession | Remove-PSsession

#Function Disconnect-ExchangeOnline {Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession}
#Disconnect-ExchangeOnline -confirm



#———— Indication ———————
write-host 
if ($lastexitcode -eq 1)
{
	
	
	write-host "The command Failed :-(" -ForegroundColor red
	write-host "Try to connect again and check your credentials" -ForegroundColor red
	
	
}
else

{
	write-host "The command complete successfully !" -ForegroundColor Yellow
	write-host "The remote PowerShell session to Exchange online was disconnected" -ForegroundColor Yellow
	
}

#———— End of Indication ———————



}

3{

##########################################
# Exit 
##########################################


$Loop = $true
Exit
}

}


}
