DATA SEGMENT
WP DB 5
NP DB 5
NUM DB 1, 6, 3, 2, 9, 10
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

BEGIN:
MOV AX, DATA
MOV DS, AX

MOV BX, 0

NLOOP:

MOV AL, NUM[BX]
INC BX
CMP AL, NUM[BX]

JA	XCHAG

NNLOOP:

DEC NP
MOV AL, NP
CMP AL, 0

JNE NLOOP
MOV BX, 0

WLOOP:

DEC WP
MOV AL, WP
CMP	AL, 0

JZ EXIT

MOV NP, AL
JMP NLOOP

XCHAG:

MOV AH, AL
MOV AL, NUM[BX]
MOV NUM[BX], AH
DEC BX
MOV NUM[BX], AL
INC BX

JMP NNLOOP

EXIT:

MOV AH, 4CH
INT 21H

CODE ENDS
END BEGIN