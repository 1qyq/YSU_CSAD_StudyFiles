;��ʼ������оƬ
DATA SEGMENT
IOY1 EQU 0640H
M8255_A EQU IOY1 + 00H * 2
M8255_B EQU IOY1 + 01H * 2
M8255_C EQU IOY1 + 02H * 2
M8255_CON EQU IOY1 + 03H * 2

IOY3 EQU 06C0H
M8254_0 EQU IOY3 + 00H * 2
M8254_1 EQU IOY3 + 01H * 2
M8254_2 EQU IOY3 + 02H * 2
M8254_CON EQU IOY3 + 03H * 2

flag DB 0;	��ʼ ��ʼ��־flag = 0����λ��־
temp DB 5
score DB 8 DUP(0)
TABLE DB 1, 2, 4, 8, 16, 32, 64, 128

ring1_fre DW 1100,600, 0  ;���ֵ�Ƶ��
ring1_time DW 3, 2, 11    ;���ֵĽ���

ring2_fre DW 300, 0  ;���ֵ�Ƶ��
ring2_time DW 10, 11    ;���ֵĽ���

ring3_fre DW 300, 400, 500, 600, 0  ;���ֵ�Ƶ��
ring3_time DW 1, 1, 1, 1, 1    ;���ֵĽ���

DATA ENDS

STACK SEGMENT
	DW 200 DUP(?)
STACK ENDS


CODE SEGMENT
ASSUME CS:CODE,DS:DATA,SS:STACK

MAIN:
	MOV AX, DATA
	MOV DS, AX
	CALL init
START:
	MOV DX, M8255_C
	IN AL,DX
	MOV flag, 0
	TEST AL,02H
	JZ H1

	MOV AL, 76H  ;8253��ʼ��
       MOV DX, M8254_CON
       OUT DX, AL
       MOV DX, M8254_1
       MOV AL, 00H
       OUT DX, AL   ;���͵�8λ��������
       MOV AL, 48H
       OUT DX, AL   ;���͸�8λ������

	MOV BYTE PTR temp, 5
	;����ܳ�ʼ��ʾΪ5
	MOV AL, 6DH
       MOV DX, M8255_B
       OUT DX, AL

	MOV DX, M8255_CON  ; gateΪ�ߵ�ƽ����ʼ��ʱ
	MOV AL, 0FH
	OUT DX, AL
	MOV flag, 1
H1: 
	CALL LED
; start 
; 	��pc1��ȡ�ź�
; 	��� ���¿�ʼ����pc1 == 1���� flag = 1
; 	���� flag = 0
; 	call led����

PROD1:
	CMP BYTE PTR temp, 0
	JNZ duru
	CALL RESER
	JMP START
duru:	
	MOV DX, M8255_A
	IN AL, DX
	MOV AH, AL
	TEST AL, 0FFH
	JNE H2

	TEST flag, 01H
	JNZ PROD1
	JMP START
H2:
	MOV DX, M8255_CON  ; gateΪ�͵�ƽ��ֹͣ��ʱ
	MOV AL, 0EH
	OUT DX, AL
	CALL LIGHT
	CALL RING
	MOV flag, 0
	CALL RESER
	JMP START

; prod1 
; 	�� pa�˿� ��ȡ�ź�
; 	��� pa ==0����flag == 1, jmp prod1
; 	��� pa == 0����flag == 0��jmp  start
	
; 	�������
; 	call ���庯�� ring
; 	call ��λ���� reser

RESER PROC
RE:	MOV DX, M8255_C		; û�а��¸�λ��, ����jz RESER
	IN AL, DX
	TEST AL, 01H
	JZ RE
	MOV AL, 00H
	MOV DX, M8255_B
	OUT DX,AL
	MOV BYTE PTR temp, 5
	RET
RESER ENDP
; reser
; 	��pc�˿ڶ�ȡ�ź�
; 	��� pc0 == 1��flag == 0���������jmp start
; 	��� pc0 == 0��jmp reser




RING PROC
ring1:      
      CMP flag, 1
      JNZ ring2  ;��flag��Ϊ1����ת������2���ӳ�������ж�
      lea SI,ring1_fre  ;������1Ƶ�ʵ�ƫ�Ƶ�ַ��ֵ��SI
      lea DI,ring1_time  ;������1���ĵ�ƫ�Ƶ�ַ��ֵ��BP
      JMP play_start   ;���ò��������ӳ���

