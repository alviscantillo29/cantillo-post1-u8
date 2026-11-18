; post2d.asm - AAA/AAS: ajuste ASCII de BCD desempaquetado
ORG 100h

section .data
  msgSuma  db "AAA: 7 + 8 = $"
  msgResta db 0Dh,0Ah,"AAS: 13 - 8 = $"
  crlf     db 0Dh,0Ah,"$"

section .text
start:
  mov ah, 09h
  mov dx, msgSuma
  int 21h

  mov al, 07h
  add al, 08h
  aaa                 ; AL = 05h, AH = 01h, CF = 1

  push ax
  mov dl, ah
  add dl, 30h
  mov ah, 02h
  int 21h
  pop ax
  mov dl, al
  add dl, 30h
  mov ah, 02h
  int 21h

  mov ah, 09h
  mov dx, msgResta
  int 21h

  mov al, 03h
  sub al, 08h
  aas                 ; AL = 05h, CF = 1

  mov dl, al
  add dl, 30h
  mov ah, 02h
  int 21h

  mov ah, 09h
  mov dx, crlf
  int 21h
  mov ah, 4Ch
  xor al, al
  int 21h
