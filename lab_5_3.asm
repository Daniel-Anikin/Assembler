format ELF64
public _start

section '.data' writeable
    newline db 10

section '.bss' writeable
    file_buf    rb 1048576
    file_size   dq 0
    fd_in       dq 0
    fd_out      dq 0

section '.text' executable
_start:
    mov rax, [rsp]
    cmp rax, 3
    jl .exit_error

    mov rdi, [rsp + 16]
    xor rsi, rsi
    xor rdx, rdx
    mov rax, 2
    syscall
    test rax, rax
    js .exit_error
    mov [fd_in], rax

    mov rdi, [fd_in]
    mov rsi, file_buf
    mov rdx, 1048576
    xor rax, rax
    syscall
    test rax, rax
    jle .exit_error
    mov [file_size], rax

    mov rdi, [rsp + 24]
    mov rsi, 577
    mov rdx, 438
    mov rax, 2
    syscall
    test rax, rax
    js .exit_error
    mov [fd_out], rax

    mov r12, [file_size]
    dec r12

.find_line:
    cmp r12, 0
    jl .done_reverse

    mov rbx, r12
.find_start:
    cmp rbx, 0
    jl .write_line
    cmp byte [file_buf + rbx], 10
    je .write_line
    dec rbx
    jmp .find_start

.write_line:
    cmp rbx, r12
    je .skip_empty

    mov rsi, file_buf
    add rsi, rbx
    inc rsi

    mov rdx, r12
    sub rdx, rbx

    mov al, [rsi + rdx - 1]
    cmp al, 10
    jne .do_write
    dec rdx

.do_write:
    cmp rdx, 0
    jle .skip_empty

    mov rdi, [fd_out]
    mov rax, 1
    syscall

    mov rdi, [fd_out]
    mov rsi, newline
    mov rdx, 1
    mov rax, 1
    syscall

.skip_empty:
    mov r12, rbx
    dec r12
    jmp .find_line

.done_reverse:
    mov rdi, [fd_in]
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
