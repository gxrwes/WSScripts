########################
## Link To Similar    ##
## by Wes Stillwell   ##
########################

# Find Articles within the Similarity of the Input

# References/Sources:
# https://germanpowershell.com/sql-server-verbinden-mit-powershell/
#

# Import Functions 
. "C:\Users\w.stillwell\OneDrive - MEG\Dokumente\TestScripts\BaseFuncs\UserIO.ps1"
. "C:\Users\w.stillwell\OneDrive - MEG\Dokumente\TestScripts\BaseFuncs\WLog.ps1"
# Initialize log
$Wlog = WL_InitializeLog("Link to Similar")

# Config
# ------------

# Anlegen der Datenquelle, also Server\Instanz            
$SQLServer = “megsql02”             
# Benutzer zum Verbinden            
$User = “anw”                
# Passwort zum Verbinden - make user imput for securrity reasons          
$Password = UserInputPassword("Input Password for Database $SQLServer as User $User :")            
# Datenbank zum Verbinden - set to profile for default          
$Datenbank = “profile"            
# The length difference a similar word can vary from the original 
$maxMatchDif = UserInput("Input allowerd variation length: (Leave empty for Default 5)")
if($maxMatchDif -eq '')
{
    $maxMatchDif = 5
}
$wLog += WL_LOG $maxMatchDif 0


# Befehl zum späteren Verbinden zum Server            
$Connect_String = “Server=$SQLServer;uid=$User; pwd=$Password;Database=$Datenbank;Integrated Security=false;” 
# Connection Objekt erstellen            
$SqlConnection_Object = New-Object System.Data.SqlClient.SqlConnection     
# ConnectionString übergeben an Connection Objekt            
$SqlConnection_Object.ConnectionString = $Connect_String   
        
# Open Connection to DB            
$SqlConnection_Object.Open()            
            
# Open input CSV
$ImportCsv = Import-Csv -Path 'searchdoc.csv' 
$IC_items = $ImportCsv.Count
$Wlog += WL_Log "Items to search: $IC_items" 1
# Define Regular Expression Pack
# - this assures us we are looking for a correct appendix for number,
# - this also needs some expanding
$regex_array = '^([0-9]{2}/[0-9]{4}-[0-9]{2,4}).*','^([0-9]{2}-[0-9]{4}-[0-9]{2,4}).*','^([0-9]{2}-[0-9]{4,6}).*','^([0-9]{2}/[0-9]{4,6}).*','^([0-9]{5,6}).*','^([0-9]{10}).{1,2}'
#$diff_regex_array = '^(\s[a-zA-Z])$','^(\.[0-9]{4,5})$','^([a-zA-Z])$','^(0\d)$','^(-\d\d)$','^(RO)$'
#,'^(\s[a-zA-Z]).*','^([a-zA-Z])','^(0\d).*','^(-\d\d).*'

# Load Regex ext array
$diff_regex_array = Import-Csv 'ext-catch-regex.csv'


$Wlog += WL_LOG "Starting Requests..." 1

# Prep output file, write CSV HEADERS
$outputline = "DO_IDNR; NFT_IDNR; NFT_STL0; DO_FSTL1; Difference; Matched Difference; diff Length ;Valid Match `n"

