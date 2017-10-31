;---------------------------------
;
; file for study and debug
;
;---------------------------------

assume cs:codesg, ds:datasg, ss:stacksg

stacksg segment stack
    db 128 dup(0)
stacksg ends

datasg segment
    letters db 128 dup(0)                                    ; 定义存放字符的缓冲区
    buffer  db 32 dup(0)                                     ; 定义键盘输入缓冲区
    msg_1   db 'Please enter the index of letter you want to start(0-25):', 13, 10, '$'
    msg_2   db 'Please enter the number of letters shown in a row:', 13, 10, '$'
    msg_3   db 13, 10, 'Enter again: ', '$'
datasg ends

codesg segment
;------------------------------------------------------------------字符串显示宏定义
; 参数: 字符串标号str
show macro str
    push dx
    lea   dx,str    ;装入str的有效地址
    mov   ah,09h    ;调用中断21,09h显示字符串
    int   21h
    pop dx
    endm
;--------------------------------------------------------------字符串显示宏定义结束


;------------------------------------------------------------------------主程序段
main proc far
    mov ax, stacksg       ; 各寄存器初始化
    mov ss, ax
    mov sp, 128
    mov ax, datasg
    mov ds, ax

    show msg_1            ; 提示用户输入输出字符起始位置
    lea bx, buffer        ; 设置ds:[bx]指向输入缓冲区
    call input            ; 接收用户输入
    call to_num           ; 字符串转数字存入 al
    mov dl, al            ; dl暂时存储al

    show msg_2            ; 提示用户输入每行显示的字符个数
    lea bx, buffer
    call input
    call to_num
    mov dh, al            ; dh暂时存储al

    mov al, dl            ; 设置显示字符的起始位置(0-25)
    mov ah, dh            ; 设置每行显示字符的数量
    mov dx, 0             ; 设置ds:[dx]指向字符存储的位置
    call show_ascii       ; 调用显示字符串的子程序

    mov ax, 4c00h
    int 21h

main endp
;---------------------------------------------------------------------主程序段结束



;----------------------------------------------------------------处理数字输入程序段
input proc near
; ds:[bx]指向输入缓冲区
    push ax
    push si
    mov si, 0
    jmp input_real
input_again:
    mov si, 0
    show msg_3
input_real:
    mov ah, 1
    int 21h
    cmp al, 0dh                 ; 是回车则在字符串末尾加'$'并返回
    je input_return
    cmp al, 30h                 ; 若ascii码小于'0'
    jb input_again              ; 则要求重新输入
    cmp al, 39h                 ; 若ascii码大于'9'
    ja input_again              ; 则要求重新输入

    mov [bx+si], al             ; 符合要求，向缓冲区输入数字字符
    inc si
    jmp input_real              ; 继续接收用户输入

input_return:
    mov byte ptr [bx+si], '$'
    pop si
    pop ax
    ret
input endp
;-------------------------------------------------------------处理数字输入程序段结束



;----------------------------------------------------------------字符串转数字程序段
; 处理0-255
; 参数 ds:[bx]指向字符串 (以'$'结尾)
; 返回 al 为转换后的数值
to_num proc near
    push si
    push dx
    mov ax, 0                   ; al保存结果转换结果
    mov si, 0
to_num_s:
    cmp byte ptr [bx+si], '$'
    je to_num_return
    mov dl, 10
    mul dl                      ; 原al数值翻10倍
    mov dl, [bx+si]
    sub dl, 30h                 ; 减去0的ascii码得到真实的数值
    add al, dl                  ; 真实数值和al相加
    inc si
    loop to_num_s

to_num_return:
    pop dx
    pop si
    ret
to_num endp
;-------------------------------------------------------------字符串转数字程序段结束



;--------------------------------------------------------------显示ascii表子程序段
; 向ds:[dx]指向的数据段输入要显示的字符信息
; 参数 al 字符开始位置 (0-25)
; 参数 ah 每行显示字符个数
show_ascii proc near
    push si
    push ax
    push bx
    push cx
    mov bl, ah                      ; bx:每行输出字符个数
    mov bh, 0
    mov ch, 0
    mov cl, 26
    sub cl, al                      ; 26-(al) 来计算需要输出的字符总数
    add al, 97                      ; al:开始位置字符的ascii码

write_letter:
    mov [si], al
    inc si
    mov byte ptr [si], ' '          ; 每个字符后留一个空格
    inc al                          ; 下一个asicii码
    inc si
    dec bx
    cmp bx, 0                       ; 判断一行输入的字符是否已满
    jne write_letter_s              ; 不满则跳转继续循环

    mov byte ptr [si], 13           ; 回车符
    inc si
    mov byte ptr [si], 10           ; 换行符
    inc si
    mov bl, ah                      ; bx:每行输出字符个数
    mov bh, 0
write_letter_s:
    loop write_letter

    mov byte ptr [si], '$'
    show letters                    ; 调用字符串显示宏

    pop cx
    pop bx
    pop ax
    pop si
    ret
show_ascii endp
;-----------------------------------------------------------显示ascii表子程序段结束


codesg ends

end main
