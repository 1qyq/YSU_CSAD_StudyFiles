data segment

operator db '+', '-', '(', ')', '&', '|'

exp db  1, '|', '(', 4, '-', 2, ')','$'
len dw $ - exp
op db 10 dup(?),'$'
num db 10 dup(?),'$'
houexp db 20 dup(?), '$'
p1 db ?
n1 db ?
data ends

stack segment stack
db 200(0)
stack ends
;一个栈, 一个操作数栈
;遇到左括号则进符号栈
;遇到右括号则计算括号内的值直到pop左括号
;其他符号判断优先级, 优先级大于栈顶符号则入栈,
;否则计算表达式直到优先级小于等于栈顶符号, 然后入符号栈
code segment
assume cs:code, ds:data, ss:stack
;首先定义两个

begin:
	mov ax, data
	mov ds, ax
	
	mov cx, len
	lea bx, exp
	lea di, operator
	lea si, num +1
lp:
	push cx; 											保护现场,循环表达式
	mov cx, 5
lp1:
	mov ax, [di]
	cmp [bx], ax
	jz jinop; 											把操作符移入op栈
	inc di
	loop lp1
	
	;															exp中是数字则
	mov ax, [bx]; 									把数字移入num栈
	mov [si], ax
	jmp ex
	
jinop:	; 													把操作符移入op栈
	mov ax, [bx]
	;push si;												数字栈指针保存
	mov dl, [op]; 									第一个数存数量
	push cx	;											对要进栈的符号循环比较优先级
	mov cl, dl
lp2:
	cmp op + dl, ax
	ja chufuhao;									当前栈顶符号优先级大
	mov op + dl, ax
	jmp en
chufuhao:
	inc si
	mov [si], op + dl;											进数字栈
	dec dl
	
en:
	push di
	lea di, 
	inc si
	mov op, si
	pop si
ex:

	inc bx
	pop cx
	loop lp
	