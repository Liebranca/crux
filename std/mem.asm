; ---   *   ---   *   ---
; CSTR
; Go charstar!
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

if ~used @std.cstr.loaded;
@std.cstr.loaded = 1;


; ---   *   ---   *   ---
; deps

if ~defined IMPORT;
include "../macro/elf.inc";


; ---   *   ---   *   ---
; info

ELF %:mem;

define VERSION v0.00.1a;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; ROM

fragment %:rom;

  .copy.prim:

    db $0000;

    db mem.copy.word-mem.copy.byte;
    db mem.copy.word_byte-mem.copy.byte;

    db mem.copy.dword-mem.copy.byte;
    db mem.copy.dword_byte-mem.copy.byte;
    db mem.copy.dword_word-mem.copy.byte;
    db mem.copy.dword_word_byte-mem.copy.byte;

    db mem.copy.qword-mem.copy.byte;

; ---   *   ---   *   ---
; EXE
;
; copy N bytes from A to B
;
; [0] rdi -> dst
; [1] rsi -> src
; [2] rdx -> len

fragment *:public copy;


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
  mov al,byte [rdx+mem.rom.copy.prim];
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
  mov r9b,byte [rsi+$01];

  mov word [rdi+$00],r8w;
  mov byte [rdi+$01],r9b;

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
; FOOT

fragment.end;

else if ~defined HEADLESS;
  extrn mem.copy;

end if; IMPORT
ELF.end;

end if; loaded


; ---   *   ---   *   ---
