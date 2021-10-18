*Just a series of basic assembly programs.
*Programs with 'bios' mean that they are built at the real mode level (ring 0). Basically, they will use BIOS and processors directly (No kernel at all!). Also, the program can only be written with a max size of 512 bytes (Real mode rules).
*'real mode' programs uses BIOS subroutines along with OS subroutines whereas 'protected mode' programs uses only OS subroutines. 
*'protected mode' programs cannot use BIOS subroutines, only OS subroutines!

* BIOS program summary:
- The BIOS finds such a boot sector, it is loaded into memory at physical address 0x7c00. There are many ways to achieve this (Source: https://wiki.osdev.org/Boot_Sequence):
    + Segment 0, Offset 0x7c00.
    + Segment 0x7c0, Offset 0.
    + Etc..

*IMPORTANT:
- How to quit QEMU:
  + Press Ctrl-A + X to quit.
  + Enter the QEMU monitor with Ctrl-A C and then type 'quit'.
