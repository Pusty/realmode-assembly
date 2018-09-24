;this kernel just renders some fancy shapes on the screen
org 0x8000
bits 16 

mov ah, 0   ;set display mode
mov al, 13h ;13h = 320x200
int  0x10

mov al, 2  ;COLOR
mov cx, 30 ;X-POS
mov dx, 20  ;Y-POS
mov si, 32 ;X-SIZE
mov di, 32
call drawCircle
mov al, 4
mov cx, 128
mov dx, 30
call drawBox

jmp $

;------------------------------------------------------
;cx = xpos , dx = ypos, si = x-length, di = y-length, al = color
drawBox:
	push si        ;save x-length
	.for_x:
		push di    ;save y-length
		.for_y:
			pusha
			;mov al, 1    ;color value
			mov bh, 0    ;page number
			add cx, si    ;cx = x-coordinate
			add dx, di    ;dx = y-coordinate
			mov ah, 0xC  ;write pixel at coordinate
			int 0x10     ;might "destroy" ax, si and di on some systems
			popa
		sub di, 1  ;decrease di by one and set flags
		jnz .for_y ;repeat for y-length
		pop di     ;restore di
	sub si, 1      ;decrease si by one and set flags
	jnz .for_x     ;repeat for x-length
	pop si         ;restore si
	ret
;------------------------------------------------------

;------------------------------------------------------
;cx = xpos , dx = ypos, si = radius, al = color
drawCircle:
	pusha          ;save all registers
	mov di, si
	add di, si     ; di = si * 2
	mov bp, si     ;bp is just another general purpose register for us
	add si, si     ; si = si * 2
	.for_x:
		push di    ;save y-length
		.for_y:
			pusha
			add cx, si    ;cx = x-coordinate
			add dx, di    ;dx = y-coordinate
			
			; (x-r)^2 + (y-r)^2  = (distance of x,y from middle of circle with radius r) ^ 2
			; (x-r)^2 + (y-r)^2  <= r^2 , as long as radius squared is bigger than distance squared ,point is within the circle
			; (si-bp)^2 + (di-bp)^2 <= bp^2
			sub si, bp      ;di = y - r
			sub di, bp      ;di = x - r
			imul si, si     ;si = x^2
			imul di, di     ;di = y^2
			add si, di      ;add (x-r)^2 and (y-r)^2
			imul bp, bp     ;signed multiplication, r * r = r^2
			cmp si, bp      ;if r^2 >= distance^2: point is within circle
			jg .skip        ;if greater: point is not within circle
					
			;mov al, 1   ;color value
			mov bh, 0    ;page number
			mov ah, 0xC  ;write pixel at coordinate
			int 0x10     ;might "destroy" ax, si and di on some systems
			.skip:
			popa
		sub di, 1  ;decrease di by one and set flags
		jnz .for_y ;repeat for y-length
		pop di     ;restore di
	sub si, 1      ;decrease si by one and set flags
	jnz .for_x     ;repeat for x-length
	popa           ;restore all registers
	ret
;------------------------------------------------------



%assign usedMemory ($-$$)
%assign usableMemory (512*16)
%warning [usedMemory/usableMemory] Bytes used
times (512*16)-($-$$) db 0 ;kernel must have size multiple of 512 so let's pad it to the correct size