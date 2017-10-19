;---------------------------------
;
; 访问 CMOS RAM 获取当前时间并显示
;
;---------------------------------

assume cs:codesg, ds:datasg, ss:stacksg

datasg segment
    dateTime    db "DateTime now is "
    year        db "00/"
    month       db "00/"
    day         db "00/ "
    hour        db "00:"
    minute      db "00:"
    seconds     db "00"
    s_end       db  0
    str_end     db '$'
datasg ends

stacksg segment stack
    db 32 dup(0)
stacksg ends

codesg segment
start:
    mov ax, datasg
    mov ds, ax
    mov ax, stacksg
    mov ss, ax
    mov sp, 32

; 年
    mov al, 9
    lea si, year
    ; mov bx, 0b800h
    ; mov es, bx
    ; mov byte ptr es:[160*12 + 40*2], ah
    ; mov byte ptr es:[160*12 + 40*2+2], al
    call get_time_data
; 月
    mov al, 8
    lea si, month
    call get_time_data
; 日
    mov al, 7
    lea si, day
    call get_time_data
; 时
    mov al, 4
    lea si, hour
    call get_time_data
; 分
    mov al, 2
    lea si, minute
    call get_time_data
; 秒
    mov al, 0
    lea si, seconds
    call get_time_data

; 不调用 show_str 函数的普通显示
    ; mov ah, 9
    ; lea dx, dateTime
    ; int 21h
; 彩色显示
    mov dh, 10
    mov dl, 20
    mov cl, 01111010b
    lea si, dateTime
    call show_str

    mov ax, 4c00h
    int 21h
; 获取时间数据
; 参数
;   al 时间数据所在单元
;   ds:[si] 要写入的单元地址
; 返回
;   null
get_time_data:
    push ax
    push cx
    push si

    out 70h, al
    in al, 71h
    mov ah, al
    mov cl, 4
    shr ah, cl
    and al, 00001111b
    add ah, 30h
    add al, 30h
    mov [si], ah
    mov [si+1], al

    pop si
    pop cx
    pop ax
    ret

show_str:
    push ax
    push dx
    push es
    push bx
    push cx
    push si

    mov al, 0ah         ;每行偏移量 a0h  映射到段地址上则为 0ah
    inc dh              ;行号修正
    mul dh
    add ax, 0b800h
    mov es, ax          ;行偏移(段地址) 0ah * 行数+显存起始地址
    mov al, 2
    mul dl
    mov bx, ax          ;列偏移(偏移地址) 2 * 列数 为偏移地址
    mov dl, cl          ;颜色赋值
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
    pop ds
    pop dx
    pop ax
    ret


codesg ends

end start
