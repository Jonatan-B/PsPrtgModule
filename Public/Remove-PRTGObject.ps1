function Remove-PRTGObject {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # Name of the object you want to be removed.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="DeviceID",
                   HelpMessage="PRTG object id to resume")]
        [ValidateNotNull()]
        [Alias("Id")]
        [Int]
        $ObjectID,
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

        # This URI will request the device be removed.
        $uri = ($Global:PrtgApiUrl.RemoveObject -f `
                $PRTGServer, `
                $Username, `
                $SerializedPassword,
                $ObjectID)
    }

    process {
        if($PSCmdlet.ShouldProcess($ObjectID, "Remove object")) {
            Invoke-RestMethod -Method POST -Uri $uri -ErrorAction Stop | Out-Null
        }
    }
}

