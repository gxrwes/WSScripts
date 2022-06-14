#
# Test how quickly files leave/added to folders
#
$testDirectory = Read-Host -Prompt 'Input a Directory to test '
$Extension = Read-Host -Prompt 'Input a Filetype to test for (no dot): '
$Extension = "*." + $Extension
# Default Watchperiod 30 secs
# Minimum WatchPeriod 1s
$watchPeriod = 30
$watchPeriodUser = Read-Host -Prompt 'Input a watch-period (Default 30s. Min 1s) '

if($watchPeriodUser.Length -gt 0 )
{
    $watchPeriod = $watchPeriodUser
}
else
{
    Write-Host "..Default Watch Period Set"
}


cd $testDirectory
Write-Host "Testing throughput of directory"
$count0 =(Get-ChildItem -Filter $Extension | Measure-Object).Count
Write-Host "Filecount at start: $count0"

$fSize1 = (gci $testDirectory | measure Length -s).sum / 1Mb
Write-Host "FSIZE: $fSize1"

$startTime = Get-Date
$timePassed = 0

while (($timePassed+1) -lt $watchPeriod) 
{
    $timePassed++
    Write-Progress -Activity "Sleep" -Status "Have been waiting for $timePassed seconds" -PercentComplete(($timePassed/$watchperiod)*100)
    Start-Sleep -Seconds 0.95
}

$count1 =(Get-ChildItem -Filter $Extension| Measure-Object).Count
$fSize2 = (gci $testDirectory | measure Length -s).sum / 1Mb
Write-Host "FSIZE: $fSize2"

$endTime = Get-Date


Write-Host "Filecount at End: $count0"

$totalTime = $endTime - $startTime
$throughput = $fSize1 - $fSize2

Write-Host "Elapsed Time: $totalTime"
$throughput = $throughput / ($totalTime.Seconds)

Write-Host "Files Per Second: " $throughput
