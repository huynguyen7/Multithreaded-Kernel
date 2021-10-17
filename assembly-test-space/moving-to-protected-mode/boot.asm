; Protected mode! Not (Real mode)
; Note: Optional tag means that the line is optional, we can remove that line!
; We added BIOS parameter block for real usage (put this bootloader into as USB stick, for example..)
; Source: https://wiki.osdev.org/Global_Descriptor_Table

ORG 0x7c00                   ; Assembly start offset (With 0 this time!!).
BITS 16                      ; Using 16-bit registers.

CODE_SEG equ gdt_code - gdt_start  ; Give us 0x8 offset.
DATA_SEG equ gdt_data - gdt_start  ; Give us 0x10 offset.

_start:                      ; Main
    jmp short boot           ; Short jump to boot section.
    nop                      ;

times 33 db 0                ; 33 bytes for BIOS parameter block.

boot:
    jmp 0:start              ; Ensure our code start from 0x7c0 segment (Optional). This may helps those segment registers start at 0x7c0.

start:
    cli                      ; Clear interrupts.
    mov ax, 0x00             ;
    mov ds, ax               ; Data segment should start from 0x7c0 * 0x10 = 0x7c00. This time, we do this MANUALLY!
    mov es, ax               ; Extra segment reg (Optional).
    mov ss, ax               ; Stack segment reg.
    mov sp, 0x7c00           ; Stack pointer reg, this will decrease as the stack grows. We want it not to conflict with the data segment at 0x7c00.
    sti                      ; Start interrupts.

.load_protected:             ; Load protected mode.
    cli                      ; Clear interrupts.
    lgdt[gdt_descriptor]     ; Load GDT.
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32

; GDT (Global Descriptor Table) Define.
gdt_start:
gdt_null:                    ; Just a 64 bits contain 0.
    dd 0x0                   ; define double word (32 bits)
    dd 0x0                   ; define double word (32 bits)

; offset 0x8 (08h): https://wiki.osdev.org/Protected_Mode
gdt_code:                    ; CS should point to this.
    dw 0xffff                ; Segment limit first 0-15 bits for Segment Descriptor.
    dw 0                     ; Base limit 16-31 bits for Segment Descriptor.
    db 0                     ; Base limit 32-39 bits for Segment Descriptor.
    db 0x9a                  ; Access-byte 40-47 bits for Segment Descriptor.
    db 11001111b             ; High 4 bits flag and low 4 bits flag.
    db 0                     ; Base bits.

; offset 0x10
gdt_data:                    ; DS,SS,ES,FS,GS
    dw 0xffff                ; Segment limit first 0-15 bits for Segment Descriptor.
    dw 0                     ; Base limit 16-31 bits for Segment Descriptor.
    db 0                     ; Base limit 32-39 bits for Segment Descriptor.
    db 0x92                  ; Access-byte 40-47 bits for Segment Descriptor.
    db 11001111b             ; High 4 bits flag and low 4 bits flag.
    db 0                     ; Base bits.
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; This chunks of code inside load32 should not have any interrupt that has BIOS routines.
[BITS 32]                    ; 32 bits code only!
load32:                      ;
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp
    jmp $                    ; Infinite jump

times 510-($ - $$) db 0      ; Using 510 bytes, if not filling any, fill those bytes with 0 values.
dw 0xAA55                    ; define word signature (16 bits) for boot loader, used for BIOS detection (let the BIOS know that this binary is a bootloader). Always be `0x55AA`. However, with Intel architecture (using little endian), we need to convert them to `0xAA55`.
