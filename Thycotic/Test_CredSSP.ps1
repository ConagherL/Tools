$credential = Get-Credential -Credential iammred\administrator

$session = New-PSSession -cn SQL1.Iammred.Net -Credential $credential -Authentication Credssp

Invoke-Command -Session $session -ScriptBlock {Test-Path \\dc1\share\PSWindowsUpdate}

Invoke-Command -Session $session -ScriptBlock {

Import-Module -Name \\dc1\Share\PSWindowsUpdate }

Invoke-Command -Session $session -ScriptBlock {Get-WUHistory }
