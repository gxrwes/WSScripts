REM Zipper Script for autozipping files in Targetpath

echo STARTING ZIPPER...

REM Might b hardcoded through zipper.cfg in future

FOR /f "eol=- delims=" %%a in (azv2.cfg) do set "%%a"
colour %SOURCEFOLDER%%TARGETFOLDER%

$TargetPath = Read-Host -Prompt "Enter Path"
$TargetFileName = Read-Host -Prompt "Enter preferred Zip name"
$DestinationPath = "C:\Users\w.stillwell\OneDrive - MEG\Dokumente\TestScripts\autozipper\$($TargetFileName)"

echo WORKING...

REM Wildcards can be added to $TargetPath eg *.wav to for finer zip exclusion

$compress = @{
  Path = $TargetPath
  CompressionLevel = "Fastest"
  DestinationPath = $DestinationPath
}
Compress-Archive @compress

echo END...