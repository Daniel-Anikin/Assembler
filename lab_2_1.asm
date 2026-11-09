format ELF64
public _start

section '.data' writable
    newline     db 10
    string_dop db '12345'
    string_dop_len = $ - string_dop
    string_dop_n = string_dop

section '.text' executable
_start:
    mov r12, string_dop_len
    mov rbx, string_dop + string_dop_len - 1
    mov r9, string_dop

reverse_loop:
    cmp rbx, r9
    je middle

    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, r9
    mov rdx, 1
    syscall

    dec rbx
    inc r9
    sub r12, 2
    cmp r12, 0
    jg reverse_loop


middle:
    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall
