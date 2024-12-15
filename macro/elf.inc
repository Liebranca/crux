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

  VERSION   v0.00.6a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; deps

  include "uid.inc";
  include "eman.inc";


; ---   *   ---   *   ---
; s-consts

if ~used elf.align;
  elf.align = $10;

end if;


; ---   *   ---   *   ---
; reads argline for macros

macro @rdline dst,line;

  ; public+name
  match any symbol =: =public name , dst line;
    any.sym    equ symbol;
    any.name   equ name;
    any.public equ 1;

  ; ^name only
  else match any symbol =: name , dst line;
    any.sym    equ symbol;
    any.name   equ name;
    any.public equ 0;

  ; ^anon
  else match any symbol , dst line;
    any.name   equ;
    any.sym    equ symbol;
    any.public equ 0;

  ; ^fail!
  else;
    err 'invalid argline',$0A;

  end match;

end macro;


; ---   *   ---   *   ---
; set file mode. modifies fragment lines

macro @FILEMODE line;


  ; run only once
  if ~used @ffx;

    ; parse input
    local   ice;
    @rdline ice,line;

    ; compile object file?
    match =% , ice.sym;
      format ELF64;
      IMPORT = 0;

    ; ^compile static?
    else match =* , ice.sym;
      format ELF64 executable 3;
      entry  _start;

      IMPORT = 1;

    ; ^throw
    else;
      err 'invalid ELF mode',$0A;

    end match;


    ; stop format line from being set again!
    @ffx = 'LOCKED';
    @ff  = IMPORT;


  ; this controls whether sources are included!
  else;
    IMPORT = @ff;

  end if; @ffx

end macro;


; ---   *   ---   *   ---
; make symbol!

macro @symbol fullname;
  match any , fullname;
    if ~used elf.SYMBOL.any;
      elf.SYMBOL.any = 1;
      any:

    end if;

  end match;

end macro;


; ---   *   ---   *   ---
; we disable these directives
; when compiling static files

macro @rmlis line;
  if @ff = $00;
    line;

  end if;

end macro;

macro @public line;

  match key name =: , line;
    @rmlis  key name;
    @symbol name;
    ok equ 1;

  else match key name , line;
    @rmlis  key name;
    @symbol name;
    ok equ 1;

  end match;

end macro;

macro @extrn line;
  match key name , line;
    @rmlis key name;

  end match;

end macro;


; ---   *   ---   *   ---
; make new string or empty buffer

;macro cstr.new name,data& {
;  match any , name \{
;    any\#: db data,$00;
;    any\#.len = $-any;
;
;  \};
;
;};
;
;macro buf.new name,size {
;  match any , name \{
;    any\#: db size dup $00;
;    any\#.len = $-any;
;    any\#.end = any+any\#.len;
;
;  \};
;
;};
;
;macro @elf.make_cask_pool cap {
;  local total;
;  total = cap;
;
;  while total > 0;
;    dq $00;
;    total = total-64;
;
;  end while;
;
;};
;
;macro cask.new NEC {
;
;  match name ezy =: cap , NEC \{
;    name\#.ezy = ezy;
;    name\#.cap = cap;
;    name\#.head: db sizeof.mmask_t dup $00;
;    name\#.pool: @elf.make_cask_pool cap;
;
;  \};
;
;};


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

macro entrypoint name:;


  ; fstate
  local have;
  have equ name;


  ; remove colon!
  match =: , have;
    have equ;

  end match;

  ; default to module name
  match any =: , have:
    have equ any;
  else match any , INFO.cpkg;
    have equ any;

  end match;


  ; declare common symbol if compiling object
  if @ff = 0;
    public have;

  ; ^declare _start on static
  else if @ff = 1;
    public _start:
    have = _start;

  end if;

end macro;


; ---   *   ---   *   ---
; replaces the default 'struc' keyword

macro @struc.inner name,glob,icen,addr;


  ; we drop everything into virtual
  ; to make instancing easier
  virtual at addr;
  if ~used vmem.has.name;
    vmem.name::
    glob:

  end if;

  ; user definition (via strucdef) pasted here
  icen:
  @struc.def.name;


  ; get total size after fields!
  if ~used vmem.has.name;
    sizeof.name = $-glob;
  end if;
  end virtual;

  vmem.has.name = 1;

end macro;


;; ---   *   ---   *   ---
;; ^interface
;
;macro @struc name;
;
;
;  ; needed to reference the virtual block
;  local glob
;  glob equ ..name;
;
;  macro name LINE;
;
;    ; 'addr' can be a register too ;>
;    match icen =at addr , LINE;
;      @struc.inner name,glob,icen,addr;
;
;    ; ^or default to current position
;    else match icen , LINE;
;      @elf.struc.inner name,glob,icen,$;
;
;    end match;
;
;  end match;
;
;end macro;


