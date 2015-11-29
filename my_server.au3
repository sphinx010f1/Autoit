#Include <process.au3>
#Region ; ���������� ����������
Global $sIPAddress = @IPAddress1
Global $iListenPort = 33891
Global $iConnectPort = 33892
;~ Global $s
Global $iListenSocket, $iConnectSocket, $iEdit, $iSocket, $szIP_Accepted
Global $msg, $sData
#EndRegion

Opt("TrayIconHide", 1)
TCPStartup() ; ������ TCP �����.

; ����������� ������� OnAutoItExit ��� ��������� ����� ��� ���������� �������.
OnAutoItExitRegister("OnAutoItExit")

; ������� ����� ��������� � ��������� IP-������� � ������
$iListenSocket = TCPListen($sIPAddress, $iListenPort)


; ���� �� ������� ������� �����, �� �����
If @error Then Return MsgBox(4096 + 16, "", "������:" & @CRLF & "�� ������� ���������� �����, @error = " & @error)


While 1
    $socket = TCPListen($sIPAddress, $iPort, 100);������� ��������� �����, �� ���������� ������
    If @error Then ExitLoop;���� �� ������� ������� �����, �� �����
    $Connect = -1
    Do
        $Connect = TCPAccept($socket);���������� �� ������� ����� ���� ��������� �������� ����������� � �������������� ������
    Until $Connect <> -1;���� ������ �����������, �� ����� �� �����, ���� ������ ��� ����� �� �����������, �� ���������� ����

     While 100
        $dannie = TCPRecv($Connect, 2048);�������� �������� 2048 �������� �� �������

        Select
        case $dannie = "Exit"
            Exit
        case $dannie = ""

;~             ShellExecute($dannie)
            ContinueLoop
        EndSelect

        If @error Then ExitLoop;���� �� ������� �������� �������, �� ����� �� �����
       WEnd
Wend

Func OnAutoItExit()
	TCPCloseSocket($socket);��������� �����
    TCPShutdown() ; ������������� TCP ������.
EndFunc   ;==>OnAutoItExit