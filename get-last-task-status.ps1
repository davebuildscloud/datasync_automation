$myarray = @()
$task_prefix = “task-prefix-name”
$tasks = (Get-DSYNTaskList) 
$tasks = $tasks.where{$_.name -like "$($task_prefix)*" -and $_.name -NotLike "ROLLBACK*"}
foreach ($task in $tasks){
    $executions = (Get-DSYNTaskExecutionList -TaskArn $task.TaskArn | Select-Object -Last 2)
    write-host "Collecting details for the $($task.Name) task"
    foreach ($execution in $executions){
        $status = (get-dsyntaskexecution -TaskExecutionArn $execution.TaskExecutionArn)
        $obj1 = [PSCustomObject]@{
            Name = $task.Name
            Status = $execution.Status
            StartTime = $status.StartTime.DateTime
            Duration = "$($status.Result.TotalDuration/1000)"
        }
        $myarray += $obj1
    
    #write-host "$($task.Name)  $($execution.Status)  $($status.StartTime.DateTime) $($status.Result.TotalDuration/1000)"
    }
}
$table = $myarray | Format-Table -Property Name, Status, StartTime, Duration -AutoSize | Out-String
Write-Host $table
