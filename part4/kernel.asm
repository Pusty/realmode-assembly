org 0x8000
bits 16 
;NOTE: Program crashes when trying to divide by 0

;Initial Clear
push main_loop
jmp clearCommand

main_loop:
	call printNL
skip_NL:
	push main_loop
	mov si, input
	call printString
	call readString
	mov si, command0
	call stringCompare
	je helpCommand
	mov si, command1
	call stringCompare
	je subNumbers
	mov si, command2
	call stringCompare
	je addNumbers
	mov si, command3
	call stringCompare
	je mulNumbers
	mov si, command4
	call stringCompare
	je divNumbers
	mov si, command5
	call stringCompare
	je clearCommand
	.commandN:
		mov si, commandStr
		jmp printString
jmp $   ; program should never arrive here
;------------------------------------------------------
;                Basic Math OS Functions
addNumbers:
call mathBase
	add dx, cx
	call printHexW
	ret
subNumbers:
	call mathBase
	sub dx, cx
	call printHexW
	ret
mulNumbers:
	call mathBase
	mov ax, dx
	xor dx, dx
	mul cx
	mov dx, ax
	call printHexW
	ret
divNumbers:
	call mathBase
	mov ax, dx
	xor dx, dx
	div cx
	mov dx, ax
	call printHexW
	ret
clearCommand: ;pretty dirty implementation
	mov cx, 24 ;empty lines
	.loop:
	call printNL
	loop .loop
	mov ah, 0x02 ;set cursor
	mov bh, 0x00 ;page 0
	mov dh, 0x00 ;0th row
	mov dl, 0x00 ;0th char
	int 0x10 ;set cursor
	pop cx
	add cx, (skip_NL-main_loop)
	push cx
	ret
helpCommand:
	mov si, helpStr
	call printString
	ret
	
mathBase:
	call read2Numbers
	;Calculate result and print
	mov [num2], dx
	mov si, numRStr
	call printString
	mov dx, [num1]
	mov cx, [num2]
	ret
read2Numbers:
	;Read 1st Number
	mov si, num1Str
	call printString
	call readString
	mov si, di
	call hexstr2num
	mov [num1], dx
	;Read 2nd Number
	mov si, num2Str
	call printString
	call readString
	mov si, di
	call hexstr2num
	ret

;------------------------------------------------------


num1 dd 0
num2 dd 0

input db "Input: ",0
num1Str db "[1]: ",0
num2Str db "[2]: ",0
numRStr db "[R]: ",0
commandStr db "Unknown command.",0
helpStr db "Known commands: help, sub, add, mul, div and clear",0
command0 db "help",0
command1 db "sub",0
command2 db "add",0
command3 db "mul",0
command4 db "div",0
command5 db "clear",0

;------------------------------------------------------
;zero flag = set if equals
stringCompare:
	pusha                                 ;save all registers
	or cx, -1                             ;set cx to biggest unsigned number
	xor al, al                            ;set al to 0
	repne scasb                           ;scan through di until zero terminator was hit and decrease cx for each scanned character
	neg cx                                ;calculate length of di by negating cx which returns the length of the string including zero terminator
	sub di, cx                            ;reset di by setting it to the original index it started with
	inc di
	repe cmpsb                            ;check if character from di match with si (including zero terminator)
	test cx, cx                           ;test if amount of matching = size of string, set zero flag if equals
	popa                                  ;restore all registers
	ret
;------------------------------------------------------

;------------------------------------------------------
;=> dx = hex => zf (zf = FAILED), si = input str |
hexstr2num:
	push ax                                ;save ax and si  
	push si
	xor dx, dx                             ;reset dx and ax to use them for working (dx will contain the resulting number)
	xor ax, ax
	.loop:
		lodsb                              ;load ASCII character from inputed string SI into AL and increase SI
		test al, al                        ;end reading in if reached zero terminator
		jz .end
		shl dx, 4                          ;shifting left by 4 => multiplying with 16
		cmp al, '0'
			jl .error                      ;if character is less than 0x30 it can't be a number or character
		cmp al, '9'
			jle .num                       ;if character is within the range of 0x30 and 0x39 it's a number
		cmp al, 'A'
			jl .error                      ;if character is bigger than 0x39 and smaller than 0x42 it's not a character
		cmp al, 'F'
			jle .clet                      ;if character is within the range of 0x42 and 0x46 it's a uppercased hex character
		cmp al, 'a'
			jl .error                      ;if character is bigger than 0x46 and smaller than 0x61 it's not a lowercased character
		cmp al, 'f'
			jle .slet                      ;if character is within the range of 0x61 and 0x66 it's a lowercased hex character
		jmp .error                         ;if it's not a number or a hex character => error
		.num:
			sub al, '0'                    ;subtract 0x30 from ASCII number to get value
			jmp .continue
		.clet:
			sub al, 'A'-0xA                ;subtract 0x42 and add 0xA to ASCII uppercased hex character to get value
			jmp .continue
		.slet:
			sub al, 'a'-0xA                ;subtract 0x61 and add 0xA to ASCII lowercased hex character to get value
		.continue:
		add dx, ax                         ;lastResult = (lastResult * 16) + currentNumber;
		jmp .loop	                       ;loop to the next character
	xor ax, ax
	cmp ax, 1                              ;ax != 1 => zero flag not set
	jmp .end
	.error:
		xor dx, dx
		test dx, dx                        ;dx == 0 => zero flag set
	.end:
	pop si                                 ;restore si and ax
	pop ax
	ret
