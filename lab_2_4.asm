format ELF64
public _start

section '.data' writeable
    N dq 5277616985

section '.bss' writeable
    buffer rb 16

section '.text' executable
_start:
    mov rax, [N]
    xor r12, r12
    mov rcx, 10

calc_sum_loop:
    test rax, rax
    jz sum_done

    xor rdx, rdx
    div rcx
    add r12, rdx
    jmp calc_sum_loop

sum_done:
    mov rax, r12
    mov rdi, buffer + 15
    mov byte [rdi], 10
    dec rdi
    mov r8, 1

convert_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    inc r8
    test rax, rax
    jnz convert_loop

    inc rdi

    mov rax, 1
    mov rdx, r8
    mov rsi, rdi
    mov rdi, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall
