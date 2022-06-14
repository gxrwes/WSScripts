
# Checks Target Folder for changed files within the last $hrsSince and copies them to $DestinationPath

# Import Functions 
. "$env:scripts\BaseFuncs\UserIO.ps1"
. "$env:scripts\BaseFuncs\WLog.ps1"
# Initialize log
$Wlog = WL_InitializeLog("Copy On Modify")

# Determine how time period for change
$hrsSince = 1

# $Path = "\\sbgmain01\bmmatrix$\Artikelfotos"
# $DestinationPath = 'C:\Users\wesle\OneDrive\Video\Kajak Renders'
$Path = UserInput("Input a directory you want to clone:")
$DestinationPath = UserInput("Input Clone Target:")
$Wlog += WL_Log "SRCDIR: $Path" 1 
$Wlog += WL_Log "DESTDIR: $DestinationPath" 1
$FolderExtension = "\*"
$TotalPath = $Path + $FolderExtension
[string[]]$Excludes = @('(GOPRO)','(gopro)','(Footage)','(footage)','(DCI)')
$Wlog += WL_Log "EXCLUDED DIR:" 1
$regex = "(?:"
foreach ($i in $Excludes) {
  $Wlog += WL_Log "../$i" 1
  $regex +=".*($i).*|"
}
$regex += " )"
$Wlog += WL_Log "SUMREGX:$regex" 1
$Wlog += WL_Log "Starting Search: $TotalPath" 1
Get-childItem $TotalPath -Recurse -Filter *.mp4  | foreach {
  $Wlog += WL_Log "$_" 1
  $lastupdatetime=$_.LastWriteTime
  $nowtime = get-date
  $copyPath = $Path + "\" + $_.Name
  #$Wlog += WL_LOG "$copyPath " 1
  if( $_.Name -match $regex )
  {
    $Wlog += WL_LOG "Ignored: $copyPath " 1
  }  
  else
  {
    if (($nowtime - $lastupdatetime).totalhours -gt $hrsSince)
    {
      $Wlog += WL_LOG 'File modified and copied  + $_.Name' 0
      Copy-Item $copyPath -Destination $DestinationPath
      $Wlog += WL_LOG "Copying file: $copyPath to: $DestinationPath" 1
    }
    else
    {
      $Wlog += WL_LOG "Untouched: $copyPath " 1
    }
  }
}


# Save Log and Quit
#WL_Save( $Wlog, 'cOM.log')