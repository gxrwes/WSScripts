
# --------------------
# MISC LIBARY
# by @Wesley Stillwell
# --------------------
$v = "1.0"

# Load WLOG to enable Logging
. "$env:scripts\BaseFuncs\WLog.ps1"

# Part of Github: https://github.com/nosalan/powershell-mtp-file-transfer/blob/master/phone_backup_recursive.ps1
function Get-PhoneMainDir($phoneName)
{
  $o = New-Object -com Shell.Application
  $rootComputerDirectory = $o.NameSpace(0x11)
  $phoneDirectory = $rootComputerDirectory.Items() | Where-Object {$_.Name -eq $phoneName} | select -First 1
    
  if($phoneDirectory -eq $null)
  {
    throw "Not found '$phoneName' folder in This computer. Connect your phone."
  }
  
  return $phoneDirectory;
}

# Test if the Leaf of the Path Exists
function DoesFileExist($pathToFile)
{
    return Test-Path -Path $pathToFile -PathType Leaf
}

function CreateIfNotExist($pathToFile)
{
  $Wlog = WL_LOG "MISC:: Testing for <$pathToFile> " 1
  $result = DoesFileExist($pathToFile)
  $Wlog += WL_LOG "MISC:: Result <$result> " 1
  if($result)
  {    
    $Wlog = WL_LOG "MISC:: File Exists! <$pathToFile> " 1   
  }
  else    
  {
    New-Item -Path $pathToFile -ItemType "file"
    $Wlog = WL_LOG "MISC:: Created New <$pathToFile> " 1
  }
  return $result
}
Write-Host "LOADED MISC LIBARY V$v"