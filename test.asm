assume cs: codesg, ds: datasg, ss: stacksg

datasg segment
    db 32 dup(0)
    msg db "hello", 13, 10, "$"
datasg ends

stacksg segment stack
    db 32 dup(0)
stacksg ends

codesg segment

show macro str
    push dx
    lea dx, str
    mov ah, 09h
	int 21h
	pop dx
    endm


main proc far
    mov ax, datasg
    mov ds, ax
    mov ax, stacksg
    mov ss, ax
    mov sp, 32

    show msg
    mov ax, 4c00h
    int 21h

main endp



codesg ends
end main
