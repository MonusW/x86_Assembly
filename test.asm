;---------------------------------
;
; program test
;
;---------------------------------

assume cs:codesg, ds:datasg, ss:stacksg

stacksg segment stack
    db 128 dup(0)
stacksg ends

datasg segment
    num_1       db 0, '*'              ; 第一个乘数
    num_2       db 0, '='              ; 第二个乘数
    result      db 0, 0                ; 乘法结果
    key_tap     db '    ', '$'         ; 4个空格
    key_return  db 13, 10, '$'         ; 回车换行
    msg         db 'The 9mul9 table:', 13, 10, '$'
datasg ends

codesg segment

;------------------------------------------------------------------字符串显示宏定义
; 参数: 字符串标号str
show macro str
    push dx
    lea   dx,str            ;装入str的有效地址
    mov   ah,09h            ;调用中断21,09h显示字符串
    int   21h
    pop dx
    endm
;--------------------------------------------------------------字符串显示宏定义结束


;------------------------------------------------------------------------主程序段
main proc far
    mov ax, stacksg
    mov ss, ax
    mov sp, 128
    mov ax, datasg
    mov ds, ax

    show msg                         ; 打印出有关乘法表的信息

    mov cx, 9                        ; 第一行的第一个乘数从9开始，依次减1
cal_and_show:
    mov bx, 1                        ; 第二个乘数从1开始，增加至与乘数相等
cal_and_show_s:
    mov ax, bx
    lea si, num_2
    call dtoc                        ; 将第二个乘数转化为十进制字符串，并放入num_2位置
    mov ax, cx
    lea si, num_1
    call dtoc                        ; 将第一个乘数转化为十进制字符串，并放入num_1位置
    mul bl
    lea si, result
    mov word ptr result, 0
    call dtoc                        ; 计算结果并转为十进制字符串，放入result位置

    show num_1                       ; 将结果等式打印

    inc bx
    cmp bx, cx                       ; 判断第二个乘数是否比第一个大
    jna cal_and_show_s               ; 不大于则继续本轮循环直到大于为止
    show key_return                  ; 打印回车换行
    loop cal_and_show


    mov ah, 4ch
    int 21h

main endp
;---------------------------------------------------------------------主程序段结束


;--------------------------------------------------word型数据转化为十进制字符串程序段
dtoc proc near
; 将word型数据转化为十进制字符串
; 参数
;   ax      word型数据
;   ds:[si] 指向输出字符串位置的首地址

    push ax
    push bx
    push cx
    push dx
    push si

    mov bx, 10
    mov dx, 0                       ; 计数器，累加入栈的字符数量
dtoc_div:
    push dx
    mov dx, 0
    div bx
    mov cx, dx                      ; 余数赋值
    add cx, 30h                     ; 计算数字的ASCii码
    pop dx
    inc dx                          ; 结果位数的计数器累加
    push cx                         ; 暂时入栈

    mov cx, ax                      ; 商赋值
    jcxz dtoc_return                ; 若商为0则返回
    jmp dtoc_div

dtoc_return:
    mov cx, dx                      ; 需要写入的字符个数
dtoc_return_s:                      ; 循环将栈中的暂存字符输入指定位置
    pop ax
    mov ds:[si], al
    inc si
    loop dtoc_return_s

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
dtoc endp
;-----------------------------------------------word型数据转化为十进制字符串程序段结束


codesg ends
end main
