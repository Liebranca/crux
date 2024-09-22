; ---   *   ---   *   ---
; OS GETDENTS
; Is this opendir?
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; ME,

; ---   *   ---   *   ---
; HEAD

include '../macro/elf.inc'


; ---   *   ---   *   ---
; info

  TITLE     os.getdents;

  VERSION   v0.00.1a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; s-consts

linux.getdents:
  .id   = $4E;
  .dir  = $04;
  .file = $08;

virtual at $00;
linux.dirent:
  .inode dq ?;
  .noff  dq ?;
  .len   dw ?;

  .fname db ?;
  .pad   db ?;
  .type  db ?;

sizeof.linux.dirent = $-linux.dirent;
end virtual;


; ---   *   ---   *   ---
; deps

ELF %;
  include "open.asm";
  include "exit.asm";


; ---   *   ---   *   ---
; ROM

fragment %;
  cstr.new nextdir.errme,'cannot read directory',$0A;


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; [0] rdi -> fd
; [1] rsi -> buf ptr
; [2] rdx -> buf size
;
; [<] rax -> bytes read, zero on end

public nextdir:

  mov rax,linux.getdents.id;
  syscall;

  cmp rax,$00;
  jge @f;

  mov rdi,$02;
  lea rsi,[nextdir.errme];
  mov rdx,nextdir.errme.len;
  mov rax,$01;
  syscall;

  mov  rdi,FATAL;
  call exit;


  @@:ret;


; ---   *   ---   *   ---
; adds to your namespace

FOOT;
  extrn nextdir;

EOF;


; ---   *   ---   *   ---
