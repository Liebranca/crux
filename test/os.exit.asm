; ---   *   ---   *   ---
; deps

define IMPORT 1;

  include '../macro/elf.inc';
  ELF %:test@os.exit;

  include '../os/exit.asm';

restore IMPORT;

; ---   *   ---   *   ---
; the bit

public _start;
fragment *:_start;
  mov  rdi,FATAL;
  call os.exit;

; ---   *   ---   *   ---
