format ELF64
public _start

section '.bss' writeable
    buf     rb 1048576
    fd1     dq 0
    fd2     dq 0
    fd_out  dq 0

section '.text' executable
_start:
    mov rax, [rsp]
    cmp rax, 4
    jl .exit_error

    mov rdi, [rsp + 16]
    xor rsi, rsi
    mov rax, 2
    syscall
    test rax, rax
    js .exit_error
    mov [fd1], rax

    mov rdi, [fd1]
    mov rsi, buf
    mov rdx, 1048576
    xor rax, rax
    syscall
    mov r12, rax

    mov rdi, [rsp + 24]
    xor rsi, rsi
    mov rax, 2
    syscall
    test rax, rax
    js .exit_error
    mov [fd2], rax

    mov rdi, [fd2]
    mov rsi, buf
    add rsi, r12
    mov rdx, 1048576
    sub rdx, r12
    xor rax, rax
    syscall
    add r12, rax

    mov rdi, [rsp + 32]
    mov rsi, 577
    mov rdx, 438
    mov rax, 2
    syscall
    test rax, rax
    js .exit_error
    mov [fd_out], rax

    mov rdi, [fd_out]
    mov rsi, buf
    mov rdx, r12
    mov rax, 1
    syscall

    mov rdi, [fd1]
    mov rax, 3
    syscall
    mov rdi, [fd2]
    mov rax, 3
    syscall
    mov rdi, [fd_out]
    mov rax, 3
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

.exit_error:
    mov rax, 60
    mov rdi, 1
    syscall
