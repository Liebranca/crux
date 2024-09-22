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

  define ELF.ALIGN $00;
  define BUFIO.SZ  $00;
  define CASK.LIST $10:$02,$20:$04;

  include '../../os/mmap.asm';
  include '../../os/exit.asm';


; ---   *   ---   *   ---
; EXE

fragment *;
entrypoint:

lis alloct E at rax;
match elem , E {


  ; setup stack
  push rbp;
  mov  rbp,rsp;
  sub  rsp,alloct.req;


  ; nit allocator
  mov  rdi,rsp;
  call begalloc;


  ; clam first slot
  mov  di,$10;
  mov  si,$02;
  call alloc;

  mov  qword [elem#.buf],$01;

  ; ^claim second slot!
  mov  di,$20;
  mov  si,$04;
  call alloc;

  mov  qword [elem#.buf],$01;


  ; del allocator
  call endalloc;


  ; cleanup and give
  leave;

  mov  rdi,OK;
  call exit;

};

restore E;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
