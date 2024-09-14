; ---   *   ---   *   ---
; deps

include '../../macro/elf.inc';
ELF *;

include '../../std/mem.asm';
include '../../os/exit.asm';


; ---   *   ---   *   ---
; ROM

fragment %;

  m00: db '$$$$$$$$','$$$$$$$$','$';
  m00.len = $-m00;

  m01: db '$$$$$$$$','$$$$$$$$','$';
  m01.len = $-m01;


; ---   *   ---   *   ---
; the bit

fragment *;
public _start;


  ; setup stack
  push rbp;
  mov  rbp,rsp;
  sub  rsp,$20;

  ; ^copy string
  lea  rdi,[rbp-$20];
  lea  rsi,[m00];
  mov  rdx,m00.len;
  call memcpy;


  ; are they equal?
  lea  rdi,[rbp-$20];
  lea  rsi,[m01];
  mov  rdx,m01.len;
  call memcmp;


  ; print result
  or  ax,$0A30;
  mov word [rbp-$20],ax;
  mov rsi,rsp;
  mov rdx,$02;
  mov rdi,$01;
  mov rax,$01;

  syscall;


  ; exit
  leave;

  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
