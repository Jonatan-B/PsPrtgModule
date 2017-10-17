function Rename-PrtgObject {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # Name of the Object you are looking for.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="DeviceID",
                   HelpMessage="PRTG object id to rename")]
        [ValidateNotNull()]
        [Alias("Id")]
        [Int]
        $ObjectId,
        # Name of the Object you are looking for.
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="New name for the PRTG object")]
        [ValidateNotNullOrEmpty()]
        [Alias("Name")]
        [String]
        $NewName,
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

        # This URI will request the name change in PRTG
        $uri = ($Global:PrtgApiUrl.RenameObject -f `
                    $PRTGServer, `
                    $username, `
                    $serializedPassword,
                    $ObjectId,
                    $newName)
    }
    process {
        if($PSCmdlet.ShouldProcess($ObjectId, "Rename object")) {
            Invoke-RestMethod -Method POST -Uri $uri -ErrorAction Stop | Out-Null
        }
    }
}