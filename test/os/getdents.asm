; ---   *   ---   *   ---
; TEST OS GETDENTS
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; ME,

; ---   *   ---   *   ---
; HEAD

include '../../macro/elf.inc';


; ---   *   ---   *   ---
; info

  TITLE     test.os.getdents;

  VERSION   v0.00.1a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

ELF *;
  include '../../os/getdents.asm';
  include '../../os/write.asm';
  include '../../os/exit.asm';

  include '../../std/cstr.asm';


; ---   *   ---   *   ---
; ROM

fragment %;
  cstr.new fname,'./test';


; ---   *   ---   *   ---
; GBL

fragment $;
  d00.ptr dq $00;
  buf.new d00,$200;


; ---   *   ---   *   ---
; EXE

fragment *;
entrypoint:


  ; setup stack
  push rbp;
  mov  rbp,rsp;
  sub  rsp,$04;

  define fd   rbp-$02;
  define left rbp-$04;


  ; open dir
  lea  rdi,[fname];
  xor  rdx,rdx;
  open.flags dir,read;
  call open;

  ; ^backup
  mov word [fd],ax;


  ; walk directory
  .top:

  xor  rdi,rdi;
  mov  di,word [rbp-$02];
  lea  rsi,[d00];
  mov  rdx,d00.len;
  call nextdir;

  ; no more?
  test rax,rax;
  jz   .cleanup;

  mov word [left],ax;


  ; ^print name of entry!
  .dump:

  mov  rdi,qword [d00.ptr];
  lea  rdi,[d00+rdi];
  add  rdi,linux.dirent.fname;
  call cstrlen;

  mov  rsi,rdi;
  mov  byte [rsi+rax],$0A;
  lea  rdx,[rax+1];
  call write;

  ; go next
  mov  dx, word [d00+linux.dirent.len];
  sub  word [left],dx;
  add  qword [d00.ptr],rdx;

  mov  dx,word [left];
  test dx,dx;
  jnz  .dump;
  jmp  .top;


  ; close dir
  .cleanup:

  call flush;

  xor  rdi,rdi;
  mov  di,word [rbp-$02];
  pinb close;

  ; exit
  restore fd;
  restore left;

  leave;

  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
