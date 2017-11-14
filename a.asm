;---------------------------------
;
; file for study and debug
;
;---------------------------------

assume cs:codesg, ds:datasg, ss: stacksg

datasg segment
	; 21 years
	year	db '1975',  '1976',  '1977',  '1978',  '1979'
            db '1980',  '1981',  '1982',  '1983',  '1984'
            db '1985',  '1986',  '1987',  '1988',  '1989'
            db '1990',  '1991',  '1992',  '1993',  '1994'
            db '1995'

	;21 number of income
	income	dd 16,      22,      382,     1356,    2390
            dd 8000,    16000,   24486,   50065,   97479
            dd 140417,  197514,  345980,  590827,  803530
            dd 1183000, 1843000, 2759000, 3753000, 4649000
            dd 5937000

	;21 number of employees
	employ	dw 3,       7,       9,       13,      28
            dw 38,      130,    220,      476,     778
            dw 1001,    1442,   2258,     2793,    4037
            dw 5635,    8226,   11542,    14430,   15257
            dw 17800

    ; number of rows in table
    count   dw 21
datasg ends

table segment
	db 21 dup ('year summ ne ?? ')      ; 21列表格

    buffer db 16 dup(0)                 ; 存储临时数据
    line dw 1                           ; 存储当前输出到屏幕的行号(取值:0-25)
table ends

stacksg segment stack
	db 128 dup (0)
stacksg ends

codesg segment
;------------------------------- 主程序------------------------------------------
start:
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

    call show                  ; 调用 show 函数来将table输出到屏幕上

	mov ax, 4c00h
	int 21h


;------------------------- 子程序(将表格打印至屏幕上)-------------------------------
show:
    mov ax, table
    mov ds, ax
    mov es, ax

    call clear_screen                      ; 调用清屏函数

    mov bx, 0                              ; 初始行偏移
    mov cx, 21                             ; 总共21行要输出
show_s:
    push cx                                ; cx暂时入栈(之后需要它来判断循环终止条件)

;------------------- 输出年份到屏幕上 -------------------
    mov si, 0
    mov ax, ds:[bx+si]                  ; 取数据，并丢到缓冲区供 show_str 函数将
    mov dx, ds:[bx+si+2]                ; 其内容写入显存
    lea si, buffer
    mov ds:[si], ax
    mov ds:[si+2], dx
    lea di, line
    mov dh, [di]                        ; 取得当前需要输出的行号
    mov dl, 5                           ; 年份第一个字符所在列号
    mov cl, 00001100b                   ; 颜色属性: 黑底高亮红字
    call show_str                       ; 将ds:[si]指向的缓冲区内容写入显存适当位置
    call clear_buffer                   ; 清空缓冲区，供其他数据使用s

;------------------- 输出总收入到屏幕上 ------------------
    mov si, 5
    mov ax, ds:[bx+si]
    mov dx, ds:[bx+si+2]
    lea si, buffer
    call dtoc                          ; 调用 dtoc 函数将dword型数据转成10进制字符串
    lea di, line                       ; 并存入 ds:[si]指向的内存区域
    mov dh, [di]
    mov dl, 25                         ; 总收入第一个字符所在列号
    mov cl, 00001100b
    call show_str
    call clear_buffer

;------------------- 输出员工人数到屏幕上 ----------------
    mov si, 0ah
    mov ax, [bx][si]
    mov dx, 0
    lea si, buffer
    call dtoc                          ; 同总收入的处理
    lea di, line
    mov dh, [di]
    mov dl, 45                         ; 人数第一个字符所在列号
    mov cl, 00001100b
    call show_str
    call clear_buffer

;------------------- 输出平均收入到屏幕上 -----------------
    mov si, 0dh
    mov ax, [bx][si]
    mov dx, 0
    lea si, buffer
    call dtoc                         ; 同总收入的处理
    lea di, line
    mov dh, [di]
    mov dl, 65                        ; 总收入第一个字符所在列号
    call show_str
    call clear_buffer

    add bx, 16
    add dh, 1
    mov [di], dh                      ; 将当前显示列数+1，并写回内存供下一循环使用
    pop cx                            ; 获取需要输出的总列数
    cmp dh, cl
    ja show_return                    ; 所有数据输出完则返回主函数，否则进行循环
    jmp near ptr show_s
