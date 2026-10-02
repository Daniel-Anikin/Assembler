format ELF64

public _start
public exit
public print_symb

section '.bss' writable
  array db 20 dup ('a'), 0xA
  place db 1

section '.text' executable
  _start:
    xor rcx, rcx
    .iter1:
       mov al, [array+rcx]
       add al, cl
       mov byte [array+rcx], al
       inc rcx
       cmp rcx,20
       jne .iter1
    xor rcx, rcx
    .iter2:
       mov al, [array+rcx]
       push rcx
       call print_symb
       pop rcx
       inc rcx
       cmp rcx,21
       jne .iter2
    call exit

print_symb:
  push rax
  mov eax, 4
  mov ebx, 1
  pop rdx
  mov [place], dl
  mov ecx, place
  mov edx, 1
  int 0x80
  ret

exit:
  mov eax, 1
  mov ebx, 0
  int 0x80
