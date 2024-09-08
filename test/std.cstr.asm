; ---   *   ---   *   ---
; deps

include '../macro/elf.inc';
ELF *:test@std.cstr;

include '../std/cstr.asm';
include '../std/mem.asm';
include '../os/exit.asm';


; ---   *   ---   *   ---
; the bit

fragment *:_start;


  ; walk argv
  mov  rdi,qword [rsp+8];
  mov  rsi,$02;
  call cstr.next;


  ; get length of this string
  mov  rdi,rax;
  call cstr.len;

  ; ^reserve length bytes in stack
  inc  rax;
  push rbp;
  mov  rbp,rsp;
  sub  rsp,rax;

  ; ^copy to stack
  mov  rsi,rdi;
  mov  rdi,rsp;
  mov  rdx,rax;
  push rax;
  call mem.copy;

  ; print ;>
  pop  rdx;
  mov  rsi,rsp;
  mov  rdi,$01;
  mov  rax,$01;

  syscall;

  ; exit
  leave;

  mov  rdi,OK;
  call os.exit;


; ---   *   ---   *   ---
; FOOT

fragment.end;
ELF.end;


; ---   *   ---   *   ---
