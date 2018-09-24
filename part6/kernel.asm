org 0x8000
bits 16 

;Let's begin by going into graphic mode
call initGraphics

;Main game loop
gameLoop:
	call resetBuffer ;reset screen to draw on empty canvas
	
	; BOX DRAW CODE
	mov cx, [player+2] ;player x to draw relative
	mov dx, [player+4] ;player z to draw relative
	mov di, box
	call drawEntity
	; END OF BOX DRAW CODE
	
	
	; PLAYER DRAWING CODE
	mov si, [player]   ;get animation
	mov ax, [player+6] ;get index within animation
	xor dx,dx
	div word [si+2]    ; animation time % time of full animation
	mov ax, dx
	xor dx, dx
	div word [si]      ; (animation time % time of full animation) /  time of one frame
	add ax, ax         ; index*2 because image address is a word
	
	add si, 4          ;skip first two words of structure
	add si, ax		   ;add the offset to the frame
	mov si, [si]       ;set the image parameter to the image referenced in the frame
	
	mov ax, 80/2 - 9/2 - 1      ;center player image
	mov bx, 50/2 - 12/2 - 1     ;center player image
	call drawImage
	; END OF PLAYER DRAWING CODE
	
	call copyBufferOver ;draw frame to screen
	
	call gameControls ;handle control logic
	
jmp gameLoop


jmp $

;di = entity cx,dx = xpos,zpos
drawEntity:
	mov si, word [di]   ;get animation
	mov si, word [si+4] ;get first frame of animation
	mov ax, word [di+2] ;get entity x
	sub ax, cx          ;subtract the position of the player from the x position
	add ax, 80/2 - 9/2 - 1  ;relative to screen image drawing code for x position
	mov bx, word [di+4] ;get entity y
	sub bx, dx          ;subtract the position of the player from the z position
	add bx, 50/2 - 12/2 - 1 ;relative to screen image drawing code for z position
	call drawImage      ;draw image to buffer
	ret

;di = entity, cx = new_xpos, dx = new_zpos, bp = new animation
checkForCollision:
	pusha                   ;save current state
	mov si, entityArray-2   ;set si to entityArray (-2 because we increment at the start of the loop)
	.whileLoop:
	add si, 2           ;set si to the next entry in the entityArray
	mov bx, word [si]   ;read entityArray entry
	test bx, bx         ;if entry is zero => end of array
	jz .whileEscape
	cmp bx, di          ;if entity is equal to di => next entity to not collide with it self
	jz .whileLoop
	
	mov ax, word [bx+2] ;ax = entity x
	sub ax, 8           ;subtract 8 because of hitbox
	cmp ax, cx ; (entityX-8 <= playerX)
		jg .whileLoop
		
	mov ax, word [bx+2] ;ax = entity x
	add ax, 8           ;add 8 because of hitbox
	cmp ax, cx ; (entityX+8 > playerX)
		jle .whileLoop

	mov ax, word [bx+4] ;ax = entity z
	sub ax, 10          ;subtract 10 because of hitbox
	cmp ax, dx ; (entityZ-10 <= playerZ)
		jg .whileLoop
		
	mov ax, word [bx+4] ;ax = entity z
	add ax, 9           ;subtract 9 because of hitbox
	cmp ax, dx ; (entityZ+9 > playerZ)
		jle .whileLoop
		
	;if we reach this point => actual collision
	mov cx, [di+2]         ;set new x pos to current x pos => no movement
	mov dx, [di+4]         ;set new z pos to current z pos => no movement
	mov word [player+6], 0 ;reset animation counter
	
	jmp .whileLoop         ;repeat for all entities in array
	.whileEscape:
	
	inc word [player+6]  ;update animation if moving
	mov word [di]   ,bp  ;update the animation in use
	mov word [di+2] ,cx  ;update x pos
	mov word [di+4] ,dx  ;update y pos
	popa                 ;reload old register state
	ret

