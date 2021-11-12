#include <stdbool.h>
#include "kernel.h"
#include "status.h"
#include "config.h"
#include "memory/heap/heap.h"
#include "memory/memory.h"

// Validate user input table size (number of blocks) if it fits with given address from ptr to end.
static bool heap_validate_table(void* ptr, void* end, struct heap_table* table) {
    int rs = OS_ALL_OK;

    size_t table_size = ((size_t) end) - ((size_t) ptr); // Size in bytes.
    size_t num_blocks = table_size / OS_HEAP_BLOCK_SIZE_BYTES;

    if(table->size != num_blocks) {
        rs = -EINVARG;
        goto out;
    }

out:
    return rs;
}

static bool heap_validate_alignment(void* ptr) {
    return ((unsigned int) ptr) % OS_HEAP_BLOCK_SIZE_BYTES == 0;
}

int heap_create(struct heap* heap, void* ptr, void* end, struct heap_table* table) { // If return 0, everything is OK! Else if negatives, look for ERROR_CODE.

    int rs = OS_ALL_OK;
    
    if(!heap_validate_alignment(ptr)
        || !heap_validate_alignment(end)) {
        rs = -EINVARG;
        goto out; // Jump to `out` label.
    }

    // Set all the bytes to 0 for heap mem.
    memset(heap, 0, sizeof(struct heap));

    heap->start_address = ptr;
    heap->table = table;

    rs = heap_validate_table(ptr, end, table);
    if(rs < 0) {
        rs = -EINVARG;
        goto out; // Jump to `out` label.
    }

    // Set all the bytes to FREE for heap's table mem.
    size_t table_size = sizeof(HEAP_BLOCK_TABLE_ENTRY) * table->size; // size in bytes;
    memset(table->entries, HEAP_BLOCK_TABLE_ENTRY_FREE, table_size);

out:
    return rs;
}

/*
 * This function will return the number of bytes needed for given input bytes, and block_size
 * For example, our block_size is 4096, if user is asking 1, we will return 4096.
 * Else, if user is asking 4097, we return 4096*2 = 8192.
 * else, if user is asking 8193, we return 4096*3 = 12288
 * And so on..
 */
static uint32_t heap_align_value_to_upper(uint32_t val) {
    if(val % OS_HEAP_BLOCK_SIZE_BYTES == 0) {
        return val;
    } else {
        val = val - (val % OS_HEAP_BLOCK_SIZE_BYTES);
        return val + OS_HEAP_BLOCK_SIZE_BYTES;
    }
}

// Return data type for malloc, we only care last 4 bits from entry (look at heap.h for more details).
static int heap_get_entry_type(HEAP_BLOCK_TABLE_ENTRY entry) {
    return entry & 0b00001111;
} 

// This function will return the start block index that could fit the number of not taken blocks..
int heap_get_start_block(struct heap* heap, uint32_t num_blocks) {
    struct heap_table* table = heap->table;
    size_t size = table->size;

    int current_block = 0;
    int start_block = -1;

    for(size_t i = 0; i < size; ++i) {
        if(heap_get_entry_type(table->entries[i]) != HEAP_BLOCK_TABLE_ENTRY_FREE) {
            current_block = 0;
            start_block = -1;
        } else {
            current_block++;
            if(start_block == -1)
                start_block = i;
            if(current_block == num_blocks)
                break;
        }
    }
    
    if(start_block == -1) return ENOMEM;
    return start_block;
}

// Return the absolute address of a block given its index and the heap mem.
void* heap_block_to_address(struct heap* heap, int start_block) {
    return OS_HEAP_BLOCK_SIZE_BYTES * start_block + heap->start_address;
}

// Mark the free blocks as taken for memory allocation.
void heap_mark_blocks_taken(struct heap* heap, int start_block, size_t num_blocks) {
    if(num_blocks < 1) return;

    struct heap_table* table = heap->table;

    if(num_blocks == 1)
        table->entries[start_block] = HEAP_BLOCK_IS_FIRST | HEAP_BLOCK_TABLE_ENTRY_TAKEN;
    else // num_blocks > 1
        table->entries[start_block] = HEAP_BLOCK_IS_FIRST | HEAP_BLOCK_HAS_NEXT | HEAP_BLOCK_TABLE_ENTRY_TAKEN; 

    for(size_t i = 1; i < num_blocks; ++i) {
        if(i == num_blocks - 1)
            table->entries[start_block+i] = HEAP_BLOCK_TABLE_ENTRY_TAKEN;
        else table->entries[start_block+i] = HEAP_BLOCK_HAS_NEXT | HEAP_BLOCK_TABLE_ENTRY_TAKEN;
    }
}

// Malloc, size in defined blocks (<n> bytes). Most likely a helper function for heap_malloc().
void* heap_malloc_blocks(struct heap* heap, uint32_t num_blocks) {
    void* address = 0;

    // Get the appropriate start block.
    int start_block = heap_get_start_block(heap, num_blocks);
    if(start_block < 0) {
        goto out;
    }

    // Find the block start absolute address.
    address = heap_block_to_address(heap, start_block);

    // Mark the blocks as taken.
    heap_mark_blocks_taken(heap, start_block, num_blocks);

out:
    return address;
}

// Malloc, size in bytes. This if for user call.
void* heap_malloc(struct heap* heap, size_t size) {
    size_t aligned_size = heap_align_value_to_upper(size);
    uint32_t num_blocks = aligned_size / OS_HEAP_BLOCK_SIZE_BYTES;
    
out:
    return heap_malloc_blocks(heap, num_blocks);
}

// Return block index in a given heap and an input address.
int heap_address_to_block(struct heap* heap, void* address) {
    return ((int) (address - heap->start_address)) / OS_HEAP_BLOCK_SIZE_BYTES;
}

// Mark blocks free from given start_block index to it last allocated block (a sequence of blocks).
void heap_mark_blocks_free(struct heap* heap, int start_block) {
    struct heap_table* table = heap->table;
    size_t size = table->size;

    // Loop through each entry until find their is no has next block bit mask.
    for(size_t i = start_block; i < size; ++i) {
        HEAP_BLOCK_TABLE_ENTRY entry = table->entries[i];
        table->entries[i] = HEAP_BLOCK_TABLE_ENTRY_FREE;

        if(!(entry & HEAP_BLOCK_HAS_NEXT))
            break;
    }
}

// Free
void heap_free(struct heap* heap, void* ptr) {
    int start_block = heap_address_to_block(heap, ptr);
    heap_mark_blocks_free(heap, start_block);
}
