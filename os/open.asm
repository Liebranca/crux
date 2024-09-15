; ---   *   ---   *   ---
; OS OPEN
; Typical filemaking
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

if ~defined @os.open.loaded;
define @os.open.loaded 1;


; ---   *   ---   *   ---
; s-consts

linux.open:

  .id     = $02;

  .read   = $0000;
  .write  = $0001;
  .flow   = $0002;

  .new    = $0040;
  .trunc  = $0200;
  .append = $0400;
  .nblock = $0800;

linux.fmode:

  .r   = $04;
  .w   = $02;
  .x   = $01;

  .rw  = $06;
  .rwx = $07;

linux.close.id  = $03;
linux.trunc.id  = $4C;
linux.unlink.id = $57;


; ---   *   ---   *   ---
; load flags!

macro open.flags [list] {

  common;
    local out;
    out equ 0;

  forward match item , list \{
    out equ out or linux.open.\#item;

  \};

  common match any , out \{
    mov rsi,any;

  \};

};

; ---   *   ---   *   ---
; load mode!

macro open.mode [list] {


  ; fstate
  common;

    local out;
    local which;
    local ok;

    out   equ 0;
    which equ 6;


  ; walk elems
  forward match item , list \{

    ; permissions for whom?
    ok equ 0;
    match =own , item \\{
      which equ 6;
      ok    equ 1;

    \\};

    match =group , item \\{
      which equ 3;
      ok    equ 1;

    \\};

    match =other , item \\{
      which equ 0;
      ok    equ 1;

    \\};

    ; ^set permissions to selected
    match =0 , ok \\{
      out equ out or (linux.fmode.\#item shl which);

    \\};

  \};

  ; load the value!
  common match any , out \{
    mov rdx,out;

  \};

};

; ---   *   ---   *   ---
; these are simple enough to
; warrant inlining

macro inline.close {
  mov rax,linux.close.id;
  syscall;

};
macro inline.unlink {
  mov rax,linux.unlink.id;
  syscall;

};


; ---   *   ---   *   ---
; deps

if ~defined IMPORT | IMPORT;
  include "../macro/elf.inc";

ELF %;
  include "exit.asm";


; ---   *   ---   *   ---
; info

define VERSION v0.00.1a;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; ROM

fragment %;
  cstr.new open.errme,'cannot find file',$0A;


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; [0] rdi -> fname
; [1] rsi -> flags
; [2] rdx -> mode
;
; [<] rax -> fd

public open:


  ; get descriptor
  mov rax,linux.open.id;
  syscall;

  ; ^errcatch
  cmp rax,$00;
  jge @f;

  mov rdi,$02;
  lea rsi,[open.errme];
  mov rdx,open.errme.len;
  mov rax,$01;
  syscall;

  mov  rdi,FATAL;
  call exit;


  @@:ret;


; ---   *   ---   *   ---
; [0] rdi -> fd

public close:
  inline.close;
  ret;


; ---   *   ---   *   ---
; [0] rdi -> fname

public unlink:
  inline.unlink;
  ret;


; ---   *   ---   *   ---
; FOOT

else if ~defined HEADLESS | ~HEADLESS;
  extrn open;
  extrn close;
  extrn unlink;

end if; IMPORT
end if; loaded


; ---   *   ---   *   ---
