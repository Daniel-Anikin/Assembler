format ELF64
public _start

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

    xor r12, r12
    xor r13, r13

.scan_loop:
    cmp r13, [file_size]
    jge .end_of_file

    mov al, [file_buf + r13]
    cmp al, '.'
    je .found_punct
    cmp al, '!'
    je .found_punct
    cmp al, '?'
    je .found_punct

    inc r13
    jmp .scan_loop

.found_punct:
    mov r14, r13

.write_sentence:
    cmp r14, r12
    jl .sentence_done

    mov rsi, file_buf
    add rsi, r14
    mov rdi, [fd_out]
    mov rdx, 1
    mov rax, 1
    syscall

    dec r14
    jmp .write_sentence

.sentence_done:
    mov r12, r13
    inc r12
    inc r13
    jmp .scan_loop

.end_of_file:
    cmp r12, [file_size]
    jge .done

    mov r14, [file_size]
    dec r14

.write_tail:
    cmp r14, r12
    jl .done

    mov rsi, file_buf
    add rsi, r14
    mov rdi, [fd_out]
    mov rdx, 1
    mov rax, 1
    syscall

    dec r14
    jmp .write_tail

.done:
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
