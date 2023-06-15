############################
#
# remove-task-schedules.ps1
# Author:  Dave Stauffacher / davebuildscloud@gmail.com
# Schedule:  Manual 
# This script scans all datasync tasks, sets their schedules to "", and exports their previous schedule settings to a .csv file 
# This .csv file can be used with the restore-task-schedules.ps1 file to reinstate the previous schedules.
#
############################

#Prerequisites
#Install-Module -Name AWS.Tools.Installer -SkipPublisherCheck -Force
#install-awstoolsmodule aws.tools.common aws.tools.datasync -Force 



$backuparray = @()
$validationarray =@()
$task_prefix = “task-name-prefix”
$tasks = (Get-DSYNTaskList) 
$tasks = $tasks.where{($_.name -Like "$($task_prefix)*") -and ($_.name -NotLike "ROLLBACK*")}
foreach ($task in $tasks){
 
    $defaultschedule = (Get-DSYNTask -TaskArn $task.TaskArn -Select Schedule)
    $obj1 = [PSCustomObject]@{
            Name = $task.Name
            Schedule = $defaultschedule.ScheduleExpression
    }
    $backuparray += $obj1

    Write-host "Updating schedule for $($task.name)"
    Update-DSYNTask -TaskArn $task.TaskArn -Schedule_ScheduleExpression ""
    $newschedule = (Get-DSYNTask -TaskArn $task.TaskArn -Select Schedule)
    $obj2 = [PSCustomObject]@{
            Name = $task.Name
            Schedule = $newschedule.ScheduleExpression
    }
    $validationarray += $obj2
}

$backuptable = $backuparray | Format-Table -Property Name, Schedule -AutoSize | Out-String
$backuparray | Export-Csv -Path .\schedulebackup.csv -NoTypeInformation
Write-Host "Original schedule data has been backed up to .\schedulebackup.csv"
Write-Host $backuptable

$validationtable = $validationarray | Format-Table -Property Name, Schedule -AutoSize | Out-String
Write-Host "Starting validation of updated datasync tasks"
Write-Host $validationtable
