assume cs: codesg, ds: datasg, ss: stacksg

datasg segment
    db 32 dup(0)

datasg ends

table segment
    dw 9768h, 5ah
    buffer db 16 dup(0)
table ends

stacksg segment stack
    db 32 dup(0)
stacksg ends

codesg segment
start:
    mov ax, table
    mov ds, ax
    mov ax, stacksg
    mov ss, ax
    mov sp, 32

    call clear_screen

    mov si, 0
    mov ax, ds:[si]
    mov dx, ds:[si+2]
    lea si, buffer
    call dtoc

    mov dh, 2
    mov dl, 5
    mov cl, 00001100b
    call show_str

    mov ax, 4c00h
    int 21h


;将dword型数据转化为十进制字符串，以0结尾
;参数
;   dx      dword型数据高16位
;   ax      dword型数据低16位
;   ds:[si] 指向输出字符串的首地址
;返回
;   null
dtoc:
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    mov bx, 10
    mov di, 0           ;计数器
dtoc_div:
    ; push dx
    ; mov dx, 0
    ; div bx
    mov cx, 10
    call divdw
    ; mov cx, dx          ;余数赋值
    add cx, 30h         ;数字的ASCii码
    ; pop dx
    inc di              ;结果位数的计数器累加
    push cx             ;暂时入栈

    mov cx, 0
    cmp dx, cx
    jne dtoc_div
    cmp ax, cx
    je dtoc_return    ;若商为0则返回
    jmp short dtoc_div

dtoc_return:
    mov cx, di          ;需要写入的字符个数
dtoc_return_s:
    pop ax
    mov ds:[si], al
    inc si
    loop dtoc_return_s


    pop si
    mov al, 0
    mov bx, di
    mov ds:[si][bx], al ;给字符串末尾赋0
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


;进行不会溢出的除法计算
;参数
;   ax dword型数据低16位
;   dx dword型数据高16位
;   cx 除数
;返回
;   dx 结果的高16位
;   ax 结果的低16位
;   cx 余数
divdw:
    push bx
    push ax

    mov ax, dx
    mov dx, 0
    div cx          ;计算后 ax为结果的高16位

    mov bx, ax      ;将结果高16位暂存至 bx
    pop ax
    div cx          ;计算后 dx为结果的余数   ax为结果的低16位

    mov cx, dx      ;余数
    mov dx, bx      ;商的高16位

    pop bx
    ret

;显示以0结尾的字符串
;参数
;   dh       行号(0-24)
;   dl       列号(0-79)
;   cl       颜色参数
;   ds:[si]  指向字符串首地址
;返回
;   null
show_str:
    push ax
    push dx
    push es
    push bx
    push cx
    push si

    mov al, 0ah         ;每行偏移量 a0h  映射到段地址上则为 0ah
    inc dh              ;行号修正
    mul dh
    add ax, 0b800h
    mov es, ax          ;行偏移(段地址) 0ah * 行数+显存起始地址
    mov al, 2
    mul dl
    mov bx, ax          ;列偏移(偏移地址) 2 * 列数 为偏移地址
    mov dl, cl          ;颜色赋值
show_str_show:
    mov ah, dl
    mov al, ds:[si]
    mov ch, 0
    mov cl, al
    jcxz show_str_return
    mov es:[bx], ax
    add bx, 2
    inc si
    jmp short show_str_show
show_str_return:
    pop si
    pop cx
    pop bx
    pop es
    pop dx
    pop ax
    ret

; 清空屏幕
; 参数
;   null
; 返回
;   null
clear_screen:
    push ax
    push bx
    push ds
    push cx

    mov ax, 0b000h
    mov ds, ax
    mov ax, 0
    mov bx, 8000h
    mov cx, 4000h
clear_screen_s:
    mov ds:[bx], ax
    add bx, 2
    loop clear_screen_s

    pop cx
    pop ds
    pop bx
    pop ax
    ret

codesg ends
end start
