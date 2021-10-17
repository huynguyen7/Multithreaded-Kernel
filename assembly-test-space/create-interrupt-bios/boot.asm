; Just an example of creating an interrupt routine for BIOS.
; This will overwrite the routine stored at address 0x0.

ORG 0                              ; Start segment offset.
BITS 16                            ; Using 16-bit registers.

_start:
    jmp short boot
    nop

boot:
    jmp 0x7c0:start

handle_zero:                       ; Interrupt zero, basically, it will print char 'A' to the BIOS screen.
    mov ah, 0eh                    ; 0eh in BIOS means write something to the screen (Source: http://www.ctyme.com/intr/rb-0106.htm)
    mov al, 'A'                    ; Just param for BIOS call (Character to write).
    mov bx, 0x00                   ; Just param for BIOS call.
    int 0x10                       ; BIOS routine call to execute instruction 0eh stored in AH.
    iret                           ; Return from interrupt (IMPORTANT).

handle_one:                        ; Interrupt one, basically, it will print char 'B' to the BIOS screen.
    mov ah, 0eh                    ; 0eh in BIOS means write something to the screen (Source: http://www.ctyme.com/intr/rb-0106.htm)
    mov al, 'B'                    ; Just param for BIOS call (Character to write).
    mov bx, 0x00                   ; Just param for BIOS call.
    int 0x10                       ; BIOS routine call to execute instruction 0eh stored in AH.
    iret                           ; Return from interrupt (IMPORTANT).

start:
    ; Note: Every interrupt creation needs 4 bytes.
    ; Thus, mov word always cost 4 bytes for offset(2 bytes) and segment(2 bytes).

    mov word[ss:0x00], handle_zero ; (Offset) Set interrupt 0 in BIOS to handle_zero routine.
    mov word[ss:0x02], 0x7c0       ; (Segment) Set the routine at stack segment 0x02 to 'start' routine.

    mov word[ss:0x04], handle_one  ; Set interrupt 0 in BIOS to handle_zero routine.
    mov word[ss:0x06], 0x7c0       ; Set the routine at stack segment 0x04 to 'start' routine.
    
    ; Call interrupt 0 (Print 'A').
    ; 1st Approach to execute interrupt 0.
    ;int 0                          ; BIOS call routine with `mov ah, 0eh` on line 5.

    ; 2nd Approach to execute interrupt 0.
    ; This is based on interrupt 0 is called whenever a `divided by 0` executed.
    mov ax, 0x00
    div ax

    ; Call interrupt 1 (Print 'B').
    int 1

    jmp $                          ; Prevent the execution run to line 12 and below. Basically, it just keep jumping to this line 10 until using enough 510 bytes.

times 510-($ - $$) db 0            ; Using 510 bytes, if not filling any, fill those bytes with 0 values.
dw 0xAA55                          ; word signature for boot loader, used for BIOS detection (let the BIOS know that this binary is a bootloader). Always be `0x55AA`. However, with Intel architecture (using little endian), we need to convert them to `0xAA55`.

