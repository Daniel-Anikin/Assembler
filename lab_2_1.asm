format ELF64
public _start

section '.data' writable
    string_data db 'dCvNLCHIwRBfHrlibTfnOuAfqXhQskBnlVMtoFF' ; Исходная строка (39 символов)
    newline     db 10                                       ; Символ '\n'

section '.text' executable
_start:
    mov r12, 39               ; Длина строки
    mov rbx, string_data + 38 ; Указатель на последний символ

reverse_loop:
    ; Посимвольный вывод с конца (sys_write)
    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, 1
    syscall

    dec rbx                   ; Сдвиг влево по строке
    dec r12                   ; Уменьшаем счетчик
    jnz reverse_loop          ; Повторяем для всех 39 символов

    ; Вывод перевода строки
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Выход из программы (sys_exit, код 0)
    mov rax, 60
    xor rdi, rdi
    syscall
