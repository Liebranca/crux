; ---   *   ---   *   ---
; CSTR
; Go charstar!
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

if ~defined @std.cstr.loaded;
define @std.cstr.loaded 1;


; ---   *   ---   *   ---
; deps

if ~defined IMPORT | IMPORT;
  include "../macro/elf.inc";

ELF %;
  include "mem.asm";


; ---   *   ---   *   ---
; info

define VERSION v0.00.3a;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; ROM

fragment %;


; ---   *   ---   *   ---
; constants for finding null bytes

  cstr.MASK_Z0 dq $7F7F7F7F7F7F7F7F
  cstr.MASK_Z1 dq $0101010101010101
  cstr.MASK_Z2 dq $8080808080808080


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; gives 0 or 1+idex of first null char
;
; [0] rdx -> bytes to check

firstnull:

macro inline.firstnull {

  xor rcx,rcx

  ; convert 00 to 80 && 01-7E to 00 ;>
  xor rdx,qword [cstr.MASK_Z0];
  add rdx,qword [cstr.MASK_Z1];
  and rdx,qword [cstr.MASK_Z2];

  je  @f;

  ; get first null byte (80)+1
  bsf rcx,rdx;
  shr rcx,$03;
  inc rcx;


  @@:

};

  inline.firstnull;
  ret;


; ---   *   ---   *   ---
; length of cstr if chars
; are in 00-7E range, else bogus
;
; [0] rdi -> string to check
;
; [<] rax -> length

public cstrlen;


  ; cleanup
  xor rax,rax;


  ; get position of first null byte
  .top:

  mov rdx,qword [rdi];
  inline.firstnull;

  ; ^end reached?
  test rcx,rcx;
  jnz  @f;

  ; ^else increase
  add rax,8
  add rdi,8
  jmp .top;


  ; sum and give final length
  @@:

  dec rcx;
  sub rdi,rax;
  add rax,rcx;

  ret;


; ---   *   ---   *   ---
; skip N entries in cstr array
;
; [0] rdi -> ptr to buff
; [1] rsi -> N
;
; [<] rdi -> ptr+N*len

public cstrnext;


  ; stop at N strings skipped
  @@:

  test rsi,rsi;
  jz   @f;

  ; ^walk next string
  call cstrlen;

  dec  rsi;
  lea  rdi,[rdi+rax+1];
  jmp  @b;


  ; give next string!
  @@:
  ret;


; ---   *   ---   *   ---
; put B in A
;
; [0] rdi -> dst
; [1] rsi -> src
;
; [<] rax -> length of src

cstrcpy:


  ; get bytes to copy
  push rdi;
  mov  rdi,rsi;
  call cstrlen;

  ; ^copy them!
  pop  rdi;
  push rax;
  mov  rdx,rax;
  call memcpy;

  ; give new length
  pop rax;
  ret;


; ---   *   ---   *   ---
; give A eq B
;
; [0] rdi -> self
; [1] rsi -> other
;
; [<] rax -> true if equal

cstrcmp:

  ; setup stack
  push rbp;
  mov  rbp,rsp;
  sub  rsp,$08;

  ; get length of A
  call cstrlen;
  mov  qword [rbp-$08],rax;

  ; get length of B;
  push rdi;
  mov  rdi,rsi;
  call cstrlen;

  ; stop if unequal lengths!
  pop  rdi;
  mov  rdx,rax;
  xor  rax,qword [rbp-$08];
  test rax,rax;
  jnz  @f;

  ; equal lengths, so compare!
  call memcmp;


  ; cleanup and give
  @@:

  leave;
  ret;


; ---   *   ---   *   ---
; FOOT

else if ~defined HEADLESS | ~HEADLESS;
  extrn cstrlen;
  extrn cstrnext;
  extrn cstrcpy;
  extrn cstrcmp;

end if; IMPORT
end if; loaded


; ---   *   ---   *   ---
