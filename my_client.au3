Global $Box
;~ HotKeySet("{F1}", "_Start")
TCPStartup()
$g_IP = InputBox("Medoc Checker", "")
$socket = TCPConnect($g_IP, 1200)
If @Error Then 
	; Сервер, вероятно, в офлайне, или порт не открыт на сервере.
	MsgBox(4096 + 16, "Клиент", "Не удалось подключиться, @error = " & @Error)
	Return False
	
	If $socket = -1 Then
		Exit
	Else
		$sMainWindow = InputBox("пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ-пїЅ:", "1 - пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ" & @CRLF & "2 - пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ")
		$msg = TCPSend($socket, $sMainWindow)
		
	EndIf
	
	While 1
		Sleep(100)
	WEnd
	
	TCPCloseSocket($socket)
	TCPShutdown()
	
