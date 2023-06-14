############################
#
# count_tasks.ps1
# Author:  Dave Stauffacher / davebuildscloud@gmail.com
# Schedule:  Manual 
# This script scans all datasync tasks and returns a count of tasks with a given task name prefix.
# In my use case, all of my copy tasks started with the name of the file system being migrated, so that file system name was used as the task_prefix value
#
############################

#Prerequisites
#Install-Module -Name AWS.Tools.Installer -SkipPublisherCheck -Force
#install-awstoolsmodule aws.tools.common aws.tools.backup aws.tools.datasync aws.tools.ebs aws.tools.ec2 aws.tools.fsx aws.tools.s3 aws.tools.securitytoken -Force 



$task_prefix = “task-prefis-name”
$tasks = (Get-DSYNTaskList) 
$tasks = $tasks.where{$_.name -like $task_prefix* -and $_.name -NotLike "ROLLBACK*"}
write-host $tasks.Count