show_return:
    ret

;--------------------------- 程序中用到的函数--------------------------------------
; 清理临时数据缓存区 buffer
clear_buffer:
    push cx
    push bx
    push ax
    lea bx, buffer
    mov cx, 16
    mov ax, 0
clear_buffer_s:
    mov ds:[bx], al
    inc bx
    loop clear_buffer_s
    pop ax
    pop bx
    pop cx
    ret

;将dword型数据转化为十进制字符串，以0结尾
;参数
;   dx      dword型数据高16位
;   ax      dword型数据低16位
;   ds:[si] 输出字符串的首地址
;返回
;   null
dtoc:
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    mov di, 0            ;计数器(记录十进制字符串的位数)
dtoc_div:
    mov cx, 10
    call divdw           ;考虑大数字除小数字的除法溢出，调用函数处理，返回cx为余数

    add cx, 30h          ;余数的ASCii码

    inc di               ;结果位数的计数器累加
    push cx              ;暂时入栈

    mov cx, 0
    cmp dx, cx
    jne dtoc_div
    cmp ax, cx
    je dtoc_return       ;若商为0则返回
    jmp short dtoc_div

dtoc_return:
    mov cx, di           ;需要写入的字符个数
dtoc_return_s:
    pop ax               ;依次出栈填入ds:[si]指向的位置
    mov ds:[si], al
    inc si
    loop dtoc_return_s

    pop si
    mov al, 0
    mov bx, di
    mov ds:[si][bx], al  ;给字符串末尾赋0

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


;进行不会溢出的除法计算
;参数
;   dx dword型数据高16位
;   ax dword型数据低16位
;   cx 除数
;返回
;   dx 结果的高16位
;   ax 结果的低16位
;   cx 余数
divdw:
    push bx
    push ax

    mov ax, dx
    mov dx, 0       ;高16位除以除数
    div cx          ;计算后 ax为结果的高16位

    mov bx, ax      ;将结果高16位暂存至 bx
    pop ax          ;低16位除以除数
    div cx          ;计算后 dx为结果的余数   ax为结果的低16位

    mov cx, dx      ;余数
    mov dx, bx      ;商的高16位

    pop bx
    ret

;显示以0结尾的字符串
;参数
;   dh       行号(0-24)
;   dl       列号(0-79)
;   cl       颜色参数
;   ds:[si]  指向字符串首地址
;返回
;   null
show_str:
    push ax
    push dx
    push es
    push bx
    push cx
    push si

    mov al, 0ah                 ;每行显存偏移量 a0h  映射到段地址上则为 0ah
    inc dh                      ;行号修正(敲完回车整体显示会上移一行，需要+1修正)
    mul dh
    add ax, 0b800h              ;行偏移(段地址) = 0ah * 行数+显存起始段地址
    mov es, ax
    mov al, 2
    mul dl
    mov bx, ax                  ;列偏移(偏移地址) = 2 * 列数 为偏移地址
    mov dl, cl                  ;颜色赋值
show_str_show:
    mov ah, dl
    mov al, ds:[si]
    mov ch, 0
    mov cl, al
    jcxz show_str_return
    mov es:[bx], ax
    add bx, 2
    inc si
    jmp short show_str_show
show_str_return:
    pop si
    pop cx
    pop bx
    pop es
    pop dx
    pop ax
    ret

; 清空显存
; 参数
;   null
; 返回
;   null
clear_screen:
    push ax
    push bx
    push ds
    push cx

    mov ax, 0b000h
    mov ds, ax
    mov ax, 0
    mov bx, 8000h
    mov cx, 4000h
clear_screen_s:
    mov ds:[bx], ax
    add bx, 2
    loop clear_screen_s

    pop cx
    pop ds
    pop bx
    pop ax
    ret


codesg ends

end start
