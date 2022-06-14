
# Checks Target Folder for changed files within the last $hrsSince and copies them to $DestinationPath
echo Starting Updater...
echo OBSOLETE 
# Determine how time period for change
$hrsSince = 1

$Path = "\\sbgmain01\bmmatrix$\Artikelfotos"
$DestinationPath = "\\megplm01\tricold\PRODUKTFOTO"
$FolderExtension = "\*"
$TotalPath = $Path + $FolderExtension

Get-Item $TotalPath -Filter *.pdf | Foreach {
  $lastupdatetime=$_.LastWriteTime
  $nowtime = get-date

  if (($nowtime - $lastupdatetime).totalhours -le $hrsSince)
  {
      Write-Host "File modified and copied "$_.Name
      $copyPath = $Path + "\" + $_.Name
      Copy-Item $copyPath -Destination $DestinationPath

      echo Copying file: $copyPath to: $DestinationPath
  }
}

echo EOF