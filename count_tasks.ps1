$task_prefix = “task-prefis-name”
$tasks = (Get-DSYNTaskList) 
$tasks = $tasks.where{$_.name -like $task_prefix* -and $_.name -NotLike "ROLLBACK*"}
write-host $tasks.Count
