format ELF64
public _start

section '.data' writeable
    K equ 11
    N equ 66

    fill_char db '+'
    newline   db 10

section '.bss' writeable
    buffer rb N

section '.text' executable
_start:
    mov rdi, buffer
    mov al, [fill_char]
    mov rcx, N
    rep stosb

    mov rbx, buffer
    mov r12, K
    mov r13, 1

print_triangle:
    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, r13
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    add rbx, r13
    inc r13
    dec r12
    jnz print_triangle

    mov rax, 60
    xor rdi, rdi
    syscall
