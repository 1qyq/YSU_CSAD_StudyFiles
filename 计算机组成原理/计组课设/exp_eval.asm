data segment
	midque db 3, '&', '(', 4, '-', 1, ')', '$'    ;  
	mem db 600 dup(?)    ;  规定50 -- 99 ， 100 -- 149 为栈 
	lastque db 7 dup(?)
data ends

stack segment
	db 100 dup(0)
stack ends

code segment
assume cs : code, ds : data, ss : stack
start:
	mov ax, data
	mov ds, ax
	mov bx, '&'
	mov BYTE ptr [bx], 2
	mov bx, '-'
	mov BYTE ptr [bx], 1
	mov bx, '('
	mov BYTE ptr [bx], 0
	mov bx, ')'
	mov BYTE ptr [bx], 0
	mov dh, 50  ;栈指针
	mov bx, 0   ;原表达式指针
	lea cx, lastque; 后缀表达式指针
LP:
	mov al, BYTE ptr [bx] ; 表达式
	cmp al, 5  ;规定数字小于5
	jb num
	cmp al, '('  ; (
	jz left
	cmp al, ')'  ; )
	jz right
	cmp al, '$' 
	jnz op
	jmp popstack

left:
	push bx
	xor bh, bh
	mov bl, dh
	mov byte ptr [bx], '('  ;'(' 此处汇编不能执行,dh需修改
	inc dh
	pop bx
	jmp return

right:  ; 已用寄存器 bx原表达式指针, dh栈顶指针, cx后缀表达式指针
	dec dh
	push bx
	xor bh, bh
	mov bl, dh
	mov al, BYTE ptr[bx]  ; 取栈顶元素， 不能执行
	cmp al, '(' ; '('
	pop bx
	jz return
	push bx
	mov bx, cx
	mov BYTE ptr [bx], al  ; 不能执行
	inc cx
	pop bx
	jmp right

num:
	push bx
	mov bx, cx
	mov BYTE ptr [bx], al;
	inc cx
	pop bx
	jmp return

op:    ; al, bx, dh, cx 将bx(此处以ah代替) push入手写栈
	cmp dh, 50
	jz pu
	push bx ; 此处应用手写栈来存
	xor bh, bh
 again:
	dec dh
	mov bl, dh
	mov ah, BYTE ptr [bx];
	push ax  ; 此处应用手写栈push al和ah
	mov bl, al
	mov al, [bx]
	mov bl, ah
	mov ah, [bx]
	cmp al, ah
	ja pushstack
	;mov si, ax ; 此处为保存al的优先级，实际不需要
	pop ax
	mov bx, cx
	mov byte ptr [bx], ah
	inc cx
	cmp dh, 50
	jz pu
	jmp again

pu:
	push bx
	xor bh, bh
	mov bl, dh
	mov [bx], al
	inc dh
	pop bx
	jmp return

pushstack:
	inc dh ; 恢复原来栈顶指针
	pop ax
	mov bl, dh
	mov BYTE ptr [bx], al  ; 实际应先pop bx再将al入栈
	inc dh
	pop bx

return:
	inc bx
	jmp LP

popstack:
	cmp dh, 50
	jz lastend
	dec dh
	mov bl, dh
	mov al, [bx]
	mov bx, cx
	mov [bx], al
	inc cx
	jmp popstack
lastend:
	mov bx, cx
	mov BYTE ptr [bx], '$'
	push dx
	lea dx, lastque
	mov ah, 09h
	int 21h
	pop dx
	
	;求表达式的值
	; cx放后缀偏移地址， dh放栈地址, al放后缀表达式的符号和栈里的数字, ah放栈里的数字
	lea cx, lastque
LP2:
	mov bx, cx
	mov al, [bx]
	cmp al, '$'
	jz valueend  ; 计算结束
	cmp al, 5
	jb pushnum ; 将数字入栈
	jmp calculate  ;进行运算
pushnum:      ;将数字入栈
	xor bh, bh
	mov bl, dh
	mov [bx], al
	inc dh
	jmp return2
calculate:				;进行运算
	cmp al, '-'   ;  检测运算符
	jz subnum
	;将栈顶数字放在ah里，次栈顶数字放在al里
	dec dh
	xor bh, bh
	mov bl, dh
	mov ah, [bx]
	dec dh
	mov bl, dh
	mov al, [bx]
	and al, ah
	jmp pushagain ;  运算结束将结果放回栈顶
subnum:
   dec dh
	xor bh, bh
	mov bl, dh
	mov ah, [bx]
	dec dh
	mov bl, dh
	mov al, [bx]
	sub al, ah
pushagain:			;  运算结束将结果放回栈顶
	xor bh, bh
	mov bl, dh
	mov [bx], al
	inc dh
	jmp return2
	
return2:
	inc cx2
0	jmp LP2
valueend: ;结果在栈底保存 即内存0032处
	;dec dh
	;xor bh, bh
	;mov bl, dh
	;mov al, [bx]
	mov ah, 4ch
	int 21h
code ends
 end start