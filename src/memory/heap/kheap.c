#include "memory/heap/kheap.h"
#include "memory/heap/heap.h"
#include "config.h"
#include "kernel.h"

struct heap kernel_heap;
struct heap_table kernel_heap_table;

// Need to run this first before we can use kmalloc() or kfree(). Else, there is no heap for us!
void kheap_init() {
    int num_table_entries = OS_HEAP_SIZE_BYTES / OS_HEAP_BLOCK_SIZE_BYTES;

    // Source: Where entry table could start: https://wiki.osdev.org/Memory_Map_(x86)
    kernel_heap_table.entries = (HEAP_BLOCK_TABLE_ENTRY*) (OS_HEAP_ADDRESS); // Map to absolute address for RAM.
    kernel_heap_table.size = num_table_entries; // Just the maximum number of blocks for heap allocation.

    void* end = (void*) OS_HEAP_ADDRESS + OS_HEAP_SIZE_BYTES; // Exclusive end limit address for the table.
    int rs = heap_create(&kernel_heap, (void*) OS_HEAP_ADDRESS, end, &kernel_heap_table);

    if(rs < 0) {
        print("[Error] Failed to create heap.\n");
    }
}

void* kmalloc(size_t size) {
    return heap_malloc(&kernel_heap, size);
}

void kfree(void* ptr) {
    heap_free(&kernel_heap, ptr);
}
