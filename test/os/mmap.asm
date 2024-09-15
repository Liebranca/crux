; ---   *   ---   *   ---
; TEST OS MMAP
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

include '../../macro/elf.inc';


; ---   *   ---   *   ---
; info

  TITLE     test.os.mmap;

  VERSION   v0.00.2;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

ELF *;
  include '../../os/mmap.asm';
  include '../../os/exit.asm';


; ---   *   ---   *   ---
; EXE

fragment *;
entrypoint:


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
; FOOT

EOF;


; ---   *   ---   *   ---
