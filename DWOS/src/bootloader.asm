;==============================
; DWOS Bootloader
; Created by Derek Witte
;==============================

;Information for a 1.44M floppy disk
;TODO allow for different types of disks (CDs, USBs, etc.)
SECTORS_PER_TRACK equ 18
HEADS equ 2
CYLINDERS equ 80

BUFFERSEG equ 0x9020

%include "lowlevel.ash"

BIOSROW db 10

BiosClearScreen:
	pusha		;Push the address that we will need to return to onto the stack.
	mov ax, 0x600 ;Clear the "window"
	mov cs, 0x0000 ;from (0,0)
	mov dx, 0x184f ;to (24,79)
	mov bh, 0x07 ; keep light grey display
	int 0x10
	popa		;Pop off the return address
	ret

BiosDisplay:
;;Displays a $-termintated string on the screen. A row counter is incremented.
;;Takes its string from es:bp as required by the bios.
;; we will assume ds == es
	pusha
	mov ax, 0x1300 ; write a string without attributes
	mov bs, 0x0007 ; page =0, attributes is lgrey/black.
	mov dl, 1	   ; first column (forced)
	mov dh, [cs:BiosRow]
	inc byte [cs:BiosRow]

	mov si, bp
	xor cx, cx ;zero out cx
.computelength:
	cmp byte [si], '$'
	jz .found
	inc cx
	inc si
	jmp .computelength
.found:
	int 0x10

;These are used by ReadSector
head: dw 0
track: dw 0
sec: dw 0
num_retries: db 0

;Used for loops reading setors form floppy
sec_count: dw 0

; Read a sector from the floppy drive.
;
; Parameters:
;	- "logical" sector number [bp+8]
;	- destination segment	  [bp+6]
;	- destination offset	  [bp+4]
ReadSector:
	push bp
	mov bp, sp
	pusha

	; Sector = log_sec % SECTORS_PER_TRACK
	; Head = (log_sec / SECTORS_PER_TRACK) % HEADS
	mov ax, [bp+8]
	xor dx, dx
	mov bx, SECTORS_PER_TRACK
	div bx
	mov [cs:sec], dx
	mov ax, bx
	xor dx, dx
	mov bx, HEADS
	div bx
	mov [cs:head], dx

	; Track = log_sec / (SECTORS_PER_TRACK*HEADS)
	mov	ax, [bp+8]
	xor dx,dx
	mov bx, SECTORS_PER_TRACK*2	;Hacked the value of heads. TODO: add an additional mul command to multply the number of heads
	div bx
	mov [cs:track], ax

	;Now, try to actually read the sector from the floppy.
	; retrying up to 3 times.
	mov [cs:num_retries], byte 0
	push es
	push 0xb800
	pop es
	mov word [es:0],'- '
	pop es

.again:
	mov ax, [bp+6]
	mov es, ax
	mov ax, (0x02 << 8) | 1

	mov bx, [cs:track]
	mov ch, bl
	mov bx, [cs:sec]
	mov cl, bl
	inc cl
	mov bx, [cs:head]
	mov dh, bl
	xor dl, dl
	mov bx. [bp+4]

	;Call the BIOS Read Diskette Sectors service
	int 0x13
	push es
	puse 0xb800
	pop es
	inc word [es:0]
	pop es

	;If the carry flas is NOT set, then there was not error, and we are done.
	jnc .done

	;Error - code stored in ah
	mov dx, ax
	call PrintHex
	inc byte [cs:num_retries]
	cmp byte [cs:num_retires] 3
	jne .again

	;If we get here, we failed three times, so we should give up
	mov dx, 0xdead
	call PrintHex
.here:
	jmp .here

.done:
	popa
	pop bp
	ret

;; read2buffer(logical_sector)
%macro read2buffer 1
	push word %1
	push word BUFFERSEG
	push word 0

	push es
	push 0xb800
	pop es
	mov word [es:0],'/ '
	pop es
	call ReadSector
	add esp, 6
	push es
	push 0xb800
	pop es
	mov word [es:0],'\ '
	pop es

%endmacro
;; read (logical_sector, seg target, off target)
%macro read 3
	push word %1
	push word %2
	push word %3
	call ReadSector
	add esp,6
%endmacro

;; buffer2mem(size, off src, off target)
;; assume segment is DS.
%macro buffer2mem 3
	pusha
	mov cx, %1
	mov di, %3
	mov si, %2

	call _buff2mem
	popa
%endmacro

_buff2mem
	push ds
	push es

	mov ax, ds
	mov bx, BUFFERSEG
	mov es, ax
	mov ds, bx

	cld
	push es
	push 0xb800
	pop es
	mov word [es:0], '| '
	pop es
	rep movsb

	pop es
	pop ds
	ret

; Print the word contained in the dx refister to the screen.
PrintHex:
	push a
	mov cx, 4
.PrintDigit:
	rol dx, 4
	mov ax, 0E0Fh
	and al, dl
	add al, 90h
	daa
	adc al, 40h
	daa
	int 10h
	loop .PrintDigit
	popa
	ret

;Print a newline.
PrintNL:
	push ax
	mov ax, 0E0Dh
	int 10h
	mov al, 0Ah
	int 10h
	pop ax
	ret
