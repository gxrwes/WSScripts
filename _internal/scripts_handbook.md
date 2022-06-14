# Script Handbook 
#### Wes Stillwell

# Execution Notes

- Einige Scripts nehmen Absolute Pfade her, bin noch nicht dazu gekommen alles zu relativieren
- scripts sind auf derzeitige csv header ausgelegt, wenn header geändert wird muss auch etwas logik geändert werden, bzw neu csv geparsed werden 
- scripts suchen nach working files im execute diretory, also in ps vorher immer cd ./scriptname dann execute, ps ./scriptname/script.ps1 funktioniert immer nur wenn keine working files die im directory abgelegt werden gibt

## Autozipper

Automatisches zippen von datein, zurzeit umbenutzt wurde inteded für sounddateien für autoimport


## BaseFuncs
  *collection*
  This is a collection of some functionalities used in multiple scripts such as User input and WLog

### UserIO

Regelt überprüfung von user imputs mit 
- userInput
- userInputPassword
- UserConfirm
Diese sollten ohne änderung in anderen scripts funktionieren

### WLog

custom logger, es kann zwischen 3 arten von message unterschieden werden
- type 0 ... debug
- type 1 ... normal output
- type 2 ... secret
- type -2 ... password

zum vereinfachen der ausgabe in der console einfach die write-host befehle kommentieren oder auf -Debug oder -Verbose ändern

*Logs werden mit Timerstammp versehen und als .log gespeichert*

#### Zukünftige todos:

- klare namensgebung, zurzeit wegen filenamingissues anders benannt
- bessere log formatierung


## CopyOnModify

Dienst scritp dass daten kopiert wenn sie in der vorgegebenen zeitspanne geändert worden sind

zurzeit verwendet um bedienungsanleitungen bei updates automatisch einzuspielen und als dienst auf profileserver augeführt.
Der betrachtungszeitraum ders scripts sollte der selbe sein wie der start intervall des dienstes

## Exclusion Counter

## Link to Similar

zum suchen ähnlicher artikel, zb farbvariationen. Strikheit der ähnlichkeit mit erlaubter zeichen bei stringunterschieden und in ext-catch-regex.csv einstellen. Zu Matchende Doks die DO_IDNR in die searchdoc.csv

ähnliche artikel und ähnlchkeitsauswertung werden dann als csv ausgegeben und mit excel können dan sql command verkettet werden und dann mit script SQL PUSHER ausgeführt werden.

## MatchcopyRename

Filecrawler um mit regex matches in targetordner zu spielen, umbenennung der original daten ist auch möglich (zb mit _) damit files nicht doppelt gefunden werden


## SQL Pusher

ausgelegt um SQL Commands zu senden, speziell für ngt durchläufe, um das field FSTL2 zu refreschen und ngt zeit zu geben dieses zu bearbeiten.
- sleep time legt fest wie lang das programm warted nach eineem erfolglosem update
- in input.csv werden sql commands gespeichert die nacheinander abgearbeitet werden

## JJ

keep awake script, SCROLL LOCK wird gesetzt um Bildschirmtimeout zu verhindern
- scroll lock on/off polling rate in MS

## Throughput Test