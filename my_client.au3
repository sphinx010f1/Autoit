Global $Box
;~ HotKeySet("{F1}", "_Start")
TCPStartup()
$g_IP = InputBox("Medoc Checker", "")
$socket = TCPConnect($g_IP, 1200)
If @Error Then 
	; ������, ��������, � �������, ��� ���� �� ������ �� �������.
	MsgBox(4096 + 16, "������", "�� ������� ������������, @error = " & @Error)
	Return False
	
	If $socket = -1 Then
		Exit
	Else
		$sMainWindow = InputBox("������ �-�:", "1 - ��������� ������" & @CRLF & "2 - ��������")
		$msg = TCPSend($socket, $sMainWindow)
		
	EndIf
	
	While 1
		Sleep(100)
	WEnd
	
	TCPCloseSocket($socket)
	TCPShutdown()
	
