Opt("TrayIconDebug", 1)
Opt("WinTitleMatchMode", 2)
Opt("TCPTimeout", 300)
Opt("GUICloseOnESC", 0)

#include <GUIRichEdit.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>

$proj = "Tet-a-Tet"

$hSW = GuiCreate("Tet-a-Tet", 200, 200)
GUISetIcon(@SystemDir & "\notepad.exe")

$tab = GUICtrlCreateTab(0, 0, 200, 200)

$tabMain = GUICtrlCreateTabItem("Main")

    $radioCl = GUICtrlCreateRadio("Client", 10, 30, 50)
    GUICtrlSetState($radioCl, $GUI_CHECKED)
    $radioSv = GUICtrlCreateRadio("Server", 70, 30, 50)

    $label_1 = GUICtrlCreateLabel("Enter your nickname:", 10, 55, 180, 17)
    $inputName = GuiCtrlCreateInput("user_" & Round(Random(999)), 10, 75, 180, 21)
    GUICtrlSetLimit($inputName, 24)

    $label_2 = GUICtrlCreateLabel("Enter server IP-address", 10, 105, 120, 17)
    $inputIp = GuiCtrlCreateInput("", 10, 125, 110, 21)
    GUICtrlSetLimit($inputIp, 15)

    $label_3 = GUICtrlCreateLabel("port", 150, 105, 40, 17)
    $inputPort = GuiCtrlCreateInput("8462", 130, 125, 60, 21)
    GUICtrlSetLimit($inputPort, 8)

    $buttConnect = GUICtrlCreateButton("Connect", 50, 160, 100, 30, $BS_DEFPUSHBUTTON + $BS_FLAT)

$ab = GUICtrlCreateTabItem("About")

GUICtrlCreateTabitem("")

$hCW = GUICreate("Tet-a-Tet - Client", 1000, 600, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_SYSMENU))
GUISetIcon(@SystemDir & "\notepad.exe")
GUISetFont(15, 800, 0, "Courier New")

$inputStr = GUICtrlCreateInput("", 5, 570, 900, 27)
GUICtrlSetLimit($inputStr, 64)

$buttSend = GUICtrlCreateButton("Send", 910, 570, 85, 27, $BS_DEFPUSHBUTTON + $BS_FLAT)

$editOut = 0
$socket = -1

GUISetState(@SW_SHOW, $hSW)

