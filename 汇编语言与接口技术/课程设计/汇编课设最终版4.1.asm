;初始化各个芯片
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

flag DB 0;	初始 开始标志flag = 0，复位标志
temp DB 5
score DB 8 DUP(0)
TABLE DB 1, 2, 4, 8, 16, 32, 64, 128

ring1_fre DW 1100,600, 0  ;音乐的频率
ring1_time DW 3, 2, 11    ;音乐的节拍

ring2_fre DW 300, 0  ;音乐的频率
ring2_time DW 10, 11    ;音乐的节拍

ring3_fre DW 300, 400, 500, 600, 0  ;音乐的频率
ring3_time DW 1, 1, 1, 1, 1    ;音乐的节拍

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

	MOV AL, 76H  ;8253初始化
       MOV DX, M8254_CON
       OUT DX, AL
       MOV DX, M8254_1
       MOV AL, 00H
       OUT DX, AL   ;先送低8位到计数器
       MOV AL, 48H
       OUT DX, AL   ;后送高8位计数器

	MOV BYTE PTR temp, 5
	;数码管初始显示为5
	MOV AL, 6DH
       MOV DX, M8255_B
       OUT DX, AL

	MOV DX, M8255_CON  ; gate为高电平，开始计时
	MOV AL, 0FH
	OUT DX, AL
	MOV flag, 1
H1: 
	CALL LED
; start 
; 	从pc1读取信号
; 	如果 按下开始键（pc1 == 1）则 flag = 1
; 	否则 flag = 0
; 	call led函数

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
	MOV DX, M8255_CON  ; gate为低电平，停止计时
	MOV AL, 0EH
	OUT DX, AL
	CALL LIGHT
	CALL RING
	MOV flag, 0
	CALL RESER
	JMP START

; prod1 
; 	从 pa端口 读取信号
; 	如果 pa ==0，且flag == 1, jmp prod1
; 	如果 pa == 0，且flag == 0，jmp  start
	
; 	亮数码管
; 	call 响铃函数 ring
; 	call 复位函数 reser

RESER PROC
RE:	MOV DX, M8255_C		; 没有按下复位键, 不能jz RESER
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
; 	从pc端口读取信号
; 	如果 pc0 == 1，flag == 0，数码管灭，jmp start
; 	如果 pc0 == 0，jmp reser




RING PROC
ring1:      
      CMP flag, 1
      JNZ ring2  ;若flag不为1，跳转到音乐2的子程序接着判断
      lea SI,ring1_fre  ;将铃声1频率的偏移地址赋值给SI
      lea DI,ring1_time  ;将铃声1节拍的偏移地址赋值给BP
      JMP play_start   ;调用播放音乐子程序

ring2:
	CMP flag, 2
	JZ ring3  ;若flag不为1，跳转到音乐2的子程序接着判断
	lea SI,ring2_fre  ;将铃声2频率的偏移地址赋值给SI
	lea DI,ring2_time  ;将铃声2节拍的偏移地址赋值给BP
	JMP play_start   ;调用播放音乐子程序
ring3:
	lea SI,ring3_fre  ;将铃声2频率的偏移地址赋值给SI
	lea DI,ring3_time  ;将铃声2节拍的偏移地址赋值给BP
	JMP play_start   ;调用播放音乐子程序
play_start:
	MOV BX,[SI]  ;音符
	CMP BX,0  ;判断音符是否为0，为0则结束播放音乐子程序
	JE end_play
	CALL sound   
	ADD SI,2
	ADD DI,2
	JMP play_start  ;继续执行音乐播放子程序，直至一首音乐结束
	   
end_play:
	MOV DX, M8255_B
	IN AL, DX
	AND AL, 7FH
	OUT DX, AL
       RET
RING ENDP

sound proc near
		;8253 芯片的设置
       MOV AL, 036H  ;8253初始化
       MOV DX, M8254_CON
       OUT DX, AL    ;43H是8253芯片控制口的端口地址
       MOV DX, 1cH    ;高16位
       MOV AX, 2000h   ;低16位                                        
       DIV BX    ;计算分频值,赋给ax。DI中存放声音的频率值。
       MOV DX, M8254_0
       OUT DX, AL   ;先送低8位到计数器，42h是8253芯片通道2的端口地址
       MOV AL, AH 
       OUT DX, AL   ;后送高8位计数器
	MOV DX, M8255_B
	IN AL, DX
	OR AL, 80H
	OUT DX, AL
       MOV DL,[DI]   ;节拍
delay:
	MOV CX, 0010H
D1:
	MOV AX, 0F00H
D2:	
	DEC AX
	JNZ D2
	LOOP D1
	DEC DL
	JNZ delay   ; 下面不一定正确
	MOV DX, M8255_B
	IN AL, DX
	AND AL, 7FH
	OUT DX, AL
      RET
sound ENDP



;ring	
;						；计数器0 gate端一直有效(初始化)
;	如果flag = 1，计数器0 置 5
;	否则 计数器0 置 60
;	pc6 = 1					；接扬声器
;	如果 pc2（计数器0的OUT） = 1，置pc6 = 0
;	否则 循环读取 pc2
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
; 	如果 flag == 1，pc4 = 0，pc5 = 1		；接led绿灯
; 	否则 pc5 = 0，pc4 = 1			；接led红灯

LIGHT PROC
	MOV AL, AH
	CMP AL, 01H  ;按下的是第一个开关 0000 0001
       JZ T1
       CMP AL, 02H  ;按下的是第二个开关 0000 0010
       JZ T2
       CMP AL, 04H  ;按下的是第三个开关 0000 0100
       JZ T3
       CMP AL, 08H  ;按下的是第四个开关 0000 1000
       JZ T4
       CMP AL, 10H  ;按下的是第五个开关 0001 0000
       JZ T5
       CMP AL, 20H
       JZ T6
       CMP AL, 40H
       JZ T7
       CMP AL, 80H
       JZ T8

T1:                       ;若按下的是第一个 则显示1 送06H给B口
	CMP flag, 0
	JZ TT1
	INC score[0]
TT1:
       MOV AL, 06H
       MOV DX, M8255_B
       OUT DX, AL
       RET      ;灯亮后直接跳转至开始
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
	;灭led
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
       MOV DX, M8255_CON  ; gate为低电平，停止计时
	MOV AL, 0EH
	OUT DX, AL
       JMP E
C1:                       ;若按下的是第一个 则显示1 送06H给B口
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
	OUT DX, AL ;8255初始化
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

	;初始化8259 主片
	MOV AL, 11H
	OUT 20H, AL ; ICW1
	MOV AL, 08H
	OUT 21H, AL ; ICW2
	MOV AL, 04H
	OUT 21H, AL ;ICW3
	MOV AL, 01H
	OUT 21H, AL ;ICW4
	MOV AL, 3FH ;OCW1	开启7，6 00111111
	OUT 21H, AL
	STI
	RET
init ENDP

CODE ENDS
END MAIN