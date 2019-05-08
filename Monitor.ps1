
While (1 -eq 1) {
    
    write-Host "$(Get-Date -format 'u') - Getting Machine Stats" -ForegroundColor Yellow
    start-sleep -Seconds 5
    # Basic Stats
    #PowerShell

    $OS = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, ServicePackMajorVersion, OSArchitecture, CSName, WindowsDirectory
    $OSName = $OS.Caption
    $OSVersion = $OS.Version
    $TimeZone = Get-TimeZone
    

    # Processor utilization
    $Processor = (Get-WmiObject -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
 
    # Memory utilization
    $ComputerMemory = Get-WmiObject -Class win32_operatingsystem -ErrorAction Stop
    $Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize)
    $RoundMemory = [math]::Round($Memory, 2)
     
    # TODO For Reach Disk
    
    # Disk
    $DiskStats =@()
    $Disks = Get-WmiObject Win32_LogicalDisk 
    $Disks | ForEach-Object{
        
        if($_.Size -ne $null)
        {
            $DiskStats += [PSCustomObject]@{
                #User = $_
                DiskLabel = $_.name
                DiskFree = ([math]::Round(($_.FreeSpace) / ($_.Size),2) *100)
                
            }
        }
       

        
    }



    $Processes = @()
    
    $SystemRAM = Get-WMIObject Win32_PhysicalMemory | Measure -Property capacity -Sum | %{$_.sum/1Mb} 
    
    $ProcessCounter = Get-Counter "\Process(*)\% Processor Time" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Countersamples | Sort-Object cookedvalue -Desc | Select-Object -First 10 instancename, cookedvalue | Where-Object { $_.InstanceName -ne '_total' -and $_.InstanceName -ne 'idle'} | ForEach-Object{

        
        $Processes += [PSCustomObject]@{
            Name = $_.InstanceName 
            CPUUsage = [math]::Round($_.cookedvalue)
            MemoryUsage = (Get-Random -Minimum 0 -Maximum 5)  # FOR DEMO ONLY TODO FIX OMG
        }
        
    }

    $Processes = $Processes | Sort-Object -Property CPUUsage,MemoryUsage -Descending | Select-Object -First 5

    
    <#
    Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | Where-Object { $_.name -inotmatch '_total|idle' -and $_.WorkingSetPrivate -ne 0 } | ForEach-Object { 
    
        $Processes += [PSCustomObject]@{
            #User = $_
            Name = $_.Name
            CPUUsage = [math]::Floor($_.PercentProcessorTime)
            MemoryUsage = ([math]::Round(($_.WorkingSetPrivate/1Mb)/$SystemRAM*100))
        }
        
    }

    $Processes | Sort-Object -Property CPUUsage,MemoryUsage -Descending | Select-Object -First 15

    $Processes = $Processes | Sort-Object -Property CPUUsage,MemoryUsage -Descending | Select-Object -First 5
    #>

    
    # Event Logs
    $EventLogs = @()
    Get-EventLog -LogName System -Newest 5 | Select-Object -Property TimeGenerated,EntryType,Message | ForEach-Object{
        
        if($_.Message.Length -lt 75){
            $FormattedMessage = ($_.Message).Replace("'","")
        }
        else {
            $FormattedMessage = ($_.Message.Substring(0,75)).Replace("'","")
        }

        $EventLogs += [PSCustomObject]@{
            #User = $_
            TimeGenerated = Get-Date $_.TimeGenerated -Format 'u'
            EntryType = $_.EntryType
            Message = $FormattedMessage
        }

    }


    #Last Logged In
    #$LastLoggedIn = Get-Process -IncludeUserName | Select-Object -Property username -Unique | Where-Object { $_ -notmatch 'SYSTEM|admin' }


    #>



    $ComputerBasicStats = New-Object PSCustomObject
    $ComputerBasicStats | Add-Member -MemberType NoteProperty -Name "CPU" -Value $Processor
    $ComputerBasicStats | Add-Member -MemberType NoteProperty -Name "RAM" -Value $RoundMemory



    # Creating custom object

    $ComputerStatsObject = [PSCustomObject]@{
        #User = $_
        TimeStamp = $(Get-Date -format 'u')
        ServerName = $env:computername
        CPU = $Processor
        RAM = $RoundMemory
        ComputerBasicStats = $ComputerBasicStats
        DiskStats = $DiskStats
        Processes = $Processes
        #EventLogs =  $EventLogs
        #LastLoggedIn = $LastLoggedIn
    }

    $BodyJson = ($ComputerStatsObject | ConvertTo-Json) 
    
    Try{
        Invoke-RestMethod -Uri http://localhost:10000/api/hoststats -Method POST -Body $BodyJson -UseBasicParsing
        write-Host "$(Get-Date -format 'u') - Sent Machine Stats to API" -ForegroundColor Green
    }
    Catch{
        write-host "Failed REST" -ForegroundColor Yellow
        Write-Host $_.Exception.ToString()
    }
    



}