function New-PRTGPasswordHash {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([Int64])]
    param(
        # Parameter help description
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [PSCredential]
        $Credential
    )

    begin {
        # Load the System.Web Namespace as it is needed for the HttpUtility class.. 
        Add-Type -AssemblyName System.Web
        
        # User the username and password that was passed through the PSCredential object.
        $username = $Credential.UserName

        try {
            $password = [System.Web.HttpUtility]::UrlEncode($Credential.GetNetworkCredential().Password)
        }
        catch {
            Write-Error -Message $_.Exception -ErrorAction Stop
        }
        

        # Create the API url with the provided information
        $uri = ($Global:PrtgApiUrl.NewPasswordHash -f $Global:PrtgServerUrl, $username, $password)
    }
    process {
        if($PSCmdlet.ShouldProcess($username, "Create password hash")) {
            Invoke-RestMethod -Method GET -Uri $uri -ErrorAction Stop
        }
    }
}