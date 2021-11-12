#ifndef HEAP_H
#define HEAP_H

#include <stdint.h>
#include <stddef.h>

/**
 *
 * BIT MASK FOR HEAP_BLOCK_TABLE_ENTRY
 * We have 8 bits for this data type:
 *        a b x x 1 2 3 4
 * bit `a` will mark if the current block has connected blocks after (for example, if we allocate a memory larger than a block, which means that we are using more than a block).
 * bit `b` will mark if the current block is the first block of allocated data.
 * bit `1`,`2`,`3`,`4` will be using for data type (for example, char, int, short..) 
 *
 */

#define HEAP_BLOCK_TABLE_ENTRY_TAKEN 0b00000001 // Entry has been taken.
#define HEAP_BLOCK_TABLE_ENTRY_FREE  0b00000000 // Entry is free.
#define HEAP_BLOCK_HAS_NEXT          0b10000000 // Entry has been taken, and it also has next entry.
#define HEAP_BLOCK_IS_FIRST          0b01000000 // Entry has been taken, and it is the first entry.

typedef unsigned char HEAP_BLOCK_TABLE_ENTRY; // single byte data type.

// This data struct will mark if the data block address has been achieved (or being using).
struct heap_table {
    HEAP_BLOCK_TABLE_ENTRY* entries; // Blocks (entries) information.
    size_t size; // Number of blocks (entries) in table.
};

struct heap {
    struct heap_table* table;
    void* start_address; // Absolute start address where free memory is.
};

int heap_create(struct heap* heap, void* ptr, void* end, struct heap_table* table); // If return 0, everything is OK! Else if negatives, look for ERROR_CODE
int heap_get_start_block(struct heap* heap, uint32_t num_blocks);
void* heap_block_to_address(struct heap* heap, int start_block);
void heap_mark_blocks_taken(struct heap* heap, int start_block, size_t num_blocks);
void* heap_malloc_blocks(struct heap* heap, uint32_t num_blocks);
void* heap_malloc(struct heap* heap, size_t size);
int heap_address_to_block(struct heap* heap, void* address);
void heap_mark_blocks_free(struct heap* heap, int start_block);
void heap_free(struct heap* heap, void* ptr);

#endif
