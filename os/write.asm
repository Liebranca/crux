; ---   *   ---   *   ---
; OS WRITE
; Buffered by default
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

include "../macro/elf.inc";


; ---   *   ---   *   ---
; info

  TITLE     os.write;

  VERSION   v0.00.2a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; s-consts

linux.write:
  .id = $01;


; ---   *   ---   *   ---
; deps

ELF %;
  include "../std/mem.asm";


; ---   *   ---   *   ---
; GBL

fragment $;


  ; use default buffer size?
  if ~defined BUFIO_SIZE;
    bufio.size = $1000;

  else;
    bufio.size = BUFIO_SIZE;

  end if;

  ; cap buffer size to 16-bit!
  assert bufio.size < $10000;

  ; make new buffer
  bufio.fd  dw $0001;
  bufio.ptr dw $0000;

  buf.new bufio.mem,bufio.size;


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; put data in buffer
;
; [0] rsi -> ptr to buf
; [1] rdx -> bytes to write
;
; [<] rax -> flush triggered

public write:


  ; setup stack
  push rbp;
  mov  rbp,rsp;
  sub  rsp,$09;

  ; save initial length and set out as false
  mov qword [rbp-$08],rdx;
  mov byte [rbp-$09],$00;


  ; get avail space in buffer
  xor rdi,rdi;
  mov di,word [bufio.ptr];

  ; have enough space?
  @@:

  mov  rax,bufio.size;
  sub  rax,rdi;
  cmp  rax,rdx;
  jge  @f;

  ; if not, then flush!
  .top:

  push rdx;
  push rsi;
  call flush;

  ; remember that we flushed the buffer!
  mov byte [rbp-$09],$01;

  ; ^restore
  pop  rsi;
  pop  rdx;
  xor  rdi,rdi;


  ; cap write to buffer size!
  mov   rax,bufio.size;
  cmp   rdx,rax;
  cmovg rdx,rax;


  ; get buffer+offset
  @@:

  push rdx;
  lea  rdi,[bufio.mem+rdi];
  call memcpy;

  pop  rdx;

  ; go next chunk
  add  word [bufio.ptr],dx;
  sub  qword [rbp-$08],rdx;
  mov  rdx,qword [rbp-$08];

  test rdx,rdx;
  jnz  .top;


  ; cleanup and give
  xor rax,rax;
  mov al,byte [rbp-$09];

  leave;
  ret;


; ---   *   ---   *   ---
; ^commit data in buffer to file!
;
; [<] rax -> bytes commited

public flush;


  ; skip if buffer is empty!
  xor  rdx,rdx;
  mov  dx,word [bufio.ptr];
  test dx,dx;
  jz   @f;

  ; load buffer
  xor rdi,rdi;
  mov di,word [bufio.fd];
  lea rsi,[bufio.mem];

  ; out to file
  push rdx;
  mov  rax,linux.write.id;
  syscall;


  ; reset length and give
  mov word [bufio.ptr],$00;
  pop rax;

  @@:ret;


; ---   *   ---   *   ---
; set output file
;
; [0] rdi -> fd

public fout:

  ; skip if file already set!
  mov si,word [bufio.fd];
  cmp di,si;
  jz  @f;

  ; else flush and reset
  push rdi;
  call flush;

  pop  rdi;
  mov  word [bufio.fd],di;

  @@:ret;


; ---   *   ---   *   ---
; adds to your namespace

FOOT;
  extrn write;
  extrn flush;
  extrn fout;

EOF;


; ---   *   ---   *   ---
