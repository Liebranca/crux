; ---   *   ---   *   ---
; TEST STD CRYPT
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

include '../../macro/elf.inc'


; ---   *   ---   *   ---
; info

  TITLE     test.std.crypt;

  VERSION   v0.00.1a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; s-consts

; ---   *   ---   *   ---
; deps

ELF *;
  include '../../std/crypt.asm'
  include '../../os/exit.asm'


; ---   *   ---   *   ---
; RAM

fragment $;
  cask.new main $10:$04;


; ---   *   ---   *   ---
; EXE

fragment *;
entrypoint:

  mov  di,main.ezy;
  mov  si,main.cap;
  lea  rbx,[main.head];
  call mmask;

  mov  rax,main.ezy*3;
  call mmaskep2;
  call mmaskfit;

  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
