; ---   *   ---   *   ---
; MEM
; You can't handle it!
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

if ~defined @std.mem.loaded;
define @std.mem.loaded 1;


; ---   *   ---   *   ---
; deps

if ~defined IMPORT | IMPORT;
  include "../macro/elf.inc";

ELF %;


; ---   *   ---   *   ---
; info

define VERSION v0.00.3a;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; ROM

fragment %;


; ---   *   ---   *   ---
; jump table for mem.copy

memcpy.jmptab:

  db $00;

  db memcpy.word-memcpy.byte;
  db memcpy.word_byte-memcpy.byte;

  db memcpy.dword-memcpy.byte;
  db memcpy.dword_byte-memcpy.byte;
  db memcpy.dword_word-memcpy.byte;
  db memcpy.dword_word_byte-memcpy.byte;

  db memcpy.qword-memcpy.byte;


; ---   *   ---   *   ---
; jump table for mem.cmp

memcmp.jmptab:

  db $00;

  db memcmp.word-memcmp.byte;
  db memcmp.word_byte-memcmp.byte;

  db memcmp.dword-memcmp.byte;
  db memcmp.dword_byte-memcmp.byte;
  db memcmp.dword_word-memcmp.byte;
  db memcmp.dword_word_byte-memcmp.byte;

  db memcmp.qword-memcmp.byte;


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; copy N bytes from A to B
;
; [0] rdi -> dst
; [1] rsi -> src
; [2] rdx -> len

public memcpy;


  ; 16 or more bytes left?
  @@:

  cmp rdx,$10;
  jl  @f;

  movdqu xmm0,xword [rsi];
  movdqu xword [rdi],xmm0;
  add    rdi,$10;
  add    rsi,$10;
  sub    rdx,$10;

  ; go next or stop?
  test   rdx,rdx;
  jnz    @b;
  ret;


  ; more than 8 and less than 16?
  @@:

  cmp rdx,$08;
  jle .prim;

  mov r8,qword [rsi];
  mov qword [rdi],r8;
  add rdi,$08;
  add rsi,$08;
  sub rdx,$08;

  ; go next or stop?
  test rdx,rdx;
  jnz  .prim;
  ret;


  ; 8 or less bytes left?
  .prim:

  xor rax,rax;
  dec rdx;
  mov al,byte [rdx+memcpy.jmptab];
  add rax,.byte;

  jmp rax;


  ; single byte!
  .byte:

  mov r8b,byte [rsi];
  mov byte [rdi],r8b;

  ret;

  ; two bytes!
  .word:

  mov r8w,word [rsi];
  mov word [rdi],r8w;

  ret;

  ; three bytes!
  .word_byte:

  mov r8w,word [rsi+$00];
  mov r9b,byte [rsi+$02];

  mov word [rdi+$00],r8w;
  mov byte [rdi+$02],r9b;

  ret;

  ; four bytes!
  .dword:

  mov r8d,dword [rsi];
  mov dword [rdi],r8d;

  ret;


  ; five bytes!
  .dword_byte:
  mov r8d,dword [rsi+$00];
  mov r9b,byte [rsi+$04];

  mov dword [rdi+$00],r8d;
  mov byte [rdi+$04],r9b;

  ret;

  ; six bytes!
  .dword_word:
  mov r8d,dword [rsi+$00];
  mov r9w,word [rsi+$04];

  mov dword [rdi+$00],r8d;
  mov word [rdi+$04],r9w;

  ret;

  ; seven bytes!
  .dword_word_byte:

  mov r8d,dword [rsi+$00];
  mov r9w,word [rsi+$04];
  mov r10b,byte [rsi+$06];

  mov dword [rdi+$00],r8d;
  mov word [rdi+$04],r9w;
  mov byte [rdi+$06],r10b;

  ret;

  ; eight bytes!
  .qword:

  mov r8,qword [rsi];
  mov qword [rdi],r8;

  ret;


; ---   *   ---   *   ---
; check bytes A[0..N] eq B[0..N]
;
; [0] rdi -> dst
; [1] rsi -> src
; [2] rdx -> len
;
; [<] rax -> true if equal

