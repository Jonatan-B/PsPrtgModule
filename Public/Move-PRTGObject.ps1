function Move-PrtgObject {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # Name of the object you want to resume.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="byID",
                   HelpMessage="PRTG object id to resume")]
        [ValidateNotNull()]
        [Int]
        $ObjectId,
        # Name of the group you want to move the device to.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="byID",
                   HelpMessage="Group Id where the device should be moved to.")]
        [ValidateNotNull()]
        [Int]
        $TargetObjectId,
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


        # This URI will request the device to be moved to the specified group id.
        $uri = ($Global:PrtgApiUrl.MoveDevice -f `
                $PRTGServer, `
                $Username, `
                $SerializedPassword,
                $ObjectId,
                $TargetObjectId)
    }
    process {
        if($PSCmdlet.ShouldProcess($ObjectId,"Move object to object id #$TargetObjectId")){
            Invoke-RestMethod -Method POST -Uri $uri -ErrorAction Stop | Out-Null
        }
    }
}