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

OK    = $00;
WARN  = $FD;
ERROR = $FE;
FATAL = $FF;

linux.exit = $3C;


; ---   *   ---   *   ---
; deps

if ~defined IMPORT;
include "../macro/elf.inc";


; ---   *   ---   *   ---
; info

ELF %:os;

define VERSION v0.00.1b;
define AUTHOR  IBN-3DILA;


; ---   *   ---   *   ---
; EXE

fragment *:exe;

public exit;
  mov rax,linux.exit;
  syscall;


; ---   *   ---   *   ---
; FOOT

fragment.end;

else if ~ defined HEADLESS;
  extrn exit;

end if; IMPORT
ELF.end;


; ---   *   ---   *   ---
