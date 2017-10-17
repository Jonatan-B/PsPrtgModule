New-Variable -Name PrtgServerUrl -Value "adimonitoring.us.ae.ge.com" -Visibility Public -Scope Global -Force 
New-Variable -Name PrtgSession -Value $null -Visibility Public -Scope Global -Force
New-Variable -Name PrtgApiUrl  -Visibility Public -Scope Global -Force -Value @{
    GetDeviceTable = "http://{0}/api/table.xml?content=devices&output=xml&columns=objid,probe,group,device&username={1}&passhash={2}&count={3}"
    GetGroupTable = "http://{0}/api/table.xml?content=groups&output=xml&columns=objid,probe,group,name&username={1}&passhash={2}&count={3}"
    GetObjectStatus = "http://{0}/api/getobjectstatus.htm?id={3}&name=status&show=text&username={1}&passhash={2}"
    GetSensorTable = "http://{0}/api/table.xml?content=sensors&output=xml&columns=objid,probe,parentid,device,name&username={1}&passhash={2}&count={3}"
    GetSensorDetails = "http://{0}/api/getsensordetails.xml?id={3}&username={1}&passhash={2}"
    GetStatus = "http://{0}/api/getstatus.htm?id={0}&username={2}&passhash={3}"
    CopySensor = "http://{0}/api/duplicateobject.htm?id={3}&name={4}&targetid={5}&Username={1}&passhash={2}"
    MoveObject = "http://{0}/moveobjectnow.htm?id={3}&targetid={4}&username={1}&passhash={2}"
    NewPasswordHash = "http://{0}/api/getpasshash.htm?username={1}&password={2}"
    RemoveObject = "http://{0}/api/deleteobject.htm?id={3}&approve=1&username={1}&passhash={2}"
    RenameObject = "http://{0}/api/rename.htm?id={3}&value={4}&username={1}&passhash={2}"
    ResumeObject = "http://{0}/api/pause.htm?id={3}&action=1&username={1}&passhash={2}"
    SetObjectProperty = "{0}/api/setobjectproperty.htm?id={3}&name={4}&value={5}&username={1}&passhash={2}"
    SuspendObjectIndefinitely = "http://{0}/api/pause.htm?id={3}&pausemsg={4}&action=0&username={1}&passhash={2}"
    SuspendObjectForDuration = "http://{0}/api/pauseobjectfor.htm?id={3}&pausemsg={4}&duration={5}&username={1}&passhash={2}"
} 

class PrtgApiSession {
    [string] $Username
    hidden [int64] $PasswordHash
    [string] $PRTGURL = $Global:PrtgServerUrl
    [bool] $IsConnected = $false;

    PrtgApiSession(){}
    
    PrtgApiSession([string]$Username, [int64]$PasswordHash){
        $this.Username = $Username
        $this.PasswordHash = $PasswordHash
        $this.IsConnected = $this.TestPrtgVersion()
    }

    PrtgApiSession([string]$Username, [int64]$PasswordHash, [string]$PRTGURL){
        $this.Username = $Username
        $this.PasswordHash = $PasswordHash
        $this.PRTGURL = $PRTGURL
        $this.IsConnected = $this.TestPrtgVersion()
    }

    [bool] TestPrtgVersion() {
        try {
            $PrtgVersion = (Invoke-RestMethod -Method GET -Uri ($Global:PrtgApiUrl.GetStatus -f $this.Get_PRTGURL(), 0, $this.Get_Username(), $this.Get_PasswordHash())).version
            if($PrtgVersion){
                return $true
            }
            else {
                return $false
            }
        }
        catch {
            throw "Unable to establish a connection to Prtg using the provided username and password hash."
        }
    }

    [void] CheckConnection() {
        $this.Set_IsConnected($this.TestPrtgVersion())
    }
}