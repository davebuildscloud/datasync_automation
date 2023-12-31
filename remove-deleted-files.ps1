############################
#
# remove-deleted-files.ps1
# Author:  Dave Stauffacher / davebuildscloud@gmail.com
# Schedule:  Manual 
# This script scans all datasync tasks and updates the "Preserve Deleted Files" setting to "REMOVE".
# This setting will allow a datasync task to remove a file from the destination that does not exist at the source.
#
############################

#Prerequisites
#Install-Module -Name AWS.Tools.Installer -SkipPublisherCheck -Force
#install-awstoolsmodule aws.tools.common aws.tools.datasync -Force 


if ($args.count -lt 1)
{
    Write-Host ""
    Write-Host "**********************************************************"
    Write-Host ""
    Write-Host "ERROR - An insufficient number of parameters were provided"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "./remove-deleted-files.ps1 'filename'"
    Write-Host ""
    Write-Host ""
    Write-Host "example:  ./remove-deleted-files.ps1 'group1.txt'"
    Write-Host ""
    Write-Host "**********************************************************"
    exit 1
}


$file = $args[0]
$names = Get-Content -Path $file
$myarray = @()
Write-host ""
Write-Host ""

foreach ($name in $names){
    $tasks = (Get-DSYNTaskList)
    $task = $tasks.where{$_.name -like $name -and $_.name -NotLike "ROLLBACK*"}
    write-host "Updating task $($task.Name)"
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
        Update-DSYNTask -TaskArn $task.TaskArn -Option @{ PreserveDeletedFiles = "REMOVE"}
        $updatedtask = Get-DSYNTask -TaskArn $task.TaskArn
        $obj1 = [PSCustomObject]@{
            Name = $updatedtask.Name
            Status = $updatedtask.Options.PreserveDeletedFiles.Value
        }
        $myarray += $obj1
    }
}
$table = $myarray | Format-Table -Property Name, Status -AutoSize | Out-String
Write-Host $table
