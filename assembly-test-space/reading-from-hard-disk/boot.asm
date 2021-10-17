ORG 0                        ; Assembly start offset (With 0 this time!!).
BITS 16                      ; Using 16-bit registers.

_start:                      ; Main
    jmp short boot           ; Short jump to boot section.
    nop                      ;

times 33 db 0                ; 33 bytes for BIOS parameter block.

boot:
    jmp 0x7c0:start          ; Ensure our code start from 0x7c0 segment (Optional). This may helps those segment registers start at 0x7c0.

start:                       ; Main
    ; This chunk of codes basically just tell BIOS where the code segment and its offset.
    cli                      ; Clear interrupts.
    mov ax, 0x7c0            ;
    mov ds, ax               ; Data segment should start from 0x7c0 * 0x10 = 0x7c00. This time, we do this MANUALLY!
    mov es, ax               ; Extra segment reg (Optional).
    mov ax, 0x00             ;
    mov ss, ax               ; Stack segment reg.
    mov sp, 0x7c00           ; Stack pointer reg, this will decrease as the stack grows. We want it not to conflict with the data segment at 0x7c00.
    sti                      ; Start interrupts.

    ; **BIOS read hard disk sector (http://www.ctyme.com/intr/rb-0607.htm).
    mov ah, 2                ; Read sector command.
    mov al, 1                ; Number of sectors to read.
    mov ch, 0                ; Cylinder low eight bits.
    mov cl, 2                ; Read sector 2.
    mov dh, 0                ; Head number.
    mov bx, buffer           ; Set the buffer to bx
    int 0x13                 ; BIOS interrupt.

    jc error                 ; If catch any error flag, jump to error segment.
    mov si, buffer           ; Else print out the string from hard disk sector.
    call print_string        ;
    jmp $                    ;

error:
    mov si, error_message
    call print_string
    jmp $

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
    int 0x10                 ; BIOS call routine with `mov ah, 0eh`.
    ret                      ; Return from the call stack (Pop out)

error_message: db '[ERROR] Failed to load sector', 0 ; Define bytes array storing string.

times 510-($ - $$) db 0      ; Using 510 bytes, if not filling any, fill those bytes with 0 values.
dw 0xAA55                    ; word signature for boot loader, used for BIOS detection (let the BIOS know that this binary is a bootloader). Always be `0x55AA`. However, with Intel architecture (using little endian), we need to convert them to `0xAA55`.

buffer:                      ; Need this label to be empty to store output.
