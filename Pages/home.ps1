New-UDPage -Name "Home" -Icon home -Endpoint {


    New-UDCard -Title "MSN DevOps meetup" -Text "It's a Demo!" -Links @(New-UDLink -Url 'https://www.meetup.com/Madison-Devops/events/260538402/' -Text "MeetupLink")


    New-UDGrid -Title "Builds" -Headers @("Name","Status","Created","project") -Properties @("name","queueStatus","createdDate","project") -Endpoint {    
        
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




