#ifndef IDT_H
#define IDT_H

#include <stdint.h>

// Interrupt descript table Descriptor structure (https://wiki.osdev.org/Interrupt_Descriptor_Table).
struct idt_desc {
    uint16_t offset_1;     // Offset bits 0-15.
    uint16_t selector;     // Selector that in our GDT (Global descriptor table).
    uint8_t zero;          // Does nothing, set to zero!
    uint8_t type_attr;     // Descriptor type and attributes.
    uint16_t offset_2;     // Offset bits 16-31.
} __attribute__((packed)); // Make sure there is no padding (data alignment), we don't want data corruption.

// Interrupt descriptor table Reference (used for loading the size of IDT, and their base address where they are located in the memory).
struct idtr_desc {
    uint16_t limit;        // Size of IDT (max is 512 interrupts)
    uint32_t base;         // Base absolute addresss of IDT on memory (where it starts at).
} __attribute__((packed)); // Make sure there is no padding (data alignment), we don't want data corruption.

// Interrupt creations.
void idt0();
void irq1();

// Just IDT initialization in Protected mode.
void idt_init();

#endif
