; ---   *   ---   *   ---
; UINT
; No signs here
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

if ~used @std.uint.loaded;
@std.uint.loaded = 1;


; ---   *   ---   *   ---
; get size constants for pow2

macro @uint.genp2 name,exp {
  match any , name \{
    sizep2.\#any = exp;
    sizeof.\#any = 1 shl exp;
    sizebs.\#any = sizeof.\#any shl 3;

    if exp < 3;
      sizebm.\#any = (1 shl sizebs.\#any)-1;

    else;
      sizebm.\#any = $FFFFFFFFFFFFFFFF;

    end if;

  \};

};


; ---   *   ---   *   ---
; ^bat

macro @uint.genp2_bat [line] {
  forward match name exp , line \{
    @uint.genp2 name,exp;
  \}
};

@uint.genp2_bat \
  byte  $00,word  $01,dword $02,qword $03,\
  xword $04,yword $05,zword $06,\
  page  $0C;


; ---   *   ---   *   ---
; deps

if ~defined IMPORT;
include "../macro/elf.inc";


; ---   *   ---   *   ---
; info

ELF %:uint;

define VERSION v0.00.1a;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; EXE
;
; rounded-up division by a power of 2
;
; [0] rdi -> X to align
; [1] cl  -> exponent

fragment *:public urdivp2;


  ; get 2^N thru shift
  mov rax,$01;
  shl rax,cl;

  ; ensure non-zero
  mov   rdx,$01;
  test  rdi,rdi;
  cmove rdi,rdx;

  ; (X + (2^N)-1) >> N
  ; gives division rounded up
  lea rax,[rdi+rax-$01];
  shr rax,cl;


  ret;


; ---   *   ---   *   ---
; FOOT

fragment.end;

else if ~defined HEADLESS;
  extrn urdivp2;

end if; IMPORT
ELF.end;

end if; loaded


; ---   *   ---   *   ---
