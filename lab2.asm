EOF = 65
DATA SEGMENT
    FILE DB "test.txt", 0
    FH DW ?                                  ; file header
    ARRAY DW 1024 DUP(?)
    NUM DW 0
    N DW 0                             ; the number of data   
    DATABUFFER DW 0                          ; data to be sorted
    BUFFER1 DB 0AH, 0DH, '$'
    BUFFER2 DB 0
    SUCCESS DB "success!", 07H, 0
DATA ENDS 

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:
    MOV AX, DATA
    MOV DS, AX 
    LEA DI, ARRAY   

OPEN: 
    MOV DX, OFFSET FILE
    MOV AX, 3D00H
    INT 21H
    MOV FH, AX                               ; place file id to fh
    
READ:
    CALL READCH
    CMP AL, EOF                              ; finished
    JZ OK
    ;CMP AL, 0DH
    ;JZ READ
    ;CMP AL, 0AH
    ;JZ READ
    CMP AL, 30H                           ; space solve
    JB SPACE
    CMP AL, 39H
    JA SPACE
    SUB AL, 30H
    MOV BL, AL
    MOV BH, 0
    MOV AX, 0AH
    MUL DATABUFFER
    MOV DATABUFFER, AX
    ADD DATABUFFER, BX
    JMP READ
       
OK:                                          ; read finished
    MOV AX, DATABUFFER
    MOV [DI], AX
    INC NUM
    MOV BX, FH
    MOV AH, 3EH
    INT 21H
    CALL SORT
    CALL OUTPUT
    JMP OVER
          
    
SPACE:
    CMP N, 1
    JZ JUMP
    MOV AX, DATABUFFER                       ; place the data in the array
    MOV [DI], AX
    ADD DI, 2
    MOV DATABUFFER, 0                        ; clear the temporary data area     
    INC NUM
JUMP:
    MOV N, 0    
    JMP READ     
                  
; read a character
READCH PROC 
    INC N                                 ; read a character
    MOV BX, FH
    MOV CX, 1
    MOV DX, OFFSET BUFFER2                   ; read the data buffer address
    MOV AH, 3FH                              ; read the file
    INT 21H
    CMP AX, CX
    JB ENDING
    MOV AL, BUFFER2
    
    RET
ENDING:                                      ; read finished
    MOV AX, EOF
    RET    
READCH ENDP

;sort datas
SORT PROC
    MOV AX, 2
    MUL NUM
    SUB AX, 2
    MOV CX, AX
    MOV BX, 0
    LEA DI, ARRAY
FORI:
    MOV AX, 0    
    MOV AL, [DI + BX]                             ; the smallest data unsorted
    MOV AH, [DI + BX + 1]
    PUSH BX
FORJ:
    MOV DX, 0
    ADD BX, 2    
    MOV DL, [DI + BX]
    MOV DH, [DI + BX + 1]
    CMP AX, DX
    JB JUDGE
    MOV DATABUFFER, BX 
    POP BX   
    MOV [DI + BX], DL
    MOV [DI + BX + 1], DH
    PUSH BX
    MOV BX, DATABUFFER
    MOV [DI + BX], AL
    MOV [DI + BX + 1], AH
    MOV AX, DX
JUDGE:
    CMP BX, CX
    JB  FORJ
    POP BX
    ADD BX, 2
    CMP BX, CX
    JB FORI
    RET       
SORT ENDP

;output 
OUTPUT PROC
    MOV CX, NUM
    MOV BX, 0    
UPPER:                                       ; 
    MOV AH, [DI + BX + 1]
    MOV AL, [DI + BX]
    PUSH BX
    PUSH CX
    MOV CX, 0
    JMP TRANS
RET2:    
    POP CX
    POP BX
    
    MOV DL, 20H
    MOV AH, 2
    INT 21H
    ADD BX, 2
    LOOP UPPER
    RET    
OUTPUT ENDP
    
TRANS:
PLACE:
    INC CX
    MOV BX, 10
    JMP DIVNO
RET1:    
    CMP AX, 0
    JNZ PLACE
    
PRINT:
    MOV AH, 2
    POP DX
    ADD DL, 30H
    INT 21H
    LOOP PRINT
    JMP RET2
    
DIVNO:
    MOV DH, 0
    MOV DH, AL
    MOV AL, AH
    MOV AH, 0
    DIV BL
    PUSH AX
    MOV AL, AH
    MOV AH, 0
    PUSH DX
    MOV DATABUFFER, 256
    MUL DATABUFFER
    POP DX
    MOV DL, DH
    MOV DH, 0
    ADD AX, DX
    DIV BL
    MOV BL, AH
    MOV DL, AL
    MOV DH, 0
    POP AX
    MOV AH, 0
    PUSH DX
    MUL DATABUFFER
    POP DX
    ADD AX, DX
    PUSH BX
    JMP RET1   

OVER:
  MOV AH, 4CH
  INT 21H
  
CODE ENDS
    END START