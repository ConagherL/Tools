# This file contains the list of servers you want to copy files/folders to
$computers = gc "C:\temp\servers.txt"
 
# This is the file/folder(s) you want to copy to the servers in the $computer variable
$source = "PATH TO SOURCE FILE"
 
# The destination location you want the file/folder(s) to be copied to
$destination = "C$\temp\"
 
#The command below pulls all the variables above and performs the file copy
foreach ($computer in $computers) {Copy-Item $source -Destination "\\$computer\$destination" -Recurse}
