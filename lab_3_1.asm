format ELF64
public _start

section '.text' executable

_start:
    mov rax, [rsp]
    cmp rax, 2
    jl .exit_error

    mov rsi, [rsp + 16]
    movzx rbx, byte [rsi]

    call print_number

    mov rax, 60
    xor rdi, rdi
    syscall

.exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

print_number:
    mov rax, rbx

    mov rdi, num_buf_end
    mov byte [rdi], 10
    mov r12, 1

.convert_loop:
    dec rdi
    inc r12

    xor rdx, rdx
    mov rcx, 10
    div rcx

    add dl, '0'
    mov [rdi], dl

    test rax, rax
    jnz .convert_loop

    mov rax, 1
    mov rsi, rdi
    mov rdi, 1
    mov rdx, r12
    syscall
    ret

section '.bss' writeable
    num_buf     rb 16
    num_buf_end = num_buf + 15
