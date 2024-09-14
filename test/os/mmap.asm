; ---   *   ---   *   ---
; deps

include '../../macro/elf.inc';
ELF *;

include '../../os/mmap.asm';
include '../../os/exit.asm';

; ---   *   ---   *   ---
; the bit

fragment *;
public _start;


  ; get mem
  mov  rdi,$1000;
  call mmap;

  ; ^free mem
  mov  rdi,rax;
  mov  rsi,$01;
  call munmap;


  ; exit
  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
