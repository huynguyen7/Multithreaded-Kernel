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

    ; Remap the master PIC (Programmable Interrupt Controller). Basically, just a vector table of interrupt from hardware to processors.
    ; These interrupts can handle most of the basics needs. However, we need to remap them since they can conflict with
    ; Intel's exceptions or interrupt handlers.
    mov al, 00010001b        ; Put the PIC into initialization mode.
    out 0x20, al             ; Call master PIC (from 0-7 IRQs) with port 0x20.

    mov al, 0x20             ; Remapping , 0x20 is where master IRQs should start.
    out 0x21, al             ;

    mov al, 00000001b        ;
    out 0x21, al             ;

    ; Enable interrupts
    sti                      ; When PIC are generating, processors may ignore, so we need this to enable those interrupts.

    ; Kernel main in kernel.c
    call kernel_main

    jmp $                    ; Infinite jump

times 512-($ - $$) db 0      ; Dealing with the alignment. Align 512%16 = 0 is perfectly fine.
