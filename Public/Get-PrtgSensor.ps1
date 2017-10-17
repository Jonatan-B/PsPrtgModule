function Get-PrtgSensor {
    param(
        # Name(s) of the Sensor you are looking for.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="SensorName",
                   HelpMessage="PRTG Sensor(s) to search for.")]
        [Alias("Sensor")]
        [String[]]
        $SensorName,
        # Wildcard search for Sensors.
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
                   ParameterSetName="SensorId",
                   HelpMessage="PRTG Sensor id to get.")]
        [Alias("Id")]
        [Int]
        $SensorId,
        # Should we query for the sensor details? 
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="Return the sensor details? ")]
        [Alias("SensorDetails")]
        [Switch]
        $Details,
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

        # This URI will request a list of all of the Sensors in PRTG
        # The return will include the following properties: ObjectID, ProbeName, ParentId, SensorName
        $uri = ($Global:PrtgApiUrl.GetSensorTable -f
                    $PRTGServer,
                    $Username,
                    $SerializedPassword,
                    $MaxReturnedItems)
        $AllSensorsTable = Invoke-RestMethod -Method GET -uri $uri -ErrorAction Stop
        
        if($AllSensorsTable) {
            if($AllSensorsTable.Sensors.Item.length -eq $MaxReturnedItems){
                Write-Warning "Max number of items reached. Results might not be accurate. It is recommended that you expand the max number of items."
            }
        }
        else {
            throw "Error: This is a table request for all sensors and nothing was returned. Contact your PRTG Administrator."
        }
    }
    process {

        # Create URI based on the parameter set        
        switch($PSCmdlet.ParameterSetName){
            "SensorName" {
                foreach($Sensor in $SensorName) {

                    $PRTGSensor = New-Object psobject
                    $results = $AllSensorsTable.Sensors.Item | Where-Object { $_.Name -eq $SensorName }
                    if($results){
                        foreach($SensorObj in $results){
                            $PRTGSensor = New-Object psobject
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $SensorObj.objid
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "Probe" -Value $SensorObj.probe
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "ParentId" -Value $SensorObj.ParentId
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "Device" -Value $SensorObj.Device
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "SensorName" -Value $SensorObj.Name
                        }
                    }
                }
            }
            "filterSearch" {
                if($filter -match "\*"){
                    $results = $AllSensorsTable.Sensors.Item | Where-Object { $_.Name -like $filter }
                    if($results){
                        foreach($SensorObj in $results){
                            $PRTGSensor = New-Object psobject
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $SensorObj.objid
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "Probe" -Value $SensorObj.probe
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "ParentId" -Value $SensorObj.ParentId
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "Device" -Value $SensorObj.Device
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "SensorName" -Value $SensorObj.Name
                        }
                    }
                }
                else {
                    $results = $AllSensorsTable.Sensors.Item | Where-Object { $_.Name -match $filter }
                    if($results){
                        foreach($SensorObj in $results){
                            $PRTGSensor = New-Object psobject
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $SensorObj.objid
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "Probe" -Value $SensorObj.probe
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "ParentId" -Value $SensorObj.ParentId
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "Device" -Value $SensorObj.Device
                            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "SensorName" -Value $SensorObj.Name
                        }
                    }
                }
            }
            "SensorId" {
                $PRTGSensor = New-Object psobject
                $results = $AllSensorsTable.Sensors.Item | Where-Object { $_.objid -eq $SensorId} 
                if($results){
                    foreach($SensorObj in $results){
                        $PRTGSensor = New-Object psobject
                        $PRTGSensor | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $SensorObj.objid
                        $PRTGSensor | Add-Member -MemberType NoteProperty -Name "Probe" -Value $SensorObj.probe
                        $PRTGSensor | Add-Member -MemberType NoteProperty -Name "ParentId" -Value $SensorObj.ParentId
                        $PRTGSensor | Add-Member -MemberType NoteProperty -Name "Device" -Value $SensorObj.Device
                        $PRTGSensor | Add-Member -MemberType NoteProperty -Name "SensorName" -Value $SensorObj.Name
                    }
                }
            }
        }

        if($Details.IsPresent){
            $uri_SensorDetails = ($Global:PrtgApiUrl.GetsensorDetails -f 
                    $PRTGServer,
                    $Username,
                    $SerializedPassword,
                    $PRTGSensor.ObjectID)
            
            $results_SensorDetails = Invoke-RestMethod -Method GET -Uri $uri_SensorDetails
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "downtime" -Value $results_SensorDetails.SensorData.downtime.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "downtimetime" -Value $results_SensorDetails.SensorData.downtimetime.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "favorite" -Value $results_SensorDetails.SensorData.favorite.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "interval" -Value $results_SensorDetails.SensorData.interval.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "lastcheck" -Value $results_SensorDetails.SensorData.lastcheck.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "lastdown" -Value $results_SensorDetails.SensorData.lastdown.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "lastmessage" -Value $results_SensorDetails.SensorData.lastmessage.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "lastup" -Value $results_SensorDetails.SensorData.lastup.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "lastvalue" -Value $results_SensorDetails.SensorData.lastvalue.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "name" -Value $results_SensorDetails.SensorData.name.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "parentdeviceid" -Value $results_SensorDetails.SensorData.parentdeviceid.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "parentdevicename" -Value $results_SensorDetails.SensorData.parentdevicenam.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "parentgroupname" -Value $results_SensorDetails.SensorData.parentgroupname.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "probename" -Value $results_SensorDetails.SensorData.probename.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "prtg-version" -Value $results_SensorDetails.SensorData.'prtg-version'.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "sensortype" -Value $results_SensorDetails.SensorData.sensortype.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "statusid" -Value $results_SensorDetails.SensorData.statusid.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "statustext" -Value $results_SensorDetails.SensorData.statustext.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "updownsince" -Value $results_SensorDetails.SensorData.updownsince.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "updowntotal" -Value $results_SensorDetails.SensorData.updowntotal.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "uptime" -Value $results_SensorDetails.SensorData.uptime.'#cdata-section'
            $PRTGSensor | Add-Member -MemberType NoteProperty -Name "uptimetime" -Value $results_SensorDetails.SensorData.uptimetime.'#cdata-section'

            $PRTGSensor
        }
        else {
            $PRTGSensor
        }
    }
}