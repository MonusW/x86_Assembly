DATAS  SEGMENT

     STRING  DB  'Hello World!',13,10,'$'
     
DATAS  ENDS

CODES  SEGMENT
    ASSUME    CS:CODES,DS:DATAS
     
START:
     MOV  AX,DATAS
     MOV  DS,AX
     
     LEA  DX,STRING;LEA 获取偏移量,并将其存入DX
     
     MOV  AH,9
     INT  21H       ;INT 21H是DOS中断的调用，其执行的操作根据AH里面的值来确定。
                    ;9，表示的是输出字符串，其地址为DS:DX
     MOV  AH,4CH
     INT  21H
CODES  ENDS
    END   START
