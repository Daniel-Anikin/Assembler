format ELF64
public _start

section '.data' writeable
    M equ 6
    K equ 11
    N equ M * K

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

print_matrix:
    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, M
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    add rbx, M
    dec r12
    jnz print_matrix

    mov rax, 60
    xor rdi, rdi
    syscall
