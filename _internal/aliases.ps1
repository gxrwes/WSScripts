CLS
# --------------------
# ALIAS SETTER
# by @Wesley Stillwell
# --------------------

#VERSION
$v = "0.1"  

# Import Functions 
. ".\UserIO.ps1"
. ".\WLog.ps1"
# _helper Functions
$Wlog = WL_InitializeLog("ALIASES V$version")

# Other Functions
function runDo101{

    # run filesync
    $Wlog += WL_LOG "RUNNING FILESYNC" 1
    Set-Location -Path C:\WSScripts\_internal\filesync    
    .\sync.ps1
    $Wlog += WL_LOG "FINISHED RUNNING FILESYNC" 1
    #

}
Set-Alias -name 'run101' -Value runDo101


run101


Write-Host "LOADED ALIAS SETTER V$v"