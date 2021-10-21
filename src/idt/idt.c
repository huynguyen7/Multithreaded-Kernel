#include "idt/idt.h"
#include "config.h"
#include "memory/memory.h"
#include "kernel.h"
#include "io/io.h"

/**
 * NOTES:
 * IRQs are interrupts for PIC (Programmable Interrupt Controller).
 */

struct idt_desc idt_descriptors[OS_TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;

// Load Routines from idt.asm
extern void idt_load(struct idtr_desc* ptr);
extern void irq1_handler();
extern void no_interrupt_handler();

// Interrupt 0
void idt0() {
    print("[Exception] Cannot divide by zero.\n"); // Just a simulation of INT 0x00, always an exception with undivisble by 0.
}

// Interrupt 1 for PIC
void irq1() {
    println("Keyboard pressed.");
    outb(0x20, 0x20);
}

// Tell the PIC we have done handling those interrupts, so it won't send anymore interrupts..
void no_interrupt() {
    outb(0x20, 0x20);
}

// Put the interrupt into the IDT.
void idt_set(int interrupt_num, void* address) {
    struct idt_desc* desc = &idt_descriptors[interrupt_num];
    desc->offset_1 = (uint32_t) address & 0x0000ffff;
    desc->selector = KERNEL_CODE_SELECTOR; // Code segment (selector)
    desc->zero = 0x00; // Unused value, set to 0.
    desc->type_attr = 0xee; // Why? Please take a look at IDT structure on OSdev. This binary should look like 0b11101110, the first bit from the RIGHT is `1` since we need this instruction to be used, the next 2 bits `11`, which means that this interrupt is only applied for privillege level 3 (user space). The next 1 bit `1` is to activate the next four bits. Lastly, the last 4 bits `1110` are 14, which means that we are using 80386 32-bit interrupt gate.
    desc->offset_2 = (uint32_t) address >> 16;
}

void idt_init() {
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors)-1;
    idtr_descriptor.base = (uint32_t) idt_descriptors;

    // Remove default interrupts from IDT.
    for(int i = 0; i < OS_TOTAL_INTERRUPTS; ++i)
        idt_set(i, no_interrupt_handler);

    /**
     * Custom interrupt creations..
     * For PIC interrupts, we don't really create new one, but we just remap them!
     */
    
    // Put interrupt 0 with idt0() routine.
    idt_set(0, idt0);
    
    // Put interrupt 21 (from PIC) with irq1_handler() routine.
    idt_set(0x21, irq1_handler);

    // Load the IDT.
    idt_load(&idtr_descriptor);
}
