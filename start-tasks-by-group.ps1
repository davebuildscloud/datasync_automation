if ($args.count -lt 1)
{
    Write-Host ""
    Write-Host "**********************************************************"
    Write-Host ""
    Write-Host "ERROR - An insufficient number of parameters were provided"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "./start-tasks-by-group.ps1 'filename'"
    Write-Host ""
    Write-Host ""
    Write-Host "example:  ./start-tasks-by-group.ps1 'group1.txt'"
    Write-Host ""
    Write-Host "**********************************************************"
    exit 1
}
 
$file = $args[0]
$names = Get-Content -Path $file
$myarray = @()

foreach ($name in $names){
    $tasks = (Get-DSYNTaskList)
    $task = $tasks.where{$_.name -like $name -and $_.name -NotLike "ROLLBACK*"}
    $count = ($task | Measure-Object)
    if ($count.Count -ne 1){
        #write-host "Problem locating one task for $($name).  Please Investigate"
        $obj1 = [PSCustomObject]@{
            Name = $name
            Status = "Error - incorrect data returned"
        }
        $myarray += $obj1
    }
    else {
        Start-DSYNTaskExecution -TaskArn $task.TaskArn
        #Write-Host "Task $($name) has been started"
        $obj1 = [PSCustomObject]@{
            Name = $name
            Status = "Started"
        }
        $myarray += $obj1
    }
}
$table = $myarray | Format-Table -Property Name, Status -AutoSize | Out-String
Write-Host $table