public memcmp;


  ; setup stack
  push rbp;
  mov  rbp,rsp;
  sub  rsp,$10;

  ; preserve/clear out
  push rbx;
  xor  rax,rax;
  xor  rbx,rbx;


  ; 16 or more bytes left?
  @@:

  cmp rdx,$10;
  jl  @f;

  ; check equality
  movdqu xmm0,xword [rsi];
  movdqu xmm1,xword [rdi];
  pxor   xmm0,xmm1;

  ; ^move to output
  movdqu xword [rbp-$10],xmm0;
  or     rax,qword [rbp-$10];
  or     rax,qword [rbp-$08];

  ; stop at first inequality!
  jnz  .stop;


  ; go next or stop?
  add  rdi,$10;
  add  rsi,$10;
  sub  rdx,$10;

  test rdx,rdx;
  jnz  @b;
  jmp  .stop;


  ; more than 8 and less than 16?
  @@:

  cmp rdx,$08;
  jle .prim;

  ; check equality
  mov rax,qword [rsi];
  mov r8,qword [rdi];
  xor rax,r8;

  ; stop at first inequality!
  jnz .stop;


  ; go next or stop?
  add rdi,$08;
  add rsi,$08;
  sub rdx,$08;

  test rdx,rdx;
  jnz  .prim;
  jmp  .stop;


  ; 8 or less bytes left?
  .prim:

  dec rdx;
  mov bl,byte [rdx+memcmp.jmptab];
  add rbx,.byte;

  xor rdx,rdx;
  xor r8,r8;

  jmp rbx;


  ; single byte!
  .byte:

  mov dl,byte [rsi];
  mov al,byte [rdi];
  xor al,dl;

  jmp .stop;

  ; two bytes!
  .word:

  mov dx,word [rsi];
  mov ax,word [rdi];
  xor ax,dx;

  jmp .stop;

  ; three bytes!
  .word_byte:

  mov dl,byte [rsi+$02];
  mov al,byte [rdi+$02];
  xor al,dl;
  shl rax,$10;

  mov dx,word [rsi+$00];
  or  ax,word [rdi+$00];
  xor ax,dx;

  jmp .stop;

  ; four bytes!
  .dword:

  mov edx,dword [rsi];
  mov eax,dword [rdi];
  xor eax,edx;

  jmp .stop;


  ; five bytes!
  .dword_byte:

  mov dl,byte [rsi+$04];
  mov al,byte [rdi+$04];
  xor al,dl;
  shl rax,$20;

  mov edx,dword [rsi+$00];
  mov r8d,dword [rdi+$00];
  xor r8d,edx;
  or  rax,r8;

  jmp .stop;

  ; six bytes!
  .dword_word:

  mov dx,word [rsi+$04];
  mov ax,word [rdi+$04];
  xor ax,dx;
  shl rax,$20;

  mov edx,dword [rsi+$00];
  mov r8d,dword [rdi+$00];
  xor r8d,edx;
  or  rax,r8;

  jmp .stop;

  ; seven bytes!
  .dword_word_byte:

  mov dl,byte [rsi+$06];
  mov al,byte [rdi+$06];
  xor al,dl;
  shl rax,$10;

  mov dx,word [rsi+$04];
  or  ax,word [rdi+$04];
  xor ax,dx;
  shl rax,$20;

  mov edx,dword [rsi+$00];
  mov r8d,dword [rdi+$00];
  xor r8d,edx;
  or  rax,r8;

  jmp .stop;

  ; eight bytes!
  .qword:

  mov rdx,qword [rsi];
  mov rax,qword [rdi];
  xor rax,rdx;


  ; true if rax is non-zero
  .stop:

  mov    rbx,$01;
  mov    rdx,$00;
  test   rax,rax;
  cmovnz rax,rdx;
  cmovz  rax,rbx;

  ; cleanup and give
  pop rbx;

  leave;
  ret;


; ---   *   ---   *   ---
; FOOT

else if ~defined HEADLESS | ~HEADLESS;
  extrn memcpy;
  extrn memcmp;

end if; IMPORT
end if; loaded


; ---   *   ---   *   ---
