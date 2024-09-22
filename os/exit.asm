; ---   *   ---   *   ---
; OS EXIT
; Abstract termination
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

include "../macro/elf.inc";


; ---   *   ---   *   ---
; info

  TITLE     os.exit;

  VERSION   v0.00.3a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; s-consts

OK    = $00;
WARN  = $FD;
ERROR = $FE;
FATAL = $FF;

linux.exit.id = $3C;

stdin  = $00;
stdout = $01;
stderr = $02;


; ---   *   ---   *   ---
; public inlines

macro inline.abort {
  mov rax,linux.exit.id;
  syscall;
};

macro throw me= {

  match any , me \{
    mov rdi,stderr;
    mov rsi,throw.\#any;
    mov rdx,throw.\#any\#.len;
    mov rax,linux.write.id;
    syscall;

  \};

  mov  rdi,FATAL;
  pinb abort;

};


; ---   *   ---   *   ---
; deps

ELF %;
  include "write.asm";


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; end program
;
; [0] rdi -> exit code

public exit:

  ; TODO: 'onexit' callback list
  pinb abort;


; ---   *   ---   *   ---
; adds to your namespace

FOOT;
  extrn exit;

EOF;


; ---   *   ---   *   ---
