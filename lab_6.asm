format ELF64

public main

extrn initscr
extrn endwin
extrn start_color
extrn init_pair
extrn noecho
extrn cbreak
extrn curs_set
extrn timeout
extrn getch
extrn move
extrn addch
extrn addstr
extrn attrset
extrn refresh
extrn napms
extrn getmaxy
extrn getmaxx

section '.text' executable

main:
    push rbx
    push r12
    push r13
    push r14
    push r15

    call initscr
    test rax, rax
    jz .init_failed
    mov [window_ptr], rax

    call noecho
    call cbreak
    call start_color

    mov edi, 1
    mov esi, 1
    xor edx, edx
    call init_pair

    mov edi, 2
    mov esi, 2
    xor edx, edx
    call init_pair

    xor edi, edi
    call curs_set

    xor edi, edi
    call timeout

    mov rdi, [window_ptr]
    call getmaxy
    mov r13d, eax
    mov rdi, [window_ptr]
    call getmaxx
    mov r14d, eax

    cmp r13d, 5
    jl .terminal_small
    cmp r14d, 5
    jl .terminal_small

    mov edi, 0
    call attrset
    mov edi, instructions
    call addstr
    call refresh

    mov dword [speed_delay], 90
    mov dword [exit_code], 0
    mov dword [current_color], 1

.pass_start:
    mov edi, [current_color]
    shl edi, 8
    call attrset

    mov dword [top_bound], 1
    mov dword [left_bound], 1
    mov dword [prev_valid], 0
    mov eax, r13d
    sub eax, 2
    mov [bottom_bound], eax
    mov eax, r14d
    sub eax, 2
    mov [right_bound], eax

    mov ebx, 1
    mov eax, [right_bound]
    mov r12d, eax
    mov r15d, 1

.row_loop:
    mov eax, [bottom_bound]
    cmp ebx, eax
    jg .pass_done

    call draw_cell
    test eax, eax
    jnz .exit_program

    cmp r15d, 0
    jne .move_left

.move_right:
    mov eax, [right_bound]
    cmp r12d, eax
    jae .end_of_row_right
    inc r12d
    jmp .row_loop

.end_of_row_right:
    inc ebx
    mov r15d, 1
    jmp .row_loop

.move_left:
    mov eax, [left_bound]
    cmp r12d, eax
    jbe .end_of_row_left
    dec r12d
    jmp .row_loop

.end_of_row_left:
    inc ebx
    mov r15d, 0
    jmp .row_loop

.pass_done:
    cmp dword [current_color], 1
    jne .set_red
    mov dword [current_color], 2
    jmp .restart
.set_red:
    mov dword [current_color], 1

.restart:
    jmp .pass_start

.terminal_small:
    mov edi, 0
    call attrset
    mov edi, small_message
    call addstr
    call refresh
    mov dword [exit_code], 1
    jmp .finish

.exit_program:
    mov dword [exit_code], 0

.finish:
    call endwin
    mov eax, [exit_code]
    jmp .return

.init_failed:
    mov eax, 1

.return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret


draw_cell:
    sub rsp, 8

    cmp dword [prev_valid], 0
    je .draw_current

    mov edi, [prev_y]
    mov esi, [prev_x]
    call move
    mov edi, '#'
    call addch

.draw_current:
    mov edi, ebx
    mov esi, r12d
    call move
    mov edi, '@'
    call addch
    call refresh

    mov [prev_y], ebx
    mov [prev_x], r12d
    mov dword [prev_valid], 1

    mov edi, [speed_delay]
    call napms

    call getch
    cmp eax, 'r'
    je .draw_exit
    cmp eax, 'h'
    jne .draw_continue

    cmp dword [speed_delay], 90
    jne .set_slow
    mov dword [speed_delay], 20
    jmp .draw_continue

.set_slow:
    mov dword [speed_delay], 90

.draw_continue:
    xor eax, eax
    add rsp, 8
    ret

.draw_exit:
    mov eax, 1
    add rsp, 8
    ret

section '.data' writeable

instructions db 'r - exit    h - change speed', 0
small_message db 'Terminal is too small. Resize it and restart.', 0

section '.bss' writeable

window_ptr    rq 1
top_bound     rd 1
bottom_bound  rd 1
left_bound    rd 1
right_bound   rd 1
speed_delay   rd 1
exit_code     rd 1
prev_y        rd 1
prev_x        rd 1
prev_valid    rd 1
current_color rd 1
