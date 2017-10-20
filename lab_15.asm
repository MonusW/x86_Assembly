;---------------------------------
;
; 修改原有 int 9 中断例程
; 按下 ESC 后改变 dos 的颜色，其他按键不受影响
; 重复安装前运行 reset 恢复原中断向量表!!! 不然会导致无法正常响应键盘输入
;
;---------------------------------

assume cs:codesg, ds:datasg, ss:stacksg

stacksg segment stack
    db 128 dup(0)
stacksg ends

codesg segment
start:
    mov ax, stacksg
    mov ss, ax
    mov sp, 128

    push cs
    pop ds

    mov ax, 0
    mov es, ax

    mov si, offset int9
    mov di, 204h
    mov cx, offset int9_end - offset int9
    cld
    rep movsb

    push es:[9*4]
    push es:[9*4+2]
    pop es:[202h]
    pop es:[200h]


    cli
    mov word ptr es:[9*4], 204h
    mov word ptr es:[9*4+2], 0
    sti

    mov ax, 4c00h
    int 21h

int9:
    push ax
    push bx
    push cx
    push es

    in al, 60h

    pushf
    mov bx, 0
    mov es, bx
    call dword ptr es:[200h]

    cmp al, 1                       ; 要响应的按键对应的扫描码(通码)  3bh 为F1键
    jne int9_ret

    mov ax, 0b800h
    mov es, ax
    mov bx, 1
    mov cx, 2000
int9_s:
    inc byte ptr es:[bx]
    add bx, 2
    loop int9_s
int9_ret:
    pop es
    pop cx
    pop bx
    pop ax
    iret
int9_end:
    nop

codesg ends

end start
