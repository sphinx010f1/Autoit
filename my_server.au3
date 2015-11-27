#Include <process.au3>
#Region ; глобальные переманные
Global $sIPAddress = @IPAddress1
Global $iListenPort = 33891
Global $iConnectPort = 33892
;~ Global $s
Global $iListenSocket, $iConnectSocket, $iEdit, $iSocket, $szIP_Accepted
Global $msg, $sData
#EndRegion

Opt("TrayIconHide", 1)
TCPStartup() ; Запуск TCP служб.

; Регистрация функции OnAutoItExit для остановки служб при завершении скрипта.
OnAutoItExitRegister("OnAutoItExit")

; Создает сокет связанный с указанным IP-адресом и портом
$iListenSocket = TCPListen($sIPAddress, $iListenPort)


; Если не удалось создать сокет, то выход
If @error Then Return MsgBox(4096 + 16, "", "Сервер:" & @CRLF & "Не удалось прослушать сокет, @error = " & @error)


While 1
    $socket = TCPListen($sIPAddress, $iPort, 100);Создаем слушающий сокет, по указанному адресу
    If @error Then ExitLoop;Если не удалось создать сокет, то выйти
    $Connect = -1
    Do
        $Connect = TCPAccept($socket);Указыываем ОС создать сокет если появилось входящее подключение в прослушиваемом сокете
    Until $Connect <> -1;Если клиент подключился, то выйти из цикла, если ошибка или никто не подключился, то продолжить цикл

     While 100
        $dannie = TCPRecv($Connect, 2048);Получаем максимум 2048 символов от клиента

        Select
        case $dannie = "Exit"
            Exit
        case $dannie = ""

;~             ShellExecute($dannie)
            ContinueLoop
        EndSelect

        If @error Then ExitLoop;Если не удалось получить символы, то выйти из цикла
       WEnd
Wend

Func OnAutoItExit()
	TCPCloseSocket($socket);Закрываем сокет
    TCPShutdown() ; Останавливает TCP службу.
EndFunc   ;==>OnAutoItExit