;------------------------------------------------------

;------------------------------------------------------
;=>di = string inputed => zf = (1 if nothing read) | ax
;Not a really good function but does what it's supposed to do, very dirty implementation of live feedback
%define readString_size 8 ;buffer max size

readString:
	mov di, .buffer
	.inner:
		call readChar
		jz .inner                          ;if input == 0 repeat reading until enter or max size
		cmp ah, 0x1C                       ;enter
		je .end
		cmp ah, 0x0E                       ;backspace
		je .remove
		stosb
		; THIS CODE IS ONLY NEEDED FOR LIVE FEEDBACK AND CAN BE REMOVED
		pusha
		call printChar
		popa 
		; END OF REMOVABLE CODE
		cmp di, (.buffer+readString_size)  ;if length of di is >= readString_size => end
		jge .end
	jmp .inner
	.remove:
		cmp di, .buffer                    ;if di is at index 0 don't remove character
		jle .inner
		dec di                             ;go one index back
		; THIS CODE IS ONLY NEEDED FOR LIVE FEEDBACK AND CAN BE REMOVED
		pusha
		call printChar ;go one character back, empty it with space and then go back again
		mov al, ' '
		call printChar
		mov al, 0x08
		call printChar
		popa
		; END OF REMOVABLE CODE
		jmp .inner
	.end:
		xor al, al
		stosb                              ;zero terminate string
		; THIS CODE IS ONLY NEEDED FOR LIVE FEEDBACK AND CAN BE REMOVED
		pusha
		call printNL
		popa 
		; END OF REMOVABLE CODE
		mov di, .buffer                    ;set output to string beginning
		ret
.buffer resb (readString_size+1)
;------------------------------------------------------




;------------------------------------------------------
;=>al = character read(ascii) => ah = character read(keycode) => zf = (1 if nothing read)  | 
readChar:
	mov ah, 1                             ; int 0x16, 0 should be enough but it behaves inconsistent without 0x16, 1 before it
	int 0x16                              ; int 0x16, 1 => check if a key is pressed (set zero flag if not)
	jz .end
	mov ah, 0                             ; int 0x16, 0 => halts till key is pressed and returns it into al and ah
	int 0x16
	ret
	.end:
	mov ax, 0                             ; if no character was pressed return al = 0 and ah = 0
	ret
;------------------------------------------------------

;------------------------------------------------------
;dx = value to print out  |
printHexW:
	xchg dl, dh
	call printHex
	xchg dl, dh
	call printHex
	ret
;------------------------------------------------------
	
;------------------------------------------------------
;dl = value to print out  |
printHex:
	call .print           ;call twice to print first 4 bit and last 4 bit
.print:
	ror dl, 4             ;because we want to print last 4 bits first we rotate
	pusha                 ;save registers (as dl has 8bit and gets rotated twice it will end up unchanged as well)
	and dl, 0x0F          ;only read first 4 bits into dl
	mov al, ('0'+0xA)     ;NUM BASE = '0' if dl <  10
	mov bl, 'A'           ;NUM BASE = 'A' if dl >= 10
	sub dl, 0xA           ;subtract 10 from dl to set flags
	cmovae ax, bx         ;if dl >= 0xA: set NUM BASE = 'A'
	add al, dl            ;dl+NUM BASE = ASCII Character
	call printChar
	popa
	ret
;------------------------------------------------------

;------------------------------------------------------
;dl = value to print out |
printBinary:
	pusha                 ;save registers
	mov cx, 8             ;read 8 bits
	rol dx, 1             ;offset everything by one
	.loop:
	bt dx, cx             ;test bit at position cx
	setc al               ;set al depending on bit value
	or al, 30h            ;or number with 0x30 to convert to ASCII
	call printChar
	loop .loop
	popa
	ret
;------------------------------------------------------

;------------------------------------------------------
;al = char to print | modifies bx, ah
printNL:
	mov al, 0Dh           ;Reset line position
	call printChar
	mov al, 0Ah           ;next line
	call printChar
	ret	
;------------------------------------------------------

;------------------------------------------------------
;al = char to print | modifies bx, ah
printChar:
	mov bh, 0x00          ;page to write to, page 0 is displayed by default
	mov bl, 0x00          ;color attribute, doesn't matter for now
	mov ah, 0x0E 
	int 0x10              ;int 0x10, 0x0E = print character in al
	ret	
;------------------------------------------------------

;------------------------------------------------------
;si = address of string to print |
printString:
	pusha                 ;save all registers to be able to call this from where every we want
	.loop:
		lodsb             ;loads byte from si into al and increases si
		test al, al       ;test if al is 0 which would mean the string reached it's end
		jz .end
		call printChar    ;print character in al
	jmp .loop             ;print next character
	.end:
	popa                  ;restore registers to original state
	ret
;------------------------------------------------------
%assign usedMemory ($-$$)
%assign usableMemory (512*16)
%warning [usedMemory/usableMemory] Bytes used
times (512*16)-($-$$) db 0 ;kernel must have size multiple of 512 so let's pad it to the correct size