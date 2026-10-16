format ELF64
public _start

section '.text' executable

_start:
    ; Проверка аргументов (должно быть не менее 2: программа и имя каталога)
    mov rax, [rsp]
    cmp rax, 2
    jl .exit_error

    ; Получаем указатель на имя каталога (argv[1])
    mov r8, [rsp + 16]

    ; 1. Переходим в целевой каталог (sys_chdir = 80)
    mov rax, 80
    mov rdi, r8
    syscall
    test rax, rax
    js .exit_error

    ; 2. Открываем текущий каталог "." (sys_open = 2)
    mov rax, 2
    mov rdi, dot_str
    xor rsi, rsi        ; O_RDONLY = 0
    xor rdx, rdx
    syscall
    test rax, rax
    js .exit_error
    mov r9, rax         ; r9 = файловый дескриптор каталога

    ; 3. Читаем структуру каталога через sys_getdents64 (217)
    mov rax, 217
    mov rdi, r9
    mov rsi, dir_buf
    mov rdx, 4096
    syscall
    test rax, rax
    js .exit_error
    mov r12, rax        ; r12 = количество байт, записанных в буфер

    ; Закрываем дескриптор каталога (sys_close = 3)
    mov rax, 3
    mov rdi, r9
    syscall

    ; 4. Получаем случайные байты для генерации прав через sys_getrandom (318)
    mov rax, 318
    mov rdi, rand_buf
    mov rsi, 16
    xor rdx, rdx
    syscall
    test rax, rax
    js .exit_error

    ; 5. Парсим буфер директории и меняем права файлов
    xor rbx, rbx        ; rbx - текущее смещение в буфере dir_buf

.parse_loop:
    cmp rbx, r12
    jge .done

    ; Структура linux_dirent64:
    ; d_ino (8 байт) + d_off (8 байт) + d_reclen (2 байта) + d_type (1 байт) + d_name (переменная длина)
    movzx rcx, word [dir_buf + rbx + 16] ; d_reclen находится со смещением 16
    test rcx, rcx
    jz .done

    ; Проверяем тип файла: d_type находится на смещении 18 (8 + 8 + 2)
    ; 8 соответствует DT_REG (обычный файл)
    mov al, byte [dir_buf + rbx + 18]
    cmp al, 8
    jne .next_entry

    ; Указатель на имя файла начинается со смещения 19
    lea rsi, [dir_buf + rbx + 19]

    ; Пропускаем скрытые файлы и точки (".", "..")
    mov al, byte [rsi]
    cmp al, '.'
    je .next_entry

    ; Генерируем случайные права на основе буфера случайных байт (например, берем байт и маскируем до 0777)
    movzx rax, byte [rand_buf + 2]
    and rax, 777o       ; Ограничиваем диапазон стандартными правами доступа в восьмеричной системе

    ; 6. Меняем права файла (sys_chmod = 90)
    mov rdi, rsi        ; имя файла
    mov rsi, rax        ; новые права (mode)
    push rax
    push rbx
    push r12
    mov rax, 90
    syscall
    pop r12
    pop rbx
    pop rax

.next_entry:
    add rbx, rcx        ; переходим к следующей записи по d_reclen
    jmp .parse_loop

.done:
    ; Успешный выход (exit code 0)
    mov rax, 60
    xor rdi, rdi
    syscall

.exit_error:
    ; Выход с ошибкой (exit code 1)
    mov rax, 60
    mov rdi, 1
    syscall

section '.data' writeable
    dot_str     db '.', 0

section '.bss' writeable
    dir_buf     rb 4096     ; Буфер для системного вызова getdents64
    rand_buf    rb 32       ; Буфер для случайных байт
