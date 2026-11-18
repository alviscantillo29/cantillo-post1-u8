; post1.asm - REP MOVSW + MOVSB: copia optimizada de cadena
; Compilar: nasm -f bin post1.asm -o post1.com
ORG 100h

section .data
  origen  db "HOLA, MUNDO!",0
  destino db 13 dup(0)
  msgCop  db "Copiado: $"
  crlf    db 0Dh,0Ah,"$"

section .text
start:
  mov ax, ds
  mov es, ax
  mov si, origen
  mov di, destino
  mov cx, 13
  cld

  mov ax, cx
  shr cx, 1           ; 6 words (12 bytes)
  rep movsw
  and ax, 1           ; byte impar sobrante
  jz  .fin
  movsb
.fin:
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
