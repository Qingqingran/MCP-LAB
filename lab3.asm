DATA SEGMENT
    CLUE DB 'Please input the number to be calculate the factorial:', '$'
    STRING DB 0AH, 0DH, 'The result is: ', '$'
    FACTORIAL DB 19 DUP(0)
    DATABUFFER DB 0
    DIVISOR DB 10
    INTERGER DB ?
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:
    MOV AX, DATA
    MOV DS, AX
    
    MOV DX, OFFSET CLUE ; output the input clue information
    MOV AH, 09H
    INT 21H
    
    CALL INPUT          ; input
    MOV CX, 0    
    MOV CL, DATABUFFER
    SUB CL, 1
    MOV AX, 0
    LEA BX, FACTORIAL    
    MOV [BX + 18], 1 
FACT:  
    MOV DI, 18  
    CALL BIGINTMUL      ; big interger multiply
    SUB DATABUFFER, 1
    LOOP FACT
    JMP OUTPUT
    
INPUT PROC
    MOV DATABUFFER, 0
CHAR:
    MOV AH, 01H
    INT 21H
    CMP AL, 30H
    JB EXIT
    CMP AL, 39H
    JA EXIT
    SUB AL, 30H
    MOV BL, AL
    MOV AX, 0AH
    MUL DATABUFFER
    MOV DATABUFFER, AL
    ADD DATABUFFER, BL
    JMP CHAR    
EXIT:
    RET           
INPUT ENDP    
        
BIGINTMUL PROC
    
CAL:        
    MOV AL, [BX + DI]
    MUL DATABUFFER
    MOV [BX + DI], AL
    SUB DI, 1
    CMP DI, 0
    JGE CAL
    
    MOV DI, 19
    PUSH DI
CIRCULATION:
    POP DI
    SUB DI, 1    
    MOV AL, [BX + DI]
    MOV [BX + DI], 0
    PUSH DI
    CMP DI, 0
    JZ EXIT1
    
PLACE:    
    DIV DIVISOR
    MOV DL, [BX + DI]
    ADD DL, AH
    MOV [BX + DI], DL
    MOV AH, 0
    SUB DI, 1
    CMP AL, 0
    JNZ PLACE
    JMP CIRCULATION
EXIT1:
    POP DI
    RET       
BIGINTMUL ENDP 

OUTPUT:
    MOV DX, OFFSET STRING
    MOV AH, 09H
    INT 21H
    MOV DI, 0
FIND:
    ADD DI, 1
    MOV DL, [BX + DI]
    CMP DL, 0
    JZ FIND
PRINT:
    ADD DL, 30H
    MOV AH, 2
    INT 21H
    ADD DI, 1         
    MOV DL, [BX + DI]
    CMP DI, 19
    JB PRINT
    
    MOV AH, 4CH
    INT 21H
    
CODE ENDS
    END START