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
; allocator base

strucdef alloct {

  ; use default for table size increment?
  if ~defined ALLOCT.STEP;
    alloct.step = $40;

  else;
    alloct.step = ALLOCT.STEP;

  end if;

  ; ^cap to 32-bit!
  assert alloct.step < (1 shl 32);


  ; fields
  .buf   dq $00;
  .mask  dq $00;

  .cnt   dd $00;
  .cap   dd alloct.step;

  .ezy   dd sizeof.alloct;
  .flags dd $00;


  ; flagdefs
  alloct.flags.dynamic = $0001;

  ; meta
  alloct.req    = sizeof.alloct * alloct.step;
  sizep2.alloct = $05;

  ; ^ensure the size is correct!
  assert sizeof.alloct = $20;

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
  or   dword [mmap.alloct.flags],\
       alloct.flags.dynamic;

  ; reset table and give
  @@:

  mov qword [mmap.alloct.buf],rdi;
  mov dword [mmap.alloct.cnt],$00;

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

  mov  eax,dword [mmap.alloct.flags];
  test eax,alloct.flags.dynamic;
  jz   @f;


  ; map bytesize to page count
  mov  edi,dword [mmap.alloct.cap];
  shl  rdi,sizep2.alloct;
  mov  cl,sizep2.page;
  pinb urdivp2;

  ; ^unmap pages!
  mov  rsi,rdi;
  mov  rdi,qword [mmap.alloct.buf];
  pinb munmap;


  ; clear table and give
  @@:

  mov qword [mmap.alloct.buf],$00;
  mov qword [mmap.alloct.mask],$00;
  mov dword [mmap.alloct.flags],$00;

  ret;


; ---   *   ---   *   ---
; adds to your namespace

FOOT;
  extrn mmap;
  extrn munmap;
  extrn begalloc;
  extrn endalloc;

EOF;


; ---   *   ---   *   ---
