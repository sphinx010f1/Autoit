Global $Box
;~ HotKeySet("{F1}", "_Start")
TCPStartup()
$g_Ip = InputBox("Medoc Checker", "�������  IP - �����")
$Socket = TCPConnect($g_Ip, 1200)
If @Error Then MsgBox(4096 + 16, "������", "������, ��������, � �������, ��� ���� �� ������ �� �������, @error = " & @Error)
If $Socket = -1 Then
	Exit
Else
	$sMainWindow = InputBox("������ �-�:", "1 - ���������� ������" & @CRLF & "2 - ��������")
	$Msg = TCPSend($Socket, $sMainWindow)
EndIf

While 1
	Sleep(100)
WEnd

TCPCloseSocket($Socket)
TCPShutdown()

Func _Start()
	$Box = InputBox("������� ���������", "������� �������� ���������")
	If ShellExecute($Box) <> 1 Then
		MsgBox(1, "", "������ ������� ��������� !")
	EndIf
EndFunc

