ORG 0x7c00                    ; Start segment offset.
BITS 16                      ; Using 16-bit registers.

start:
    mov si, message          ; Copy message bytes array address to SI register.
    call print_string        ; Put print_string on top of the stack.
    jmp $                    ; Prevent the execution run to line 30 and below. Basically, it just keep jumping to this line 10 until using enough 510 bytes.

print_string:                ; Max 510 bytes string printing routine.
    mov bx, 0                ; Just param for BIOS call.

.loop:
    lodsb                    ; Load the character address where SI register is pointing in memory to AL register, then increment the SI register address's value. For example, `H` char is being point at, it should be load to AL register and then increment the pointer from SI to `e` character in message byte array.
    cmp al, 0                ; Compare the AL register memory address with 0 value, if it is true, je(jump equal) statement execute.
    je .done                 ; If value is 0 at AL, ret is executed.
    call print_char          ; Print the char.
    jmp .loop                ; Looping..

.done:
    ret                      ; Return from the call stack (Pop out)

print_char:
    mov ah, 0eh              ; 0eh in BIOS means write something to the screen (Source: http://www.ctyme.com/intr/rb-0106.htm)
    int 0x10                 ; BIOS call routine with `mov ah, 0eh` on line 23.
    ret                      ; Return from the call stack (Pop out)


message: db 'Hello World', 0 ; Define bytes array storing string `Hello World`, then terminate.

times 510-($ - $$) db 0      ; Using 510 bytes, if not filling any, fill those bytes with 0 values.
dw 0xAA55                    ; word signature for boot loader, used for BIOS detection (let the BIOS know that this binary is a bootloader). Always be `0x55AA`. However, with Intel architecture (using little endian), we need to convert them to `0xAA55`.
