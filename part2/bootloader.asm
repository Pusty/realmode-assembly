org 0x7C00

;Initialize Registers
cli
xor ax, ax
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax
mov sp, 0x6ef0 ; setup the stack like qemu does
sti

;Reset disk system
mov ah, 0
int 0x13 ; 0x13 ah=0 dl = drive number

;Read from harddrive and write to RAM
mov bx, 0x8000     ; bx = address to write the kernel to
mov al, 1 		   ; al = amount of sectors to read
mov ch, 0          ; cylinder/track = 0
mov dh, 0          ; head           = 0
mov cl, 2          ; sector         = 2
mov ah, 2          ; ah = 2: read from drive
int 0x13   		   ; => ah = status, al = amount read
jmp 0x8000
times 510-($-$$) db 0
;Begin MBR Signature
db 0x55 ;byte 511 = 0x55
db 0xAA ;byte 512 = 0xAA