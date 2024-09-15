; ---   *   ---   *   ---
; deps

include '../../macro/elf.inc';

ELF *;
  include '../../os/open.asm';


; ---   *   ---   *   ---
; ROM

fragment %;
  cstr.new m00,'./testf';


; ---   *   ---   *   ---
; the bit

fragment *;
public _start;


  ; make new file
  lea rdi,[m00];
  open.flags write,new;
  open.mode  own,rw;
  call open;

  ; ^close it!
  mov rdi,rax;
  inline.close;

  ; delete file ;>
  lea rdi,[m00];
  inline.unlink;


  ; exit
  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
