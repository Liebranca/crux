; ---   *   ---   *   ---
; TEST STD CSTR
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

include '../../macro/elf.inc';


; ---   *   ---   *   ---
; info

  TITLE     test.std.cstr;

  VERSION   v0.00.2;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

ELF *;
  include '../../std/cstr.asm';
  include '../../std/mem.asm';
  include '../../os/exit.asm';


; ---   *   ---   *   ---
; ROM

fragment %;
  cstr.new m00,'HLOWRLD!';
  cstr.new m01,'HLOWRLD!';


; ---   *   ---   *   ---
; GBL

fragment $;
  buf.new b00,$100;


; ---   *   ---   *   ---
; the bit

fragment *;
entrypoint:


  ; get second string in stack
  mov  rdi,qword [rsp+8];
  mov  rsi,$02;
  call cstrnext;

  ; ^copy to static
  mov  rsi,rdi;
  lea  rdi,[b00];
  call cstrcpy;


  ; put newline and print
  lea rdi,[b00+rax+$01];
  mov byte [rdi],$0A;
  add rax,$02;

  lea rsi,[b00];
  mov rdx,rax;
  mov rdi,$01;
  mov rax,$01;

  syscall;


  ; compare strings!
  lea  rdi,[m00];
  lea  rsi,[m01];
  call cstrcmp;

  ; print result
  or  ax,$0A30;
  mov word [b00.end-$02],ax;
  lea rsi,[b00.end-$02];
  mov rdx,$02;
  mov rdi,$01;
  mov rax,$01;

  syscall;


  ; exit
  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