ring2:
	CMP flag, 2
	JZ ring3  ;��flag��Ϊ1����ת������2���ӳ�������ж�
	lea SI,ring2_fre  ;������2Ƶ�ʵ�ƫ�Ƶ�ַ��ֵ��SI
	lea DI,ring2_time  ;������2���ĵ�ƫ�Ƶ�ַ��ֵ��BP
	JMP play_start   ;���ò��������ӳ���
ring3:
	lea SI,ring3_fre  ;������2Ƶ�ʵ�ƫ�Ƶ�ַ��ֵ��SI
	lea DI,ring3_time  ;������2���ĵ�ƫ�Ƶ�ַ��ֵ��BP
	JMP play_start   ;���ò��������ӳ���
play_start:
	MOV BX,[SI]  ;����
	CMP BX,0  ;�ж������Ƿ�Ϊ0��Ϊ0��������������ӳ���
	JE end_play
	CALL sound   
	ADD SI,2
	ADD DI,2
	JMP play_start  ;����ִ�����ֲ����ӳ���ֱ��һ�����ֽ���
	   
end_play:
	MOV DX, M8255_B
	IN AL, DX
	AND AL, 7FH
	OUT DX, AL
       RET
RING ENDP

sound proc near
		;8253 оƬ������
       MOV AL, 036H  ;8253��ʼ��
       MOV DX, M8254_CON
       OUT DX, AL    ;43H��8253оƬ���ƿڵĶ˿ڵ�ַ
       MOV DX, 1cH    ;��16λ
       MOV AX, 2000h   ;��16λ                                        
       DIV BX    ;�����Ƶֵ,����ax��DI�д��������Ƶ��ֵ��
       MOV DX, M8254_0
       OUT DX, AL   ;���͵�8λ����������42h��8253оƬͨ��2�Ķ˿ڵ�ַ
       MOV AL, AH 
       OUT DX, AL   ;���͸�8λ������
	MOV DX, M8255_B
	IN AL, DX
	OR AL, 80H
	OUT DX, AL
       MOV DL,[DI]   ;����
delay:
	MOV CX, 0010H
D1:
	MOV AX, 0F00H
D2:	
	DEC AX
	JNZ D2
	LOOP D1
	DEC DL
	JNZ delay   ; ���治һ����ȷ
	MOV DX, M8255_B
	IN AL, DX
	AND AL, 7FH
	OUT DX, AL
      RET
sound ENDP



;ring	
;						��������0 gate��һֱ��Ч(��ʼ��)
;	���flag = 1��������0 �� 5
;	���� ������0 �� 60
;	pc6 = 1					����������
;	��� pc2��������0��OUT�� = 1����pc6 = 0
;	���� ѭ����ȡ pc2
LED PROC
	TEST flag, 01H
	JNZ H3
	MOV DX, M8255_CON
	MOV AL, 0AH
	OUT DX,AL
	MOV AL, 09H
	OUT DX,AL
	RET
H3:
	MOV DX, M8255_CON
	MOV AL, 0BH
	OUT DX,AL
	MOV AL, 08H
	OUT DX,AL
	RET
LED ENDP
; led	
; 	��� flag == 1��pc4 = 0��pc5 = 1		����led�̵�
; 	���� pc5 = 0��pc4 = 1			����led���

LIGHT PROC
	MOV AL, AH
	CMP AL, 01H  ;���µ��ǵ�һ������ 0000 0001
       JZ T1
       CMP AL, 02H  ;���µ��ǵڶ������� 0000 0010
       JZ T2
       CMP AL, 04H  ;���µ��ǵ��������� 0000 0100
       JZ T3
       CMP AL, 08H  ;���µ��ǵ��ĸ����� 0000 1000
       JZ T4
       CMP AL, 10H  ;���µ��ǵ�������� 0001 0000
       JZ T5
       CMP AL, 20H
       JZ T6
       CMP AL, 40H
       JZ T7
       CMP AL, 80H
       JZ T8

T1:                       ;�����µ��ǵ�һ�� ����ʾ1 ��06H��B��
	CMP flag, 0
	JZ TT1
	INC score[0]
TT1:
       MOV AL, 06H
       MOV DX, M8255_B
       OUT DX, AL
       RET      ;������ֱ����ת����ʼ
T2:
	CMP flag, 0
	JZ TT2
	INC score[1]
TT2:
       MOV AL, 5BH
       MOV DX, M8255_B
       OUT DX, AL
       RET
        
T3:
	CMP flag, 0
	JZ TT3
	INC score[2]
