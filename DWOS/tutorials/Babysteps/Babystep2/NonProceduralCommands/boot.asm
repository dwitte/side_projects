;This code is adapted from http://wiki.osdev.org/Babystep1
;This intended to be used as a resource for learning the 
;	basics of assembly and operating systems.
;To run this you will need Virtual Box, and nasm installed
;You will need to run the following commands:
;		nasm boot.asm -f bin -o boot.bin
;		dd if=/dev/zero of=floppy.img count=2880
;		dd if=boot.bin of=floppy.img bs=512 count=1 conv=notrunc
;Then run Virtual Box off of the floppy.img file.
;There should just be a blank screen with a cursor in the top left.

;boot.asm
	mov ax, 0x07C0				 ;Code is loaded at 0x00007c00 = segment * 16 + offset (0x07c0 is our segment in this case)
	mov ds, ax					 ;Data Segment register (ds) should be set to the code load location.

	mov si, msg

ch_loop:
	lodsb
	or al, al
	jz hang
	mov ah, 0x0E
	int 0x10
	jmp ch_loop

hang:
	jmp hang					 ; Loop indefintely

msg	db 'Welcome to my first Operating System', 13, 10, 0
	times 510 - ( $ - $$ ) db 0  ; write 0's to fill 510 bytes
	db 0x55
	db 0xAA						 ; signature for end of the boot sector
