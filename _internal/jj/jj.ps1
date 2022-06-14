# MouseJiggler Powershell Script
# Written by AndrewDavis 
# https://gist.github.com/AndrewDavis


# Import Functions 
. "C:\Users\w.stillwell\OneDrive - MEG\Dokumente\TestScripts\BaseFuncs\UserIO.ps1"
. "C:\Users\w.stillwell\OneDrive - MEG\Dokumente\TestScripts\BaseFuncs\WLog.ps1"

Clear-Host
# Initialize log
$Wlog = WL_InitializeLog("Jiggler")
$wLog += WL_LOG 'Keep-alive with Scroll Lock...' 1
$time = UserInput("Jiggle Freq in ms")
$Wlog += WL_LOG "Jiggling f: $time"


$sleep = 10 # seconds
if($time -gt $sleep){$sleep = $time}
$announcementInterval = 10 # loops

Clear-Host

$WShell = New-Object -com "Wscript.Shell"
$date = Get-Date -Format "dddd MM/dd HH:mm (K)"

$stopwatch
# Some environments don't support invocation of this method.
try {
    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
} catch {
    $Wlog += WL_LOG  "Couldn't start the stopwatch." 1
}

$Wlog += WL_LOG  "Executing ScrollLock-toggle NoSleep routine." 1
$temp =  "Start time: $(Get-Date -Format "dddd MM/dd HH:mm (K)")"
$Wlog += WL_LOG $temp 1
Write-Host "<3" -fore red

$index = 0
while ( $true )
{
    Write-Host "< 3" -fore red      # heartbeat
    $WShell.sendkeys("{SCROLLLOCK}")

    Start-Sleep -Milliseconds $sleep

    $WShell.sendkeys("{SCROLLLOCK}")
    Write-Host "<3" -fore red       # heartbeat

    Start-Sleep -Seconds $sleep

    # Announce runtime on an interval
    if ( $stopwatch.IsRunning -and (++$index % $announcementInterval) -eq 0 )
    {
        $temp = "Elapsed time: " + $stopwatch.Elapsed.ToString('dd\.hh\:mm\:ss')
        $Wlog += WL_LOG $temp 1
    }
}