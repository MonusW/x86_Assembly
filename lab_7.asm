assume cs:codesg, ds:datasg, ss: stacksg

datasg segment
	; ten years
	year	db '1975', '1976', '1977', '1978', '1979', '1980'
			db '1990', '1991', '1992', '1993', '1994', '1995'

	;ten number of income
	income	dd 16, 22, 382, 1356, 2390
		 	dd 1843000, 2759000, 3753000, 4649000, 5937000

	;ten number of employees
	employ	dw 3, 7, 9, 13, 28
			dw 8226, 11542, 14430, 15257, 17800
datasg ends

table segment
	db 10 dup ('year summ ne ?? ')
table ends

stacksg segment stack
	db 20 dup (0)
stacksg ends

codesg segment
start:
	mov ax, datasg
	mov ds, ax				;data
	mov ax, stacksg
	mov ss, ax
	mov sp, 20				;stack
	mov ax, table
	mov es, ax

;complete year column
	mov bx, 0				;every row in table
	mov si, 0
	lea bp, year
	mov cx, 10				;ten rows in table in total
s1:
	push cx
	mov cx, 4
s1_1:
	mov al, ds:[bp][si]
	mov es:[bx][si], al
	inc si
	loop s1_1

	mov si, 0
	add bx, 16
	add bp, 4
	pop cx
	loop s1

;complete income column
	mov bx, 0				;every row in table
	mov si, 0
	lea bp, income
	mov cx, 10				;ten rows in table in total
s2:
	push cx
	mov cx,	2
s2_2:
	mov ax, ds:[bp][si]
	mov es:[bx].5[si], ax
	add si, 2
	loop s2_2

	mov si, 0
	add bx, 16
	add bp, 4
	pop cx
	loop s2

;complete employ column
	mov bx, 0				;every row in table
	lea bp, employ
	mov cx, 10				;ten rows in table in total
s3:
	mov ax, ds:[bp]
	mov es:[bx].10, ax

	add bx, 16
	add bp, 2
	loop s3

;complete average column
	mov bx, 0				;every row in table
	mov cx, 10				;ten rows in table in total
s4:
	mov ax, es:[bx].5
	mov dx, es:[bx].7
	div word ptr es:[bx].10
	mov es:[bx].13, ax

	add bx, 16
	loop s4


	mov ax, 4c00h
	int 21h

codesg ends

end start
