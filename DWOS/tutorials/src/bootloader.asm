;This is the bootloader for DWOS.
;It is based off of the bootloader information provided on
;wiki.osdev.org.
;Below is the structure of the 512 bytes
;

;Correct the offsets
ORG 0x7C00

;Code Section (440 Bytes)
jmp 0x0000:start
start:
	
	jmp start

ExtendedRead:		; dl needs to be set by the caller. (This is the Drive number)
					; Also a packet needs setup such that the si register points to
					;	Offset    | Size  | Description
					;    0x00     | BYTE  | SIze of packet (0x10 or 0x18)
					;    0x01     | BYTE  | Reserved (Must be 0x00)
					;    0x02	  | WORD  | Number of blocks to transfer
					;    0x04     | DWORD | -> Transfer Buffer
					;    0x08     | QWORD | Starting Absolute Block Number
					;	 0x10     | QWORD | 64-bit flat address of transfer buffer (used if DWROD at 0x04 is 0xFFFF:0xFFFF
	mov ah, 0x42    ; This is an extended read command

	
	

times 440-($-$$) db 0 ;Fill the rest of the code section with 0x00

;Disk Signature (4 Bytes)
times 4 db 0 ;Fill extra space with 0x00

;Nulls (2 Bytes)
times 2 db 0	; Fill location with 0x00

;Partition Table (64 Bytes)
;Empty until a need arises to utilize different partitions.
;Currently only loading from a floppy disk image. 

times 64 db 0

;MBR Signature (2 Bytes)
db 0x55
db 0xAA
