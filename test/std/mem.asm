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


; ---   *   ---   *   ---
; GBL

fragment $;

  b00: db $100 dup $00;
  b00.len = $-b00;
  b00.end = b00+b00.len;


; ---   *   ---   *   ---
; the bit

fragment *;
public _start;


  ; copy string from ROM to static
  lea  rdi,[b00];
  lea  rsi,[m00];
  mov  rdx,m00.len;
  call memcpy;


  ; are they equal?
  lea  rdi,[b00];
  lea  rsi,[m00];
  mov  rdx,m00.len;
  call memcmp;

  ; print result
  or  ax,$0A30;
  lea rsi,[b00.end-$02];
  mov word [rsi],ax;
  mov rdx,$02;
  mov rdi,$01;
  mov rax,$01;

  syscall;


  ; modify and try again!
  lea rdi,[b00];
  xor qword [rdi],$2020;

  ; are they still equal?
  lea  rdi,[b00];
  lea  rsi,[m00];
  mov  rdx,m00.len;
  call memcmp;

  ; print result
  or  ax,$0A30;
  lea rsi,[b00.end-$02];
  mov word [rsi],ax;
  mov rdx,$02;
  mov rdi,$01;
  mov rax,$01;

  syscall;


  ; exit
  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
