format ELF64
public _start

section '.text' executable

_start:
    mov rax, [rsp]
    cmp rax, 3
    jl .exit_error

    mov rsi, [rsp + 16]
    call atoi
    mov r9, rax

    mov rsi, [rsp + 24]
    call atoi
    mov r10, rax

    mov rax, r10
    sub rax, r9
    sub rax, r9
    cqo
    idiv r9

    call print_number

    mov rax, 60
    xor rdi, rdi
    syscall

.exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

atoi:
    xor rax, rax
    xor r11, r11

    movzx rcx, byte [rsi]
    cmp rcx, '-'
    jne .parse_loop
    inc rsi
    mov r11, 1

.parse_loop:
    movzx rcx, byte [rsi]
    test rcx, rcx
    jz .atoi_done
    cmp rcx, '0'
    jb .atoi_done
    cmp rcx, '9'
    ja .atoi_done

    sub rcx, '0'
    imul rax, 10
    add rax, rcx
    inc rsi
    jmp .parse_loop

.atoi_done:
    test r11, r11
    jz .atoi_ret
    neg rax
.atoi_ret:
    ret

print_number:
    mov rdi, num_buf_end
    mov byte [rdi], 10
    mov r12, 1

    xor r11, r11
    test rax, rax
    jns .convert_loop
    neg rax
    mov r11, 1

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

    test r11, r11
    jz .print_sys
    dec rdi
    inc r12
    mov byte [rdi], '-'

.print_sys:
    mov rax, 1
    mov rsi, rdi
    mov rdi, 1
    mov rdx, r12
    syscall
    ret

section '.bss' writeable

    num_buf     rb 32
    num_buf_end = num_buf + 31
