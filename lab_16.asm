;---------------------------------
;
; 改写 int 7ch 中断例程 使其具有多个子程序
; 功能
; 0 清屏
; 1 改变前景色
; 2 改变背景色
; 3 下移一行
; 参数
;   ah 子程序编号 0-3
;   al 1，2 程序的颜色值 0-7
;
;---------------------------------

assume cs:codesg, ss:stacksg

stacksg segment stack
    db 128 dup(0)
stacksg ends

codesg segment

start:
    mov ax, stacksg
    mov ss, ax
    mov sp, 128

    mov ax, cs
    mov ds, ax
    mov si, offset set_screen
    mov ax, 0
    mov es, ax
    mov di, 200h
    mov cx, offset set_end - offset set_screen
    cld
    rep movsb

    mov word ptr es:[7ch*4], 200h
    mov word ptr es:[7ch*4+2], 0

    ; for test
    ; mov ah, 1
    ; mov al, 2
    ; int 7ch

    mov ax, 4c00h
    int 21h

    ; !!! 告诉编译器之后代码 起始地址为 200h 不然 table 内标号定位会有问题   !!!
    org 200h            ;fuck the bug
set_screen:
    jmp short set

    table dw sub1, sub2, sub3, sub4

set:
    push bx
    cmp ah, 3
    ja sret
    mov bl, ah
    mov bh, 0
    add bx, bx

    call word ptr table[bx]
sret:
    pop bx
    iret           ;fuck the bug

; 清屏
sub1:
    push bx
    push cx
    push es
    mov bx, 0b800h
    mov es, bx
    mov bx, 0
    mov cx, 2000   ;4000
sub1_s:
    mov byte ptr es:[bx], ' '
    add bx, 2
    loop sub1_s
    pop es
    pop cx
    pop bx
    ret

; 设置前景色
; 参数 al
;   al = 0-7
sub2:
    push bx
    push cx
    push es

    mov bx, 0b800h
    mov es, bx
    mov bx, 1
    mov cx, 2000
sub2_s:
    and byte ptr es:[bx], 11111000b
    or es:[bx], al
    add bx, 2
    loop sub2_s
    pop es
    pop cx
    pop bx
    ret

; 设置背景色
; 参数 al
;   al = 0-7
sub3:
    push bx
    push cx
    push es
    mov cl, 4
    shl al, cl
    mov bx, 0b800h
    mov es, bx
    mov bx, 1
    mov cx, 2000
sub3_s:
    and byte ptr es:[bx], 10001111b
    or es:[bx], al
    add bx, 2
    loop sub3_s
    pop es
    pop cx
    pop bx
    ret

; 向上滚动一行
sub4:
    push cx
    push si
    push di
    push es
    push ds
    mov si, 0b800h
    mov es, si
    mov ds, si              ;fuck the bug
    mov si, 160
    mov di, 0
    cld
    mov cx, 24
sub4_s:
    push cx
    mov cx, 160
    rep movsb
    pop cx
    loop sub4_s

    mov cx, 80
    mov si, 0
sub4_s1:
    mov byte ptr [160*24+si], ' '
    add si, 2
    loop sub4_s1

    pop ds
    pop es
    pop di
    pop si
    pop cx
    ret

set_end:
    nop





codesg ends

end start
