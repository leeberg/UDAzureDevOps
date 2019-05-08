New-UDPage -Name "Host_Status" -Icon podcast -Endpoint {

    
    New-UDLayout -Columns 3 -Content {  


        New-UdMonitor -Title "CPU" -Type Line -DataPointHistory 15 -RefreshInterval 5 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
            $Cache:ComputerStatus | Select-Object -Last 1 -ExpandProperty CPU | Out-UDMonitorData
            #$Cache:ComputerStatus | Select-Object -Last 1 -ExpandProperty RAM | Out-UDMonitorData
        }

        New-UdMonitor -Title "RAM" -Type Line -DataPointHistory 15 -RefreshInterval 5 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
            $Cache:ComputerStatus | Select-Object -Last 1 -ExpandProperty RAM | Out-UDMonitorData
            #$Cache:ComputerStatus | Select-Object -Last 1 -ExpandProperty RAM | Out-UDMonitorData
        }


        New-UdChart -ID "HostStatsDiskChart" -Title "Disk Space by Drive" -Type Bar -AutoRefresh -Endpoint {
            
            $Cache:ComputerStatus.DiskStats | ForEach-Object {
                [PSCustomObject]@{ 
                    DiskLabel = $_.DiskLabel;
                    DiskFree = $_.DiskFree } } | Out-UDChartData -LabelProperty "DiskLabel" -Dataset @(
                        New-UdChartDataset -DataProperty "DiskFree" -Label "Free Space" -BackgroundColor "#8014558C" -HoverBackgroundColor "#8014558C"
                    )
        }

    
    }
        
    New-UDLayout -Columns 2 -Content {  


        New-UDGrid -Id "HostStatusProcesses" -Title "Top 5 Processes" -Headers @("Name","CPU Usage %","Memory Usage %") -Properties @("Name","CPUUsage","MemoryUsage") -Endpoint {    
        
            # Get The Computer Status I have selected...
            # Read the Processe

            $Cache:ComputerStatus.Processes | ForEach-Object{

                [PSCustomObject]@{
                    #User = $_
                    Name = $_.Name
                    CPUUsage = $_.CPUUsage
                    MemoryUsage = $_.MemoryUsage
                }
                
            } | Out-UDGridData
            
        }
    

        New-UDGrid -Id "HostEventsProcesses" -Title "Last 5 System Events" -Headers @("Name","CPU Usage %","Memory Usage %") -Properties @("Name","CPUUsage","MemoryUsage") -Endpoint {    
        
            # Get The Computer Status I have selected...
            # Read the Processe

            $Cache:ComputerStatus.Processes | ForEach-Object{

                [PSCustomObject]@{
                    #User = $_
                    Name = $_.Name
                    CPUUsage = $_.CPUUsage
                    MemoryUsage = $_.MemoryUsage
                }
                
            } | Out-UDGridData
            
        }
    }


}




