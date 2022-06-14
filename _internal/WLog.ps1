# --------------------
# WLOG 
# by @Wesley Stillwell
# --------------------

$v = "1.0"

# Write Out 
# type 0 ... debug
# type 1 ... normal output
# type 2 ... secret
function WL_Log{
	param(
      [String] $message,
      [Int] $type
    )
    $date = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $day = Get-Date -Format "MM-dd-yyyy-HH"
    $outstring = ""
    #Write-Host $type
    if($type -eq 0) 
    { 
        $outstring = "[ $date ] -DEBUG-`t $message`n"  
        Write-Debug $outstring
    }
    elseif ($type -eq 1)
    {
        $outstring = "[ $date ] -     -`t $message`n"  
        Write-Host $outstring
    }
    elseif ($type -eq -1)
    {
        $outstring = "[ $date ] - PSW -`t ******* `n"  # do not log Passwords
        Write-Host $outstring
    }
    else {
        $outstring = "[ $date ] - --- -`t $message`n" 
    }
    Add-Content "$day.log" $outstring
    return $outstring
}

# Write Log header
function WL_InitializeLog{
    param([string] $logname)
    $date = Get-Date -Format "MM/dd/yyyy HH:mm K"
    $outstring = "|STARTING WLOG FOR: $logname `n|`tDate: $date`n|-------------------------------------`n"
    return $outstring
}

function WL_Save{
    param(
        [string] $log,
        [string] $outpath
    )
    $date = Get-Date -Format "MM-dd-yyyyHH-mmK"
    $log += "`n-------------------------------------`nLog Saved $date`n-------------------------------------"
    $out = WL_Log "$log" 1
    #$outpath = "$date"+"WL.log"
    #New-Item -Path $outpath -ItemType File
    #$log | Out-File -FilePath $outpath
    # Some issues with Save

}

Write-Host "LOADED WLOGLIBARY V$v"