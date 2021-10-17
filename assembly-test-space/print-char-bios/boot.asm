ORG 0x7c00                    ; Start segment offset.
BITS 16                      ; Using 16-bit registers.

start:
    mov ah, 0eh              ; 0eh in BIOS means write something to the screen (Source: http://www.ctyme.com/intr/rb-0106.htm)
    mov al, 'A'              ; Just param for BIOS call (Character to write).
    mov bx, 0                ; Just param for BIOS call.
    int 0x10                 ; BIOS call routine with `mov ah, 0eh` on line 5.

    jmp $                    ; Prevent the execution run to line 12 and below. Basically, it just keep jumping to this line 10 until using enough 510 bytes.

times 510-($ - $$) db 0      ; Using 510 bytes, if not filling any, fill those bytes with 0 values.
dw 0xAA55                    ; word signature for boot loader, used for BIOS detection (let the BIOS know that this binary is a bootloader). Always be `0x55AA`. However, with Intel architecture (using little endian), we need to convert them to `0xAA55`.

