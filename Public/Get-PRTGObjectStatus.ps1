function Get-PrtgObjectStatus {
    param(
        # PRTG ID of the object to get status.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="PRTG Device ID to get status.")]
        [Alias("Id")]
        [Int]
        $ObjectId,
        # Session object obtained from New-PrtgConnection or creating a new manual object with [PrtgApiSession]::New()
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="Session object obtained from New-PrtgConnection")]
        [Alias("PrtgApiSession")]
        [PrtgApiSession]
        $Session = $Global:PrtgSession
    )
    begin {
        
        if(($Session.Get_IsConnected()) -or ($Session.CheckConnection())){
            $Username = $session.Get_Username()
            $SerializedPassword = $session.Get_PasswordHash()
            $PrtgServer = $Global:PrtgServerUrl
        }
        else {
            throw "The session provided is not connected. This usually happens when the username and password were not provided correctly."
        }

        # This URI will request a list of all of the devices in PRTG
        # The return will include the following properties: ObjectID, ProbeName, GroupName, DeviceName
        $uri = ($Global:PrtgApiUrl.GetObjectStatus -f `
                    $PrtgServer, `
                    $Username, `
                    $SerializedPassword,
                    $ObjectId)
        
    }
    process {

            $ObjectStatus = Invoke-RestMethod -Method GET -uri $uri -ErrorAction Stop
            $ObjectStatus.prtg.result
    }
}