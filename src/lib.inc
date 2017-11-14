;---------------------------------------------

;一些实用函数

;---------------------------------------------


; al 传送要显示的数据
show_byte:
    jmp short show_byte_show
    table db '0123456789ABCDEF'
show_byte_show:
    push ax
    push bx
    push es

    mov ah, al
    shr ah, 1
    shr ah, 1
    shr ah, 1
    shr ah, 1
    and al, 00001111b

    mov bl, ah
    mov bh, 0
    mov ah, table[bx]
    mov bx, 0b800h
    mov es, bx
    mov es:[160*12+2*40], ah
    mov byte ptr es:[160*12+2*40+1], 01111010b

    mov bl, al
    mov bh, 0
    mov al, table[bx]
    mov bx, 0b800h
    mov es, bx
    mov es:[160*12+2*40+2], al
    mov byte ptr es:[160*12+2*40+3], 01111010b


    pop es
    pop bx
    pop ax
    ret


; 延迟函数
; 参数
;   dx:循环次数的高16位
;   ax:循环次数的低16位
;   推荐 循环 10_0000h 次
; 返回
;   null
delay:
    push ax
    push dx
;    mov dx, 10h     ; 循环 10_0000h 次 可根据自己机器调整
;    mov ax, 0
delay_s1:
    sub ax, 1
    sbb dx, 0
    cmp ax, 0
    jne delay_s1
    cmp dx, 0
    jne delay_s1
    pop dx
    pop ax
    ret

; 将以0结尾的字符串中的小写字母转化为大写字母
; 参数
;   ds:[si] 指向字符串首地址
; 返回
;   null
letterc:
    push ax
    push si
letterc_s:
    mov al, ds:[si]
    cmp al, 'a'
    jb letterc_next             ; 字符ASCii码小于'a'则 continue
    cmp al, 'z'
    ja letterc_next             ; 字符ASCii码大于'z'亦 continue
    and al, 11011111b
    mov ds:[si], al
letterc_next:
    inc si
    cmp al, 0
    jne letterc_s               ; 字符不为0则继续读取

    pop si
    pop ax
    ret

; 将两个128位的数字相加，结果存储在第一个数字的存储空间
; 参数
;   ds:si 指向第一个128位数字 8个字单元
;   ds:di 指向第二个数字
; 返回
;   null
add128:
    push ax
    push cx
    push si
    push di

    sub ax, ax             ; 将CF位 置0
    mov cx, 8
add128_s:
    mov ax, ds:[si]
    adc ax, ds:[di]
    mov ds:[si], ax
    inc si                 ; 注意不能用 add 会给CF赋值
    inc si
    inc di
    inc di
    loop add128_s

    pop di
    pop si
    pop cx
    pop ax
    ret

;将word型数据转化为十进制字符串，以0结尾
;注意，需要根据数据大小定义相应的栈段大小 推荐 32byte
;参数
;   ax      word型数据
;   ds:[si] 指向输出字符串的首地址
;返回
;   null
dtoc:
    push ax
    push bx
    push cx
    push dx
    push si

    mov bx, 10
    mov dx, 0           ;计数器
dtoc_div:
    push dx
    mov dx, 0
    div bx
    mov cx, dx          ;余数赋值
    add cx, 30h         ;数字的ASCii码
    pop dx
    inc dx              ;结果位数的计数器累加
    push cx             ;暂时入栈

    mov cx, ax          ;商赋值
    jcxz dtoc_return    ;若商为0则返回
    jmp short dtoc_div

dtoc_return:
    mov cx, dx          ;需要写入的字符个数
dtoc_return_s:
    pop ax
    mov ds:[si], al
    inc si
    loop dtoc_return_s

    pop si
    mov al, 0
    mov bx, dx
    mov ds:[si][bx], al ;给字符串末尾赋0
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
    pop es                   ; fuck the bug !!!!  ds -> es
    pop dx
    pop ax
    ret
