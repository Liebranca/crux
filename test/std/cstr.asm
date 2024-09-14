; ---   *   ---   *   ---
; deps

include '../../macro/elf.inc';
ELF *;

include '../../std/cstr.asm';
include '../../std/mem.asm';
include '../../os/exit.asm';


; ---   *   ---   *   ---
; the bit

fragment *;
public _start;


  ; get second string in stack
  mov  rdi,qword [rsp+8];
  mov  rsi,$02;
  call cstrnext;


  ; get length of this string
  call cstrlen;

  ; ^reserve length bytes in stack
  add  rax,$02;
  push rbp;
  mov  rbp,rsp;
  sub  rsp,rax;

  ; ^copy to stack
  mov  rsi,rdi;
  mov  rdi,rsp;
  push rax;
  dec  rax;
  mov  rdx,rax;
  call memcpy;


  ; put newline and print
  mov byte [rbp-$01],$0A;

  pop rdx;
  mov rsi,rsp;
  mov rdi,$01;
  mov rax,$01;

  syscall;


  ; exit
  leave;

  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
