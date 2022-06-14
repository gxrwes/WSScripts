########################
## matchCopyRename    ##
## by Wes Stillwell   ##
########################

Write-Host "MatchCopyRename V1.1 2022"
Write-Host "-------------------------"

# Import Functions 
. "$env:scripts\BaseFuncs\UserIO.ps1"
. "$env:scripts\BaseFuncs\WLog.ps1"

$Wlog = WL_InitializeLog("matchCopyRename")

# DIRECTORIES
$Path = UserInput("Input search path")
$DestinationPath = UserInput('Input destination path ')

# SEARCH PARAMETERS
$userRegex = UserInput('Input a search expression (type 1 for default: ^([0-9]{5,6}).*)')
if($userRegex -eq "1")
{
    $userRegex = ""
}
$Wlog += WL_LOG "User Regex: $userRegex"
$userExtension = ""

# EDIT PARAMETERs
$userExtension = UserInput("Enter filetype (extension without DOT)")
$userRename = $false;
$renameConfirmation = UserConfirm("Rename copied files")
$userPrefix = ""
$Wlog += WL_LOG "EXT: $userExtension" 1

if ($renameConfirmation -eq 'y') 
{
    $Wlog += WL_LOG "Renaming: ON" 1
    $userRename = $true;
    $userPrefix = UserInput('Rename: Input a Prefix to be added to the Original File')
}
else
{
    $Wlog += WL_LOG "Renaming: OFF" 1
}

$Extension = "*.cdr"
if($userExtension.Length -gt 0)
{
    $Extension = '*.' + $userExtension
}

# Input Test

If ($userRegex.Length -lt 1)
{
    $Wlog += WL_Log "Regex: default" 1
    $regexPattern = "^([0-9]{5,6}).*"
}
else
{
    $Wlog += WL_LOG "Regex:  $userRegex" 1
    $regexPattern = $userRegex
}
If ($userPrefix.Length -lt 1)
{
    $Wlog += WL_LOG "Prefix: _ (default)" 1
    $userPrefix = "_"
}
else
{
	$Wlog += WL_LOG "Prefix custom:  $userPrefix" 1
}


# Print current settings

$Wlog += WL_LOG "Starting with parameters:" 1
$Wlog += WL_LOG "Renaming: `t`t$renameConfirmation" 1
$Wlog += WL_LOG "Renaming Prefix: `t`t$userPrefix" 1
$Wlog += WL_LOG "Regex:`t`t$regexPattern" 1
$Wlog += WL_LOG "Extension:`t`t$Extension" 1
$Wlog += WL_LOG "From `t$Path" 1
$Wlog += WL_LOG "To `t$DestinationPath" 1


$Wlog += WL_LOG "Starting Crawl..." 1

# Initiate Logic
$count = 0;
$dupliCount = 0;
$total =(Get-ChildItem $Path -Filter $Extension -Recurse -Depth 10 | Measure-Object).Count

$Wlog += WL_LOG "Found $total files" 1

# Main Logic
Get-ChildItem $Path -Filter $Extension -Recurse -Depth 10 |  Where-Object { $_.Name -match $regexPattern }| ForEach {
    
    $Dest = $DestinationPath 
    $Path = ($_.DirectoryName + "\") -Replace [Regex]::Escape($Source), $Dest
    
    $DestFilePath = $DestinationPath +"\"+ $_.Name
    
    # check for duplicates and overwrite if newer
    #Write-Host "..Testing if Files " $DestFilePath " exists"

    IF (Test-Path -Path $DestFilePath -PathType Leaf)
    {
        $dupliCount++;
        
        $old = Get-Item $DestFilePath

        $t =  "..File Duplicate warning: `n`t-->`tOLD: " + $old.Name + "`n`t-->`tNEW: 0" + $_.Name
        $Wlog += WL_LOG $t 0
        # add underline for copied items
        $newName = "$userPrefix$_"

        IF( Test-Path $_.FullName -NewerThan $old.LastAccessTime)
        {
            #Write-Host "..File in destination is older and will be overwritten"

            Copy-Item $_.FullName -Destination $Dest -Force

            
            if($userRename)
            {
                Rename-Item $_.FullName -newname $newName
            }
            $Wlog += WL_LOG "..File overwritten: "+ $_.Name 0
            
        }
        else
        {
            $Wlog += WL_LOG "..File skipped "+ $_.Name 0

            # Rename this file as skipped file and _OLD_
            $newName = "_OLD$newName"

            if($userRename)
            {
                Rename-Item $_.FullName -newname $newName
            }
        }
    }
    else
    {
        Copy-Item $_.FullName -Destination $Dest -Force
        # add underline for copied items
        $newName = "$userPrefix$_"
        if($userRename)
        {
            Rename-Item $_.FullName -newname $newName
        }
        $tmp = $_.Name
        $Wlog += WL_LOG "..File found and copied:  + $tmp)" 0
    }
    # Progress Bar 
    $count++
    $Wlog += WL_LOG "Working $count of $total" 1
    Write-Progress -Activity "MatchAndCopy" -Status "Working $count of $total" -PercentComplete(($count/$total)*100)
    
}

$Wlog += WL_LOG "Total touched files: `t$count `nDuplicates Found: `t$dupliCount `nEOF" 1
# Save Log and Quit
WL_Save( $Wlog, 'mCR.log')