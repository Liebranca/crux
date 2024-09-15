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

  VERSION   v0.00.2a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; s-consts

OK    = $00;
WARN  = $FD;
ERROR = $FE;
FATAL = $FF;

linux.exit.id = $3C;


; ---   *   ---   *   ---
; deps

ELF %;


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; end program
;
; [0] rdi -> exit code

public exit:

  ; TODO: 'onexit' callback list

  mov rax,linux.exit.id;
  syscall;


; ---   *   ---   *   ---
; adds to your namespace

FOOT;
  extrn exit;

EOF;


; ---   *   ---   *   ---
