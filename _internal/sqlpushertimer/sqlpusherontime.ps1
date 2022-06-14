########################
## SQL Pusher    ##
## by Wes Stillwell   ##
########################

# Find Articles within the Similarity of the Input

# References/Sources:
# https://germanpowershell.com/sql-server-verbinden-mit-powershell/
#

# Usability Functions - copied from others cos wes doesnt know how to use a remote "class"
. "UserIO.ps1"
. "WLog.ps1"

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
# Config
# ------------

# Anlegen der Datenquelle, also Server\Instanz            
$SQLServer = “”             
# Benutzer zum Verbinden            
$User = “”                
# Passwort zum Verbinden - make user imput for securrity reasons          
$Password = UserInputPassword("Input Password for Database $SQLServer as User $User :")            
# Datenbank zum Verbinden - set to profile for default          
$Datenbank = “"            
 
# Befehl zum späteren Verbinden zum Server            
$Connect_String = “Server=$SQLServer;uid=$User; pwd=$Password;Database=$Datenbank;Integrated Security=false;” 
# Connection Objekt erstellen            
$SqlConnection_Object = New-Object System.Data.SqlClient.SqlConnection     
# ConnectionString übergeben an Connection Objekt            
$SqlConnection_Object.ConnectionString = $Connect_String   
        
# Open Connection to DB            
$SqlConnection_Object.Open()            
            
# Open input CSV
$ImportCsv = Import-Csv -Path '\input\input.csv' 

# USER INPUT
$sleepTimer = UserInput("Input sleep timer (in S) for delay between Updates")


# Initialize log
$Wlog = WL_InitializeLog("SQLPushtime")
$Wlog += WL_LOG "Starting Requests..." 1

# Prep output file, write CSV HEADERS
#$outputline = "DO_IDNR; NFT_IDNR; NFT_STL0; DO_FSTL1; Difference; Matched Difference; diff Length ;Valid Match `n"

# Predefined Rexex
$regex_1 = '.*DO_IDNR\s=\s*([0-9]{5,8})'

# count total lines
$Wlog += WL_LOG "Counting total Lines" 1
$total = 0
foreach($SQLLine in $ImportCsv)
{
  $total++
}
$Wlog += WL_LOG "Total Lines $total" 1
$c = 0
foreach($SQLLine in $ImportCsv){

    #$Wlog += WL_LOG "INPUT FROM FILE : $SQLLine"
    $_SQLLine_temp = ''
    $_SQLLine_temp = $SQLLine -replace '@{SQL=', ''
    $_SQLLine_temp = $_SQLLine_temp -replace '}', ' '
    $_workingline = $true
    $_counter = 0
    $Wlog += WL_LOG "...Working line: $_SQLLine_temp" 1

    # SQL request to see if a field empty and ready to be reassigneed
    if($_SQLLine_temp -match $regex_1)
    {
        $DO_IDNR = $Matches[1]
        $Wlog += WL_LOG ":: $DO_IDNR"
        #Start-Sleep  10
        while (($_workingline) -and ($_counter -lt 50)) {
            $_counter++
            $Wlog += WL_LOG "...attempt[$_counter]" 1
            
            $Q = “SELECT*FROM .WHERE DO_IDNR = $DO_IDNR”
            $Wlog += WL_LOG "`tSQL-Req Q1: $Q" 0
            # Command Objekt für Befehle erstellen            
            $Q1 = $SqlConnection_Object.CreateCommand()            
            # Query als CommandText übergeben            
            $Q1.CommandText = $Q      
            # Query als Reader ausführen            
            $Q1Result = $Q1.ExecuteReader()           
            # DataTable Objekt für die SQL Daten erstellen            
            $Q1ResultTable = new-object System.Data.DataTable   
            # Resultate in die DataTable laden            
            $Q1ResultTable.Load($Q1Result)
            
            $D1_FSTL2 = ""
            Start-Sleep -Seconds 1
            foreach ($row in $Q1ResultTable)
            {
                $D1_FSTL2 = $row["DO_FSTL2"];
                $Wlog += WL_LOG "`tDO_FSTL2 Content: $D1_FSTL2 |" 0
                if($D1_FSTL2 -eq '')
                {
                    # Field is empty and ready to be reassigned
                    $QUpdate = $_SQLLine_temp
                    $Wlog += WL_LOG "`tSQL sending command: $QUpdate" 0
                    $Q2 = $SqlConnection_Object.CreateCommand()        
                    $Q2.CommandText = $QUpdate  
                    $Q2.Connection = $SqlConnection_Object        
                    $Q2.ExecuteNonQuery()
                    $Wlog += WL_LOG "...updating field" 1    
                    $_workingline = $false;

                    # set manual touch status 102
                    #$Wlog += WL_LOG "...Settin Manual touch Status" 1    
                    #$QStatus.CommandText = "UPDATE DOKSTAMM DO_FSTL5 = '102' WHERE DO_IDNR = $DO_IDNR"  
                    #$Qstatus.Connection = $SqlConnection_Object        
                    #$QStatus.ExecuteNonQuery()
                }
                else {
                    $_workingline = $true;
                    $Wlog += WL_LOG "...delaying for $sleepTimer" 1
                    Start-Sleep -Seconds $sleepTimer  
                } 
            }
        }
        
    }
    else {
            $Wlog += WL_LOG 'SQL Send Failed..' 1
            $t_S = "Field occupied: $_SQLLine_temp" 
            $Wlog += WL_LOG $t_s 1
            Start-Sleep -Seconds $sleepTimer
        }
    $c++
    $Wlog += WL_LOG "Worked $c out of $total Files" 1
}

# Save Reult to files
#$outputline | Out-File -FilePath 'C:\Users\w.stillwell\OneDrive - MEG\Dokumente\TestScripts\linkToSimilar\results.csv'
$Wlog += WL_LOG "Closing SQL Connection and Shutting down" 1
WL_Save( $Wlog, 'C:\Users\w.stillwell\OneDrive - MEG\Dokumente\TestScripts\sqlpushtimer\SQLPT')
# Verbindung zum SQL Server wieder trennen            
$SqlConnection_Object.Close()            
