; ���� ������ - ������. ��������� ���� ������ ������, ����� ������� ������� ������� �� ������� ������� TCPRecv

Example()

Func Example()
    TCPStartup() ; ������ TCP �����.

    ; ����������� ������� OnAutoItExit ��� ��������� ����� ��� ���������� �������.
    OnAutoItExitRegister("OnAutoItExit")

    Local $iSocket, $sData
    ; ���������� $sIPAddress �� �����, ��� ������. �� ������� ��� ���������� IP-�����
    ;   Local $szServerPC = @ComputerName
    ;   Local $sIPAddress = TCPNameToIP($szServerPC)

    ; ��������� IP-������ � �����
    Local $sIPAddress = @IPAddress1
    Local $iPort = 33891 ; ����, ������������ ��� ����������.

    ; ���������� ������������� ������, ���������� IP-������ � �����.
    $iSocket = TCPConnect($sIPAddress, $iPort)

    If @error Then ; ���� ������, ��
        MsgBox(4112, "������", "������:" & @CRLF & "�� ������� ������������, @error = " & @error)
    Else
        ; ����������� ���� ������������� ������ ��� �������� �� ������
        While 1
            ; ������ ������ ��� ��������
            $sData = InputBox("������", @LF & @LF & "������� ������ ��� �������� �������")

            ; ������� ������ ��� �������� ������ �������, ����� ��������� ����������� ����
            If @error Or $sData = '' Then ExitLoop

            ; ���������� ����� ������ � $sData, ����� ������� �� ����� ������������ �����.
            ; ������������ �������� UTF-16 � UTF-8 � � �������� ������
            TCPSend($iSocket, StringToBinary($sData, 4))

            ; ���� ���������� ���� �������� ������ � @error, ��� ��������, ��� ����� ��������. �������������� ����� �� �����.
            If @error Then ExitLoop
        WEnd
    EndIf
EndFunc   ;==>Example

Func OnAutoItExit()
    TCPShutdown() ; ������������� TCP ������.
EndFunc   ;==>OnAutoItExit