;; ---   *   ---   *   ---
;; sum fields of multiple strucs
;
;macro @elf.struc.from_list type;
;  irp t,type;
;    @struc.def.type;
;
;  end irp;
;
;end macro;


; ---   *   ---   *   ---
; makes a struc from one or more definitions

macro @struc.ice NL&;

  match NAME =: LIST , NL;
    macro @elf.struc.def.NAME;
      @struc.from_list LIST;

    end macro;

    @struc NAME;

  else match NAME , NL;
    @struc NAME;

  end match;

end macro;


; ---   *   ---   *   ---
; ~




; ---   *   ---   *   ---
; public macros from here on out!

end namespace;

; FIX
;public fix elf.@public public;
;extrn  fix elf.@extrn  extrn;


; ---   *   ---   *   ---
; can't call it segment ;>

macro fragment line;


  ; throw if output mode isn't set
  if ~used @ffx;
    display 'ELF was not invoked',$0A;
    err;

  end if;


  ; parse input
  local   ice;
  local   type;
  local   dir.args;
  @rdline ice,line;


  ; have ROM?
  match =% , ice#.sym;
    dir.args equ '.rodata';
    type equ;

  ; have executable?
  else match =* , ice#.sym;
    dir.args equ '.text';
    type equ executable;

  ; have memory pool?
  else match =$ , ice#.sym;
    dir.args equ '.data';
    type equ writeable;

  ; fail!
  else;
    err 'invalid fragment type',$0A;

  end match;


  ; make new segment
  if @ff = 0;
    if elf.align = $00;
      section dir.args type;

    else;
      section dir.args type align elf.align;

    end if;

  else if @ff = 1;
    segment readable type;
    if elf.align;
      align elf.align;

    end if;

  end if;


  ; label beggining of segment?
  match =1 name , ice.public ice.name;
    public name;

  else match =0 name , ice.public ice.name;
    @symbol name;

  end match;

end macro;


; ---   *   ---   *   ---
; aliases for common checks

macro ELF! line;
  if ~used IMPORT | IMPORT;
    @FILEMODE line;

end macro;

macro FOOT!;
  else if ~used HEADLESS | ~HEADLESS;

end macro

macro EOF!;
  end if; IMPORT
  INFO.EOF;

end macro;


; ---   *   ---   *   ---
; [p]aste-[in] [b]lock
;
; alias for invoking macros defined
; within the 'inline' namespace

macro pinb name,args:;
  inline.name args;

end macro;


; ---   *   ---   *   ---
; ^aliases for the madness

capture  $non.strucdef;
strucdef testy;
  .me:   db '$$$$',$0A;
  .term: db $3B;

end strucdef;

macro testy NA;


  ; parse argline
  local id;
  local addr;
  local buf;

  match ID =at ADDR , NA;
    id   equ ID;
    addr equ ADDR;

  else;
    id   equ NA;
    addr equ $00;

  end match;


  virtual at addr;
    match <name=:len=,code> ID ,\
          elf.$utypes.testy id;

      ; make instance!
      ID::
      namespace ID;

        buf equ code;
        repeat len;
          match {line} left , buf;
            line;
            buf reequ left;

          else match {line} , buf;
            line;

          end match;

        end repeat;

      end namespace;


    end match;

  end virtual;

end macro;

testy ice;

;load me:4 from ice:$00;
;display me,$0A;


; FIX
;struc fix @elf.struc.ice;


; ---   *   ---   *   ---
; ^make static instance

macro static line;


  ; fstate
  local name;
  local type;
  local addr;

  ; ^parse args
  match T N =at X , line;
    type equ T;
    name equ N;
    addr equ X;

  else match T N , line;
    type equ T;
    name equ N;
    addr equ $;

  end match;


  ; copy definition from vmem
  match T N X , type name addr;
    T N at X;
    db sizeof.T dup $00;

    repeat sizeof.T;
      load  chunk byte  from vmem.T:..T+(%-1);
      store byte  chunk at   N+(%-1);

    end repeat;

  end match;

end macro;


; ---   *   ---   *   ---
; ^make scoped instance
;
; this means generate a discardable
; unique ID that can then be unrolled!

macro lis line;


  ; fstate
  local name;
  local type;
  local addr;

  ; ^parse args
  match T N =at X , line;
    type equ T;
    name equ N;
    addr equ X;

  else match T N , line;
    type equ T;
    name equ N;
    addr equ $;

  end match;


  ; make ice
  local uid;
  uid.new uid,lis;

  match T N X U , type name addr uid;
    T U at X;
    define N U;

  end match;

end macro;


; ---   *   ---   *   ---
; FOOT

restore INFO.cpkg;
end if; loaded


; ---   *   ---   *   ---
