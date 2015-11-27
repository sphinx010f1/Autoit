#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_outfile=Client.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Array.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <GuiListView.au3>
#include <TCP.au3>
#include <WindowsConstants.au3>
#include <Crypt.au3>
HotKeySet("{PRINTSCREEN}", "PRT")
$ip = InputBox("Внимание!", "Введите ip адрес сервера")
$pass = InputBox("Внимание!", "Введите пароль для шифрования")
$passn = $pass & @MDAY & '23707' & @MON & '23707' & @YEAR
$one = 0
$filez = 0
$filp = 0
$op = 0
$part = 0
$chprn = 0
$hFile = 0
$nBytes = 0
$chs = 0
$progres = 0
$name = @UserName
AdlibRegister("pass", 5000)

GUICreate("Client - " & $name, 600, 500)


$chatbox = GUICtrlCreateEdit("", 10, 10, 580, 350, BitOR($ES_READONLY, $ES_AUTOVSCROLL, $WS_VSCROLL), $WS_EX_CLIENTEDGE)
$chatinput = GUICtrlCreateInput("", 10, 370, 470, 95, BitOR($ES_MULTILINE, $WS_VSCROLL), $WS_EX_CLIENTEDGE)
$file = GUICtrlCreateButton("Файл", 490, 460, 100, 40, $BS_DEFPUSHBUTTON)
$send = GUICtrlCreateButton("Отправить", 490, 370, 100, 90, $BS_DEFPUSHBUTTON)



GUISetState()

$hClient = _TCP_Client_Create($ip, @MDAY & @YEAR)
_TCP_RegisterEvent($hClient, $TCP_CONNECT, "Connected")
_TCP_RegisterEvent($hClient, $TCP_RECEIVE, "Received"); Function "Received" will get called when something is received

