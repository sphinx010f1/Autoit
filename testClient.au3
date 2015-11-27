; Этот скрипт - клиент. Запустите этот скрипт вторым, после запуска скрипта сервера из примера функции TCPRecv

Example()

Func Example()
    TCPStartup() ; Запуск TCP служб.

    ; Регистрация функции OnAutoItExit для остановки служб при завершении скрипта.
    OnAutoItExitRegister("OnAutoItExit")

    Local $iSocket, $sData
    ; Установить $sIPAddress на такой, где сервер. Мы изменим имя компьютера IP-адрес
    ;   Local $szServerPC = @ComputerName
    ;   Local $sIPAddress = TCPNameToIP($szServerPC)

    ; Установка IP-адреса и порта
    Local $sIPAddress = @IPAddress1
    Local $iPort = 33891 ; Порт, используемый для соединения.

    ; Подключает прослушивание сокета, указанного IP-адреса и порта.
    $iSocket = TCPConnect($sIPAddress, $iPort)

    If @error Then ; Если ошибка, то
        MsgBox(4112, "Ошибка", "Клиент:" & @CRLF & "Не удалось подключиться, @error = " & @error)
    Else
        ; Бесконечный цикл запрашивающий данные для отправки на сервер
        While 1
            ; Запрос данных для передачи
            $sData = InputBox("Клиент", @LF & @LF & "Введите данные для передачи серверу")

            ; Нажмите отмену или оставьте данные пустыми, чтобы завершить бесконечный цикл
            If @error Or $sData = '' Then ExitLoop

            ; Необходимо иметь данные в $sData, чтобы выслать их через подключенный сокет.
            ; Конвертирует нативный UTF-16 в UTF-8 и в бинарные данные
            TCPSend($iSocket, StringToBinary($sData, 4))

            ; Если происходит сбой отправки данных с @error, это означает, что сокет отключен. Соответственно выход из цикла.
            If @error Then ExitLoop
        WEnd
    EndIf
EndFunc   ;==>Example

Func OnAutoItExit()
    TCPShutdown() ; Останавливает TCP службу.
EndFunc   ;==>OnAutoItExit