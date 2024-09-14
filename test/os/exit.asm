; ---   *   ---   *   ---
; deps

include '../../macro/elf.inc';
ELF *;

include '../../os/exit.asm';

; ---   *   ---   *   ---
; the bit

fragment *:_start;
  mov  rdi,FATAL;
  call exit;


; ---   *   ---   *   ---
