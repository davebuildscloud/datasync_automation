{
    Write-Host ""
    Write-Host "**********************************************************"
    Write-Host ""
    Write-Host "ERROR - An insufficient number of parameters were provided"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "./parseplan.ps1 'filename'"
    Write-Host ""
    Write-Host ""
    Write-Host "example:  ./parseplan.ps1 'group1.txt'"
    Write-Host ""
    Write-Host "**********************************************************"
    exit 1
}
 
$file = $args[0]
$lines = Get-Content -Path $file
$myarray = @()
$destroycount = 0
$updatecount = 0
$createcount = 0
$replacecount = 0

foreach ($line in $lines) {
    $destroyed = ($line | Select-String -Pattern 'destroyed')
    $updated = ($line | Select-String -Pattern 'in-place')
    $created = ($line | Select-String -Pattern 'created')
    $replaced = ($line | Select-String -Pattern 'replaced')
    if ($destroyed -ne $null) {
        $obj1 = [PSCustomObject]@{
            Status = "destroy"
            Line = $line    
        }
        $myarray += $obj1
        $destroycount += 1
    }
    if ($updated -ne $null) {
        $obj1 = [PSCustomObject]@{
            Status = "update"
            Line = $line
        }
        $myarray += $obj1
        $updatecount += 1
    }
    if ($created -ne $null) {
        $obj1 = [PSCustomObject]@{
            Status = "create"
            Line = $line
        }
        $myarray += $obj1
        $createcount += 1
    }
    if ($replaced -ne $null) {
        $obj1 = [PSCustomObject]@{
            Status = "replace"
            Line = $line
        }
        $myarray += $obj1
        $replacecount += 1
    }
}

$table = $myarray | Format-Table -Property Status, Line -AutoSize | Out-String
Write-Host $table
Write-host "$($createcount) items will be created."
Write-Host "$($replacecount) items will be replaced."
write-host "$($destroycount) items will be destroyed."
Write-Host "$($updatecount) items will be updated in-place."
$table | Out-File -FilePath ".\parsed-plan.txt"
