# --------------------
# FILE SYNC
# by @Wesley Stillwell
# --------------------

CLS
$version = 1

$Wlogx = "--------------------" 
$Wlogx += "File Sync V$version" 
$Wlogx += "--------------------" 

# Import Functions 
. "$env:scripts\BaseFuncs\UserIO.ps1"
. "$env:scripts\BaseFuncs\WLog.ps1"
. "$env:scripts\BaseFuncs\Misc.ps1"

$Wlog = WL_InitializeLog("File Sync V$version")

$Wlog += WL_LOG "$Wlogx" 1
$Wlog += WL_LOG "...loading successful" 1

# Other Functions
function addDirectoryToFile_CSVD($pathToFile){
    $p = UserInput("SRC_Directory")
    $t = UserInput("DST_Directory")
    $c = UserInput("Filter")
    $content = "$p,$t,$c"
    Add-Content -Path $pathToFile -Value $content
    $Wlog += WL_LOG "Add To FileAdded: $p | $t, $c" 1
  }
  function addDirectoryToFile_CSVDAuto{
      param([string]$pathToFile,[string]$content)
    $Wlog += WL_LOG "XXXXXXXXXXX: $content" 1
    $ptf = $pathToFile
    $c = $content
    Add-Content -Path $ptf -Value $c
    $Wlog += WL_LOG "Add To FileAdded: $content" 1
  }

# Full Sync Function
# This is where the main copying happens
function fullSync{
    param([string]$DST_Path,[string]$SRC_Path)
    $Wlog += WL_LOG "RUNNING SYNC" 1

    $CSV_SRC = Import-Csv -Path $CSV_SRC_PATH # is now the only src for paths as contains dst and src
    #$CSV_DST = Import-Csv -Path $CSV_DST_PATH
    # Loop for targeting
    foreach($dest_line in $CSV_SRC)
    {
        $d_type = $dest_line.FILTER
        $d_dst = $dest_line.DST_Directory
        $d_src = $dest_line.SRC_Directory
        $Wlog += WL_LOG "Copy Job: `tFrom: $d_src`tTo: $d_src`tType:" 1
        robocopy $d_src $d_dst "*$d_type" /S /J /mt
     
    }
}
# Open Config CSV
$Wlog += WL_LOG "...functions loaded" 1
$Wlog += WL_LOG "...loading configs" 1
$CSV_SRC_PATH = "$PSScriptRoot\CSV\src.txt"
$CSV_DST_PATH = "$PSScriptRoot\CSV\dst.txt"
$CSV_CFG_PATH = "$PSScriptRoot\CSV\config.cfg"
$fail = 0;


if( DoesFileExist($CSV_SRC_PATH) )
{   
    
    $Wlog += WL_LOG "SRC File Found $test_src" 1
}
else
{
    $Wlog += WL_LOG "SRC Not File Found" 1  
    $test_src = CreateIfNotExist($CSV_SRC_PATH) 
    addDirectoryToFile_CSVDAuto $CSV_SRC_PATH 'SRC_DIRECTORY,DST_DIRECTORY,FILTER'
    $fail++
}

#  Redundant in new system 
if(DoesFileExist($CSV_DST_PATH)  )
{
    $Wlog += WL_LOG "DST File Found" 1
}
else
{
    $test_dst = CreateIfNotExist($CSV_DST_PATH)
    $Wlog += WL_LOG "DST File Not Found" 1   
    addDirectoryToFile_CSVDAuto $CSV_DST_PATH 'DIRECTORY,TYPE,COMMENT' 
    $fail++
}

# NOT USED FOR ANYTHING YET
if( DoesFileExist($CSV_CFG_PATH)  )
{
    $Wlog += WL_LOG "CFG File Found" 1
}
else
{  
    $test_cfg = CreateIfNotExist($CSV_CFG_PATH)
    $Wlog += WL_LOG "CFG Not File Found" 1   
    addDirectoryToFile_CSVDAuto $CSV_CFG_PATH 'Timestamp,TYPE,COMMENT'
    $fail++
}

$temp = "$fail/3 New Files Created"
$Wlog += WL_LOG "$temp" 1
$Wlog += WL_LOG "...Loading Data" 1
$CSV_SRC = Import-Csv -Path $CSV_SRC_PATH
$CSV_DST = Import-Csv -Path $CSV_DST_PATH

$fail = 0;
$Wlog += WL_LOG "Building Menu" 0
$array = @('Run Sync','Add new Copy Job','SHOW Log','Exit')
$m1 = BuildNewMenu $array "What Do You Wanna Do?"
$Wlog += WL_LOG "READY LAUNCHING IN 3 SECONDS" 0
Start-Sleep -Seconds 3

# Main Loop
# ---------
$run = 1
do{
    $Wlog += WL_LOG "$m1" 1

    $m1_result = UserInputNum("")
    switch($m1_result)
    {
    '0' {
            CLS
            $Wlog += WL_LOG '----------------' 1
            $Wlog += WL_LOG 'RUNNING SYNC....' 1
            fullSync $CSV_DST_PATH $CSV_SRC_PATH 
        }
    '1' {   
            CLS
            $Wlog += WL_LOG '--------------------------' 1
            $Wlog += WL_LOG 'Add a new Source-Directory' 1
            addDirectoryToFile_CSVD($CSV_SRC_PATH)
        } 
    #'2' {
     #       $Wlog += WL_LOG '-------------------------------' 1
      #      $Wlog += WL_LOG 'Add a new Destination-Directory' 1
       #     addDirectoryToFile_CSVD($CSV_SRC_PATH)
        #} 
    '2' {
            CLS
            $Wlogt += WL_LOG '-------------------------------' 1
            $Wlogt += WL_LOG "Dumping Log " 1
            $Wlogt += WL_LOG '-------------------------------' 1
            $Wlog += WL_LOG "`n $Wlog " 1
            $Wlog += WL_LOG '-------------------------------' 1
        } 
    '3' {
            $Wlog += WL_LOG '----------------' 1
            $Wlog += WL_LOG '...Shutting Down' 1
            $Wlog += WL_LOG '.' 1
            $Wlog += WL_LOG '...Good Bye' 1
            $run = 0
        }
    }
}
until ($run -eq 0)
$Wlog += WL_LOG 'Shutting down...' 1
CLS

# -----

