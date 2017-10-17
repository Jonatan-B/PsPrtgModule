function Get-PrtgGroup {
    param(
        # Name(s) of the Name you are looking for.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="groupName",
                   HelpMessage="PRTG group(s) to search for.")]
        [Alias("Name")]
        [String[]]
        $groupName,
        # wildcard search for groups.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="filterSearch",
                   HelpMessage="PRTG filter search. Example: EMS*, EMS")]
        [string]
        $filter,
        # Name of the Object you are looking for.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="groupID",
                   HelpMessage="PRTG group id to get.")]
        [Alias("id")]
        [Int]
        $groupID,
        # Number of objects that will be returned.
        [Parameter(Mandatory=$false,
                   Position=4,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="Maximum number of objects that will be returned. (Default 500)")]
        [ValidateRange(1,50000)]
        [Alias("maxItems")]
        [Int]
        $maxReturnedItems = 50000,
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

        # This URI will request a list of all of the groups in PRTG
        # The return will include the following properties: ObjectID, ProbeName, GroupName, groupName
        $uri = ($Global:PrtgApiUrl.GetGroupTable -f `
                    $PRTGServer, `
                    $username, `
                    $serializedPassword,
                    $maxReturnedItems)
        
        $data = Invoke-RestMethod -Method GET -uri $uri -ErrorAction Stop

        if($data) {
            if($data.Groups.Item.length -eq $MaxReturnedItems){
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
            "groupName" {
                foreach($group in $groupName) {
                    $PRTGGroup = New-Object psobject
                    $GroupObj = $data.groups.Item | Where-Object { $_.Name -eq $group } 
                    $PRTGGroup | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $GroupObj.objid
                    $PRTGGroup | Add-Member -MemberType NoteProperty -Name "Probe" -Value $GroupObj.probe
                    $PRTGGroup | Add-Member -MemberType NoteProperty -Name "Group" -Value $GroupObj.group
                    $PRTGGroup | Add-Member -MemberType NoteProperty -Name "groupName" -Value $GroupObj.Name
                    $PRTGGroup
                }
            }
            "filterSearch" {
                if($filter -match "\*"){
                    $results = $data.groups.Item | Where-Object { $_.Name -like $filter }
                    foreach($GroupObj in $results){
                        $PRTGGroup = New-Object psobject
                        $PRTGGroup | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $GroupObj.objid
                        $PRTGGroup | Add-Member -MemberType NoteProperty -Name "Probe" -Value $GroupObj.probe
                        $PRTGGroup | Add-Member -MemberType NoteProperty -Name "Group" -Value $GroupObj.group
                        $PRTGGroup | Add-Member -MemberType NoteProperty -Name "groupName" -Value $GroupObj.Name
                        $PRTGGroup
                    } 
                }
                else {
                    $results = $data.groups.Item | Where-Object { $_.Name -match $filter }
                    foreach($GroupObj in $results){
                        $PRTGGroup = New-Object psobject
                        $PRTGGroup | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $GroupObj.objid
                        $PRTGGroup | Add-Member -MemberType NoteProperty -Name "Probe" -Value $GroupObj.probe
                        $PRTGGroup | Add-Member -MemberType NoteProperty -Name "Group" -Value $GroupObj.group
                        $PRTGGroup | Add-Member -MemberType NoteProperty -Name "groupName" -Value $GroupObj.Name
                        $PRTGGroup
                    }
                }
            }
            "groupID" {
                $PRTGGroup = New-Object psobject
                $GroupObj = $data.groups.Item | Where-Object { $_.objid -eq $groupID} 
                $PRTGGroup | Add-Member -MemberType NoteProperty -Name "ObjectID" -Value $GroupObj.objid
                $PRTGGroup | Add-Member -MemberType NoteProperty -Name "Probe" -Value $GroupObj.probe
                $PRTGGroup | Add-Member -MemberType NoteProperty -Name "Group" -Value $GroupObj.group
                $PRTGGroup | Add-Member -MemberType NoteProperty -Name "groupName" -Value $GroupObj.Name
                $PRTGGroup
            }
        }
    }
}