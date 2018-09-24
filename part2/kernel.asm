org 0x8000 
bits 16
mov si, msg
call printNullTerminatedString

jmp $   ; this freezes the system, best for testing
hlt		;this makes a real system halt
ret     ;this makes qemu halt, to ensure everything works we add both

printCharacter:
	;before calling this function al must be set to the character to print
	mov bh, 0x00 ;page to write to, page 0 is displayed by default
	mov bl, 0x00 ;color attribute, doesn't matter for now
	mov ah, 0x0E 
	int 0x10 ; int 0x10, 0x0E = print character in al
	ret	
printNullTerminatedString:
	pusha ;save all registers to be able to call this from where every we want
	.loop:
		lodsb ;loads byte from si into al and increases si
		test al, al ;test if al is 0 which would mean the string reached it's end
		jz .end
		call printCharacter ;print character in al
	jmp .loop ;print next character
	.end:
	popa ;restore registers to original state
	ret
msg db "Hello World!"
times 512-($-$$) db 0 ;kernel must have size multiple of 512 so let's pad it to the correct size