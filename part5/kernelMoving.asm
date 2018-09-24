;This kernel renders a moving square on the screen
org 0x8000
bits 16 

mov ah, 0   ;set display mode
mov al, 13h ;13h = 320x200
int  0x10

mov cx, 160-10 ;let start position be the middle of the screen
mov dx, 100-10
mov si, 20    ;size of square = 20x20 pixel
mov di, 20
mov al, 4     ;red color
main:

call drawBox ;draw our little square

;CLEAR SCREEN AND DON'T CHANGE CONTEXT
pusha
xor al, al
xor dx, dx
xor dx, dx
mov si, 320
mov di, 200
call drawBox
popa
;CLEAR SCREEN AND DON'T CHANGE CONTEXT

add cx, 10     ;add 10 the the x-position of the square
cmp cx, 320-20 ;if square reaches out of screen: reset its x-position
jge .reset
jmp .skip
.reset:
	mov cx, 0
.skip:

jmp main ;loop this

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

%assign usedMemory ($-$$)
%assign usableMemory (512*16)
%warning [usedMemory/usableMemory] Bytes used
times (512*16)-($-$$) db 0 ;kernel must have size multiple of 512 so let's pad it to the correct size