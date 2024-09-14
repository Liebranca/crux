; ---   *   ---   *   ---
; deps

include '../../macro/elf.inc';
ELF *;

include '../../std/cstr.asm';
include '../../std/mem.asm';
include '../../os/exit.asm';


; ---   *   ---   *   ---
; ROM

fragment %;

  m00: db 'HLOWRLD!',$00;
  m00.len = $-m00;

  m01: db 'HLOWRLD!',$00;
  m01.len = $-m01;


; ---   *   ---   *   ---
; GBL

fragment $;

  buf00: db $100 dup $00;
  buf00.len = $-buf00;
  buf00.end = buf00+buf00.len;


; ---   *   ---   *   ---
; the bit

fragment *;
public _start;


  ; get second string in stack
  mov  rdi,qword [rsp+8];
  mov  rsi,$02;
  call cstrnext;

  ; ^copy to static
  mov  rsi,rdi;
  lea  rdi,[buf00];
  call cstrcpy;


  ; put newline and print
  lea rdi,[buf00+rax+$01];
  mov byte [rdi],$0A;
  add rax,$02;

  lea rsi,[buf00];
  mov rdx,rax;
  mov rdi,$01;
  mov rax,$01;

  syscall;


  ; compare strings!
  lea  rdi,[m00];
  lea  rsi,[m01];
  call cstrcmp;

  ; print result
  or  ax,$0A30;
  mov word [buf00.end-$02],ax;
  lea rsi,[buf00.end-$02];
  mov rdx,$02;
  mov rdi,$01;
  mov rax,$01;

  syscall;


  ; exit
  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
