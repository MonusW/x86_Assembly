; module2

public show_str
public clear_screen

code2 segment
    assume cs: code2

;显示以0结尾的字符串
;参数
;   dh       行号(0-24)
;   dl       列号(0-79)
;   cl       颜色参数
;   ds:[si]  指向字符串首地址
;返回
;   null
show_str proc far
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
    pop es                   ; fuck the bug !!!!  ds -> es
    pop dx
    pop ax
    ret
show_str endp

; 清空显存
; 参数
;   null
; 返回
;   null
clear_screen proc far
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
clear_screen endp

code2 ends
end
