function New-PRTGConnection { 
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # The username that will be used to create the PRTG Connection
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]
        $Username,
        # The password that will be used to create the PRTG Connection
        [Parameter(Mandatory,Position=1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [SecureString]
        $Password,
        # Should the cmdlet return an object or store it as a global variable?
        [Parameter(Position=2, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Switch]
        $ShouldReturn
    )
    begin {
        $PSCredentials = New-Object -TypeName PSCredential -ArgumentList $Username, $Password
        $PasswordHash = New-PRTGPasswordHash -Credential $PSCredentials
    }
    process {

        if($PSCmdlet.ShouldProcess($username, "Create Prtg Session")) {
            $Global:PrtgSession = [PrtgApiSession]::New($Username, $PasswordHash)
            if($ShouldReturn.IsPresent){
                $Global:PrtgSession
                $Global:PrtgSession = $null
            }            
        }
        
    }
}