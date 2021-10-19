; This chunks of code inside load32 should not have any interrupt that has BIOS routines.
[BITS 32]                    ; 32 bits code only!

global _start                ; Make it public for linker ld to find!
extern kernel_main

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:                      ;
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp
    
    ; Enable A20 line: https://wiki.osdev.org/A20_Line.
    in al, 0x92
    or al, 2
    out 0x92, al

    call kernel_main

    jmp $                    ; Infinite jump

times 512-($ - $$) db 0      ; Dealing with the alignment. Align 512%16 = 0 is perfectly fine.
