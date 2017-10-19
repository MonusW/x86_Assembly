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
    int 0

    mov ax, 4c00h
    int 21


codesg ends

end start
