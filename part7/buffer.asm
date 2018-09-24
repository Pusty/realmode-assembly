%ifndef CODE_BUFFER
    %define CODE_BUFFER
	
;set's graphic mode	
initGraphics:
	mov ah, 0   ;set display mode
	mov al, 13h ;13h = 320x200
	int  0x10
	ret

;resets screen to full black
resetBuffer:
	pusha
	mov cx, 80*60/2
	;xor ax, ax ;this will make the background black
	mov ax, 0xC3C3 ;this paints the background green
	mov di, [screenPos]
	rep stosw
	popa
	ret

;screen has size 320x200 but buffer only 80x60
copyBufferOver:
	pusha
	push es
    mov es, word [graphicMemory]
    xor di, di
	mov cx, 200
	.loop:
		mov dx, cx
		mov cx, 320/4
		.innerloop:
			mov si, 320
			sub si, cx ;invert x-axis
			mov bx, 200
			sub bx, dx ;invert y-axis
			shr bx, 2
			imul bx, 80
			add si, bx
			add si, [screenPos]
			lodsb ;read from buffer (ds:si)
			mov ah, al
			stosw ;write 4 pixel row to graphic memory (es:di)
			stosw
		loop .innerloop
		mov cx, dx
	loop .loop
	pop es
	popa
	ret
	
;si = position of image, ax = xpos, bx = ypos
;a bit messy because of all the error checks to not draw out of screen
drawImage:
	pusha
	xor di, di
	imul di, bx, 80     ;add offset y-position
	add di, [screenPos] ;make it a pixel in buffer
	;add di, ax          ;add offset x-position
	mov bp, ax          ;backup x-position offset
	xor ax, ax
	lodsb
	mov cx, ax ;x-size
	lodsb
	mov dx, ax ;y-size
	.for_y: 
			mov bx, di
			add bx, cx ;bx = offsetOnScreen + xsize
			sub bx, word [screenPos]  ;skip if line is out of top border screen
			jl .skip_x
			sub bx, cx
			sub bx, 80*60
			jge .skip_x   ;skip if line is out of bottom border screen
			xor bx, bx
		.for_x:
			mov al, byte [si+bx]
			add bx, bp
			test al, al  ;skip 0bytes as transparent
			jz .skip
			cmp bx, 80   ;if pixel is right out of screen, skip it
			jge .skip
			cmp bx, 0    ;if pixel is left out of screen, skip it
			jl .skip			
			mov byte [di+bx], al ;write byte to buffer
			.skip:
			sub bx, bp
			inc bx
			cmp bx, cx
		jl .for_x
		.skip_x:
		add di, 80 ;next row within buffer
		add si, cx ;next row within image
		dec dx
	jnz .for_y ;repeat for y-length
	popa
	ret

graphicMemory dw 0xA000
screenPos dw 0x0500 ;double buffer will be at this address

%endif