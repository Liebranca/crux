; ---   *   ---   *   ---
; TEST OS GETDENTS
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; ME,

; ---   *   ---   *   ---
; HEAD

include '../../macro/elf.inc';


; ---   *   ---   *   ---
; info

  TITLE     test.os.getdents;

  VERSION   v0.00.3a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

ELF *;

  define CASK.LIST $10:$200;

  include '../../os/mmap.asm';
  include '../../os/getdents.asm';
  include '../../os/write.asm';
  include '../../os/exit.asm';

  include '../../std/cstr.asm';


; ---   *   ---   *   ---
; ROM

fragment %;
  cstr.new CURDIR,'.';
  cstr.new PARDIR,'..';
  cstr.new FNAME,'../avtomat/sys/';


; ---   *   ---   *   ---
; GBL

fragment $;
  mainmem db (alloct.req+$10*$200) dup $00


; ---   *   ---   *   ---
; EXE

fragment *;


; ---   *   ---   *   ---
; get fname from dirent and print
;
; [0] rbx -> dirent ptr
; [1] rdi -> nullargs
;
; [<] rax -> do nothing

dirprint:

  lea  rdi,[rbx+linux.dirent.fname];
  mov  rsi,$01;
  call cstrput;

  mov  rax,dirwalk.noop;
  ret;


; ---   *   ---   *   ---
; ^recursively
;
; [0] rbx -> dirent ptr
; [1] rdi -> filter fptr
;
; [<] rax -> recurse or do nothing

rec_dirprint:

  ; get whether this fname is excluded
  mov  rax,rdi;
  lea  rdi,[rbx+linux.dirent.fname];
  call rax;

  test rax,rax;
  jz   @f;


  ; print name
  call dirprint;

  ; recurse on directory
  xor rdx,rdx;
  mov dx,word [rbx+linux.dirent.len];
  sub dx,1;
  mov dl,byte [rdx+rbx];
  cmp dl,linux.getdents.dir;
  jnz @f;

  mov  rax,dirwalk.recurse;
  ret;

  ; ^else do nothing
  @@:

  mov rax,dirwalk.noop;
  ret;


; ---   *   ---   *   ---
; discard fname if it's '.' or '..'
;
; [0] rdi -> fname
;
; [<] rax -> true if valid

dotfilter:

  push rdi;
  lea  rsi,[CURDIR];
  call cstrcmp;

  pop  rdi;
  test rax,rax;
  jz   @f;
  not  rax;
  and  rax,$01;
  ret;

  @@:

  lea   rsi,[PARDIR];
  call  cstrcmp;
  not   rax;
  and   rax,$01;
  ret;


; ---   *   ---   *   ---
; walk directory and print fname of each entry!

entrypoint:

  ; startup
  lea  rdi,[mainmem];
  call begalloc;

  ; print entire directory structure
  lea  rdi,[FNAME];
  xor  rsi,rsi;
  lea  r10,[rec_dirprint];
  lea  r8,[dotfilter];
  call dirwalk;
  call flush;


  ; cleanup and give
  call endalloc;

  mov  rdi,OK;
  call exit;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