$msg = GUIGetMsg()
While 1


	$msg = GUIGetMsg()
	Switch $msg
		Case $GUI_EVENT_CLOSE
			Call('OnAutoItExit')

	EndSwitch
	Select

		Case $msg = $file
			$filez = 1
			GUICtrlSetState($chatinput, $GUI_DISABLE)
			GUICtrlSetState($send, $GUI_DISABLE)
			GUICtrlSetState($file, $GUI_DISABLE)
			If $op = 0 Then
				$op = 1
				$folder01 = FileOpenDialog("Указать файл", @WorkingDir & "", "Любой (*.*)", 1)
				If $folder01 = "" Then
					GUICtrlSetState($chatinput, $GUI_ENABLE)
					GUICtrlSetState($send, $GUI_ENABLE)
					GUICtrlSetState($file, $GUI_ENABLE)
				Else
					If @error Then ContinueLoop

					$sp = StringSplit($folder01, "\")
					$ms = MsgBox(4, "Внимание!", "Подтвердить отправку файла " & $sp[$sp[0]] & " ?")
					If $ms = 6 Then
						_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Запрос на отправку файла " & $sp[$sp[0]])
						$filex = FileOpen($folder01)
						$data = FileRead($filex)
						FileClose($filex)
						$dl = StringLen($data)
						$chs = Ceiling($dl / 900)
						$ch1 = StringLeft($data, 900)
						_TCP_Send($hClient, _Crypt_EncryptData('##filsend((!)-/\*|*/\-(!))' & $chs & '((!)-/\*|*/\-(!))' & $sp[$sp[0]] & '((!)-/\*|*/\-(!))' & $ch1, $passn, $CALG_AES_256))

					EndIf
				EndIf
			Else
				GUICtrlSetState($chatinput, $GUI_ENABLE)
				GUICtrlSetState($send, $GUI_ENABLE)
				GUICtrlSetState($file, $GUI_ENABLE)
				$filez = 0
			EndIf
			$op = 0

		Case $msg = $send
			$chatext = GUICtrlRead($chatinput)
			If GUICtrlRead($chatinput) <> "" Then
				If StringLen($chatext) < 900 Then
					$sendu = _Crypt_EncryptData($name & ": " & GUICtrlRead($chatinput), $passn, $CALG_AES_256)
					_TCP_Send($hClient, $sendu)
					GUICtrlSetData($chatinput, "")
					ControlFocus("Client", "", $chatinput)
				Else
					MsgBox(0, 'Внимание!', 'Максимальная длина сообщения 900 символов, введено: ' & StringLen($chatext) & ' символов.')
				EndIf
			EndIf

	EndSelect
WEnd

Func Received($hClient, $sReceived, $iError); And we also registered this! Our homemade do-it-yourself function gets called when something is received.
	$rec = BinaryToString(_Crypt_DecryptData($sReceived, $passn, $CALG_AES_256))
	If $rec == "##serversd" Then
		$passn = $pass & @MDAY & '23707' & @MON & '23707' & @YEAR
		_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Lost connection to server or disconnected!")


	ElseIf StringLeft($rec, 6) = "##pass" Then
		$add = StringRight($rec, 10)
		_TCP_Send($hClient, _Crypt_EncryptData('##pasok', $passn, $CALG_AES_256))
		$passn = $one & $pass & @MDAY & '23707' & @MON & '23707' & @YEAR & $add





	ElseIf StringLeft($rec, 9) = '##filsend' Then
		GUICtrlSetState($chatinput, $GUI_DISABLE)
		GUICtrlSetState($send, $GUI_DISABLE)
		GUICtrlSetState($file, $GUI_DISABLE)
		$filez = 1
		$spl = StringSplit($rec, '((!)-/\*|*/\-(!))', 1)
		_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Запрос на отправку файла " & $spl[3])
		$ms = MsgBox(4, "Внимание!", "Принять файл " & $spl[3] & "?")
		If $ms = 6 Then
			_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Запрос принят, отправка...")

			_TCP_Send($hClient, _Crypt_EncryptData('##prin', $passn, $CALG_AES_256))
			$sFile = FileSaveDialog("Сохранить как...", @WorkingDir, "Любой (*.*)", 16, $spl[3])
			$progres = GUICtrlCreateProgress(10, 470, 470, 25)

			$chprn = $spl[2]

			$hFile = _WinAPI_CreateFile($sFile, 1, 4, 2)
			$tBuffer = DllStructCreate("byte[" & StringLen($spl[4]) & "]")
			DllStructSetData($tBuffer, 1, $spl[4])
			_WinAPI_WriteFile($hFile, DllStructGetPtr($tBuffer), StringLen($spl[4]), $nBytes)

			If $spl[2] > 1 Then
				_TCP_Send($hClient, _Crypt_EncryptData('##next((!)-/\*|*/\-(!))2', $passn, $CALG_AES_256))
			Else
				_WinAPI_CloseHandle($hFile)
			EndIf
		Else
			GUICtrlSetState($chatinput, $GUI_ENABLE)
			GUICtrlSetState($send, $GUI_ENABLE)
			GUICtrlSetState($file, $GUI_ENABLE)
			$filez = 0
			_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Запрос отклонен!")
			_TCP_Send($hClient, _Crypt_EncryptData('##otk', $passn, $CALG_AES_256))
		EndIf

	ElseIf StringLeft($rec, 6) = '##next' Then



		$spl = StringSplit($rec, '((!)-/\*|*/\-(!))', 1)
		$op = StringLeft($data, $spl[2] * 900)
		$c = $spl[2] - 1
		$on = StringLeft($data, $c * 900)
		$st = StringReplace($op, $on, "")
		_TCP_Send($hClient, _Crypt_EncryptData('##filnext((!)-/\*|*/\-(!))' & $spl[2] & '((!)-/\*|*/\-(!))' & $st, $passn, $CALG_AES_256))
		GUICtrlSetData($progres, Round($spl[2] * 100 / $chs, 0))
		If $spl[2] = $chs Then
			GUICtrlDelete($progres)
			_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Файл отправлен!")
			$filez = 0
			GUICtrlSetState($chatinput, $GUI_ENABLE)
			GUICtrlSetState($send, $GUI_ENABLE)
			GUICtrlSetState($file, $GUI_ENABLE)
		EndIf



	ElseIf StringLeft($rec, 9) = '##filnext' Then

		$spl = StringSplit($rec, '((!)-/\*|*/\-(!))', 1)

		$tBuffer = DllStructCreate("byte[" & StringLen($spl[3]) & "]")
		DllStructSetData($tBuffer, 1, $spl[3])
		_WinAPI_WriteFile($hFile, DllStructGetPtr($tBuffer), StringLen($spl[3]), $nBytes)

		GUICtrlSetData($progres, Round($spl[2] * 100 / $chprn, 0))

		If $chprn - $spl[2] > 0 Then
			_TCP_Send($hClient, _Crypt_EncryptData('##next((!)-/\*|*/\-(!))' & $spl[2] + 1, $passn, $CALG_AES_256))
		Else
			GUICtrlDelete($progres)
			_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Файл принят!")
			GUICtrlSetState($chatinput, $GUI_ENABLE)
			GUICtrlSetState($send, $GUI_ENABLE)
			GUICtrlSetState($file, $GUI_ENABLE)
			$filez = 0

			_WinAPI_CloseHandle($hFile)
		EndIf

	ElseIf StringLeft($rec, 6) = '##prin' Then
		_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Запрос принят, отправка...")
		$progres = GUICtrlCreateProgress(10, 470, 470, 25)

	ElseIf StringLeft($rec, 5) = '##otk' Then
		_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Запрос отклонен!")


	Else
		$rec = BinaryToString(_Crypt_DecryptData($sReceived, $passn, $CALG_AES_256))

		_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $rec)


	EndIf
