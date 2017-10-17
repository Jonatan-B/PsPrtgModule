function Suspend-PrtgObject {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # Name of the Object you are looking for.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="PRTG object id to suspend")]
        [ValidateNotNull()]
        [Alias("Id")]
        [Int]
        $ObjectId,
        # The reason why the suspension is being applied.
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="Why is the senson being paused?")]
        [ValidateNotNullOrEmpty()]
        [Alias("Reason")]
        [String]
        $Message,
        # Amount of time to suspend the sensor or device.
        [Parameter(Mandatory=$false,
                   Position=2,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="How long should the device be suspeneded? ( in Minutes )")]
        [ValidateNotNull()]
        [Alias("Time")]
        [Int]
        $Duration=0,
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
        
        if($Duration -eq 0){
            # This URI will request the device be suspended indefinitely.
            $uri = ($Global:PrtgApiUrl.SuspendObjectIndefinitely -f `
                    $PRTGServer, `
                    $Username, `
                    $SerializedPassword,
                    $ObjectId,
                    $Message)
        }
        else {
            # This URI will request the device be suspended for X minutes
            $uri = ($Global:PrtgApiUrl.SuspendObjectForDuration -f `
                    $PRTGServer, `
                    $Username, `
                    $SerializedPassword,
                    $ObjectId,
                    $Message,
                    $Duration)
        }
    }
    process {
        if($PSCmdlet.ShouldProcess($ObjectId, "Pause monitoring")) {
            Invoke-RestMethod -Method POST -Uri $uri -ErrorAction Stop | Out-Null
        }
    }
}