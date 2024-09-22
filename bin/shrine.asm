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
; HEAD

include '../macro/elf.inc';


; ---   *   ---   *   ---
; info

  TITLE     shrine;

  VERSION   v0.00.2a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

ELF *;
  define BUFIO.SZ temple.len;
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
db '; ME,',$0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;
db '; HEAD',$0A;
db $0A;
db "include '../macro/elf.inc'",$0A;
db $0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;
db '; info',$0A;
db $0A;
db '  TITLE     module;',$0A;
db $0A;
db '  VERSION   v0.00.1a;',$0A;
db "  AUTHOR    'ME';",$0A;
db $0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;
db '; s-consts',$0A;
db $0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;
db '; deps',$0A;
db $0A;
db "ELF %;",$0A;
db $0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;
db '; EXE',$0A;
db $0A;
db "fragment *;",$0A;
db $0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;
db '; adds to your namespace',$0A;
db $0A;
db 'FOOT;',$0A;
db $0A;
db 'EOF;',$0A;
db $0A;
db $0A;
db '; ---   *   ---   *   ---',$0A;

temple.len = $-temple;


; ---   *   ---   *   ---
; EXE

fragment *;
entrypoint:


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
  xor  rax,rax;
  mov  ax,word [rbp-$02];
  cmp  ax,$01;
  je   @f;

  mov  rdi,rax;
  pinb close;


  ; cleanup and give
  @@:

  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
