#ifndef CONFIG_H
#define CONFIG_H


#define KERNEL_CODE_SELECTOR 0x08
#define KERNEL_DATA_SELECTOR 0x10
#define OS_TOTAL_INTERRUPTS 512


/** Heap configurations */

// Note: OS_HEAP_SIZE_BYTES must be evenly divided by OS_HEAP_BLOCK_SIZE_BYTES
#define OS_HEAP_SIZE_BYTES 104857600  // 100 Mbs heap size.
#define OS_HEAP_BLOCK_SIZE_BYTES 4096 // 4096 bytes per block for allocations.

// Where are absolute addresses of available mem - Source: https://wiki.osdev.org/Memory_Map_(x86)
#define OS_HEAP_ADDRESS 0x01000000 // absolute start address for RAM access.
#define OS_HEAP_TABLE_ADDRESS 0x00007E00 // absolute start address for heap table address.


#endif
