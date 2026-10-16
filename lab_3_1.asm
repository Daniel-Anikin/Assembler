format ELF64                  ; формат 64-бит ELF
public _start                 ; точка входа

section '.text' executable    ; секция кода

_start:
    mov rax, [rsp]            ; argc
    cmp rax, 2                ; аргументов >= 2?
    jl .exit_error            ; нет - ошибка

    mov rsi, [rsp + 16]       ; argv[1] (наш символ)
    movzx rbx, byte [rsi]     ; сам символ в rbx

    call print_number         ; вывести число

    mov rax, 60               ; sys_exit
    xor rdi, rdi              ; код 0
    syscall

.exit_error:
    mov rax, 60               ; sys_exit
    mov rdi, 1                ; код 1 (ошибка)
    syscall

print_number:
    mov rax, rbx              ; число в rax

    mov rdi, num_buf_end      ; конец буфера
    mov byte [rdi], 10        ; '\n' в конец
    mov r12, 1                ; длина строки = 1

.convert_loop:
    dec rdi                   ; назад по буферу
    inc r12                   ; +1 к длине

    xor rdx, rdx              ; очистка rdx
    mov rcx, 10               ; делитель
    div rcx                   ; rax/10, остаток в rdx

    add dl, '0'               ; цифра -> ASCII
    mov [rdi], dl             ; записать в буфер

    test rax, rax             ; rax == 0?
    jnz .convert_loop         ; нет - продолжаем

    mov rax, 1                ; sys_write
    mov rsi, rdi              ; адрес строки
    mov rdi, 1                ; stdout
    mov rdx, r12              ; длина
    syscall
    ret

section '.bss' writeable
    num_buf     rb 16         ; буфер под число
    num_buf_end = num_buf + 15
