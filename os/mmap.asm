; ---   *   ---   *   ---
; OS MMAP
; Hands you BIG mem ;>
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

  TITLE     os.mmap;

  VERSION   v0.00.4a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; s-consts

linux.mmap:

  .id        = $09;

  .proto_r   = $01;
  .proto_rw  = $03;
  .proto_rx  = $05;

  .anon      = $22;
  .shared    = $01;

  .nofd      = -1;


linux.munmap.id = $0B;


; ---   *   ---   *   ---
; calculates size of main table

macro @mmap.proc_casks [item] {

  common;
    local step;
    local elems;
    local sz;
    local mask.sz;

    step    equ 0;
    elems   equ 0;
    sz      equ 0;
    mask.sz equ 0;

  forward match cnt =: ezy , item \{
    step    equ step  + 1;
    elems   equ elems + (cnt);
    sz      equ sz    + (ezy);
    mask.sz equ mask.sz + (cnt + ((1 shl 6)-1)) shr 6

  \};

  common;

    alloct.step    = step;
    alloct.cap     = step;
    alloct.mask_sz = mask.sz;
    alloct.req     = sizeof.alloct * alloct.step \
                   + (alloct.mask_sz shl 3);

};

; ---   *   ---   *   ---
; allocator base

strucdef alloct {


  ; read pre-allocations to build main table!
  if ~defined ALLOCT.READY;
    match list , CASK.LIST \{
      @mmap.proc_casks list;

    \};

  end if;


  ; fields
  .buf   dq $00;

  .cnt   dw $00;
  .cap   dw alloct.step;

  .ezy   dw sizeof.alloct;
  .flags dw $00;

  .mask:


  ; consts
  if ~defined ALLOCT.READY

    ; flagdefs
    alloct.flags.dynamic = $0001;

    ; meta
    sizep2.alloct = $04;

    ; ^ensure the size is correct!
    assert sizeof.alloct = $10;

  end if;
  define ALLOCT.READY 1;

};

struc alloct;


; ---   *   ---   *   ---
; public inlines

macro inline.munmap {

  ; N pages to N*page
  shl rsi,sizep2.page;

  ; cleanup and give
  mov rax,linux.munmap.id;
  syscall;

};


; ---   *   ---   *   ---
; deps

ELF %;
  include "exit.asm";
  include "../std/uint.asm";


; ---   *   ---   *   ---
; ROM

fragment %;

  cstr.new throw.alloctab_renit,\
    'illegal: alloctab renit',$0A;

  cstr.new throw.alloctab_dfree,\
    'illegal: alloctab dfree',$0A;


; ---   *   ---   *   ---
; GBL

fragment $;
  static alloct mmap.alloct;


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; get block of memory
;
; [0] rdi -> size in bytes
;
; [<] rax -> ptr to block

public mmap;


  ; preserve
  push r11;

  ; align input to page size
  mov  cl,sizep2.page;
  pinb urdivp2;

  shl  rax,cl;
  mov  rsi,rax;


  ; boilerpaste
  mov rdx,linux.mmap.proto_rw;
  mov r10,linux.mmap.anon;
  mov r8 ,linux.mmap.nofd;

  xor rdi,rdi;
  xor r9 ,r9;

  ; ^call mmap
  mov rax,linux.mmap.id;
  syscall;


  ; restore and give
  pop r11;
  ret;


; ---   *   ---   *   ---
; ^dstruc
;
; [0] rdi -> ptr to block
; [1] rsi -> total pages

public munmap;
  pinb munmap;
  ret;


; ---   *   ---   *   ---
; barebones allocator!
;
; [0] rdi -> ptr to buf, null for new
;
; [<] rdi -> ptr to buf

public begalloc:


  ; check that the table is uninitialized
  mov   rax,qword [mmap.alloct.buf];
  test  rax,rax;
  jz    @f;

  throw alloctab_renit;


  ; get memory or use existing?
  @@:

  test rdi,rdi;
  jnz  @f;

  mov  rdi,alloct.req;
  call mmap;

  mov  rdi,rax;
  or   word [mmap.alloct.flags],\
       alloct.flags.dynamic;

  ; reset table and give
  @@:

  mov qword [mmap.alloct.buf],rdi;
  mov word [mmap.alloct.cnt],$00;

  ret;


; ---   *   ---   *   ---
; ^dstruc

public endalloc:


  ; check that the table is initialized
  mov   rax,qword [mmap.alloct.buf];
  test  rax,rax;
  jnz   @f;

  throw alloctab_dfree;

  ; need to free heap?
  @@:

  mov  ax,word [mmap.alloct.flags];
  test ax,alloct.flags.dynamic;
  jz   @f;


  ; map bytesize to page count
  xor  rdi,rdi;
  mov  di,word [mmap.alloct.cap];
  shl  rdi,sizep2.alloct;
  add  rdi,alloct.mask_sz shl 3;
  mov  cl,sizep2.page;
  pinb urdivp2;

  ; ^unmap pages!
  mov  rsi,rax;
  mov  rdi,qword [mmap.alloct.buf];
  pinb munmap;


  ; clear table
  @@:

  mov qword [mmap.alloct.buf],$00;
  mov dword [mmap.alloct.flags],$00;

  ret;


; ---   *   ---   *   ---
; get unused table entry
;
; [0] di -> cap
; [1] si -> ezy
;
; [<] rax -> ptr to alloct entry

public alloc:

lis alloct E at rax;
match elem , E {


  ; preserve/clear
  push rbx;
  xor  rdx,rdx;


  ; get next elem
  @@:

  mov rax,qword [mmap.alloct.buf];
  add rax,rdx;

  ; occupied?
  mov  rbx,qword [elem#.buf];
  test rbx,rbx;
  jz   @f;


  ; skip mask array (qword count)
  push rdi;
  xor  rdi,rdi;
  mov  di,word [elem#.cap];
  mov  cl,sizep2.zword;
  pinb urdivp2;
  shl  rax,3;
  lea  rdx,[rax+sizeof.alloct];

  pop  rdi;
  jmp  @b;


  ; fill out meta
  @@:

  mov word [elem#.cap],di;
  mov word [elem#.ezy],si;

  ; restore and give
  pop rbx;
  ret;

};

restore E;


; ---   *   ---   *   ---
; adds to your namespace

FOOT;
  extrn mmap;
  extrn munmap;
  extrn begalloc;
  extrn endalloc;
  extrn alloc;

EOF;


; ---   *   ---   *   ---
