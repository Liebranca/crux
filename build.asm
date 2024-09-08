; ---   *   ---   *   ---
; BUILD
; Setup wizard
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; deps

include 'macro/elf.inc';
ELF *:build;

include 'os/exit.asm';


; ---   *   ---   *   ---
; info

define VERSION v0.00.1b;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; TODO:
;
; ~ open dir
; ~ \--> get *.asm file list
; ~ \--> get *.obj file list
;
; ~ generate build dir
; ~ call binary (fork into exec* syscall)
; ~ \--> rebuild *.obj when MOO than matching *.asm
; ~ \--> call the linker
;
;
; per OLINK standard, we'd use these defaults:
;
; * ld.bfd --relax --omagic -d --gc-sections
;
;
; the remaining arguments:
;
; * -o (name)
;
; * *.obj file list
; * *.a file list


; ---   *   ---   *   ---
; for now we just do nothing ;>

fragment *;
_start:
  mov  rdi,FATAL;
  call os.exit;


; ---   *   ---   *   ---
; FOOT

ELF.end;


; ---   *   ---   *   ---
