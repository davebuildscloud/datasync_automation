if ($args.count -lt 1)
{
    Write-Host ""
    Write-Host "**********************************************************"
    Write-Host ""
    Write-Host "ERROR - An insufficient number of parameters were provided"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "./validate-rollback-by-group.ps1 'filename'"
    Write-Host ""
    Write-Host ""
    Write-Host "example:  ./validate-rollback-by-group.ps1 'group1.txt'"
    Write-Host ""
    Write-Host "**********************************************************"
    exit 1
}

$file = $args[0]
$names = Get-Content -Path $file
$myarray = @()

foreach ($name in $names) {
    
    $tasks = (Get-DSYNTaskList)
    $task = $tasks.where{$_.name -like "ROLLBACK-$($name)"}
    $count = ($task | Measure-Object)
    if ($count.Count -ne 1){
        write-host "Problem locating one task for $($task.Name).  Please Investigate"
        $obj1 = [PSCustomObject]@{
            Name = $task.Name
            Status = "Error - incorrect data returned"
            StartTime = ""
            Duration = ""
        }
        $myarray += $obj1
    }
    else {
        $execution = (Get-DSYNTaskExecutionList -TaskArn $task.TaskArn | Select-Object -Last 1)
        $status = (get-dsyntaskexecution -TaskExecutionArn $execution.TaskExecutionArn)
        #write-host "$($task.Name)    $($execution.Status)    $($status.StartTime.DateTime)    $($status.Result.TotalDuration/1000) seconds"
        write-host "working on $($task.Name)"
        $obj1 = [PSCustomObject]@{
            Name = $task.Name
            Status = $execution.status
            StartTime = $status.StartTime.DateTime
            Duration = "$($status.Result.TotalDuration/1000)"
        }
        $myarray += $obj1
    }
}
$table = $myarray | Format-Table -Property Name, Status, StartTime, Duration -AutoSize | Out-String
Write-Host $table
