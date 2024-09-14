; ---   *   ---   *   ---
; ELF
; Little helper
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

if ~defined @elf.loaded;
define @elf.loaded 1;

include "uid.inc";


; ---   *   ---   *   ---
; info

define VERSION v0.00.2a;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; reads argline for macros

macro @elf.rdline dst,line {


  ; fstate
  local ok;
  ok equ 0;


  ; public+name
  match any symbol =: =public name , dst line \{
    any\#.sym    equ symbol;
    any\#.name   equ name;
    any\#.public equ 1;

    ok equ 1;

  \};

  ; ^name only
  match =0 any symbol =: name , ok dst line \{
    any\#.sym    equ symbol;
    any\#.name   equ name;
    any\#.public equ 0;

    ok equ 1;

  \};

  ; ^anon
  match =0 any symbol , ok dst line \{
    any\#.name   equ;
    any\#.sym    equ symbol;
    any\#.public equ 0;

    ok equ 1;

  \};


  ; ^fail!
  match =0 , ok \{
    display 'invalid argline',$0A;
    err;

  \};

};


; ---   *   ---   *   ---
; set file mode. modifies fragment lines

macro ELF line {


  ; fstate
  local last;
  local ice;
  local ok;
  ok equ 0;


  ; parse input
  @elf.rdline ice,line;


  ; compile object file?
  match =% , ice#.sym \{

    ; run only once
    if ~defined @elf.ffx;
      format ELF64;

      @elf.ff = 0;

    end if;

    ok equ 1;

  \};

  ; compile static?
  match =* , ice#.sym \{

    ; run only once
    if ~defined @elf.ffx;
      format ELF64 executable 3;
      entry  _start;

      @elf.ff = 1;

    end if;

    ok equ 1;

  \};


  ; fail!
  match =0 , ok \{
    display 'invalid ELF mode',$0A;
    err;

  \};


  ; stop format line from being set again!
  define @elf.ffx 'LOCKED';

};


; ---   *   ---   *   ---
; can't call it segment ;>

macro fragment line {


  ; throw if output mode isn't set
  match , @elf.ff \{
    display 'ELF was not invoked',$0A;
    err;

  \};


  ; fstate
  local ice;
  local type;
  local dir.args;
  local ok;
  ok equ 0;


  ; parse input
  @elf.rdline ice,line;


  ; have ROM?
  match =% , ice#.sym \{

    dir.args equ '.rodata';

    type equ;
    ok   equ 1;

  \}

  ; have executable?
  match =* , ice#.sym \{

    dir.args equ '.text';

    type equ executable;
    ok   equ 1;

  \};

  ; have memory pool?
  match =$ , ice#.sym \{

    dir.args equ '.data';

    type equ writeable;
    ok   equ 1;

  \};


  ; fail!
  match =0 , ok \{
    display 'invalid fragment type',$0A;
    err;

  \};


  ; make new segment
  if @elf.ff = 0;
    section dir.args type;

  else if @elf.ff = 1;
    segment readable type;

  end if;


  ; label beggining of segment?
  match =1 name , ice#.public ice#.name \{
    public name;

  \}

  match =0 name , ice#.public ice#.name \{
    @elf.symbol name;

  \}

};


; ---   *   ---   *   ---
; make symbol!

macro @elf.symbol fullname {

  match any , fullname \{
    if ~defined SYMBOL.\#any;
      define SYMBOL.\#any 1;
      any\#:

    end if;

  \}

};


; ---   *   ---   *   ---
; we disable these directives
; when compiling static files

macro @elf.rmlis line {
  match =$00 , @elf.ff \{line\};

};

macro @elf.public line {
  match key name , line \{
    @elf.rmlis  key name;
    @elf.symbol name;

  \};

};

macro @elf.extrn line {
  match key name , line \{
    @elf.rmlis key name;

  \};

};

public fix @elf.public public;
extrn  fix @elf.extrn  extrn;


; ---   *   ---   *   ---
; make new string or empty buffer

macro cstr.new name,data& {
  match any , name \{
    any\#: db data,$00;
    any\#.len = $-any;

  \};

};

macro buf.new name,size {
  match any , name \{
    any\#: db size dup $00;
    any\#.len = $-any;
    any\#.end = any+any\#.len;

  \};

};


; ---   *   ---   *   ---
; FOOT

end if; loaded


; ---   *   ---   *   ---
