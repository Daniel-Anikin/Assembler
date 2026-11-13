format ELF64
public _start

section '.data' writeable
    prompt db 'Введите пароль: '
    prompt_len = $ - prompt
    password db '52671488'
    password_len = $ - password
    wrong_msg db 'Неверный пароль', 10
    wrong_len = $ - wrong_msg
    success_msg db 'Вошли', 10
    success_len = $ - success_msg
    failure_msg db 'Неудача', 10
    failure_len = $ - failure_msg

section '.bss' writeable
    input_buf rb 128

section '.text' executable
_start:
    mov r12, 5

.attempt:
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    xor rax, rax
    xor rdi, rdi
    mov rsi, input_buf
    mov rdx, 128
    syscall

    test rax, rax
    jle .wrong

    mov rbx, rax

.trim:
    test rbx, rbx
    jz .wrong
    mov al, byte [input_buf + rbx - 1]
    cmp al, 10
    je .remove_last
    cmp al, 13
    je .remove_last
    jmp .compare

.remove_last:
    dec rbx
    jmp .trim

.compare:
    cmp rbx, password_len
    jne .wrong

    mov rsi, input_buf
    mov rdi, password
    mov rcx, password_len
    cld
    repe cmpsb
    jne .wrong

    mov rax, 1
    mov rdi, 1
    mov rsi, success_msg
    mov rdx, success_len
    syscall
    jmp .exit_success

.wrong:
    mov rax, 1
    mov rdi, 1
    mov rsi, wrong_msg
    mov rdx, wrong_len
    syscall

    dec r12
    jnz .attempt

    mov rax, 1
    mov rdi, 1
    mov rsi, failure_msg
    mov rdx, failure_len
    syscall
    jmp .exit_failure

.exit_success:
    mov rax, 60
    xor rdi, rdi
    syscall

.exit_failure:
    mov rax, 60
    mov rdi, 1
    syscall
