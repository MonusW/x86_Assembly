;   source module1

extrn show_str: far
extrn clear_screen: far

data segment common
    ary     dw 100 dup(?)
    count   dw 100
    sum     dw ?
    msg db "smart ass?", 0
data ends

stacksg segment stack
    db 128 dup(0)
stacksg ends


code1 segment

main proc far
    assume cs:code1, ds:data

start:
    mov ax, data
    mov ds, ax
    mov ax, stacksg
    mov ss, ax
    mov sp, 128

    call clear_screen

    mov dh, 3
    mov dl, 5
    mov cl, 00001100b
    lea si, msg
    call show_str


    mov ax, 4c00h
    int 21h

main endp

code1 ends
end start
