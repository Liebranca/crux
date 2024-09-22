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

include "INFO.inc";


; ---   *   ---   *   ---
; info

  TITLE     elf;

  VERSION   v0.00.4a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

  include "uid.inc";


; ---   *   ---   *   ---
; s-consts

if ~defined ELF.ALIGN;
  elf.align = $10;

else
  elf.align = ELF.ALIGN;

end if;


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

macro @ELF line {


  ; run only once
  if ~defined @elf.ffx;


    ; fstate
    local last;
    local ice;
    local ok;
    ok equ 0;


    ; parse input
    @elf.rdline ice,line;


    ; compile object file?
    match =% , ice#.sym \{

      format ELF64;

      IMPORT equ 0;
      ok     equ 1;

    \};

    ; compile static?
    match =* , ice#.sym \{

      format ELF64 executable 3;
      entry  _start;

      IMPORT equ 1;
      ok     equ 1;

    \};


    ; fail!
    match =0 , ok \{
      display 'invalid ELF mode',$0A;
      err;

    \};


    ; stop format line from being set again!
    define @elf.ffx 'LOCKED';
    @elf.ff = IMPORT;


  ; this controls whether sources are included!
  else;
    IMPORT equ @elf.ff;

  end if; @elf.ffx

};


; ---   *   ---   *   ---
; can't call it segment ;>

macro fragment line {


  ; throw if output mode isn't set
  if ~defined @elf.ffx;
    display 'ELF was not invoked',$0A;
    err;

  end if;


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
    if elf.align = $00;
      section dir.args type;

    else;
      section dir.args type align elf.align;

    end if;

  else if @elf.ff = 1;
    segment readable type;
    if elf.align;
      align elf.align;

    end if;

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
  if @elf.ff = $00;
    line;

  end if;

};

macro @elf.public line {

  local ok;
  ok equ 0;

  match key name =: , line \{
    @elf.rmlis  key name;
    @elf.symbol name;
    ok equ 1;

  \};

  match =0 key name , ok line \{
    @elf.rmlis  key name;
    @elf.symbol name;
    ok equ 1;

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
; typically, one only declares an
; entry point for the final static
;
; however, we can use statics within
; objects and viceversa, and an entry
; point should be converted into a regular
; symbol in that case. essentially, turning
; '_start' into a regular function
;
; this alias does just that!

macro entrypoint name= {


  ; fstate
  local have;
  local ok;

  have equ name;
  ok   equ 0;


  ; remove colon!
  match =: , have \{
    have equ;

  \};


  ; default to module name
  match , have \{
    match any , this.module \\{
      have equ any;

    \\};

  \};

  ; remove colon (again!)
  match any =: , have \{
    have equ any;

  \};


  ; declare common symbol if compiling object
  if @elf.ff = 0;
    public have;

  ; ^declare _start on static
  else if @elf.ff = 1;
    public _start:
    have = _start;

  end if;

};


; ---   *   ---   *   ---
; aliases for common checks

macro ELF line {
  if ~defined IMPORT | IMPORT;
  @ELF line;

};

macro FOOT {
  else if ~defined HEADLESS | ~HEADLESS;

};

macro EOF {
  end if; IMPORT
  EOF;

};


; ---   *   ---   *   ---
; [p]aste-[in] [b]lock
;
; alias for invoking macros defined
; within the 'inline' namespace

macro pinb name {inline.#name};


; ---   *   ---   *   ---
; replaces the default 'struc' keyword

macro @elf.struc.inner name,glob,icen,addr {


  ; we drop everything into virtual
  ; to make instancing easier
  virtual at addr;
  if ~defined vmem.has.#name;
    vmem.#name#::
    glob#:

    define vmem.has.#name 1;

  end if;

  ; user definition (via strucdef) pasted here
  icen#:
  @elf.struc.def.\##name;


  ; get total size after fields!
  sizeof.#name = $-glob;
  end virtual;

};

; ---   *   ---   *   ---
; ^interface

macro @elf.struc name {


  ; needed to reference the virtual block
  local glob
  glob equ ..#name;

  macro name LINE \{

    local ok;
    ok equ 0;

    ; 'addr' can be a register too ;>
    match icen =at addr , LINE \\{
      @elf.struc.inner name,glob,icen,addr;
      ok equ 1;

    \\};

    ; ^or default to current position
    match =0 icen , LINE \\{
      @elf.struc.inner name,glob,icen,$;

    \\};

  \};

};


; ---   *   ---   *   ---
; sum fields of multiple strucs

macro @elf.struc.from_list [type] {
  forward @elf.struc.def.\##type;

};


; ---   *   ---   *   ---
; makes a struc from one or more definitions

macro @elf.struc.ice NL& {

  local ok;
  ok equ 0;


  match NAME =: LIST , NL \{
    macro @elf.struc.def.\#\#NAME \\{
      @elf.struc.from_list LIST;

    \\};

    @elf.struc NAME;
    ok equ 1;

  \};

  match =0 NAME , ok NL \{
    @elf.struc NAME;

  \};

};

; ---   *   ---   *   ---
; ^aliases for the madness

strucdef fix macro @elf.struc.def.;
struc fix @elf.struc.ice;


; ---   *   ---   *   ---
; ^make static instance

macro static line {


  ; fstate
  local name;
  local type;
  local addr;
  local ok;

  ok equ 0;

  ; ^parse args
  match T N =at X , line \{
    type equ T;
    name equ N;
    addr equ X;
    ok   equ 1;

  \};

  match =0 T N , ok line \{
    type equ T;
    name equ N;
    addr equ $;
    ok   equ 1;

  \};


  ; copy definition from vmem
  match T N X , type name addr \{
    T N at X;
    db sizeof.\#T dup $00;

    repeat sizeof.\#T;
      load  chunk byte  from vmem.\#T\#:..\#T+(%-1);
      store byte  chunk at   N+(%-1);

    end repeat;

  \};

};


; ---   *   ---   *   ---
; FOOT

end if; loaded


; ---   *   ---   *   ---
