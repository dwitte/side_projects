[ORG 0x7c00]
	xor ax, ax
	mov ds, ax

	call msgload
	call bios_print

hang:
	jmp hang

msg	db 'Welcome to DWOS', 13, 10, 0

msgload:
	mov si, msg
	jmp done

bios_print:
	lodsb
	or al, al
	jz done
	mov ah, 0x0e
	int 0x10
	jmp bios_print
done:
	ret

	times 510-($-$$) db 0
	db 0x55
	db 0xAA
