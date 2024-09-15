; ---   *   ---   *   ---
; SHRINE
; Elf temple
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; deps

include '../macro/elf.inc';
ELF *;

define BUFIO_SIZE temple.len;
include '../os/open.asm';
include '../os/write.asm';
include '../os/exit.asm';
include '../std/cstr.asm';


; ---   *   ---   *   ---
; ROM

fragment %;
temple:

db '; ---   *   ---   *   ---',$0A;
db '; [NAME]',$0A;
db '; [DESCRIPTION]',$0A;
db ';',$0A;
db '; LIBRE SOFTWARE',$0A;
db '; Licensed under GNU GPL3',$0A;
db '; be a bro and inherit',$0A;
db ';',$0A;
db '; CONTRIBUTORS',$0A;
db '; lyeb,',$0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;
db '; HEAD',$0A;
db $0A;
db 'if ~defined @[name].loaded;',$0A;
db 'define @[name].loaded 1;',$0A;
db $0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;
db '; s-consts',$0A;
db $0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;
db '; deps',$0A;
db $0A;
db 'if ~defined IMPORT | IMPORT;',$0A;
db "  include '../macro/elf.inc'",$0A;
db $0A;
db "ELF %;",$0A;
db $0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;
db '; FOOT',$0A;
db $0A;
db 'else if ~defined HEADLESS | ~HEADLESS;',$0A;
db $0A;
db 'end if; IMPORT',$0A;
db 'end if; loaded',$0A;
db $0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;

temple.len = $-temple;

; ---   *   ---   *   ---
; EXE

fragment *;
public _start:


  ; argc > 1?
  mov   rdx,$01;
  mov   rax,qword [rsp];
  cmp   rax,rdx;
  cmove rax,rdx;
  je    @f;

  ; ^use first arg as output path!
  mov  rdi,qword [rsp+8];
  mov  rsi,$01;
  call cstrnext;

  ; make file
  open.flags new,write;
  open.mode  rw;
  call open;


  ; setup stack
  @@:

  push rbp;
  mov  rbp,rsp;
  sub  rsp,$02;

  ; ^save fd
  mov word [rbp-$02],ax;


  ; set output file
  mov  rdi,rax;
  call fout;


  ; put template
  lea  rsi,[temple];
  mov  rdx,temple.len;
  call write;
  call flush;

  ; need to close file?
  xor rax,rax;
  mov ax,word [rbp-$02];
  cmp ax,$01;
  je  @f;

  mov rdi,rax;
  inline.close;


  ; cleanup and give
  @@:

  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
