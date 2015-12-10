Global $Box
;~ HotKeySet("{F1}", "_Start")
TCPStartup()
$g_Ip = InputBox("Medoc Checker", "Введите  IP - адрес")
$Socket = TCPConnect($g_Ip, 1200)
If @Error Then MsgBox(4096 + 16, "Клиент‚", "Сервер, вероятно, в офлайне, или порт не открыт на сервере, @error = " & @Error)
If $Socket = -1 Then
	Exit
Else
	$sMainWindow = InputBox("Список ф-й:", "1 - посмотреть версию" & @CRLF & "2 - обновить")
	$Msg = TCPSend($Socket, $sMainWindow)
EndIf

While 1
	Sleep(100)
WEnd

TCPCloseSocket($Socket)
TCPShutdown()

Func _Start()
	$Box = InputBox("Введите программу", "Введите название программы")
	If ShellExecute($Box) <> 1 Then
		MsgBox(1, "", "Ошибка запуска программы !")
	EndIf
EndFunc

