############################
#
# stop-all-tasks.ps1
# Author:  Dave Stauffacher / davebuildscloud@gmail.com
# Schedule:  Manual 
# This script stops all queued, pending, or running DataSync Tasks.
# If you only want to stop tasks with a given name prefix, add the following
# $task_prefix = “task-prefix-name”
# $tasks = $tasks.where{$_.name -like $task_prefix* -and $_.name -NotLike "ROLLBACK*"}
#
############################

#Prerequisites
#Install-Module -Name AWS.Tools.Installer -SkipPublisherCheck -Force
#install-awstoolsmodule aws.tools.common aws.tools.datasync -Force 



$tasks = (Get-DSYNTaskList)

#Stop tasks in queue first
foreach ($task in $tasks) {
    $task_details = (Get-DSYNTask -TaskArn $task.TaskArn)
    $task_executions = (Get-DSYNTaskExecutionList -TaskArn $task.TaskArn)
    $task_name = $task_details.Name
    if ($task_details.Status -eq "QUEUED") {
        foreach ($task_execution in $task_executions){
            $task_execution_arn = $task_execution.TaskExecutionArn
            if ($task_execution.status -eq "QUEUED"){
                write-host "the task arn is $($task_execution_arn)"
                write-host "Stopping queued task $($task_name)"
                Stop-DSYNTaskExecution -TaskExecutionArn $task_execution_arn
                #write-host "This is where the task stop step would run"
                while ((Get-DSYNTask -TaskArn $task.TaskArn).Status -ne "AVAILABLE") {
                    write-host "waiting for $($task.name) to stop.  Pausing for 3 seconds."
                    start-sleep -seconds 3
                }
            }
        }
    }
}


#Stop all other tasks
foreach ($task in $tasks) {
    $task_details = (Get-DSYNTask -TaskArn $task.TaskArn)
    $task_name = $task_details.Name
    if ($task_details.Status -ne "AVAILABLE") {
        write-host "stopping $($task_name)"
        Stop-DSYNTaskExecution -TaskExecutionArn $task_details.CurrentTaskExecutionArn
        #write-host "This is where non-queued tasks would be stopped"
        while ((Get-DSYNTask -TaskArn $task.TaskArn).Status -ne "AVAILABLE") {
            write-host "waiting for $($task.Name) to stop.  Pausing for 3 seconds."
            start-sleep -seconds 3
        }
    }
}

foreach ($task in $tasks) {
    if ($task.Status -ne "AVAILABLE") {
    write-host "$($task.name) still has a status of $($task.status)"
    }
}
