section .asm

; Let the linker knows!
global insb
global insb
global outb 
global outw

insb:                  ; Getting input byte from <port> routine.
    push ebp           ; Create stack frame, just good practice for using asm. This will change the address for esp reg to the base address of the next stack being pushed.
    mov ebp, esp       ; Load address from esp reg to ebp reg.

    xor eax, eax       ; Make eax stores zeros (Clear eax reg).
    mov edx, [ebp+8]   ; Parse the first argument <port> and store into edx reg.
    ; Load input byte from <port> from dx reg into al reg.
    in al, dx          ; Why storing in eax reg? Yes, For C, it always use eax as the register storing the return value for function call (stack call).
    
    pop ebp            ; Pop out of the stack.
    ret                ;

insw:                  ; Getting input word from <port> routine.
    push ebp           ; Create stack frame, just good practice for using asm. This will change the address for esp reg to the base address of the next stack being pushed.
    mov ebp, esp       ; Load address from esp reg to ebp reg.

    xor eax, eax       ; Make eax stores zeros (Clear eax reg).
    mov edx, [ebp+8]   ; Parse the first argument <port> and store into edx reg.

    ; Load input byte from <port> from dx reg into ax reg.
    in ax, dx          ; Why storing in eax reg? Yes, For C, it always use eax as the register storing the return value for function call (stack call).
    
    pop ebp            ; Pop out of the stack.
    ret                ;

outb:
    push ebp           ; Create stack frame, just good practice for using asm. This will change the address for esp reg to the base address of the next stack being pushed.
    mov ebp, esp       ; Load address from esp reg to ebp reg.

    mov eax, [ebp+12]  ; Parse the second argument and store into eax reg.
    mov edx, [ebp+8]   ; Parse the first argument and store into edx reg.

    ; Output byte from al reg to <port> in dx reg.
    out dx, al

    pop ebp            ; Pop out of the stack.
    ret                ;

outw:
    push ebp           ; Create stack frame, just good practice for using asm. This will change the address for esp reg to the base address of the next stack being pushed.
    mov ebp, esp       ; Load address from esp reg to ebp reg.

    mov eax, [ebp+12]  ; Parse the second argument and store into eax reg.
    mov edx, [ebp+8]   ; Parse the first argument and store into edx reg.

    ; Output word from ax reg to <port> in dx reg.
    out dx, ax
    
    pop ebp            ; Pop out of the stack.
    ret                ;
