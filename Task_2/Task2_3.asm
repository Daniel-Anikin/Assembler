format ELF64
public _start

section '.text' executable

_start:
    ; Проверяем количество аргументов (должно быть не меньше 2: имя программы и n)
    mov rax, [rsp]
    cmp rax, 2
    jl .exit_error

    ; Получаем argv[1] (указатель на строку с числом n)
    mov rsi, [rsp + 16]
    call atoi
    mov r9, rax         ; r9 = n

    ; Проверяем, что n >= 1
    cmp r9, 1
    jl .exit_error

    xor r12, r12        ; r12 = общая сумма (sum = 0)
    mov r10, 1          ; r10 = текущее число i от 1 до n

.main_loop:
    cmp r10, r9
    jg .main_done

    ; --- Алгоритм реверса текущего числа (r10) ---
    mov rax, r10        ; копируем число для обработки
    xor r8, r8          ; r8 будет содержать перевернутое число (начало: 0)

.rev_loop:
    test rax, rax
    jz .rev_done

    xor rdx, rdx
    mov rcx, 10
    div rcx             ; rax = rax / 10, rdx = остаток (последняя цифра)

    imul r8, 10
    add r8, rdx         ; r8 = r8 * 10 + последняя цифра
    jmp .rev_loop

.rev_done:
    add r12, r8         ; прибавляем перевернутое число к общей сумме
    inc r10             ; переходим к следующему числу (i++)
    jmp .main_loop

.main_done:
    ; Переносим итоговую сумму в rax и выводим на экран
    mov rax, r12
    call print_number

    ; Успешный выход из программы (код 0)
    mov rax, 60
    xor rdi, rdi
    syscall

.exit_error:
    ; Выход с ошибкой (код 1)
    mov rax, 60
    mov rdi, 1
    syscall


; --- Функция atoi (преобразование строки в число) ---
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


; --- Функция print_number (вывод числа из rax в консоль) ---
print_number:
    push r12            ; сохраняем r12 на стек, так как используем его для длины
    mov rdi, num_buf_end
    mov byte [rdi], 10  ; символ перевода строки
    mov r12, 1          ; длина строки (начинаем с 1 для '\n')
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
    pop r12             ; восстанавливаем r12
    ret


section '.bss' writeable
    num_buf     rb 32
    num_buf_end = num_buf + 31
