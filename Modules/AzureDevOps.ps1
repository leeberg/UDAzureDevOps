Function Get-Repositories
{

    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName
    )

    $RetrievedRepositories = @()
    $uri = "https://dev.azure.com/$organization/$projectName/_apis/git/repositories?api-version=5.0"
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    $result.value | ForEach-Object {

        #$_.id
        #$_.name

        $RetrievedRepositories += $_

    }

    return $RetrievedRepositories

}



Function Get-PullRequests
{

    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName
    )

    $RetrievedPullRequests = @()
    $uri = "https://dev.azure.com/$organization/$projectName/_apis/git/pullrequests?api-version=5.0"
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    $result.value | ForEach-Object {

        #$_.id
        #$_.name

        $RetrievedPullRequests += $_

    }

    return $RetrievedPullRequests

}

Function Get-Commits
{

    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName,

        [parameter(Mandatory=$true)]
        [string]$repositoryId
    )

    $RetrievedCommits = @()
    $uri = "https://dev.azure.com/$organization/$projectName/_apis/git/repositories/"+$repositoryId+"/commits?api-version=5.0"
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    $result.value | ForEach-Object {

        #$_.id
        #$_.name

        $RetrievedCommits += $_

    }

    return $RetrievedCommits

}




Function Get-WorkItems
{

    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName,
            
        [parameter(Mandatory=$false)] # Work Item Query
        [string]$WorkItemQueryID = '45765909-a639-46c3-8707-286ec31277ba'
    )

    # Work Item Query Results
    $RetrievedWorkItems = @()
    $uri = "https://dev.azure.com/$organization/$projectName/_apis/wit/wiql/$WorkItemQueryID" + '?api-version=5.0'
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    $WorkItems = $result.workItems
    $WorkItems | ForEach-Object{
        
        $WorkItemID = $_.id
    
        #Todo Get Single Work Item - should probably be batch :)
        $uri = "https://dev.azure.com/$organization/$projectName/_apis/wit/workitems/$WorkItemID"+'?api-version=5.0'
        $WorkItem = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

        $RetrievedWorkItems += $WorkItem 

       
        <# 
        Work Items Properties
            System.Title
            System.State
            System.Description
            System.WorkItemType
            System.CreatedDate
            System.CreatedBy
            System.ChangedDate
            System.ChangedBy
            System.AssignedTo
        #>
    }

    return $RetrievedWorkItems

}




Function Get-Builds
{

    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName
            
    )

    # Get BUild Defintions

    $RetrievedBuilds = @()

    $uri = "https://dev.azure.com/$organization/$projectName/_apis/build/builds?api-version=5.0"
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    $Builds = $result.value
    $Builds | ForEach-Object {

        #$_.id
        #$_.name

        $RetrievedBuilds += $_

    }

    return $RetrievedBuilds | Sort-Object -Property queueTime -Descending

}


Function Get-BuildDefinitions
{

    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName
            
    )

    # Get BUild Defintions

    $RetrievedBuilds = @()

    $uri = "https://dev.azure.com/$organization/$projectName/_apis/build/definitions?api-version=5.0"
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    $Builds = $result.value
    $Builds | ForEach-Object {

        #$_.id
        #$_.name

        $RetrievedBuilds += $_

    }

    return $RetrievedBuilds

}


Function Get-BuildDetails
{
    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName,
        
        [parameter(Mandatory=$true)]
        [int]$BuildID
    
        
    )

    $uri = "https://dev.azure.com/$Organization/$ProjectName/_apis/build/builds/$BuildID" + '?api-version=5.0'
    $uri 
    $result = Invoke-RestMethod -Uri $uri -Method GET -Body $RequestBody -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    return $result
    
}



Function Get-Definitions
{

    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName
            
    )

    # Get BUild Defintions

    $RetrievedDefinitions = @()

    $uri = "https://dev.azure.com/$organization/$projectName/_apis/build/definitions?api-version=5.0"
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    $Definitions = $result.value
    $Definitions | ForEach-Object {

        #$_.id
        #$_.name

        $RetrievedDefinitions += $_

    }

    return $RetrievedDefinitions

}








Function Get-BuildBadge{
    
    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName,

        [parameter(Mandatory=$true)]
        [int]$BuildID
            
    )
       
    $uri = "https://dev.azure.com/$Organization/_apis/public/build/definitions/$ProjectName/$BuildID/badge?api-version=5.0"
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    return $result

}



Function Get-Releases
{

    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName
            
    )

    # Get Release Defintions

    $RetrievedReleases = @()

    $uri = "https://vsrm.dev.azure.com/$organization/$projectName/_apis/release/definitions?api-version=5.0"
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    $Releases = $result.value
    $Releases | ForEach-Object {

        $RetrievedReleases += $_

    }

    return $RetrievedReleases

}


#######################


Function Get-ReleaseDetails
{

    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName,

        [parameter(Mandatory=$true)]
        [string]$ReleaseId
            
    )

    # Get Release Defintions

    $RetrievedReleases = @()

    $uri = "https://vsrm.dev.azure.com/$organization/$projectName/_apis/release/releases/$ReleaseId" + '?api-version=5.0'
    $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}

    return $result


}




# ACTIONS
Function Invoke-QueueBuild
{
    param(
        [parameter(Mandatory=$true)]
        [string]$Organization,

        [parameter(Mandatory=$true)]
        [string]$ProjectName,
        
        [parameter(Mandatory=$true)]
        [int]$BuildID,
        
        [parameter(Mandatory=$false)]
        [string]$Reason = 'Manually Triggered'
    )

    #Body for Definition
    $RequestBody = '{ "definition": { "id": '+ $BuildID + '}, reason: "' + $Reason + '", priority: "Normal"}' # build body

    $uri = "https://dev.azure.com/$organization/$projectName/_apis/build/builds?api-version=5.0"
    $result = Invoke-RestMethod -Uri $uri -Method POST -Body $RequestBody -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $Cache:base64AuthInfo)}


}