TT3:
       MOV AL, 4FH
       MOV DX, M8255_B
       OUT DX, AL
       RET
T4:
	CMP flag, 0
	JZ TT4
	INC score[3]
TT4:
       MOV AL, 66H
       MOV DX, M8255_B
       OUT DX, AL
       RET
T5:
	CMP flag, 0
	JZ TT5
	INC score[4]
TT5:
       MOV AL, 6DH
       MOV DX, M8255_B
       OUT DX, AL
       RET
T6:
	CMP flag, 0
	JZ TT6
	INC score[5]
TT6:
       MOV AL, 7CH
       MOV DX, M8255_B
       OUT DX, AL
       RET
T7:
	CMP flag, 0
	JZ TT7
	INC score[6]
TT7:
       MOV AL, 07H
       MOV DX, M8255_B
       OUT DX, AL
       RET
T8:
	CMP flag, 0
	JZ TT8
	INC score[7]
TT8:
       MOV AL, 7FH
       MOV DX, M8255_B
       OUT DX, AL
    RET
LIGHT ENDP

code_end PROC
	MOV flag, 2
	CALL RING
	MOV AH, 7
	MOV DH, score[7]
	MOV CX, 7
LP:
	MOV BX, CX
	DEC BX
	MOV DL, score[BX]
	CMP DL, DH
	JBE R
	MOV DH, DL
	MOV AH, BL

R:
	; PUSH AX
	; PUSH DX
	; MOV DL, AH
	; ADD DL, 30H
	; MOV AH, 2
	; INT 21H
	; POP DX
	; POP AX

	LOOP LP
	CMP DH, 0
	JNZ R1
	MOV AL, 3FH
	MOV DX, M8255_B
	OUT DX, AL
	JMP R2
R1:
	XOR BH, BH
	MOV BL, AH
	MOV AH, TABLE[BX]
	CALL LIGHT
R2:
	;��led
	MOV DX, M8255_C
	MOV AL, 00H
	OUT DX,AL
	MOV AH, 4CH
	INT 21H
	IRET
code_end ENDP

clock PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DS
	MOV CL, temp
	DEC CL
	MOV temp, CL

	CMP CL, 0
	JZ C0
	CMP CL, 01H
       JZ C1
       CMP CL, 02H
       JZ C2
       CMP CL, 03H
       JZ C3
       CMP CL, 04H
       JZ C4
C0:
	MOV AL, 3FH
	MOV DX, M8255_B
       OUT DX, AL
       MOV DX, M8255_CON  ; gateΪ�͵�ƽ��ֹͣ��ʱ
	MOV AL, 0EH
	OUT DX, AL
       JMP E
C1:                       ;�����µ��ǵ�һ�� ����ʾ1 ��06H��B��
       MOV AL, 06H
       MOV DX, M8255_B
       OUT DX, AL
       JMP E
C2:
       MOV AL, 5BH
       MOV DX, M8255_B
       OUT DX, AL
       JMP E
        
C3:
       MOV AL, 4FH
       MOV DX, M8255_B
       OUT DX, AL
       JMP E
C4:
       MOV AL, 66H
       MOV DX, M8255_B
       OUT DX, AL
E:
	MOV AL, 20H
	OUT 20H, AL
	POP DS
	POP DX
	POP CX
	POP BX
	POP AX
	IRET
clock ENDP


init PROC
MOV AL, 91H
	MOV DX, M8255_CON 
	OUT DX, AL ;8255��ʼ��
	MOV AL, 00H
	MOV DX, M8255_B
	OUT DX,AL

	PUSH DS
	MOV AX, 0000H
	MOV DS, AX
	MOV AX, OFFSET clock ; MIR6   code_end
	MOV SI, 0038H
	MOV [SI], AX
	MOV AX, CS
	MOV SI, 003AH
	MOV [SI], AX

	MOV AX, OFFSET code_end ; MIR7  clock
	MOV SI, 003CH
	MOV [SI], AX
	MOV AX, CS
	MOV SI, 003EH
	MOV [SI], AX

	CLI
	POP DS

	;��ʼ��8259 ��Ƭ
	MOV AL, 11H
	OUT 20H, AL ; ICW1
	MOV AL, 08H
	OUT 21H, AL ; ICW2
	MOV AL, 04H
	OUT 21H, AL ;ICW3
	MOV AL, 01H
	OUT 21H, AL ;ICW4
	MOV AL, 3FH ;OCW1	����7��6 00111111
	OUT 21H, AL
	STI
	RET
init ENDP

CODE ENDS
END MAIN