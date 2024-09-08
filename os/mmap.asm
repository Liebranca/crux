; ---   *   ---   *   ---
; OS MMAP
; Hands you BIG mem ;>
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

if ~used @os.mmap.loaded;
@os.mmap.loaded = 1;

; ---   *   ---   *   ---
; s-consts

linux.mmap:

  .id        = $09;

  .proto_r   = $01;
  .proto_rw  = $03;
  .proto_rx  = $05;

  .anon      = $22;
  .shared    = $01;

  .nofd      = -1;


linux.munmap.id = $0B;


; ---   *   ---   *   ---
; deps

if ~defined IMPORT;
include "../macro/elf.inc";
include "../std/uint.asm";


; ---   *   ---   *   ---
; info

ELF %:os;

define VERSION v0.00.1a;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; EXE
;
; [0]:rdi -> size in bytes

fragment *:public mmap;


  ; preserve
  push r11;

  ; align input to page size
  mov  cl,sizep2.page;
  call std.urdivp2;

  shl  rax,cl;
  mov  rsi,rax;


  ; boilerpaste
  mov rdx,linux.mmap.proto_rw;
  mov r10,linux.mmap.anon;
  mov r8 ,linux.mmap.nofd;

  xor rdi,rdi;
  xor r9 ,r9;

  ; ^call mmap
  mov rax,linux.mmap.id;
  syscall;


  ; restore and give
  pop r11;
  ret;


; ---   *   ---   *   ---
; ^dstruc
;
; [0] rdi -> ptr to block
; [1] rsi -> total pages

public munmap;

  ; N pages to N*page
  shl rsi,sizep2.page;

  ; cleanup and give
  mov rax,linux.munmap.id;
  syscall;

  ret;


; ---   *   ---   *   ---
; FOOT

fragment.end;

else if ~defined HEADLESS;
  extrn mmap;
  extrn munmap;

end if; IMPORT
ELF.end;

end if; loaded

; ---   *   ---   *   ---
