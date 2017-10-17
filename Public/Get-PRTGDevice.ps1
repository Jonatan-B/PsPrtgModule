function Get-PrtgDevice {
    param(
        # Name(s) of the device you are looking for.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="DeviceName",
                   HelpMessage="PRTG device(s) to search for.")]
        [Alias("Device")]
        [String[]]
        $DeviceName,
        # Wildcard search for devices.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="filterSearch",
                   HelpMessage="PRTG filter search. Example: EMS*, EMS")]
        [String]
        $Filter,
        # Name of the Object you are looking for.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="DeviceID",
                   HelpMessage="PRTG device id to get.")]
        [Alias("Id")]
        [Int]
        $DeviceID,
        # Number of objects that will be returned.
        [Parameter(Mandatory=$false,
                   Position=4,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="Maximum number of objects that will be returned. (Default 1000)")]
        [ValidateRange(1,50000)]
        [Alias("MaxItems")]
        [Int]
        $MaxReturnedItems = 50000,
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
        $uri = ($Global:PrtgApiUrl.GetDeviceTable -f `
                    $PRTGServer, `
                    $Username, `
                    $SerializedPassword,
                    $MaxReturnedItems)
        $Data = Invoke-RestMethod -Method GET -uri $uri -ErrorAction Stop
        
        if($Data) {
            if($Data.Devices.Item.length -eq $MaxReturnedItems){
                Write-Warning "Max number of items reached. Results might not be accurate. It is recommended that you expand the max number of items."
            }
        }
        else {
            throw "Error: This is a table request for all devices and nothing was returned. Contact your PRTG Administrator."
        }
        
    }
    process {

        # Create URI based on the parameter set        
        switch($PSCmdlet.ParameterSetName){
            "DeviceName" {
                foreach($device in $deviceName) {

                    $PRTGDevice = New-Object psobject
                    $results = $Data.devices.Item | Where-Object { $_.Device -eq $deviceName }
                    if($results){
                        foreach($DeviceObj in $results){
                            $PRTGDevice = New-Object psobject
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $DeviceObj.objid
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "Probe" -Value $DeviceObj.probe
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "Group" -Value $DeviceObj.group
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "DeviceName" -Value $DeviceObj.device
                            $PRTGDevice
                        }
                    }
                }
            }
            "filterSearch" {
                if($filter -match "\*"){
                    $results = $Data.devices.Item | Where-Object { $_.Device -like $filter }
                    if($results){
                        foreach($DeviceObj in $results){
                            $PRTGDevice = New-Object psobject
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $DeviceObj.objid
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "Probe" -Value $DeviceObj.probe
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "Group" -Value $DeviceObj.group
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "DeviceName" -Value $DeviceObj.device
                            $PRTGDevice
                        }
                    }
                }
                else {
                    $results = $Data.devices.Item | Where-Object { $_.Device -match $filter }
                    if($results){
                        foreach($DeviceObj in $results){
                            $PRTGDevice = New-Object psobject
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $DeviceObj.objid
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "Probe" -Value $DeviceObj.probe
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "Group" -Value $DeviceObj.group
                            $PRTGDevice | Add-Member -MemberType NoteProperty -Name "DeviceName" -Value $DeviceObj.device
                            $PRTGDevice
                        }
                    }
                }
            }
            "DeviceID" {
                $PRTGDevice = New-Object psobject
                $results = $Data.devices.Item | Where-Object { $_.objid -eq $deviceID} 
                if($results){
                    foreach($DeviceObj in $results){
                        $PRTGDevice = New-Object psobject
                        $PRTGDevice | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $DeviceObj.objid
                        $PRTGDevice | Add-Member -MemberType NoteProperty -Name "Probe" -Value $DeviceObj.probe
                        $PRTGDevice | Add-Member -MemberType NoteProperty -Name "Group" -Value $DeviceObj.group
                        $PRTGDevice | Add-Member -MemberType NoteProperty -Name "DeviceName" -Value $DeviceObj.device
                        $PRTGDevice
                    }
                }
            }
        }
    }
}