$_progress_c = 0;
foreach($DO_IDNR in $ImportCsv){
    $Wlog += WL_LOG "FILE $_progress_c of $IC_items" 1
    $_progress_c += 1;
    $Wlog += WL_LOG "Working File $DO_IDNR" 1
    # Build SQL Query to get Document     
    $_DO_IDNR = $DO_IDNR -replace '@{DO_IDNR=', ''
    $_DO_IDNR = $_DO_IDNR -replace '}', ''
    
    $Q1select_DO_IDNR = “SELECT DO_FSTL1, DO_FSTL2 FROM DOKSTAMM WHERE DO_IDNR = $_DO_IDNR”
    $Wlog += WL_LOG "SQL-Req Q1: $Q1select_DO_IDNR" 0

    # Command Objekt für Befehle erstellen            
    $Q1 = $SqlConnection_Object.CreateCommand()            
    # Query als CommandText übergeben            
    $Q1.CommandText = $Q1select_DO_IDNR      
    # Query als Reader ausführen            
    $Q1Result = $Q1.ExecuteReader()           
    # DataTable Objekt für die SQL Daten erstellen            
    $Q1ResultTable = new-object System.Data.DataTable   
    # Resultate in die DataTable laden            
    $Q1ResultTable.Load($Q1Result)
    
    $D1_FSTL1 = ""
    foreach ($row in $Q1ResultTable)
    {
        $D1_FSTL1 = $row["DO_FSTL1"];
        $Wlog += WL_LOG "Loaded Document: $D1_FSTL1 " 1
    }
    # now that we have our original document:
    # - extract articlenumber
    # - look for article
    # - if no article look for similar articles
    # - only match if the variation is allowed in the regex collection

    # Set search term to fstl1 incase parsing fails
    $search_term = $D1_FSTL1;
    $firstmatch = 'false'
    # Parsing of the name to a article nr
    foreach($regex in $regex_array)
    {
        #Write-Host "`t`tRegex Parsing For : $D1_FSTL1  with $regex"
        if( ( $firstmatch -eq 'false' ) -and ( $D1_FSTL1  -match $regex ))
        {
            $search_term = $Matches[1];
            $Wlog += WL_LOG "Parser Result: $search_term " 1
            $firstmatch = 'true'
        }
    }
    # Save parsed NR to variable, as $search_term is edited
    $parsed_fstl1 = $search_term
    # Add Wildcard at the end of name
    #$search_term += '[^0-9]%'
    $search_term += '%'
    # SQL Request to search for Articles containing the name
    #$Q2similarities =  "SELECT NFT_STL0 NFT_IDNR FROM NFSTAMM WHERE NFT_STL0 Like '$search_term'"

    # Clear some counters just incase
    $_difference_stubstring = ""
    $_difsize = 0
    
    if($search_term.Length -gt 8)
    {
        $Q2similarities =  "SELECT * FROM NFSTAMM WHERE NFT_STL0 Like '$search_term' AND NFT_IDNR NOT IN ($_DO_IDNR)"
        $Wlog += WL_LOG "SQL-Req Q2: $Q2similarities" 1
        $Q2 = $SqlConnection_Object.CreateCommand()      
        $Q2.CommandText = $Q2similarities 
        # Query als Reader ausführen
        $Q2LikeResult = $Q2.ExecuteReader()           
        # DataTable Objekt für die SQL Daten erstellen            
        $Q2ResultTable = new-object System.Data.DataTable
        # Resultate in die DataTable laden            
        $Q2ResultTable.Load($Q2LikeResult)

        # $Q2ResultTable
        # Format result
        $Wlog += WL_LOG "Working results.." 0
        foreach($rown in $Q2ResultTable)
        {
            $_difsize = 0
            $_nfidnr = $rown["NFT_IDNR"]
            $_nftstl0 =$rown["NFT_STL0"]
            $Wlog += WL_Log "`tWorking Pair-> NFTIDNR: $_nfidnr - NFTSTLO: $_nftstl0 - D1_FSTL1: $D1_FSTL1 " 0

            # Check if the searchterm is longer than result
            # Make substrings and see if they are valid matches
            # Valid appendicies: A-Z,a-z, 0/d, etc
            $_subNFTSTL0 = $_nftstl0
            $_subD1_FSTL = $parsed_fstl1
            $_difference_stubstring = ""
            
            if($_nftstl0.Length -lt $parsed_fstl1.Length)
            {
                $_difference_stubstring = $_subD1_FSTL.Substring($_subNFTSTL0.Length)
            }
            else 
            {
                $_difference_stubstring = $_subNFTSTL0.Substring($parsed_fstl1.Length) 
            }
            
            $_difsize = $_difference_stubstring.Length
            $Wlog += WL_Log "`t`tDifference: $_difference_stubstring " 0
            $Wlog += WL_LOG "`t`tDifference lenth: $_difsize " 0

            # Create  output line, fill this with csv data
            if($_difference_stubstring.Length -lt 8)
            {
                $Wlog += WL_LOG "Matching Difference..." 1
                $_counter = 0;
                $valid_bool = 'false';
                $__ = ""

                foreach ($phrase in $diff_regex_array)
                {
                    $phrase = $phrase -replace '@{regex=', ''
                    $phrase = $phrase.Substring(0,$Phrase.length-1)

                    $Wlog += WL_LOG "-- Matching with Phrase $phrase to $_difference_stubstring " 0
                    if($valid_bool -eq 'false')
                    {
                        if( $_subNFTSTL0 -ceq $parsed_fstl1 )
                        {
                            $Wlog += WL_LOG " - Found Perfect Match - [ $_counter ]: $__ " 1
                            $_counter ++
                            $valid_bool = 'true'
                        }
                        elseif( $_difference_stubstring -match $phrase )
                        {
                            $__ = $Matches[1]
                            $_counter ++
                            $Wlog += WL_LOG " - regex-matching" 0
                            
                            $Wlog += WL_LOG " - Found Valid Match - [ $_counter ]: $__ " 1
                            $valid_bool = 'true'
                            
                        }
                        
                    }
                } 
                $Wlog += WL_LOG "Writing result to file..." 0
                $outputline += "$_DO_IDNR;$_nfidnr;$_nftstl0;$parsed_fstl1;$__ ;$_difference_stubstring ;$_difsize;$valid_bool`n"
            }
            else {
                $Wlog += WL_LOG "`t`tDifference too large" 0
                $outputline += "$_DO_IDNR;$_nfidnr;$_nftstl0;$parsed_fstl1;diff to large;$_difference_stubstring;$_difsize;false`n"
            }
        }
    }  
    else
    { 
        $Wlog += WL_LOG "Search term too short" 0
    }
    $Wlog += WL_Log "0" 0
}

# Save Reult to files
$Wlog += WL_Log "... done and saving to file" 1
# TODO make this a add file in the loop so incase of stop we have result
$outputline | Out-File -FilePath 'C:\Users\w.stillwell\OneDrive - MEG\Dokumente\TestScripts\linkToSimilar\results.csv'
$Wlog += WL_LOG "Closing SQL Connection and Shutting down" 1
# Verbindung zum SQL Server wieder trennen            
$SqlConnection_Object.Close()   

# Save Log and Quit
WL_Save( $Wlog, 'C:\Users\w.stillwell\OneDrive - MEG\Dokumente\TestScripts\linkToSimilar\L2S')
