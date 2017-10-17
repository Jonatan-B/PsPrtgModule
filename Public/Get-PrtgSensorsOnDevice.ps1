function Get-PrtgSensorsOnDevice {
    param(
        # The Id of the device we need to get the sensors for. 
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="SensorId",
                   HelpMessage="PRTG Device Id that you want to get the sensors for.")]
        [Alias("Id")]
        [Int]
        $DeviceId,
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

        # This URI will request a list of all of the Sensors in PRTG
        # The return will include the following properties: ObjectID, ProbeName, ParentId, Device, SensorName
        $uri = ($Global:PrtgApiUrl.GetSensorTable -f `
                    $PRTGServer, `
                    $Username, `
                    $SerializedPassword,
                    50000)
        $AllSensorsTable = Invoke-RestMethod -Method GET -uri $uri -ErrorAction Stop
        
        if($AllSensorsTable) {
            if($AllSensorsTable.Sensors.Item.length -eq $MaxReturnedItems){
                Write-Warning "Max number of items reached, and no results were found. Contact your PRTG Administrator."
            }
        }
        else {
            throw "Error: This is a table request for all sensors and nothing was returned. Contact your PRTG Administrator."
        }
    }
    process {

        $PRTGSensor = New-Object psobject
        $results = $AllSensorsTable.Sensors.Item | Where-Object { $_.ParentId -eq $DeviceId} 
        if($results){
            foreach($SensorObj in $results){
                $PRTGSensor = New-Object psobject
                $PRTGSensor | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $SensorObj.objid
                $PRTGSensor | Add-Member -MemberType NoteProperty -Name "Probe" -Value $SensorObj.probe
                $PRTGSensor | Add-Member -MemberType NoteProperty -Name "ParentId" -Value $SensorObj.ParentId
                $PRTGSensor | Add-Member -MemberType NoteProperty -Name "Device" -Value $SensorObj.Device
                $PRTGSensor | Add-Member -MemberType NoteProperty -Name "SensorName" -Value $SensorObj.Name
                $PRTGSensor
            }
        }
    }
}