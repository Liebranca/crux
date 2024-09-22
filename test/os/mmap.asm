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

  VERSION   v0.00.3;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

ELF *;

  define ELF.ALIGN   $00;
  define BUFIO.SZ    $00;
  define ALLOCT.STEP $10;

  include '../../os/mmap.asm';
  include '../../os/exit.asm';


; ---   *   ---   *   ---
; EXE

fragment *;
entrypoint:


  ; setup stack
  push rbp;
  mov  rbp,rsp;
  sub  rsp,alloct.req;


  ; nit allocator
  mov  rdi,$00;
  call begalloc;

  ; del allocator
  call endalloc;


  ; cleanup and give
  leave;

  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
