org 0x8000
bits 16 

mov ah, 0   ;set display mode
mov al, 13h ;13h = 320x200
int  0x10

mov si, imageFile
call drawImage ;draw image

jmp $

;------------------------------------------------------
;si = image source
drawImage:
	pusha
	xor ax, ax
	lodsb
	mov cx, ax ;x-position
	lodsb
	mov dx, ax ;y-position
	.for_x:
		push dx
		.for_y:
			mov bh, 0  ;page number
			lodsb       ;al (color) -> next byte
			mov ah, 0xC ;write pixel at coordinate
			int 0x10 ;might "destroy" ax, si and di on some systems
		sub dx, 1  ;decrease dx by one and set flags
		jnz .for_y ;repeat for y-length
		pop dx     ;restore dx
	sub cx, 1      ;decrease si by one and set flags
	jnz .for_x     ;repeat for x-length
	popa
	ret
;------------------------------------------------------

imageFile: incbin "image.bin" ;include the image binary

%assign usedMemory ($-$$)
%assign usableMemory (512*16)
%warning [usedMemory/usableMemory] Bytes used
times (512*16)-($-$$) db 0 ;kernel must have size multiple of 512 so let's pad it to the correct size