gameControls:
	mov di, player ;select the player as the main entity for "checkForCollision"
	call checkKey  ;check if a key is pressed
	jz .nokey
		mov cx, word [player_PosX] ;set cx to player x
		mov dx, word [player_PosZ] ;set dx to player z
		mov bp, [player]           ;set bp to current animation
		cmp ah, 0x20 ;try to move x+1 if 'd' is pressed and set animation accordingly, test other cases otherwise
		jne .n1
		inc cx
		mov bp, playerImg_right
		.n1: cmp ah, 0x1e ;try to move x-1 if 'a' is pressed and set animation accordingly, test other cases otherwise
		jne .n2
		dec cx
		mov bp, playerImg_left
		.n2: cmp ah, 0x11 ;try to move z-1 if 'w' is pressed and set animation accordingly, test other cases otherwise
		jne .n3
		dec dx
		mov bp, playerImg_back
		.n3: cmp ah, 0x1F ;try to move z+1 if 's' is pressed and set animation accordingly, test other cases otherwise
		jne .n4
		inc dx
		mov bp, playerImg_front
		.n4:
		call checkForCollision ;check if player would collide on new position, if not change position to new position
	.nokey:
	ret

checkKey:
	mov ah, 1
	int 0x16   ;int 0x16 ah=1 => read key status, zeroflag if no key pressed
	jz .end
	mov ax, 0  ;int 0x16 ah=0 => read key
	int 0x16
	ret
	.end:
	mov ax, 0  ;return 0 if no key is pressed
	ret
	
%include "buffer.asm"


;entity array
entityArray:
			dw player
			dw box
			dw 0

;player structure
player:
player_Anim  dw playerImg_front ;pointer to animation
player_PosX  dw 0               ;position of player (x)
player_PosZ  dw 0               ;position of player (z)
player_AnimC dw 0               ;animation counter

;entity structure
box:
box_Anim  dw boxImg          ;pointer to animation
box_PosX  dw 0x10            ;position of box (x)
box_PosZ  dw 0x10            ;position of box (z)
box_AnimC dw 0               ;animation counter

;animation structure
playerImg_front:
	dw 5
	dw 20
	dw playerImg_front_0
	dw playerImg_front_1
	dw playerImg_front_0
	dw playerImg_front_2
	dw 0
	
playerImg_back:
    dw 5
	dw 20
	dw playerImg_back_0
	dw playerImg_back_1
	dw playerImg_back_0
	dw playerImg_back_2
	dw 0
	
playerImg_right:
    dw 5
	dw 20
	dw playerImg_right_0
	dw playerImg_right_1
	dw playerImg_right_0
	dw playerImg_right_2
	dw 0
	
playerImg_left:
	dw 5
	dw 20
	dw playerImg_left_0
	dw playerImg_left_1
	dw playerImg_left_0
	dw playerImg_left_2
	dw 0
	
boxImg:
	dw 1            ;time per frames
	dw 1            ;time of animation
	dw boxImg_0     ;frames
	dw 0            ;zero end frame

playerImg_front_0 incbin "img/player_front_0.bin"
playerImg_front_1 incbin "img/player_front_1.bin"
playerImg_front_2 incbin "img/player_front_2.bin"
playerImg_back_0  incbin "img/player_back_0.bin"
playerImg_back_1  incbin "img/player_back_1.bin"
playerImg_back_2  incbin "img/player_back_2.bin"
playerImg_right_0 incbin "img/player_right_0.bin"
playerImg_right_1 incbin "img/player_right_1.bin"
playerImg_right_2 incbin "img/player_right_2.bin"
playerImg_left_0  incbin "img/player_left_0.bin"
playerImg_left_1  incbin "img/player_left_1.bin"
playerImg_left_2  incbin "img/player_left_2.bin"

boxImg_0          incbin "img/box.bin"

%assign usedMemory ($-$$)
%assign usableMemory (512*16)
%warning [usedMemory/usableMemory] Bytes used
times (512*16)-($-$$) db 0 ;kernel must have size multiple of 512 so let's pad it to the correct size