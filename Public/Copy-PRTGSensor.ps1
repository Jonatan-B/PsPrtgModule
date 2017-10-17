function Copy-PrtgSensor {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # The ID of the sensor that will be cloned.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="The ID of the PRTG sensor to clone.")]
        [ValidateNotNullOrEmpty()]
        [Alias("Sensor")]
        [Int]
        $SensorID,
        # PRTG Device Id(s) where the sensor(s) will be clone to.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="PRTG Device Id(s) where the sensor(s) will be clone to.")]
        [ValidateNotNull()]
        [Alias("TargetId")]
        [Int[]]
        $TargetDeviceId,
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="The name of the new PRTG sensor(s).")]
        [ValidateNotNullOrEmpty()]
        [Alias("NewName")]
        [String]
        $NewSensorName,
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
    }
    process {

        foreach($deviceID in $TargetDeviceId){

            if($PSCmdlet.ShouldProcess($SensorID,"Clone sensor to $deviceID with name $NewSensorName")){
                # This URI will request the given sensor is cloned.
                $uri = ($PrtgApiUrl.CopySensor -f 
                            $PrtgServer,
                            $Username,
                            $SerializedPassword,
                            $SensorID,
                            $NewSensorName,
                            $deviceID)

                $newSensor = Invoke-WebRequest -Uri $uri -MaximumRedirection 0 -ErrorAction SilentlyContinue

                if(!($newSensor)){
                    "The sensor ID was not returned by PRTG. The sensor cannot be configured and will be left in Pause status."
                    continue
                }

                $newSensorId = $newSensor.Headers.Location.substring($newSensor.Headers.Location.indexOf("=")+1)

                try {
                    Set-PRTGObjectProperty -ObjectID $newSensorId -PropertyName "exeparams" -PropertyValue '-ComputerName %host' -Session $Session -ErrorAction Stop
                }
                catch {
                    "Failed to set the property 'exeparams' for the sensor with ID $newSensorId. Change will have to be done manually. See the error details below."
                    Write-Error -Exception $_.Exception
                    continue
                }
                
                try {
                    Resume-PRTGObject -ObjectID $newSensorId -Session $Session -ErrorAction Stop
                }
                catch {
                    "Failed to start the sensor with ID $newSensorID.  Change will have to be done manually. See the error details below."
                    Write-Error -Exception $_.Exception
                    continue
                }
            }
        }
        
    }
}