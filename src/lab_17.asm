;---------------------------------
;
; 实现简单的接收字符串输入操作，可退格，输入回车结束
;
;---------------------------------

assume cs:codesg, ds:datasg, ss:stacksg

stacksg segment stack
    db 128 dup(0)
stacksg ends

datasg segment
    db 128 dup(0)
datasg ends

codesg segment

start:
    mov ax, stacksg
    mov ss, ax
    mov sp, 128

    mov ax, datasg
    mov ds, ax
    mov si, 0
    mov dh, 12
    mov dl, 5

    call getstr

    mov ax, 4c00h
    int 21h


getstr:
    push ax
getstrs:
    mov ah, 0
    int 16h
    cmp al, 20h         ; 20h 以后才是字符
    jb nochar
    mov ah, 0
    call charstack
    mov ah, 2
    call charstack
    jmp getstrs
nochar:
    cmp ah, 0eh         ; 退格的扫描码
    je backspace
    cmp ah, 1ch         ; 回车的扫描码
    je enter
    jmp getstrs

backspace:
    mov ah, 1
    call charstack
    mov ah, 2
    call charstack
    jmp getstrs

enter:
    mov al, 0
    mov ah, 0
    call charstack
    mov ah, 2
    call charstack
    pop ax
    ret


; 字符栈操作
; ah=0 字符入栈 al 为需要入栈的字符
; ah=1 字符出栈，al为返回的出栈字符
; ah=2 字符串显示 dh 行, dl 列

charstack:
    jmp charstart
    table dw charpush, charpop, charshow
    top dw 0
charstart:
    push bx
    push es
    push dx
    push di

    cmp ah, 2
    ja charstack_ret
    mov bl, ah
    mov bh, 0
    add bx, bx
    jmp word ptr table[bx]
charpush:
    mov bx, top
    mov [si][bx], al
    inc top
    jmp charstack_ret
charpop:
    cmp top, 0
    je charstack_ret
    dec top
    mov bx, top
    mov al, [si][bx]
    jmp charstack_ret
charshow:
    mov bx, 0b800h
    mov es, bx
    mov al, 160
    mov ah, 0
    mul dh
    mov di, ax
    add dl, dl
    mov dh, 0
    add di, dx

    mov bx, 0
    charshows:
        cmp bx, top
        jne noempty
        mov byte ptr es:[di], ' '
        jmp charstack_ret

    noempty:
        mov al, [si][bx]
        mov es:[di], al
        mov al, 00001010b       ;设置字体颜色 这里是高亮绿色
        mov es:[di+1], al
        inc bx
        add di, 2
        jmp charshows

charstack_ret:
    pop di
    pop dx
    pop es
    pop bx
    ret

codesg ends

end start
