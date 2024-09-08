; ---   *   ---   *   ---
; deps

include '../macro/elf.inc';
ELF *:test@os.exit;

include '../os/exit.asm';

; ---   *   ---   *   ---
; the bit

fragment *:_start;
  mov  rdi,FATAL;
  call os.exit;

; ---   *   ---   *   ---
