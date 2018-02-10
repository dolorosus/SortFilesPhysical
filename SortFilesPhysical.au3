#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 123456 -v12
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <FileConstants.au3>
#include <File.au3>
#include <Array.au3>

OnAutoItExitRegister("term")

Global Const $sSplashTitle = "Files physisch sortieren"
Global Const $csFldrCreErr="Ordnerliste konnte nicht erstellt werden. Error_:%d Extended_:%s\n"
Global Const $csFldrSearchMsg = "Ordner suchen"
Global Const $csFldrSortErr="Ordnerliste konnte nicht sortiert werden. Error_:%s Extended_:%s\n"
Global Const $csFlistCreErr="Dateiliste %s konnte nicht erstellt werden. Error_:%s Extended_:%s\n"
Global Const $csFlistSortErr="Dateiliste konnte nicht sortiert werden. Error_:%s Extended_:%s\n"
Global Const $csDryRunMsg="DryRun no execution"
Global Const $csFmoveErr="Filemove %s to %s fehlgeschlagen\n"

sortFiles()

Func term()
	SplashOff()
EndFunc   ;==>term

Func sortFiles($sSrcDir = "",$bDryRun=true)


	Local $aFilelist, $iFilelistUpb
	Local $aFldrlist, $iFldrlistUpb, $aPathSplit


	Local Const $sDstDir = "Sorted"
	Local $sSrc, $sDst

	Local Const $iAscending = 0

	While $sSrcDir = ""
		$sSrcDir = FileSelectFolder($csFldrSearchMsg, "")
		If @error = 1 Then Return (False)
	WEnd

	$aFldrlist = _FileListToArrayRec($sSrcDir, "*", $FLTAR_FOLDERS, $FLTAR_RECUR, Default, $FLTAR_FULLpath)

	SplashTextOn($sSplashTitle, "", 600, 100, -1, -1, BitOR(4, 16), "", 10)

	Switch @error
		Case 0
			;
		Case 9
			$aFldrlist[0] = "1"
			$aFldrlist[1] = "."
		Case Else
			Msg(sf($csFldrCreErr, @error,@extended))
			Exit 1
	EndSwitch

	$iFldrlistUpb = $aFldrlist[0]
	_ArraySort($aFldrlist, $iAscending, 1, $iFldrlistUpb)
	If @error Then Msg(sf($csFldrSortErr, @error,@extended))

	For $i = 1 To $aFldrlist[0]

		$aFilelist = _FileListToArrayRec($aFldrlist[$i], "*", $FLTAR_FILES, $FLTAR_RECUR, Default, $FLTAR_FULLpath)
		If @error Then
			Msg(sf($csFlistCreErr, $aFldrlist[$i], @error, @extended))
		Else
			;
			; Die Dateiliste wird in physischer Reihenfolge angeliefert,
			; also muss sie erstmal sortiert werden
			;
			$iFilelistUpb = $aFilelist[0]
			_ArraySort($aFilelist, $iAscending, 1, $iFilelistUpb)
			If @error Then Msg(sf($csFlistSortErr, @error,@extended))
			;
			; Jetzt die Dateien ins Zielverzeichnis versieben
			;
			For $j = 1 To $aFilelist[0]

				$sSrc = $aFilelist[$j]
				$aPathSplit=PathSplit($aFilelist[$j])
				$sDst = sf("%s\%s%s%s%s",$aPathSplit[1] ,$sDstDir , $aPathSplit[2] ,$aPathSplit[3] , $aPathSplit[4])

				Msg(sf("FileMove(%s,%s)\n", $sSrc, $sDst))

				If $bDryRun Then
					msg($csDryRunMsg&@crlf)
				Else
					If Not FileMove($sSrc, $sDst, BitOR($FC_NOOVERWRITE, $FC_CREATEPATH)) Then
						Msg(sf($csFmoveErr, $sSrc, $sDst))
						Return 1
					EndIf
				EndIf

			Next
		EndIf
	Next

EndFunc   ;==>sortFiles


Func Msg($sMsg)
	ConsoleWrite($sMsg)
	ControlSetText($sSplashTitle, "", "Static1", $sMsg)
EndFunc   ;==>Msg

;===============================================================================
;
; Function Name:   sf($sFormat,$var1...$var20)
; Description:    liefert einen formatierten String zurück
; Parameter(s):    $sFormat - Formatstring
;                  $var1...$var20 -
; Requirement(s):
; Return Value(s):  formatierter String
; Author(s):
; Modified:
; Remarks:			Doku siehe StringFormat

;===============================================================================
Func sf($sFormat, $v1 = "", $v2 = "", $v3 = "", $v4 = "", $v5 = "", $v6 = "", $v7 = "", $v8 = "", $v9 = "", $v10 = "", _
		$v11 = "", $v12 = "", $v13 = "", $v14 = "", $v15 = "", $v66 = "", $v17 = "", $v18 = "", $v19 = "", $v20 = "")
	Return StringFormat($sFormat, $v1, $v2, $v3, $v4, $v5, $v6, $v7, $v8, $v9, $v10, $v11, $v12, $v13, $v14, $v15, $v66, $v17, $v18, $v19, $v20)
EndFunc   ;==>sf


Func PathSplit($sFilePath)

	Local $sDir

	Local $aArray = StringRegExp($sFilePath, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", $STR_REGEXPARRAYMATCH)
	If @error Then ; This error should never happen.
		ReDim $aArray[5]
		$aArray[0] = $sFilePath
	EndIf

	If StringLeft($aArray[2], 1) == "/" Then
		$sDir = StringRegExpReplace($aArray[2], "\h*[\/\\]+\h*", "\/")
	Else
		$sDir = StringRegExpReplace($aArray[2], "\h*[\/\\]+\h*", "\\")
	EndIf
	$aArray[2] = $sDir

	Return $aArray
EndFunc   ;==>_PathSplit
