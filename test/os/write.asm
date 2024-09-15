; ---   *   ---   *   ---
; TEST OS WRITE
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

  TITLE     test.os.write;

  VERSION   v0.00.2;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

ELF *;
  include '../../os/write.asm';
  include '../../os/exit.asm';


; ---   *   ---   *   ---
; ROM

fragment %;
  cstr.new m00,'SYSWRITE',$0A;


; ---   *   ---   *   ---
; the bit

fragment *;
entrypoint:


  ; put message!
  lea  rsi,[m00];
  mov  rdx,m00.len;

  call write;

  ; ^flush if need
  test rax,rax;
  jnz  @f;

  call flush;


  ; exit
  @@:

  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
