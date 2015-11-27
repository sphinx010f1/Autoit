Global $Box
;~ HotKeySet("{F1}", "_Start")
TCPStartUp()
$g_IP = InputBox("¬ведите  IP - адрес","¬ведите  IP - адрес")
$socket = TCPConnect( $g_IP, 1200 )
;~ $msg = TCPSend($socket, $Box)

If $socket = -1 Then
    Exit
Else
    $sMainWindow = InputBox("—писок ф-й:", "1 - проверить версию" & @CRLF & "2 - обновить")
	$msg = TCPSend($socket, $sMainWindow)

EndIf

while 1
          Sleep(100)
WEnd

TCPCloseSocket($socket)
TCPShutdown()
