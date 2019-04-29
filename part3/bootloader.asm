org 0x7C00
;Note that the jump and NOP are part of the BPB
jmp short start
nop

; The following code wasn't written by me
; it's just a Standard BIOS Parameter Block with a FAT12/FAT16 extension
; considering the comments are pretty good and already describe the use of each value
; we might just use this as it's working (which is something I had many problems with).
; Source MikeOS
; http://mikeos.sourceforge.net/
; ------------------------------------------------------------------
; Disk description table, to make it a valid floppy
; Note: some of these values are hard-coded in the source!
; Values are those used by IBM for 1.44 MB, 3.5" diskette
OEMLabel		db "Example "	; Disk label
BytesPerSector		dw 512		; Bytes per sector
SectorsPerCluster	db 1		; Sectors per cluster
ReservedForBoot		dw 1		; Reserved sectors for boot record
NumberOfFats		db 2		; Number of copies of the FAT
RootDirEntries		dw 224		; Number of entries in root dir
; (224 * 32 = 7168 = 14 sectors to read)
LogicalSectors		dw 2880		; Number of logical sectors
MediumByte		db 0F0h		; Medium descriptor byte
SectorsPerFat		dw 9		; Sectors per FAT
SectorsPerTrack		dw 18		; Sectors per track (36/cylinder)
Sides			dw 2		; Number of sides/heads
HiddenSectors		dd 0		; Number of hidden sectors
LargeSectors		dd 0		; Number of LBA sectors
; MikeOS's bootloader didn't mention this but the FAT12/FAT16 extension starts here
DriveNo			dw 0		; Drive No: 0
Signature		db 41		; Drive signature: 41 for floppy
VolumeID		dd 00000000h	; Volume ID: any number
VolumeLabel		db "Example    "; Volume Label: any 11 chars
FileSystem		db "FAT12   "	; File system type: don't change!
start: 
; ------------------------------------------------------------------

;Reset disk system
mov ah, 0
int 0x13 ; 0x13 ah=0 dl = drive number

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