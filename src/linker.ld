ENTRY(_start) /* Starting point of asm code segment. */
OUTPUT_FORMAT(binary) /* Output format should be binary. */
SECTIONS
{
    /* The origin ORG should start at 0x10000. */
    . = 1M; /* Our kernel section (code) should be started at 1 Megabyte (1024 * 1024, or 0x10000) into memory. In another word, the origin of the code for the linker. */
    /* Alignment with 512 bytes = 4096 bits. */
    /* Ensure everything is aligned by 16 bytes because GCC compiler's default. We don't want to have any issue with alignment. */
    .text : ALIGN(4096)
    {
        *(.text)
    }

    .rodata : ALIGN(4096)
    {
        *(.rodata)
    }

    .data : ALIGN(4096)
    {
        *(.data)
    }

    .bss : ALIGN(4096)
    {
        *(COMMON)
        *(.bss)
    }

    .asm : ALIGN(4096)
    {
        *(.asm)
    }
}
