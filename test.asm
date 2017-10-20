;---------------------------------
;
; test lab_16
;
;---------------------------------

assume cs:codesg
codesg segment

start:
    mov ah,1
    mov al,1
    int 7ch
    call delay
    mov ah,2
    mov al,2
    int 7ch
    call delay
    mov ah,3
    int 7ch
    call delay
    mov ah,0
    int 7ch

    mov ax,4c00h
    int 21h

delay:
    push ax
    push dx
    mov dx,10h
    mov ax,0
    s1:
    sub ax,1
    sbb dx,0
    cmp ax,0
    jne s1
    cmp dx,0
    jne s1
    pop dx
    pop ax
    ret

codesg ends
end start
