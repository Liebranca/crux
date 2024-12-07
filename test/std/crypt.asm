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

  define EZY $10;
  define CAP $04;

  macro makepool {
    local total;
    total = CAP;

    while total > 0;
      dq $00;
      total = total-64;

    end while;

  };

  head: db sizeof.mmask_t dup $00;
  pool: makepool;


; ---   *   ---   *   ---
; EXE

fragment *;
entrypoint:

  mov  di,EZY;
  mov  si,CAP;
  lea  rbx,[head];
  call mmask;

  mov  rax,EZY*3;
  call mmaskep2;
  call mmaskfit;

  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
