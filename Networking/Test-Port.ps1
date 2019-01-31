function Test-Port {
    Param(
        [string]$ComputerName,
        [int]$Port,
        [int]$Timeout,
        [switch]$Verbose
    )
    $ErrorActionPreference = "SilentlyContinue"
    # Create TCP Client
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    # Begin Async connection to remote host on specified port
    $beginConnect = $tcpClient.BeginConnect($ComputerName,$Port,$null,$null)
    # Set the wait time
    $wait = $beginConnect.AsyncWaitHandle.WaitOne($Timeout,$false)
    # Check to see if the connection is done
    if(!$wait) {
        # Close the connection and report timeout
        $tcpClient.Close()
        if($Verbose){
            Write-Host "Connection Timeout"
        }
        return $false
    }
    else {
        # Close the connection and report the error if there is one
        $error.Clear()
        $tcpclient.EndConnect($beginConnect) | out-Null
        if(!$?){
            if($verbose){
                Write-Host $_.Exception.Message
            }
            $failed = $true
        }
        $tcpclient.Close()
    }
    # Return $true if connection Establish else $False
    if($failed) {
        return $false
    }
    else {
        return $true
    }
}
