;---------------------------------
;
; file for study and debug
;
;---------------------------------

include test.asm


assume cs:codesg, ds:datasg, ss: stacksg

datasg segment
	msg db "hello", 13, 10 , '$'
datasg ends


stacksg segment stack
	db 128 dup (0)
stacksg ends


codesg segment
	extrn clean: far

show macro str
	push dx
	lea dx, str
	mov ah, 09h
	int 21h
	pop dx
	endm



main proc far
start:
	mov ax, stacksg
	mov ss, ax
	mov sp, 128
	mov ax, datasg
	mov ds, ax

	call clean

	mov ax, 4c00h
	int 21h
main endp

codesg ends

end start
