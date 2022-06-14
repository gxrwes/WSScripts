using namespace System.Management.Automation.Host
# --------------------
# USER IO 
# by @Wesley Stillwell
# --------------------

$v = "1.0"
function UserInput{
	param([string]$message)
    $_input = ""
    while($_input.Length -lt 1)
    {
        $_input = Read-Host "$message "
    }
    
    return $_input
}
function UserInputNum{
	param([string]$message)
    $_input = ""
    while($_input.Length -lt 1)
    {
        $_input = Read-Host "$message "
        if($_input -match  '\d')
        {
          # is a number
        }
        else
        {
          $_input = ""
        }
    }
    
    return $_input
}
function UserInputPassword{
	param([string]$message)
    $_input = ""
    while($_input.Length -lt 1)
    {
        $_input = Read-Host "$message " -AsSecureString
    }
    
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_input))
}

function UserConfirm{
	param([string]$message)
    $_input = ""
    $valid = $false # default set to false
    while( -Not $valid )
    {
        $_input = Read-Host "$message (Y/N) "
    
        if (($_input -eq 'y') -or ($_input -eq 'Y')) 
        {
            $valid = $true
            return "y"
        }
        elseif(($_input -eq 'n') -or ($_input -eq 'N') )
        {
            $valid = $true
            return "n"
        }
        Write-Host "Invalid Input, please try again"
    }
}

function Compare-String {
    # SRC: https://stackoverflow.com/questions/25169424/using-powershell-to-find-the-differences-in-strings 
    # Bill_Stewart
    param(
      [String] $string1,
      [String] $string2
    )
    if ( $string1 -ceq $string2 ) {
      return -1
    }
    for ( $i = 0; $i -lt $string1.Length; $i++ ) {
      if ( $string1[$i] -cne $string2[$i] ) {
        return $i
      }
    }
    return $string1.Length
  }

# Builds A CMD Menu
# params
# 1: Array of options
# 2: Title of Menu
# 3: Question
function BuildNewMenu {
  [CmdletBinding()]
  param(
      [String[]] $Options,
      [string] $title
  )
  $output = "`n`t| $title |`n"
  $c = 0
  foreach ($o in $Options)
  {
    $output += "`t[$c]`t$o`n" 
    $c++
  }
  return $output
}

function SelectFromMenu{
  [CmdletBinding()]
  param(
      [String] $input,
      [string] $options
  )

  # do more stuff
}

Write-Host "LOADED USERIO V$v"