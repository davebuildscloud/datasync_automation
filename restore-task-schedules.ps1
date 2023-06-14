if ($args.count -lt 1)
{
    Write-Host ""
    Write-Host "**********************************************************"
    Write-Host ""
    Write-Host "ERROR - An insufficient number of parameters were provided"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "./starttasks.ps1 'filename'"
    Write-Host ""
    Write-Host ""
    Write-Host "example:  ./starttasks.ps1 'group1.txt'"
    Write-Host ""
    Write-Host "**********************************************************"
    exit 1
}


#Reads in the file passed in the CLI and removes the first header line from the file
$file = $args[0]
$content = Get-Content -Path $file
$content = $content[1..($content.Count - 1)]
$content | Out-File -filepath $file

$validationarray = @()
$restores = Import-Csv -Path $file -Header 'Name', 'Schedule'
foreach ($restore in $restores){

    $tasks = (Get-DSYNTaskList)
    $task = $tasks.where{$_.name -like $restore.Name -and $_.name -NotLike "ROLLBACK*"}
    $count = ($task | Measure-Object)
    if ($count.Count -ne 1){
        write-host "Problem locating one task for $($restore.Name).  Please Investigate"
        $obj1 = [PSCustomObject]@{
            Name = $task.Name
            Schedule = "Error - incorrect data returned"
        }
        $validationarray += $obj1
    }
    else {
        Update-DSYNTask -TaskArn $task.TaskArn -Schedule_ScheduleExpression $restore.Schedule
        Write-Host "Task $($task.Name) has been scheduled with $($restore.Schedule)"
        start-sleep -Seconds 5
        $rescheduledtask = (Get-DSYNTask -TaskArn $task.TaskArn -Select Schedule)
        $obj1 = [PSCustomObject]@{
            Name = $task.Name
            Schedule = $rescheduledtask.ScheduleExpression
        }
        $validationarray += $obj1
    }
}
$table = $validationarray | Format-Table -Property Name, Schedule -AutoSize | Out-String
Write-Host "Starting validation of restored task schedules"
Write-Host $table
