format ELF
public _start

firstname db "Аникин", 0xA
firstname_len = $ - firstname

name db "Даниил", 0xA
name_len = $ - name

fathername db "Владимирович", 0xA
fathername_len = $ - fathername

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, firstname
    mov edx, firstname_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, name
    mov edx, name_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, fathername
    mov edx, fathername_len
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80
