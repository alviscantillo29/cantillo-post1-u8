; post2b.asm - DAA y DAS: aritmetica BCD empaquetada
ORG 100h

section .data
  bcd1      db 47h
  bcd2      db 38h
  resultado db 0
  msg       db "BCD suma: $"
  msgDas    db "DAS OK: 45",0Dh,0Ah,"$"
  msgErr    db "Error BCD.$"
  crlf      db 0Dh,0Ah,"$"

section .text
start:
  mov al, [bcd1]
  add al, [bcd2]
  daa
  mov [resultado], al

  mov ah, 09h
  mov dx, msg
  int 21h

  mov al, [resultado]
  mov bl, al
  shr al, 4
  add al, 30h
  mov dl, al
  mov ah, 02h
  int 21h

  mov al, bl
  and al, 0Fh
  add al, 30h
  mov dl, al
  mov ah, 02h
  int 21h

  mov ah, 09h
  mov dx, crlf
  int 21h

  ; Resta BCD con DAS: 73h - 28h = 45h
  mov al, 73h
  sub al, 28h
  das
  cmp al, 45h
  jne .err

  ; Caso con prestamo: 20h - 01h = 19h
  mov al, 20h
  sub al, 01h
  das
  cmp al, 19h
  jne .err

  mov ah, 09h
  mov dx, msgDas
  int 21h
  jmp .fin

.err:
  mov ah, 09h
  mov dx, msgErr
  int 21h
.fin:
  mov ah, 4Ch
  xor al, al
  int 21h
