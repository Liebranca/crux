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

if ~defined @os.mmap.loaded;
define @os.mmap.loaded 1;


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

if ~defined IMPORT | IMPORT;
  include "../macro/elf.inc";

ELF %;
  include "../std/uint.asm";


; ---   *   ---   *   ---
; info

define VERSION v0.00.2a;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; get block of memory
;
; [0] rdi -> size in bytes
;
; [<] rax -> ptr to block

public mmap;


  ; preserve
  push r11;

  ; align input to page size
  mov  cl,sizep2.page;
  call urdivp2;

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

else if ~defined HEADLESS | ~HEADLESS;
  extrn mmap;
  extrn munmap;

end if; IMPORT
end if; loaded


; ---   *   ---   *   ---
