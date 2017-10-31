;---------------------------------------
;
; 安装 0号中断(除法溢出) 处理函数，并进行测试
;
;---------------------------------------

assume cs:codesg, ds:datasg, ss:stacksg

datasg segment
    db "Welcome to masm!"
    db 16 dup(0)
datasg ends

stacksg segment stack
    db 16 dup(0)
stacksg ends

codesg segment
start:
    mov ax, cs
    mov ds, ax
    mov ax, stacksg
    mov ss, ax
    mov sp, 16

; 安装中断向量处理函数
    mov si, offset do0
    mov ax, 0
    mov es, ax
    mov di, 200h            ;设置 es:di 指向目标地址
    mov cx, offset do0end-offset do0
    cld
    rep movsb

; 设置中断向量表 0号
    mov ax, 0
    mov es, ax
    mov word ptr es:[0*4], 200h
    mov word ptr es:[0*4+2], 0

; 测试程序
    mov ax, 0ffffh
    mov bl, 0
    div bl

    mov ax, 4c00h
    int 21h

do0:
    jmp short do0_start
    db "divide error!"          ;
do0_start:
    mov ax, cs
    mov ds, ax
    mov si, 202h            ;设置 ds:si 指向字符串

    mov ax, 0b800h
    mov es, ax
    mov di, 12*160 + 32*2   ;计算偏移地址 12行 36列
    mov cx, 13               ;字符串长度

do0_s:
    mov al, [si]
    mov ah, 01111010b
    mov es:[di], ax
    inc si
    add di, 2
    loop do0_s

    mov ax, 4c00h
    int 21h
do0end:
    nop


codesg ends

end start
