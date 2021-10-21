section .asm                   ; Let linker knows this is .asm section.

; Export from C files to use in this asm codes..
extern irq1                    ;
extern no_interrupt            ;

; Let linker knows so C can use those routines..
global idt_load
global irq1_handler
global no_interrupt_handler

idt_load:                      ; IDT Load routine.
    push ebp                   ; Push to stack to make sure we don't change ebp value within this label.
    
    mov ebp, esp               ; Load the stack pointer address to base pointer register.
    mov ebx, [ebp+8]           ; Load the first argument address to ebx register.

    lidt [ebx]                 ; Load IDT address from ebx register.

    pop ebp                    ; Make ebp goes back to its previous state.
    ret                        ; Return from routine.

irq1_handler:                  ; Interrupt 1 for PIC, for Programmable Interrupt Controller (PIC), this 21h routine handle keyboard interruption.
    cli                        ; Clear all interrupts.
    pushad                     ; Push all the general purpose regs to the stack. Basically, we need to keep the states of regs when doing PIC interrupts.
    call irq1                  ; Call from C file.
    popad                      ; Pop
    sti                        ; Start the interrupt.
    iret                       ; Return from interrupt, this will stop pointing things to functions. We need to treat this as an interrupt.

no_interrupt_handler:          ;
    cli                        ; Clear all interrupts.
    pushad                     ; Push all the general purpose regs to the stack. Basically, we need to keep the states of regs when doing PIC interrupts.
    cli
    call no_interrupt          ; Call from C file.
    sti                        ; Start the interrupt.
    popad                      ; Pop
    sti
    iret                       ; Return from interrupt, this will stop pointing things to functions. We need to treat this as an interrupt.
