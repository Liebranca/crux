; ---   *   ---   *   ---
; TEST OS EXIT
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

  TITLE     test.os.exit;

  VERSION   v0.00.2;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

ELF *;
  include '../../os/exit.asm';


; ---   *   ---   *   ---
; EXE

fragment *;
entrypoint:
  mov  rdi,FATAL;
  call exit;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
