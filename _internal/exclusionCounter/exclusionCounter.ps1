cls
# LIST ALL FILES MATCHING REGEX IN PATH

Write-Host "MatchCopyRename V1.1 2022"
Write-Host "-------------------------"

function UserInput{
	param([string]$message)
    $input = ""
    while($input.Length -lt 1)
    {
        $input = Read-Host "$message "
    }
    
    return $input
}

function UserConfirm{
	param([string]$message)
    $input = ""
    $valid = $false # default set to false
    while( -Not $valid )
    {
        $input = Read-Host "$message (Y/N) "
    
        if (($input -eq 'y') -or ($input -eq 'Y')) 
        {
            $valid = $true
            return "y"
        }
        elseif(($input -eq 'n') -or ($input -eq 'N') )
        {
            $valid = $true
            return "n"
        }
        Write-Host "Invalid Input, please try again"
    }
}

# User Input

# DIRECTORIES
$Path = UserInput("Input search path")

# SEARCH PARAMETERS
$userRegex = UserInput('Input a search expression (type 1 for default: ^([0-9]{5,6}).*)')
if($userRegex -eq "1")
{
    $userRegex = ""
}
$userExtension = ""

# EDIT PARAMETERs
$userExtension = UserInput("Enter filetype (extension without DOT)")
$userRename = $false;
$userPrefix = ""

if ($renameConfirmation -eq 'y') 
{
    Write-Host "Renaming: ON"
    $userRename = $true;
    $userPrefix = UserInput('Rename: Input a Prefix to be added to the Original File')
}
else
{
    Write-Host "Renaming: OFF"
}

$Extension = "*.cdr"
if($userExtension.Length -gt 0)
{
    $Extension = '*.' + $userExtension
}

# Input Test

If ($userRegex.Length -lt 1)
{
    Write-Host "Regex: default"
    $regexPattern = "^([0-9]{5,6}).*"
}
else
{
    Write-Host "Regex:  $userRegex"
    $regexPattern = $userRegex
}
If ($userPrefix.Length -lt 1)
{
    Write-Host "Prefix: _ (default)"
    $userPrefix = "_"
}
else
{
	Write-Host "Prefix custom:  $userPrefix"
}


# Print current settings

Write-Host "Starting with parameters:"
Write-Host "Regex:`t`t$regexPattern"
Write-Host "Extension:`t`t$Extension"
Write-Host "From `t$Path"

Write-Host "Starting Crawl..."

# Initiate Logic
$count = 0;
$dupliCount = 0;
$total =(Get-ChildItem $Path -Filter $Extension -Recurse -Depth 10 | Measure-Object).Count

Write-Host "Found $total files"

# Main Logic
Get-ChildItem $Path -Filter $Extension -Recurse -Depth 10 |  Where-Object { $_.Name -match $regexPattern }| ForEach {
    
    $Dest = $DestinationPath 
    $Path = ($_.DirectoryName + "\") -Replace [Regex]::Escape($Source), $Dest
    
    $DestFilePath = $DestinationPath +"\"+ $_.Name
    
    # check for duplicates and overwrite if newer
    #Write-Host "..Testing if Files " $DestFilePath " exists"

    # Progress Bar 
    $count++
    Write-Progress -Activity "MatchAndCopy" -Status "Working $count of $total" -PercentComplete(($count/$total)*100)
    
}

Write-Host "Files found: $total`nFiles already imported: $count"