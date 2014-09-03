#include <File.au3>
 
;  ------------------------------------------------------------------------------------
;   Special thanks for AutoIT forums: getkub 2013-06-02
;   Version 1.01 - Initial version
;   Version 1.03 - Changed to accomodate Server type in config file
;   Version 1.04 - Accomodates SSH keys
;  ------------------------------------------------------------------------------------
Global $aConfig, $aTemplate, $aValues, $sOutput, $outDirectory, $tempVarHostName, $pUserName
Global $inputColourDir, $inputColourFile, $inputColourFileData
Global $superOutDirectory
Global $isPublicKeyEnabled = True, $PublicKeyFileEntry
Global $userName = "", $sshport = "22", $finalOperatingDirectory

$userName = @UserName  
$finalOperatingDirectory = "C:\PuttyPortable"  
; =====================================================================================
; Check if PriviateKey file present. 
; Checks for name "privatekey.ppk" in "sshKeys" directory
; =====================================================================================
$privateKeyFile = $finalOperatingDirectory & "\sshKeys\privatekey.ppk"    ; 

If FileExists($privateKeyFile) Then 
    $pUserName = "UserName\" & $userName & "\"
	$privateKeyFile = StringReplace($privateKeyFile, "\", "%5C")  ; Need to use %5C for "\" within Putty         
	$PublicKeyFileEntry = "PublicKeyFile\" & $privateKeyFile & "\"
Else
    $userName = "UserName\\"
	$PublicKeyFileEntry = "PublicKeyFile\\"
EndIf

; =====================================================================================
; Read config file 
; =====================================================================================
If Not _FileReadToArray(@ScriptDir & "\SessionConfig\ServerList.csv", $aConfig)  Then
    MsgBox(0, "", "An error occurred reading the config file. @error: " & @error)
	Exit
EndIf

; =====================================================================================
; Read template file 
; =====================================================================================
If Not _FileReadToArray(@ScriptDir & "\SessionConfig\Template.txt", $aTemplate)  Then
    MsgBox(0, "", "An error occurred reading the Template file. @error: " & @error) 
	Exit
EndIf

; =====================================================================================
; Open output file per item in Config File
; =====================================================================================
$outDirectory = @ScriptDir &"\ses"
If NOT FileExists($outDirectory) Then 
	MsgBox(0,"Session Folder Not Found","The folder " & $outDirectory & " does NOT exists for writing sessions")
	Exit
EndIf

; =====================================================================================
; Super Putty Settings 
; =====================================================================================
$superOutDirectory = @ScriptDir & "\SuperPutty"
$superOutFile = $superOutDirectory & "\Settings\Sessions.xml"

If NOT FileExists($superOutDirectory) Then 
	MsgBox(0,"SuperPutty Sessions Dir Not Found", $superOutDirectory & " does NOT exists")
    Exit
EndIf
Local $superOutFileVar = FileOpen($superOutFile, 2)  ; Erases previous data
FileWrite($superOutFileVar, "<ArrayOfSessionData>" & @CR) 

; =====================================================================================
; Logic to generate Putty Sessions and SuperPutty xml
; Delete all files first
; =====================================================================================
FileDelete($outDirectory & "\*.session")


; To avoid comments (lines starting with # )
For $i = 1 To $aConfig[0]

	If Stringleft($aConfig[$i], 1) <> "#" Then     
		$aValues = StringSplit($aConfig[$i], ",") 

	; #SERVERTYPE,IPADDRESS,HOSTNAME,ENVIRONMENT,SERVICE,SHORTNAME
		$SERVERTYPE = $aValues[1]
		$IPADDRESS = $aValues[2]
		$HOSTNAME = $aValues[3]
		$ENVIRONMENT = $aValues[4]
		$SERVICE = $aValues[5]
		$SHORTNAME = $aValues[6]
		
		; SessionFiles will be created with SERVICE_ENV_HOSTNAME format
		$tempVarHostName = $SERVICE & "_" & $ENVIRONMENT & "_" & $HOSTNAME

		$inputColourFileName = @ScriptDir & "\SessionConfig\" & $ENVIRONMENT & "_Colour.txt"
		$inputColourFile = FileOpen(@ScriptDir & "\SessionConfig\" & $ENVIRONMENT & "_Colour.txt", 0)
			If $inputColourFile = -1 Then
				MsgBox(0, "Error", "Unable to find Colour Configuration file: " & @ScriptDir & "\SessionConfig\" & $ENVIRONMENT & "_Colour.txt")
				Exit
			EndIf		
	
		$hOutput = FileOpen($outDirectory  & "\" & $tempVarHostName & ".session", 2)
		
		For $j = 1 To $aTemplate[0] 
			 $sOutput = StringReplace($aTemplate[$j], "\DYNAMIC_PUTTY_TITLE\", "\" & $tempVarHostName & "\")  ; ServerHostName         
			 $sOutput = StringReplace($sOutput, "\DYNAMIC_HOSTNAME_IP\", "\" & $IPADDRESS & "\")  ; IPAddress         
			 ; @CR is very much required for Putty as Putty follows Unix Linefeeds         
			 FileWriteLine($hOutput, $sOutput & @CR)     
		 Next 

		; Special Cases
		; If SSH Keyenabled
		FileWriteLine($hOutput, $pUserName & @CR)
		FileWriteLine($hOutput, $PublicKeyFileEntry & @CR)

		; Also Read line by line from $inputColourFile and write to $hOutput with @CR
		For $k = 1 to _FileCountLines($inputColourFileName)
			$line = FileReadLine($inputColourFile, $k)
			FileWriteLine($hOutput, $line & @CR) 
		Next	
				
		FileClose($hOutput)
		
		; Writes SuperPutty xml per entry
		FileWrite($superOutFileVar, '<SessionData SessionId="' & $SERVERTYPE & "/" & $SERVICE & "/" & $ENVIRONMENT & "/" & $HOSTNAME & '" SessionName="' & $tempVarHostName & '" Host="' & $IPADDRESS & '" Port="' & $sshport & '" Proto="SSH" PuttySession="' & $tempVarHostName & '" Username="' & $userName & '" />' & @CR) 
		
	EndIf
 Next 

FileWrite($superOutFileVar, "</ArrayOfSessionData>") 
FileClose($superOutFileVar)

    MsgBox(0, "", "Successfully completed generating Putty Sessions & SuperPutty Config File")
