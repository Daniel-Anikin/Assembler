format ELF
public _start

firstname db "Аникин", 0xA
firstname_len = $ - firstname

name db "Даниил", 0xA
name_len = $ - name

space db " "
space_len = $ - space

fathername db "Владимирович", 0xA
fathername_len = $ - fathername

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, firstname
    mov edx, firstname_len
    int 0x80

    mov ecx, (firstname_len/2)-1
.loop1:
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, space_len
    int 0x80
    pop ecx
    loop .loop1

    mov eax, 4
    mov ebx, 1
    mov ecx, name
    mov edx, name_len
    int 0x80

    mov ecx, (firstname_len+name_len)/2-2
.loop2:
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, space_len
    int 0x80
    pop ecx
    loop .loop2

    mov eax, 4
    mov ebx, 1
    mov ecx, fathername
    mov edx, fathername_len
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80
