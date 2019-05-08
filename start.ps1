Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI

$Cache:organization = 'ExpertsLiveUS'
$Cache:projectName = 'Project Management2'
$Cache:user = Get-Content .\accessuser.txt
$Cache:token = Get-Content .\accesstoken.txt

# Base64-encodes the Personal Access Token (PAT) appropriately
$Cache:base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Cache:user,$Cache:token)))

$Cache:ComputerStatus = @();

$Pages = @()
$Pages += . (Join-Path $PSScriptRoot "pages\home.ps1")

Get-ChildItem (Join-Path $PSScriptRoot "pages") -Exclude "home.ps1" | ForEach-Object {
    $Pages += . $_.FullName
}

#Load Modules for Pages into Endpointse
$Endpoints = New-UDEndpointInitialization -Module @("Modules\AzureDevOps.ps1")
    
#Startup the Dashboard
$Dashboard = New-UDDashboard -Title "DevOps Demo" -Pages $Pages -EndpointInitialization $Endpoints

$ComputerStatsEndpoint = New-UDEndpoint -Url "/hoststats" -Method "POST" -ArgumentList $Cache:ComputerStatus -Endpoint {
    param($Body)
    
    $Cache:ComputerStatus = $args[0] 
    $ComptuterStatusObject = $Body | ConvertFrom-Json
    $Cache:ComputerStatus += $ComptuterStatusObject
   
    Sync-UDElement -Id 'HostStatsDiskChart' -Broadcast
    Sync-UDElement -Id 'HostStatusProcesses' -Broadcast
}



Try
{
    Start-UDDashboard -Dashboard $Dashboard -Port 10000 -Endpoint $ComputerStatsEndpoint
}
Catch
{
    Write-Error($_.Exception)
}