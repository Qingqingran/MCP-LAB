DATA SEGMENT
    ARRAY DW 36 DUP(?)
    NOTES DB 0AH, 0DH, '$'    ; wrap and left indent
DATA ENDS    

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START: 
    MOV AX, DATA
    MOV DS, AX                ; DS points the DATA
    MOV CX, 36                ; used for loop counter
    MOV AX, 0                 ; used for initiate the array
    MOV BL, -1                ; used for count the line number
    LEA DI, ARRAY
    
INIT:
    INC AX                    ; initiate the array from 1 to 36
    MOV [DI], AX
    ADD DI, 2
    LOOP INIT 
    
LINE:
    INC BL
    MOV AL, 12
    MUL BL                  
    LEA DI, ARRAY             ; DI points the ARRAY
    ADD DI, AX                ; DI points the next line
    MOV CX, BX                ; NO.k line shoouold output k+1 numbers
    INC CX
    
DEAL:
    MOV AX, [DI]              ; take out the value of the ARRAY
    ADD DI, 02H
    MOV BH, 0AH               ; decimal output
    DIV BH                    ; calculate the ten and digit
    MOV BH, 0                 ; BH = 0 and BX count the line
    CMP AL, 0                 ; judge whether the ten is 0
    JZ OUTPUT                 ; jump to the output of digit and space
    
    PUSH AX                   ; save the value of AX to the stack temporarily
    ADD AL, 30H               ; used for tens output
    MOV DL, AL                ; put the number to be output to DL
    MOV AH, 02H               ; output only
    INT 21H                   ; output ten number
    POP AX                    ; take out the value of AX     
    
OUTPUT:
    ADD AH, 30H
    MOV DL, AH                ; output digit number
    MOV AH, 02H
    INT 21H
    MOV DL, 20H               ; output space
    MOV AH, 02H
    INT 21H
    LOOP DEAL
    
    LEA DX, NOTES             ; wrap and left indent
    MOV AH, 09H
    INT 21H
    CMP BL, 5                 ; judge whether output completely
    JNZ LINE
    
    MOV AH, 4CH               ; return DOS
    INT 21H               
    
CODE ENDS
    END START