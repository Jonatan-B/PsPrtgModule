function Set-PrtgObjectProperty {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # The ID of the PRTG object to modify.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="What is the Id of the object to modify?")]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        [Int]
        $ObjectID,
        # The Object's property that we want to set.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="What is the name of the property that we want to set? (Hint: The 'PropertyName' parameter can be discerned by opening the 'Settings page of an object and looking at the HTML source of the INPUT fields.)")]
        [ValidateNotNull()]
        [Alias("Property")]
        [String]
        $PropertyName,
        # The Value that should be assigned to the Object's property.
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="What value should be assigned to the property?")]
        [ValidateNotNullOrEmpty()]
        [Alias("Value")]
        [String]
        $PropertyValue,
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

        $uri = ( $Global:PrtgApiUrl.SetObjectProperty -f `
            $PrtgServer, 
            $Username, `
            $SerializedPassword,
            $ObjectID, 
            $PropertyName, 
            $PropertyValue)
    }
    process {
        if($PSCmdlet.ShouldProcess($ObjectId,"Set property $PropertyName with value $PropertyValue")){

            Invoke-RestMethod -Method POST -Uri $uri -ErrorAction Stop | Out-Null
        }        
    }
}