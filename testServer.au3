#include <GUIConstantsEx.au3>

; ���� ������ - ������. ��������� ��� ������ ������, ����� ��� ��� ��������� ������ ������� �� ������� ������� TCPSend

Example()

Func Example()
    ; ������������� IP-����� (@IPAddress1).
    ;   Local $szServerPC = @ComputerName
    ;   Local $sIPAddress = TCPNameToIP($szServerPC)
    Local $sIPAddress = @IPAddress1
    Local $iPort = 33891
    Local $iListenSocket, $iEdit, $iSocket, $szIP_Accepted
    Local $msg, $sData

    TCPStartup() ; ������ TCP �����.

    ; ����������� ������� OnAutoItExit ��� ��������� ����� ��� ���������� �������.
    OnAutoItExitRegister("OnAutoItExit")

    ; ������� ����� ��������� � ��������� IP-������� � ������
    $iListenSocket = TCPListen($sIPAddress, $iPort)

    ; ���� �� ������� ������� �����, �� �����
    If @error Then Return MsgBox(4096 + 16, "", "������:" & @CRLF & "�� ������� ���������� �����, @error = " & @error)

    ; ������� GUI ��� ������ ���������
    $hGui = GUICreate("������ (" & $sIPAddress & ")", 300, 200, 100, 100)
    $iEdit = GUICtrlCreateEdit("", 10, 10, 280, 180)
    GUISetState()

    ; �������� � ���� ����������
    Do
        $iSocket = TCPAccept($iListenSocket)
        If @error Then Return MsgBox(4096 + 16, "", "������:" & @CRLF & "�� ������� ������� �������� ����������, @error = " & @error, 0, $hGui)
    Until $iSocket <> -1

    ; �������� IP ��������������� �������
    $szIP_Accepted = SocketToIP($iSocket)

    While 1 ; ���� ��������� GUI
        If GUIGetMsg() = $GUI_EVENT_CLOSE Then ExitLoop

        ; ������� �������� (��) 2048 ����
        $sData = TCPRecv($iSocket, 2048)

        ; ���� ���������� ������ @error, ��� ��������, ��� ����� ��������. �������������� ����� �� �����.
        If @error Then ExitLoop

        ; ������������ �������� ������ �� UTF-8 � �������� UTF-16
        $sData = BinaryToString($sData, 4)

        ; ��������� ���� ����� ��������� ����������� �������
        If $sData Then GUICtrlSetData($iEdit, _
                $szIP_Accepted & " > " & $sData & @CRLF & GUICtrlRead($iEdit))
    WEnd

    If $iSocket <> -1 Then TCPCloseSocket($iSocket)
EndFunc   ;==>Example

; ������� ���������� IP-����� ������������� ������.
Func SocketToIP($iSocket)
    Local $tSockAddr, $aRet
    $tSockAddr = DllStructCreate("short;ushort;uint;char[8]")
    $aRet = DllCall("Ws2_32.dll", "int", "getpeername", "int", $iSocket, "ptr", DllStructGetPtr($tSockAddr), "int*", DllStructGetSize($tSockAddr))
    If Not @error And $aRet[0] = 0 Then
        $aRet = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($tSockAddr, 3))
        If Not @error Then Return $aRet[0]
    EndIf
    Return 0
EndFunc   ;==>SocketToIP

Func OnAutoItExit()
    TCPShutdown() ; ������������� TCP ������.
EndFunc   ;==>OnAutoItExit