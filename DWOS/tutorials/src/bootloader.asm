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

times 440-($-$$) db 0 ;Fill the rest of the code section with 0x00

;Disk Signature (4 Bytes)
times 4 db 0 ;Fill extra space with 0x00

;Nulls (2 Bytes)
times 2 db 0	; Fill location with 0x00

;Partition Table (64 Bytes)

times 64 db 0

;MBR Signature (2 Bytes)
db 0x55
db 0xAA
