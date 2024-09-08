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

if ~used @elf.loaded;
@elf.loaded = 1;

include "uid.inc";


; ---   *   ---   *   ---
; info

define VERSION v0.00.1a;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; reads argline for macros

macro @elf.rdline dst,line,prefix= {


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

    any\#.sym    equ symbol;
    any\#.public equ 0;
    ok equ 1;

    match have , prefix \\{
      uid.new any\#.name,have;

    \\};

    match , prefix \\{
      uid.new any\#.name,any;

    \\};

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
  @elf.rdline ice,line,ff;


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


  ; set namespace
  match name , ice#.name \{
    define \@elf.namespace name;

  \}

  ; stop format line from being set again!
  define @elf.ffx 'LOCKED';

};


; ---   *   ---   *   ---
; namespace closer

macro ELF.end {
  restore @elf.namespace;

};


; ---   *   ---   *   ---
; clears previous fragment

macro fragment.end {

  if defined @elf.cblk;
    match prev , @elf.cblk \{
      \#prev\#.len = $-\#prev;

    \}

    restore @elf.cblk;

  end if;

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
  @elf.rdline ice,line,fragment;


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


  ; close previous and make new segment
  fragment.end;

  if @elf.ff = 0;
    section dir.args type;

  else if @elf.ff = 1;
    segment readable type;

  end if;


  ; make label with namespace?
  match namespace name , @elf.namespace ice#.name \{

    define @elf.cblk namespace\#.\#name;

    ; make global and local symbols
    @elf.symbol @elf.cblk;
    name = @elf.cblk;

  \}

  ; ^no namespace, make local only!
  match , @elf.namespace \{
    define @elf.cblk ice#.name;
    @elf.symbol ice#.name;

  \}

  match =1 name , ice#.public ice#.name \{
    public name;

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
  match key name namespace , line @elf.namespace \{
    @elf.rmlis  key namespace\#.\#name;
    @elf.symbol namespace\#.\#name;

  \};

};

macro @elf.extrn line {
  match key name namespace , line @elf.namespace \{
    @elf.rmlis key namespace\#.\#name;

  \};

};

public fix @elf.public public;
extrn  fix @elf.extrn  extrn;


; ---   *   ---   *   ---
; FOOT

end if; loaded


; ---   *   ---   *   ---
