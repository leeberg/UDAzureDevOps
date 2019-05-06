New-UDPage -Name "CICD" -Icon arrow_up -Endpoint {

    New-UDLayout -Columns 2 -Content {  

        New-UDGrid -Title "Build Definitions" -Headers @("Name","Status","Created","Project","Trigger") -Properties @("name","queueStatus","createdDate","project","trigger") -Endpoint {    
            
            Get-BuildDefinitions -Organization $Cache:organization -ProjectName $Cache:projectName | ForEach-Object{

                
                [PSCustomObject]@{
                    #User = $_
                    name = $_.name
                    queueStatus = $_.queueStatus
                    createdDate = $_.createdDate
                    project = $_.project.name
                    trigger = New-UDButton -Text "Trigger" -OnClick (New-UDEndpoint -Endpoint {
                        
                        $buildID = $ArgumentList[0]
                        $buildName = $ArgumentList[0]
                        Invoke-QueueBuild -Organization $Cache:organization -ProjectName $Cache:projectName -BuildID $buildID
                        Show-UDToast -Message "Triggered Build: $buildName" -Duration 10000 -BackgroundColor '#26c6da'
                        Sync-UDElement -Id "CICDBuilds" -Broadcast

                    } -ArgumentList $_.id, $_.name)
                }
                
            } | Out-UDGridData
            
        }

        New-UDGrid -Title "Releases" -Headers @("Name","createdDate","lastModifiedBy","lastModified","View Details") -Properties @("name","createdDate","lastModifiedBy","lastModified","viewData") -Endpoint {    
            
            Get-Releases -Organization $Cache:organization -ProjectName $Cache:projectName | ForEach-Object{
                
                $releaseid = $_.id

                [PSCustomObject]@{
                    #User = $_
                    name = $_.name
                    createdDate = $_.createdOn
                    lastModifiedBy = $_.modifiedBy.displayName
                    lastModified = $_.modifiedOn
                    viewData = New-UDButton -Text "Details" -OnClick (New-UDEndpoint -Endpoint {
                        
                        $ReleaseID = $ArgumentList[0]

                        Show-UDModal -Content {

                            New-UDGrid -Title "Release Deatils" -Headers @("Name","Status","Description") -Properties @("name","status","description") -Endpoint {
                                Get-ReleaseDetails -Organization $Cache:organization -ProjectName $Cache:projectName -ReleaseId  $ReleaseID | ForEach-Object{
                                    [PSCustomObject]@{
                                        name = $_.name
                                        status = $_.status
                                        description = $_.description
                                        project = $_.project.name
                                    }
                                } | Out-UDGridData                                         
                            }

                            New-UDGrid -Title "Release Environments" -Headers @("Name","Status","Trigger Reason") -Properties @("name","status","triggerReason") -Endpoint {
                                $Release = Get-ReleaseDetails -Organization $Cache:organization -ProjectName $Cache:projectName -ReleaseId $ReleaseID
                                $Release.environments | ForEach-Object{
                                    [PSCustomObject]@{
                                        #User = $_
                                        name = $_.name
                                        status = $_.status
                                        triggerReason = $_.triggerReason
                                    }
                                } | Out-UDGridData
                            }

                        } 
                    } -ArgumentList $releaseid)
                } 
            } | Out-UDGridData
 
        }
    }


    New-UDGrid -Title "Builds" -Id "CICDBuilds" -Headers @("Name","Definition","Status","Result","Queue Time","Start Time","Finish Time","Url") -Properties @("name","definition","status","result","queueTime","startTime","finishTime","url") -Endpoint {    
            
        Get-Builds -Organization $Cache:organization -ProjectName $Cache:projectName | ForEach-Object{
        
            [PSCustomObject]@{
                #User = $_
                name = $_.buildNumber
                definition = $_.definition.name
                status = $_.status
                result = $_.result
                queueTime = $_.queueTime
                startTime = $_.startTime
                finishTime = $_.finishTime
                url = New-UDButton -Text "Open" -OnClick (New-UDEndpoint -Endpoint {
                    
                    Invoke-UDRedirect -Url $ArgumentList[0] -OpenInNewWindow

                } -ArgumentList $_.url)
            }
            
        } | Out-UDGridData
        
    }



}




