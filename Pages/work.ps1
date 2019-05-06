New-UDPage -Name "Work" -Icon home -Endpoint {

    New-UDGrid -Title "Work Items" -Headers @("Name","Status","Created","project") -Properties @("name","queueStatus","createdDate","project") -Endpoint {    
        
        Get-BuildDefinitions -Organization $Cache:organization -ProjectName $Cache:projectName | ForEach-Object{

            [PSCustomObject]@{
                #User = $_
                name = $_.name
                queueStatus = $_.queueStatus
                createdDate = $_.createdDate
                project = $_.project.name
                
            }
            
        } | Out-UDGridData
        
    }




}




