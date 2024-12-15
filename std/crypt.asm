; ---   *   ---   *   ---
; CRYPT
; Spooky stuff!
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

include '../macro/elf.inc'


; ---   *   ---   *   ---
; info

  TITLE     std.crypt;

  VERSION   v0.00.1a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; s-consts

; ---   *   ---   *   ---
; public inlines

macro inline.xorkey bits {

  mov rdx,rax;

  local total;
  total = sizebs.qword;

  while total;
    ror rdx,bits;
    xor rax,rdx;
    total = total - bits;

  end while;

  xor rdx,rdx;
  and rax,(1 shl bits)-1;

};

macro inline.bitfind {
  xor    rcx,rcx;
  bsf    r8,rdi;
  cmovnz rcx,r8;

};


; ---   *   ---   *   ---
; 64-bit memory occupation mask
; used for cask slot fit and reuse

strucdef mmask_t {

  .ezy dw $00;
  .cap dw $00;
  .cnt dw $00;
  .pad dw $00;

  .buf^:

};

struc mmask_t;


; ---   *   ---   *   ---
; deps

ELF %;
  include 'memcpy.asm';
  include 'uint.asm';


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; make mmask
;
; [*] rbx -> ptr to mem or null for alloc
; [0] di  -> ezy
; [1] si  -> cap
;
; [<] rbx -> ice

public mmask:

lis mmask_t SELF at rbx;
match self , SELF {

  ; get number of masks needed
  xor    rdx,rdx;
  xor    rcx,rcx;
  xor    rax,rax;
  mov    ax,si;
  mov    cx,64;
  div    rcx;

  mov    rcx,$01;
  test   rdx,rdx;
  cmovnz rdx,rcx;
  add    rax,rdx;

  ; TODO: alloc
  test  rbx,rbx;
  jnz   @f;

  ; make ice
  @@:

  mov word [self#.ezy],di;
  mov word [self#.cap],si;
  mov word [self#.cnt],cx;


  ; zero-flood buf
  xor  rdx,rdx;
  mov  dx,di;
  shl  rdx,3;
  lea  rdi,[self#.buf^];
  xor  rsi,rsi;
  call memset;
  ret;


};

restore SELF;


; ---   *   ---   *   ---
; maps size in bytes to bitmask
;
; [*] rbx -> ice
; [0] rax -> req (ezy*cnt)
;
; [<] rax -> elem bitmask (zero if req too big!)

public mmaske:

lis mmask_t SELF at rbx;
match self , SELF {

  ; get block count
  xor    rdx,rdx;
  xor    rcx,rcx;
  mov    cx,word [self#.ezy];
  div    rcx;

  mov    rcx,$01;
  test   rdx,rdx;
  cmovnz rdx,rcx;
  add    rax,rdx;

  ; make bitmask and give
  call mmaske.result;
  ret;

};

restore SELF;


; ---   *   ---   *   ---
; ^faster version for ezy eq pow2
;
; [*] rbx -> ice
; [0] rax -> req (ezy*cnt)
;
; [<] rax -> elem bitmask (zero if req too big!)

public mmaskep2:

lis mmask_t SELF at rbx;
match self , SELF {

  ; get block count
  mov  cx,word [self#.ezy];
  bsf  cx,cx;
  mov  rdi,rax;
  pinb urdivp2;

  ; make bitmask and give
  call mmaske.result;
  ret;

};

restore SELF;


; ---   *   ---   *   ---
; ^common to both!

mmaske.result:

  ; edge case: 64 blocks or more!
  cmp   rax,$40;
  jl    @f;

  mov    rcx,-$01;
  mov    rdx,$00;
  cmovz  rax,rcx;
  cmovnz rax,rdx;
  ret;


  ; make bitmask from count!
  @@:

  mov rcx,rax;
  mov rax,$01;
  shl rax,cl;
  lea rax,[rax-$01];


  ; cleanup and give
  ret;


; ---   *   ---   *   ---
; ^insert elem!
;
; [*] rbx -> ice
; [0] rax -> elem bitmask
;
; [<] rax -> slot idex ($40 on fail!)

public mmaskfit:

lis mmask_t SELF at rbx;
match self , SELF {

  ; setup stack
  push rbp;
  mov  rbp,rsp;
  sub  rsp,$08;

  mov  qword [rbp-$08],$00;


  ; get next mask chunk
  .next_chunk:

  mov rsi,qword [rbp-$08];
  shr rsi,3;

  ; reset counter, then stop if no more chunks!
  xor    rdx,rdx;
  mov    r8w,word [self#.cnt];
  xor    rcx,rcx;
  cmp    si,r8w;
  cmovge rax,rcx;
  jge    .ok;

  ; else continue
  shl rsi,3;
  add qword [rbp-$08],$08;
  mov rdi,qword [self#.buf^+rsi];


  ; get free bits in mask
  .find:

  not  rdi;
  pinb bitfind;
  not  rdi;

  ; reset on over-shift
  ror    rdi,cl;
  popcnt r8,rax;
  dec    r8;
  lea    r8,[r8+rdx];
  add    r8,rcx;
  cmp    r8,$40;
  jge    .next_chunk;

  ; up counter and stop if elem fits!
  add  rdx,rcx;
  test rax,rdi;
  jz   .ok;


  ; else skip occupied portion
  pinb bitfind;
  test cl,cl;
  jz   .next_chunk;

  ror  rdi,cl;
  add  rdx,rcx;
  jmp  .find;


  ; cleanup and give
  .ok:

  mov rsi,qword [rbp-$08];
  sub rsi,$08;
  mov rcx,rdx;
  shl rax,cl;
  or  qword [self#.buf^+rsi],rax;

  leave;
  ret;

};

restore SELF;


; ---   *   ---   *   ---
; hashes 64-bit value into N-bits
;
; [0] rax -> num to squash
;
; [<] rax -> key

public xorkey8:
  pinb xorkey,8;
  ret;


; ---   *   ---   *   ---
; get first set/unset bit
;
; [0] rax -> elem bitmask
; [1] rdi -> mmask buf^
;
; [<] rcx -> bit idex (zero if full!)

public bitfind:
  pinb bitfind;
  ret;


; ---   *   ---   *   ---
; adds to your namespace

FOOT;
  extrn mmask;
  extrn mmaske;
  extrn mmaskep2;
  extrn mmaskfit;
  extrn xorkey8;
  extrn bitfind;

EOF;


; ---   *   ---   *   ---
