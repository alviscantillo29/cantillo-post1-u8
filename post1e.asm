; post1e.asm - LODSB + STOSB: copia con transformacion a mayusculas
ORG 100h

section .data
  origen  db "hola, mundo!",0
  destino db 13 dup(0)
  msgCop  db "Transformado: $"
  crlf    db 0Dh,0Ah,"$"

section .text
start:
  mov ax, ds
  mov es, ax

  mov si, origen
  mov di, destino
  mov cx, 13
  cld

.bucle:
  lodsb
  cmp al, 'a'
  jb .escribir
  cmp al, 'z'
  ja .escribir
  sub al, 20h
.escribir:
  stosb
  loop .bucle

  mov ah, 09h
  mov dx, msgCop
  int 21h
  mov dx, destino
  int 21h
  mov dx, crlf
  int 21h

  mov ah, 4Ch
  xor al, al
  int 21h
