data segment
	midque db 3, '&', '(', 4, '-', 1, ')', '$'    ;  
	mem db 600 dup(?)    ;  �涨50 -- 99 �� 100 -- 149 Ϊջ 
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
	mov dh, 50  ;ջָ��
	mov bx, 0   ;ԭ���ʽָ��
	lea cx, lastque; ��׺���ʽָ��
LP:
	mov al, BYTE ptr [bx] ; ���ʽ
	cmp al, 5  ;�涨����С��5
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
	mov byte ptr [bx], '('  ;'(' �˴���಻��ִ��,dh���޸�
	inc dh
	pop bx
	jmp return

right:  ; ���üĴ��� bxԭ���ʽָ��, dhջ��ָ��, cx��׺���ʽָ��
	dec dh
	push bx
	xor bh, bh
	mov bl, dh
	mov al, BYTE ptr[bx]  ; ȡջ��Ԫ�أ� ����ִ��
	cmp al, '(' ; '('
	pop bx
	jz return
	push bx
	mov bx, cx
	mov BYTE ptr [bx], al  ; ����ִ��
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

op:    ; al, bx, dh, cx ��bx(�˴���ah����) push����дջ
	cmp dh, 50
	jz pu
	push bx ; �˴�Ӧ����дջ����
	xor bh, bh
 again:
	dec dh
	mov bl, dh
	mov ah, BYTE ptr [bx];
	push ax  ; �˴�Ӧ����дջpush al��ah
	mov bl, al
	mov al, [bx]
	mov bl, ah
	mov ah, [bx]
	cmp al, ah
	ja pushstack
	;mov si, ax ; �˴�Ϊ����al�����ȼ���ʵ�ʲ���Ҫ
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
	inc dh ; �ָ�ԭ��ջ��ָ��
	pop ax
	mov bl, dh
	mov BYTE ptr [bx], al  ; ʵ��Ӧ��pop bx�ٽ�al��ջ
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
	
	;����ʽ��ֵ
	; cx�ź�׺ƫ�Ƶ�ַ�� dh��ջ��ַ, al�ź�׺���ʽ�ķ��ź�ջ�������, ah��ջ�������
	lea cx, lastque
LP2:
	mov bx, cx
	mov al, [bx]
	cmp al, '$'
	jz valueend  ; �������
	cmp al, 5
	jb pushnum ; ��������ջ
	jmp calculate  ;��������
pushnum:      ;��������ջ
	xor bh, bh
	mov bl, dh
	mov [bx], al
	inc dh
	jmp return2
calculate:				;��������
	cmp al, '-'   ;  ��������
	jz subnum
	;��ջ�����ַ���ah���ջ�����ַ���al��
	dec dh
	xor bh, bh
	mov bl, dh
	mov ah, [bx]
	dec dh
	mov bl, dh
	mov al, [bx]
	and al, ah
	jmp pushagain ;  �������������Ż�ջ��
subnum:
   dec dh
	xor bh, bh
	mov bl, dh
	mov ah, [bx]
	dec dh
	mov bl, dh
	mov al, [bx]
	sub al, ah
pushagain:			;  �������������Ż�ջ��
	xor bh, bh
	mov bl, dh
	mov [bx], al
	inc dh
	jmp return2
	
return2:
	inc cx2
0	jmp LP2
valueend: ;�����ջ�ױ��� ���ڴ�0032��
	;dec dh
	;xor bh, bh
	;mov bl, dh
	;mov al, [bx]
	mov ah, 4ch
	int 21h
code ends
 end start