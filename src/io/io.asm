section .asm

; Let the linker knows!
global insb
global insb
global outb 
global outw

insb:                ; Getting input byte from <port> routine.
    push ebp         ; Create stack frame, just good practice for using asm.
    mov ebp, esp     ; Load address from esp reg to ebp reg.

    xor eax, eax     ; Make eax stores zeros (Clear eax reg).
    mov edx, [ebp+8] ; Parse the first argument <port> and store into edx reg.
    ; Load input byte from <port> from dx reg into al reg.
    in al, dx        ; Why storing in eax reg? Yes, For C, it always use eax as the register storing the return value for function call (stack call).
    
    pop ebp          ; Pop out of the stack.
    ret              ;

insw:                ; Getting input word from <port> routine.
    push ebp         ; Create stack frame, just good practice for using asm.
    mov ebp, esp     ; Load address from esp reg to ebp reg.

    xor eax, eax     ; Make eax stores zeros (Clear eax reg).
    mov edx, [ebp+8] ; Parse the first argument <port> and store into edx reg.

    ; Load input byte from <port> from dx reg into ax reg.
    in ax, dx        ; Why storing in eax reg? Yes, For C, it always use eax as the register storing the return value for function call (stack call).
    
    pop ebp          ; Pop out of the stack.
    ret              ;

outb:
    push ebp         ; Create stack frame, just good practice for using asm.
    mov ebp, esp     ; Load address from esp reg to ebp reg.

    mov eax, [ebp+12]; Parse the second argument and store into eax reg.
    mov edx, [ebp+8] ; Parse the first argument and store into edx reg.
    ; Output byte to ax from <port> in dx reg.
    out dx, al
    
    pop ebp          ; Pop out of the stack.
    ret              ;

outw:
    push ebp         ; Create stack frame, just good practice for using asm.
    mov ebp, esp     ; Load address from esp reg to ebp reg.

    mov eax, [ebp+12]; Parse the second argument and store into eax reg.
    mov edx, [ebp+8] ; Parse the first argument and store into edx reg.
    ; Output word to ax from <port> in dx reg.
    out dx, ax
    
    pop ebp          ; Pop out of the stack.
    ret              ;
