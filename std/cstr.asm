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

if ~used @std.cstr.loaded;
@std.cstr.loaded = 1;


; ---   *   ---   *   ---
; deps

if ~defined IMPORT;
include "../macro/elf.inc";


; ---   *   ---   *   ---
; info

ELF %;

define VERSION v0.00.2a;
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
; length of cstr if chars
; are in 00-7E range, else bogus
;
; [0] rdi -> string to check

public cstrlen;


  ; cleanup
  xor rax,rax;


  ; get position of first null byte
  @@:

  mov  rdx,qword [rdi];
  call firstnull;

  ; ^end reached?
  test  rcx,rcx;
  jnz   @f;

  ; ^else increase
  add   rax,8
  add   rdi,8
  jmp   @b;


  ; sum and give final length
  @@:

  dec   rcx;
  sub   rdi,rax;
  add   rax,rcx;

  ret;


; ---   *   ---   *   ---
; gives 0 or 1+idex of first null char
;
; [0] rdx -> bytes to check

firstnull:

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
  ret;


; ---   *   ---   *   ---
; skip N entries in cstr array
;
; [0] rdi -> ptr to buff
; [1] rsi -> N

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
; FOOT

else if ~defined HEADLESS;
  extrn cstrlen;
  extrn cstrnext;

end if; IMPORT
end if; loaded


; ---   *   ---   *   ---
