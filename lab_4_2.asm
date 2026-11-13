format ELF64
public _start

section '.data' writeable
    newline db 10

section '.bss' writeable
    in_buf  rb 32
    num_buf rb 32
    num_buf_end = num_buf + 31

section '.text' executable

_start:

    xor rax, rax
    xor rdi, rdi
    mov rsi, in_buf
    mov rdx, 32
    syscall

    mov rsi, in_buf
    call atoi
    mov r12, rax

    xor r13, r13
    mov r14, 1

.calc_loop:
    cmp r14, r12
    jg .print_result

    mov rax, r14
    imul rax, r14

    test r14, 1
    jz .even_k
    add r13, rax
    jmp .next_iter
.even_k:
    sub r13, rax

.next_iter:
    inc r14
    jmp .calc_loop

.print_result:
    mov rax, r13
    call print_number
    mov rax, 60
    xor rdi, rdi
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
