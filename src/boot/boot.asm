; A boot loader with Real mode, then SWITCH to Protected mode!
; Note: Optional tag means that the line is optional, we can remove that line!
; We added BIOS parameter block for real usage (put this bootloader into as USB stick, for example..)

ORG 0x7c00                   ; Assembly start offset (https://wiki.osdev.org/Boot_Sequence).
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

.load_protected:             ; Load protected mode (https://wiki.osdev.org/Protected_Mode).
    cli                      ; Clear interrupts.
    lgdt[gdt_descriptor]     ; Load GDT (Global Descriptor Table).
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32

; GDT (Global Descriptor Table) Define.
; Source: https://wiki.osdev.org/Global_Descriptor_Table
gdt_start:
gdt_null:                    ; Just a 64 bits contain 0.
    dd 0x0                   ; define double word (32 bits)
    dd 0x0                   ; define double word (32 bits)

; offset 0x8 (08h)
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

[BITS 32]
load32:
    mov eax, 1               ; Load from sector 1. We dont want to load sector 0 since it is for bootloader.
    mov ecx, 100             ; The total number of sectors we want to load.
    mov edi, 0x0100000       ; Load the sectors to address 0x0100000.
    call ata_lba_read        ;
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax             ; Backup the value storing at eax to ebx.

    ; Send the highest 8 bits of the lba to hard disk controller.
    shr eax, 24
    or eax, 0xE0             ; Select the master drive.
    mov dx, 0x1f6
    out dx, al

    ; Send the total sectors to read.
    mov eax, ecx
    mov dx, 0x1f2
    out dx, al

    ; Send more bits of lba.
    mov eax, ebx             ; Restor the backup lba.
    mov dx, 0x1f3
    out dx, al

    ; Send more bits of lba.
    mov dx, 0x1f4
    mov eax, ebx             ; Restore the backup lba.
    shr eax, 8
    out dx, al

    ; Send upper 16 bits of lba.
    mov dx, 0x1f5
    mov eax, ebx             ; Restore the backup lba.
    shr eax, 16
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

; Read all sectors to memory.
.next_sector:
    push ecx                 ; Put to stack for later usage.

; Check if we need to read.
.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8               ; Test if al is storing value 8
    jz .try_again            ; If test fail, jump back to .try_again
    
    ; We need to read 256 words (512 bytes or 1 sector) at a time.
    mov ecx, 256
    mov dx, 0x1f0
    rep insw
    pop ecx
    loop .next_sector
    ret

times 510-($ - $$) db 0      ; Using 510 bytes, if not filling any, fill those bytes with 0 values.
dw 0xAA55                    ; define word signature (16 bits) for boot loader, used for BIOS detection (let the BIOS know that this binary is a bootloader). Always be `0x55AA`. However, with Intel architecture (using little endian), we need to convert them to `0xAA55`.
