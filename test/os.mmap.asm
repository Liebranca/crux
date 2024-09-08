; ---   *   ---   *   ---
; deps

include '../macro/elf.inc';
ELF *:test@os.mmap;

include '../os/mmap.asm';
include '../os/exit.asm';

; ---   *   ---   *   ---
; the bit

fragment *:_start;


  ; get mem
  mov  rdi,$1000;
  call os.mmap;

  ; ^free mem
  mov  rdi,rax;
  mov  rsi,$01;
  call os.munmap;


  ; exit
  mov  rdi,OK;
  call os.exit;

fragment.end;
ELF.end;

; ---   *   ---   *   ---
