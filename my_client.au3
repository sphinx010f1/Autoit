Global $Box
;~ HotKeySet("{F1}", "_Start")
TCPStartUp()
$g_IP = InputBox("�������  IP - �����","�������  IP - �����")
$socket = TCPConnect( $g_IP, 1200 )
;~ $msg = TCPSend($socket, $Box)

If $socket = -1 Then
    Exit
Else
    $sMainWindow = InputBox("������ �-�:", "1 - ��������� ������" & @CRLF & "2 - ��������")
	$msg = TCPSend($socket, $sMainWindow)

EndIf

while 1
          Sleep(100)
WEnd

TCPCloseSocket($socket)
TCPShutdown()
