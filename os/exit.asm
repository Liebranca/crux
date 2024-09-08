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

if ~used @os.exit.loaded;
@os.exit.loaded = 1;

; ---   *   ---   *   ---
; s-consts

OK    = $00;
WARN  = $FD;
ERROR = $FE;
FATAL = $FF;

linux.exit.id = $3C;


; ---   *   ---   *   ---
; deps

if ~defined IMPORT;
include "../macro/elf.inc";


; ---   *   ---   *   ---
; info

ELF %:os;

define VERSION v0.00.2a;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; EXE
;
; [0] rdi -> exit code

fragment *:public exit;
  mov rax,linux.exit.id;
  syscall;


; ---   *   ---   *   ---
; FOOT

fragment.end;

else if ~defined HEADLESS;
  extrn exit;

end if; IMPORT
ELF.end;

end if; loaded


; ---   *   ---   *   ---