While 1
    $msg = GUIGetMsg()
    Select
        Case $msg = -3
            TCPShutdown()
            Exit
        Case $msg = $radioSv
            GUICtrlSetState($label_2, $GUI_DISABLE)
            GUICtrlSetState($inputIp, $GUI_DISABLE)
            GUICtrlSetData($buttConnect, "Start")
            WinSetTitle("Tet-a-Tet - Client", "", "Tet-a-Tet - Server")
        Case $msg = $radioCl
            GUICtrlSetState($label_2, $GUI_ENABLE)
            GUICtrlSetState($inputIp, $GUI_ENABLE)
            GUICtrlSetData($buttConnect, "Connect")
            WinSetTitle("Tet-a-Tet - Server", "", "Tet-a-Tet - Client")
        Case $msg = $buttConnect And GUICtrlRead($radioSv) = 1          ; старт сервера
            $sNick = GUICtrlRead($inputName)
            $sPort = GUICtrlRead($inputPort)
                If $sNick = "" Or $sPort = "" Then
                    GUISetState(@SW_DISABLE, $hSW)
                    MsgBox(0x40000, "Error", "Fill empty fields")
                    GUISetState(@SW_ENABLE, $hSW)
                Else                                                    ; создание сокета
                    _editOut_create()
                    GUISetState(@SW_SHOW, $hCW)
                    GUISetState(@SW_HIDE, $hSW)
                    GUICtrlSetState($inputStr, $GUI_DISABLE)
                    GUICtrlSetState($buttSend, $GUI_DISABLE)
                    TCPStartup()
                    _GUICtrlRichEdit_AppendText($editOut, "Starting server...")
                    $count = 1
                    Sleep(1000)
                    $startSocket = TCPListen(@IPAddress1, $sPort)
                    While $startSocket = -1                             ; повторное создание сокета
                        $count += 1
                        If $count = 11 Then                             ; после 10 неаудачных попыток - выход
                            _GUICtrlRichEdit_AppendText($editOut, @CRLF & "All attempts not succesfuls" & @CRLF & "Quit...")
                            Sleep(2500)
                            _exit_CW()
                            ExitLoop
                        EndIf
                        _GUICtrlRichEdit_AppendText($editOut, ".")
                        Sleep(1000)
                        TCPCloseSocket($startSocket)
                        Sleep(500)
                        $startSocket = TCPListen(@IPAddress1, $sPort)
                        Sleep(500)
                    WEnd
                    If $startSocket <> -1 Then                          ; ожидание входящих подключений
                        Opt("GUIOnEventMode", 1)
                        _GUICtrlRichEdit_AppendText($editOut, @CRLF & "Server succesfuly running!" & @CRLF & "Waiting incoming connections press [Ctrl-Z] for canceling... ")
                        Sleep(1000)
                        $abort = 0
                        GUISetOnEvent("-3", "_exit_CW", $hCW)
                        HotKeySet("^z", "_exit_CW")
                            Do                                          ; ожидание входящих подключений в цикле
                                If $abort = 1 Then ExitLoop             ; выход по команде пользователя
                                _GUICtrlRichEdit_AppendText($editOut, ".")
                                $socket = TCPAccept($startSocket)
                                Sleep(1000)
                            Until $socket <> -1
                        HotKeySet("^z")
                        If $abort = 0 Then                              ; клиент присоединился, получаем его Ник и IP-адрес
                            Do
                                If $abort = 1 Then ExitLoop                     ; выход по команде пользователя
                                If $socket = -1 Then
                                    _GUICtrlRichEdit_AppendText($editOut, @CRLF & "Connection lost")
                                    Sleep(2500)
                                    GUISetState(@SW_SHOW, $hSW)
                                    GUISetState(@SW_HIDE, $hCW)
                                    _GUICtrlRichEdit_Destroy($editOut)
                                    TCPShutdown()
                                    ExitLoop
                                EndIf
                                $sClNick_IP = TCPRecv($socket, 54)
                                Sleep(100)
                            Until StringLen($sClNick_IP) >= 1
                            $aClNick_IP = StringSplit($sClNick_IP, "###$$$000uuu@@@", 1)
                            $sNick2 = $aClNick_IP[1]
                            $sIP2 = $aClNick_IP[2]
                            If $sNick2 = $sNick Then $sNick2 = $sNick2 & "_1" ; если ники сервера и клиента совпадают - переименовываем клиентский
                            If $sNick2 <> "" Then               ; при получении ника соединение оборвалось
                                _GUICtrlRichEdit_AppendText($editOut, @CRLF & "Client [" & $sNick2 & "] connected from IP [" & $sIP2 & "]")
                                TCPSend($socket, $sNick)                    ; передаем свой ник
                                GUICtrlSetState($inputStr, $GUI_ENABLE)
                                GUICtrlSetState($buttSend, $GUI_ENABLE)
                                Opt("GUIOnEventMode", 1)
                                GUISetOnEvent("-3", "_exit_CW", $hCW)
                                GUICtrlSetOnEvent($buttSend, "_send_message")
                                While $socket <> -1                     ; пока есть соединение - отправляем/принимаем сообщения
                                    If $abort = 1 Then  ExitLoop        ; выход по команде пользователя
                                    Sleep(25)
                                    $sIn = TCPRecv($socket, 64)
                                    If StringLen($sIn) >=1 And $sIn = "###$$$000uuu@@@" Then ; получена команда завершения соедининия от клиента
                                        _GUICtrlRichEdit_AppendText($editOut, @CRLF & "Connection closed by " & $sNick2)
                                        Sleep(2500)
                                        GUISetState(@SW_SHOW, $hSW)
                                        GUISetState(@SW_HIDE, $hCW)
                                        _GUICtrlRichEdit_Destroy($editOut)
                                        TCPShutdown()
                                        ExitLoop
                                    ElseIf StringLen($sIn) <> 0 Then    ; отображение сообщения клиента
                                        _GUICtrlRichEdit_AppendText($editOut, @CRLF & $sNick2 & " << " & $sIn)
                                    EndIf
                                WEnd
                            EndIf
                        EndIf
                        Opt("GUIOnEventMode", 0)
                    EndIf
                EndIf
        Case $msg = $buttConnect And GUICtrlRead($radioCl) = 1          ; запуск клиента
            $sNick = GUICtrlRead($inputName)
            $ip = GUICtrlRead($inputIp)
            $sPort = GUICtrlRead($inputPort)
            If $ip = "" Or $sNick = "" Or $sPort = "" Then
                GUISetState(@SW_DISABLE, $hSW)
                MsgBox(0x40000, "Error", "Fill empty fields")
                GUISetState(@SW_ENABLE, $hSW)
            ElseIf _IsIP($ip) <> 1 Then                                 ; проверка синтаксиса строки адреса сервера
                GUISetState(@SW_DISABLE, $hSW)
                MsgBox(0x40000, "Syntax Error", "IP-Address incorrect")
                GUISetState(@SW_ENABLE, $hSW)
            Else                                                        ; соединение с сервером
                Opt("GUIOnEventMode", 1)
                _editOut_create()
                GUISetState(@SW_SHOW, $hCW)
                GUISetState(@SW_HIDE, $hSW)
                GUICtrlSetState($inputStr, $GUI_DISABLE)
                GUICtrlSetState($buttSend, $GUI_DISABLE)
                TCPStartup()
                _GUICtrlRichEdit_AppendText($editOut, "Connecting to server [" & $ip & "] press [Ctrl-Z] for canceling... ")
                Sleep(1000)
                $abort = 0
                GUISetOnEvent("-3", "_exit_CW", $hCW)
                HotKeySet("^z", "_exit_CW")
                    Do                                                  ; попытки соединения с сервером в цикле
                        If $abort = 1 Then ExitLoop                     ; выход по команде пользователя
                        _GUICtrlRichEdit_AppendText($editOut, ".")
                        $socket = TCPConnect($ip, $sPort)
                        Sleep(1000)
                    Until $socket <> -1
                HotKeySet("^z")
                If $abort = 0 Then                                      ; после соединения передаем ник клиента и его IP-адрес на сервер, с использованием разделителя (=
                    TCPSend($socket, $sNick & "###$$$000uuu@@@" & @IPAddress1)
                    Do                                                  ; ждем получения ника сервера
                        If $abort = 1 Then  ExitLoop                    ; выход по команде пользователя
                        If $socket = -1 Then
                            _GUICtrlRichEdit_AppendText($editOut, @CRLF & "Connection lost")
                            Sleep(2500)
                            GUISetState(@SW_SHOW, $hSW)
                            GUISetState(@SW_HIDE, $hCW)
                            _GUICtrlRichEdit_Destroy($editOut)
                            TCPShutdown()
                            ExitLoop
                        EndIf
                        $sSvNick = TCPRecv($socket, 24)
                        Sleep(100)
                    Until StringLen($sSvNick) >= 1
                    If $sSvNick = $sNick Then $sSvNick = $sSvNick & "_1" ; если ники сервера и клиента совпадают - переименовываем серверный
                    If $sSvNick <> "" Then                              ; при получении ника соединение оборвалось
                        _GUICtrlRichEdit_AppendText($editOut, @CRLF & "Successful join with server [" & $ip & "], now on server - [" & $sSvNick & "]")
                        GUICtrlSetState($inputStr, $GUI_ENABLE)
                        GUICtrlSetState($buttSend, $GUI_ENABLE)
                        GUICtrlSetOnEvent($buttSend, "_send_message")
                        While $socket <> -1                             ; пока есть соединение - отправляем/принимаем сообщения
                            If $abort = 1 Then  ExitLoop                ; выход по команде пользователя
                            Sleep(250)
                            $sIn = TCPRecv($socket, 64)
                            If StringLen($sIn) >=1 And $sIn = "###$$$000uuu@@@" Then ; получена команда завершения соедининия от клиента
                                _GUICtrlRichEdit_AppendText($editOut, @CRLF & "Connection closed by " & $sSvNick)
                                Sleep(2500)
                                GUISetState(@SW_SHOW, $hSW)
                                GUISetState(@SW_HIDE, $hCW)
                                _GUICtrlRichEdit_Destroy($editOut)
                                TCPShutdown()
                                ExitLoop
                            ElseIf StringLen($sIn) <> 0 Then            ; отображение сообщения сервера
                                _GUICtrlRichEdit_AppendText($editOut, @CRLF & $sSvNick & " << " & $sIn)
                            EndIf
                        WEnd
                    EndIf
                EndIf
                Opt("GUIOnEventMode", 0)
            EndIf
        Case $msg = $tab
            If GUICtrlRead($tab) = 1 Then
                GUICtrlSetState($tabMain, $GUI_SHOW)
                _about($proj)
            EndIf
    EndSelect
WEnd

Func _editOut_create()
    $editOut = _GUICtrlRichEdit_Create($hCW, "", 5, 5, 990, 560, BitOR($ES_AUTOVSCROLL, $WS_VSCROLL, $ES_READONLY, $ES_MULTILINE))
    _GUICtrlRichEdit_SetBkColor($editOut, 0x000000)
    _GUICtrlRichEdit_SetFont($editOut, 15, "Courier New")
    _GUICtrlRichEdit_SetCharAttributes($editOut, "+bo")
    _GUICtrlRichEdit_SetCharColor($editOut, 0xFFFFFF)
EndFunc ;==>_editOut_create

Func _exit_CW()
    If $socket <> -1 Then TCPSend($socket, "###$$$000uuu@@@")
    _GUICtrlRichEdit_AppendText($editOut, @CRLF & "Session is interrupted by user" & @CRLF & "Quit...")
    Sleep(1000)
    GUISetState(@SW_SHOW, $hSW)
    GUISetState(@SW_HIDE, $hCW)
    _GUICtrlRichEdit_Destroy($editOut)
    TCPShutdown()
    HotKeySet("^z")
    $abort = 1
EndFunc ;==>_exit_CW

Func _IsIP($ip)
    $aOctet = StringSplit($ip, ".")
    If StringRegExp($ip, "(\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z)") = 0 Then
        Return 0
    ElseIf $aOctet[1] = 0 Or $aOctet[1] > 255 Or $aOctet[2] > 255 Or $aOctet[3] > 255 Or $aOctet[4] > 255 Then
        Return -1
    Else
        Return 1
    EndIf
EndFunc ;==>_IsIP

Func _send_message()
    $sMess = GUICtrlRead($inputStr)
    If $sMess = "###$$$000uuu@@@" Then
        $sMess = "I am a stupid idiot - try to use bug"
        TCPSend($socket, $sMess)
        GUICtrlSetData($inputStr, "")
        _GUICtrlRichEdit_AppendText($editOut, @CRLF & $sNick & " >> " & $sMess)
    ElseIf Not $sMess = "" Then
        TCPSend($socket, $sMess)
        GUICtrlSetData($inputStr, "")
        _GUICtrlRichEdit_AppendText($editOut,  @CRLF & $sNick & " >> " & $sMess)
    EndIf
EndFunc ;==>_send_message

Func _about($proj)
    $coord = WinGetPos($proj)
    WinSetState($hSW, "", @SW_DISABLE)
    $email = "mail@mail.ru"
    $aboutGui = GUICreate("About " & $proj, 300, 120, $coord[0] - ((300 - $coord[2])/2) - 4, $coord[1] - ((120 - $coord[3])/2) - 11, -1, $WS_EX_TOOLWINDOW, $hSW)
    $mail = GUICtrlCreateLabel($email, 212, 102, 85, 15, $SS_RIGHT)
    GUICtrlSetFont($mail, -1, 400, 4)
    GUICtrlSetColor($mail, 0x000FF)
    GUICtrlSetCursor($mail, 0)
    $drag = GUICtrlCreatePic("", 0, 0, 300, 120, -1, $GUI_WS_EX_PARENTDRAG)
    $prog_nm = GUICtrlCreateLabel($proj, 35, 42, 230, 25, $SS_CENTER)
    GUICtrlSetFont($prog_nm, 11, 800)
    GUICtrlCreateGroup("", 25, 20, 250, 58)
    $copy = GUICtrlCreateLabel("Copyright © " & @YEAR & " redline", 5, 102, 140, 15, $SS_LEFT)
    GUICtrlSetState($copy, 128)
    GUISetState(@SW_SHOW, $aboutGui)
    While 1
        $msg = GUIGetMsg($aboutGui)
        Select
            Case $msg = -3
                ExitLoop
            Case $msg = $mail
                ShellExecute("mailto:" & $email)
        EndSelect
    WEnd
    WinSetState($hSW, "", @SW_ENABLE)
    GUIDelete($aboutGui)
EndFunc ;==>_about
 
