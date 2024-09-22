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

  VERSION   v0.00.3;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

ELF *;
  define BUFIO.SZ $00;
  include '../../os/exit.asm';


; ---   *   ---   *   ---
; ROM

fragment %;
  cstr.new throw.fatal_test,'SUCCESS',$0A;


; ---   *   ---   *   ---
; EXE

fragment *;
entrypoint:
  throw fatal_test;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
