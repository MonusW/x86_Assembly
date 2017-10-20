;---------------------------------
;
; 恢复中断向量表(部分)
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

    mov ax, 0
    mov ds, ax

    ; int 9
    cli
    mov word ptr ds:[9*4], 0e987h
    mov word ptr ds:[9*4+2], 0f000h
    sti

    mov ax, 4c00h
    int 21h

codesg ends
end start
