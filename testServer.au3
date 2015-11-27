#include <GUIConstantsEx.au3>

; Этот скрипт - сервер. Запустите это скрипт первым, перед тем как запустить скрипт клиента из примера функции TCPSend

Example()

Func Example()
    ; Устанавливает IP-адрес (@IPAddress1).
    ;   Local $szServerPC = @ComputerName
    ;   Local $sIPAddress = TCPNameToIP($szServerPC)
    Local $sIPAddress = @IPAddress1
    Local $iPort = 33891
    Local $iListenSocket, $iEdit, $iSocket, $szIP_Accepted
    Local $msg, $sData

    TCPStartup() ; Запуск TCP служб.

    ; Регистрация функции OnAutoItExit для остановки служб при завершении скрипта.
    OnAutoItExitRegister("OnAutoItExit")

    ; Создает сокет связанный с указанным IP-адресом и портом
    $iListenSocket = TCPListen($sIPAddress, $iPort)

    ; Если не удалось создать сокет, то выход
    If @error Then Return MsgBox(4096 + 16, "", "Сервер:" & @CRLF & "Не удалось прослушать сокет, @error = " & @error)

    ; Создает GUI для вывода сообщений
    $hGui = GUICreate("Сервер (" & $sIPAddress & ")", 300, 200, 100, 100)
    $iEdit = GUICtrlCreateEdit("", 10, 10, 280, 180)
    GUISetState()

    ; Ожидание и приём соединения
    Do
        $iSocket = TCPAccept($iListenSocket)
        If @error Then Return MsgBox(4096 + 16, "", "Сервер:" & @CRLF & "Не удалось принять входящее соединение, @error = " & @error, 0, $hGui)
    Until $iSocket <> -1

    ; Получает IP подключившегося клиента
    $szIP_Accepted = SocketToIP($iSocket)

    While 1 ; Цикл сообщений GUI
        If GUIGetMsg() = $GUI_EVENT_CLOSE Then ExitLoop

        ; Попытка получить (до) 2048 байт
        $sData = TCPRecv($iSocket, 2048)

        ; Если возвращает ошибку @error, это означает, что сокет отключен. Соответственно выход из цикла.
        If @error Then ExitLoop

        ; Конвертирует бинарные данные из UTF-8 в нативный UTF-16
        $sData = BinaryToString($sData, 4)

        ; Обновляет окно приёма сообщений полученными данными
        If $sData Then GUICtrlSetData($iEdit, _
                $szIP_Accepted & " > " & $sData & @CRLF & GUICtrlRead($iEdit))
    WEnd

    If $iSocket <> -1 Then TCPCloseSocket($iSocket)
EndFunc   ;==>Example

; Функция возвращает IP-адрес подключенного сокета.
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
    TCPShutdown() ; Останавливает TCP службу.
EndFunc   ;==>OnAutoItExit