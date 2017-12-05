;---------------------- 打印信息到屏幕上的子程序 -----------------------------------

public show

table segment common
	db 21 dup ('year summ ne ?? ')      ; 21列表格

    buffer db 16 dup(0)                 ; 存储临时数据
    line dw 1                           ; 存储当前输出到屏幕的行号(取值:0-25)
table ends

extrn dtoc: far
extrn divdw: far
extrn show_str: far
extrn clear_screen: far

codesg2 segment
    assume cs:codesg2, ds:table

show proc far
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
show endp


; 清理临时数据缓存区 buffer
clear_buffer proc near
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
clear_buffer endp


codesg2 ends
end
