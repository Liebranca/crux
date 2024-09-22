; ---   *   ---   *   ---
; TEST OS OPEN
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

  TITLE     test.os.open;

  VERSION   v0.00.2;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

ELF *;
  include '../../os/open.asm';


; ---   *   ---   *   ---
; ROM

fragment %;
  cstr.new m00,'./testf';


; ---   *   ---   *   ---
; the bit

fragment *;
entrypoint:


  ; make new file
  lea rdi,[m00];
  open.flags write,new;
  open.mode  own,rw;
  call open;

  ; ^close it!
  mov  rdi,rax;
  pinb close;

  ; delete file ;>
  lea  rdi,[m00];
  pinb unlink;


  ; exit
  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