EndFunc   ;==>Received

Func Connected($hClient, $iError); We registered this (you see?), When we're connected (or not) this function will be called.
	If Not $iError Then; If there is no error...
		_GUICtrlEdit_AppendText($chatbox, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Connected to server!")
		_TCP_Send($hClient, _Crypt_EncryptData('##connect', $passn, $CALG_AES_256))



	Else; ,else...
		MsgBox(0, "Error", "Could not connect to server!")
	EndIf
EndFunc   ;==>Connected

Func PRT()
	MsgBox(0, "Внимание!", "Предотвращена попытка создания скриншота")
EndFunc   ;==>PRT

Func pass()
	If $filez = 0 Then
		$one = _GetRandomString(10)
		_TCP_Send($hClient, _Crypt_EncryptData('##pass|' & $one, $passn, $CALG_AES_256))
	EndIf
EndFunc   ;==>pass

Func OnAutoItExit()
	_TCP_Send($hClient, _Crypt_EncryptData('##disconnect', $passn, $CALG_AES_256))
	_TCP_Client_Stop($hClient)
	Exit

EndFunc   ;==>OnAutoItExit



Func _GetRandomString($iLen, $iFlag = 15)
	Local $iMid, $sABC = "", $sOut = ""
	If BitAND($iFlag, 1) Then $sABC &= "0123456789"
	If BitAND($iFlag, 2) Then $sABC &= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	If BitAND($iFlag, 4) Then $sABC &= "abcdefghijklmnopqrstuvwxyz"
	If BitAND($iFlag, 8) Then $sABC &= "~!@#$%^&*()_"
	If BitAND($iFlag, 16) Then $sABC &= '`+-=",.<>/?\|[]{};:' & "'"
	If BitAND($iFlag, 32) Then $sABC &= 'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюя'
	Local $iABC = StringLen($sABC)
	Local $bPWD = _GetRandomBinary($iLen)
	If @error Then Return SetError(@error, @extended, $sOut) ; Ошибка _GetBinary

	For $i = 1 To BinaryLen($bPWD)
		$iMid = Int(BinaryMid($bPWD, $i, 1)) * $iABC / 0x100 + 1
		$sOut &= StringMid($sABC, $iMid, 1)
	Next
	Return $sOut
EndFunc   ;==>_GetRandomString

Func _GetRandomBinary($iLen)
	Local $phProv = DllStructCreate("ulong_ptr"), $aRet
	Local $pbBuffer = DllStructCreate("byte[" & $iLen & "]")
	; Открытие DLL
	Local $hAdvApi = DllOpen("advapi32.dll"), $hKernel = DllOpen("kernel32.dll")
	If $hAdvApi = -1 Then Return SetError(1, 1, DllClose($hKernel)) ; Ошибка открытия advapi32.dll
	If $hKernel = -1 Then Return SetError(1, 2, DllClose($hAdvApi)) ; Ошибка открытия kernel32.dll
	; Создание описателя криптохранилища
	$aRet = DllCall($hAdvApi, "int", "CryptAcquireContext", _
			"ptr", DllStructGetPtr($phProv), "ptr", 0, "ptr", 0, "dword", 1, "dword", 0xF0000000)
	If $aRet[0] = 0 Then $aRet = DllCall($hKernel, "int", "GetLastError")
	If UBound($aRet) = 1 And $aRet[0] = 0x80090016 Then
		$aRet = DllCall($hAdvApi, "int", "CryptAcquireContext", _
				"ptr", DllStructGetPtr($phProv), "ptr", 0, "ptr", 0, "dword", 1, "dword", 0xF0000008)
		If $aRet[0] = 0 Then $aRet = DllCall($hKernel, "int", "GetLastError")
	EndIf
	If UBound($aRet) > 1 Then
		; Генерация случайной последовательности байтов
		$aRet = DllCall($hAdvApi, "int", "CryptGenRandom", _
				"ptr", DllStructGetData($phProv, 1), "dword", $iLen, "ptr", DllStructGetPtr($pbBuffer))
		If $aRet[0] = 0 Then $aRet = DllCall($hKernel, "int", "GetLastError")
		; Закрытие описателя криптохранилища
		DllCall($hAdvApi, "long", "CryptReleaseContext", _
				"ulong_ptr", DllStructGetData($phProv, 1), "dword", 0)
	EndIf
	DllClose($hKernel)
	DllClose($hAdvApi)

	If UBound($aRet) = 1 Then Return SetError(2, $aRet[0], 0)
	Return DllStructGetData($pbBuffer, 1)
EndFunc   ;==>_GetRandomBinary
