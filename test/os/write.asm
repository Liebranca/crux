; ---   *   ---   *   ---
; deps

include '../../macro/elf.inc';

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
public _start;


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
