New-UDPage -Name "Work" -Icon home -Endpoint {

    New-UDGrid -Title "Work Items" -Headers @("Name","Status","Type","Assigned To") -Properties @("title","state","type","assignedto") -Endpoint {    
        
        Get-WorkItems -Organization $Cache:organization -ProjectName $Cache:projectName | ForEach-Object{

            [PSCustomObject]@{
                title = $_.fields.'System.Title'
                state = $_.fields.'System.State'
                type = $_.fields.'System.WorkItemType'
                assignedto = $_.fields.'System.AssignedTo'.displayName
            }
            
        } | Out-UDGridData

                
        
    }




}


