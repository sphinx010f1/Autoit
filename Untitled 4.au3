Example1()
Example2()

; Пример 1
Func Example1()
    ; Простой скрипт с тремя пользовательскими функциями,
    ; Обратите внимание на переменные, а также ByRef и Return

    Local $foo = 2
    Local $bar = 5
    MsgBox(0, "Сегодня " & today(), "Значение $foo равно " & $foo)
    Swap($foo, $bar)
    MsgBox(0, "После того, как $foo и $bar поменялись местами", "$foo теперь равно " & $foo)
    MsgBox(4096, "И наконец", "Большим из чисел 3 и 4 является " & Max(3, 4) & " :)")
EndFunc

Func swap(ByRef $a, ByRef $b) ;меняет местами значения двух переменных
    Local $t
    $t = $a
    $a = $b
    $b = $t
EndFunc

Func today() ; Возвращает сегодняшнюю дату в форме дд.мм.гггг
    Return (@MDAY & "." & @MON & "." & @YEAR)
EndFunc

Func max($x, $y) ; Возвращает большее из двух чисел
    If $x > $y Then
        Return $x
    Else
        Return $y
    EndIf
EndFunc

; Конец примера 1

; Пример 2
Func Example2()
    ; Простой скрипт с использованием макроса @NumParams
    Test_Numparams(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
EndFunc

Func Test_Numparams($v1 = 0, $v2 = 0, $v3 = 0, $v4 = 0, $v5 = 0, $v6 = 0, $v7 = 0, $v8 = 0, $v9 = 0, _
        $v10 = 0, $v11 = 0, $v12 = 0, $v13 = 0, $v14 = 0, $v15 = 0, $v16 = 0, $v17 = 0, $v18 = 0, $v19 = 0)
    #forceref $v1, $v2, $v3, $v4, $v5, $v6, $v7, $v8, $v9, $v10, $v11, $v12, $v13, $v14, $v15, $v16, $v17, $v18, $v19
    Local $val
    For $i = 1 To @NumParams
        $val &= Eval("v" & $i) & " "
    Next
    MsgBox(0, "Пример с @NumParams", "@NumParams =" & @NumParams & @CRLF & @CRLF & $val)
EndFunc

; Конец примера 2