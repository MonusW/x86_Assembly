;-------------------------- 主程序 ----------------------------------------------

extrn show: far

; 数据段
datasg segment
	; 21 years
	year	db '1975',  '1976',  '1977',  '1978',  '1979'
            db '1980',  '1981',  '1982',  '1983',  '1984'
            db '1985',  '1986',  '1987',  '1988',  '1989'
            db '1990',  '1991',  '1992',  '1993',  '1994'
            db '1995'

	; 21 number of income
	income	dd 16,      22,      382,     1356,    2390
            dd 8000,    16000,   24486,   50065,   97479
            dd 140417,  197514,  345980,  590827,  803530
            dd 1183000, 1843000, 2759000, 3753000, 4649000
            dd 5937000

	; 21 number of employees
	employ	dw 3,       7,       9,       13,      28
            dw 38,      130,    220,      476,     778
            dw 1001,    1442,   2258,     2793,    4037
            dw 5635,    8226,   11542,    14430,   15257
            dw 17800

    ; number of rows in table
    count   dw 21
datasg ends

; 公共存储段(为了在show内能调用到)
table segment common
	db 21 dup ('year summ ne ?? ')      ; 21列表格

    buffer db 16 dup(0)                 ; 存储临时数据
    line dw 1                           ; 存储当前输出到屏幕的行号(取值:0-25)
table ends

stacksg segment stack
	db 128 dup (0)
stacksg ends



codesg segment
    assume cs:codesg, ds:datasg, ss: stacksg

start proc far
	mov ax, datasg             ; 各寄存器初始化
	mov ds, ax
	mov ax, stacksg
	mov ss, ax
	mov sp, 128
	mov ax, table
	mov es, ax

;------------------- 填充表格中的年份列 -----------------------
	mov bx, 0				     ; table 中每列的偏移值(初始为1，每次循环+16)
	mov si, 0
	lea bp, year                 ; 原始数据中每条数据的偏移位置
	mov cx, count				 ; 共 21 列需要填写
s1:
	push cx
	mov cx, 4
s1_1:
	mov al, ds:[bp][si]
	mov es:[bx][si], al
	inc si
	loop s1_1

	mov si, 0
	add bx, 16                  ; table 中列头偏移+16
	add bp, 4                   ; 原始数据中数据偏移值+4
	pop cx
	loop s1

;------- 填充表格中的总收入列 (数据填充思路与年份列类似) -------------
	mov bx, 0
	mov si, 0
	lea bp, income
	mov cx, count
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

;----- 填充表格中的员工数量列 (数据填充思路与年份列类似) --------------
	mov bx, 0
	lea bp, employ
	mov cx, count
s3:
	mov ax, ds:[bp]
	mov es:[bx].10, ax

	add bx, 16
	add bp, 2
	loop s3

;------------------- 填充表格中的员工平均收入列 -------------------
	mov bx, 0				   ; table 中列头偏移
	mov cx, 21				   ; 共21列
s4:
	mov ax, es:[bx].5
	mov dx, es:[bx].7
	div word ptr es:[bx].10    ; 平均收入不超过65535， 可以不用考虑除法溢出
	mov es:[bx].13, ax         ; 将除法商值存入表对应位置

	add bx, 16
	loop s4

    call far ptr show                  ; 调用 show 函数来将table输出到屏幕上

	mov ax, 4c00h
	int 21h
start endp



codesg ends

end start
