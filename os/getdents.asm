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

  VERSION   v0.00.4a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; s-consts

linux.chdir:
  .id = $50;

linux.fchdir:
  .id = $51;

linux.getdents:
  .id   = $4E;
  .dir  = $04;
  .file = $08;

virtual at $00;
linux.dirent:
  .inode dq ?;
  .off   dq ?;
  .len   dw ?;

  .fname db ?;
  .pad   db ?;
  .type  db ?;

sizeof.linux.dirent = $-linux.dirent;
end virtual;

dirwalk.noop      = $00;
dirwalk.recurse   = $01;

dirwalk.alloc_cap = $10;
dirwalk.alloc_ezy = $20;


; ---   *   ---   *   ---
; deps

ELF %;
  include "open.asm";
  include "exit.asm";


; ---   *   ---   *   ---
; ROM

fragment %;
  cstr.new dirnext.errme,'cannot read directory',$0A;
  cstr.new throw.chdir,'not a directory',$0A;

; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; set dir from path
;
; [0] rdi -> fname

public chdir:

  mov  rax,linux.chdir.id;
  syscall;

  test rax,rax;
  jz   @f;

  throw chdir;

  @@:ret;


; ---   *   ---   *   ---
; ^set dir from fd
;
; [0] rdi -> fd

public fchdir:

  mov rax,linux.fchdir.id;
  syscall;

  test rax,rax;
  jz   @f;

  throw chdir;

  @@:ret;


; ---   *   ---   *   ---
; read next record for dir
;
; [0] rdi -> fd
; [1] rsi -> buf ptr
; [2] rdx -> buf size
;
; [<] rax -> bytes read, zero on end

public dirnext:

  mov rax,linux.getdents.id;
  syscall;

  cmp rax,$00;
  jge @f;

  mov rdi,$02;
  lea rsi,[dirnext.errme];
  mov rdx,dirnext.errme.len;
  mov rax,$01;
  syscall;

  mov  rdi,FATAL;
  call exit;


  @@:ret;


; ---   *   ---   *   ---
; helper struc for next F

strucdef dirwalk_t {

  .buf  dq $00;
  .ptr  dq $00;

  .fn   dq $00;
  .args dq $00;

  .len  dw $00;
  .left dw $00;
  .fd   dw $00;
  .pad  dw $00;

};

struc dirwalk_t;


; ---   *   ---   *   ---
; map F to each entry in dir
;
; [0] rdi -> fname
; [1] rsi -> buf, alloc on null
; [2] dx  -> len, ignored on null buf
; [3] r10 -> F
; [4] r8  -> args

public dirwalk:

lis dirwalk_t CTX at rbp-sizeof.dirwalk_t;
match ctx , CTX {


  ; setup stack
  push rbp;
  mov  rbp,rsp;
  sub  rsp,sizeof.dirwalk_t;

  ; setup ctx
  mov qword [ctx#.buf],rsi;
  mov qword [ctx#.ptr],$00;
  mov word [ctx#.len],dx;
  mov qword [ctx#.fn],r10;
  mov qword [ctx#.args],r8;

  ; need to get mem?
  test rsi,rsi;
  jnz  @f;

  push rdi;
  mov  di,dirwalk.alloc_cap;
  mov  si,dirwalk.alloc_ezy;
  call alloc;

  mov  qword [ctx#.buf],rax;
  mov  qword [ctx#.len],dirwalk.alloc_cap * \
                        dirwalk.alloc_ezy;
  pop  rdi;

  ; preserve
  @@:push rbx;


  ; open dir
  xor        rdx,rdx;
  open.flags dir,read;
  call       open;

  ; ^backup and jmp to dir!
  mov  word [ctx#.fd],ax;

  xor  rdi,rdi;
  mov  di,ax;
  call fchdir;


  ; read next chunk of records
  .top:

  mov  rsi,qword [ctx#.buf];
  xor  rdx,rdx;
  mov  dx,word [ctx#.len];
  xor  rdi,rdi;
  mov  di,word [ctx#.fd];
  call dirnext;

  ; no more?
  test rax,rax;
  jz   .bot;

  mov  word [ctx#.left],ax;


  ; make indirect call for this record
  .invoke:
  mov  rax,qword [ctx#.fn];
  mov  rbx,qword [ctx#.buf];
  add  rbx,qword [ctx#.ptr];
  mov  rdi,qword [ctx#.args];
  call rax;

  ; recurse?
  cmp  rax,dirwalk.recurse;
  jnz  .go_next;

  lea  rdi,[rbx+linux.dirent.fname];
  xor  rsi,rsi;
  mov  r10,qword [ctx#.fn];
  mov  r8,qword [ctx#.args];
  call dirwalk;

  xor  rdi,rdi;
  mov  di,word [ctx#.fd];
  call fchdir;


  ; advance ptr and substract remain
  .go_next:

  xor rdx,rdx;
  mov dx, word [rbx+linux.dirent.len];
  sub word [ctx#.left],dx;
  add qword [ctx#.ptr],rdx;

  ; go to next entry on record?
  mov dx,word [ctx#.left];
  cmp dx,0;
  jg  .invoke;

  ; ^else read next record!
  mov qword [ctx#.ptr],$00;
  jmp .top;


  ; close dir
  .bot:

  xor  rdi,rdi;
  mov  di,word [ctx#.fd];
  pinb close;

  ; cleanup and give
  pop rbx;
  leave;
  ret;

};

restore CTX;


; ---   *   ---   *   ---
; adds to your namespace

FOOT;
  extrn chdir;
  extrn fchdir;
  extrn dirnext;
  extrn dirwalk;

EOF;


; ---   *   ---   *   ---
