; ---   *   ---   *   ---
; NON
; Motherscope
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

if ~definite $non.loaded;


; ---   *   ---   *   ---
; dirty self->macro_name(args) impl
;
; we need this because macros have no context,
; and so a package cannot find the macros defined
; within itself if the name is incomplete

define %CAS  $non;
define %ICE;
define %THIS %CAS;

macro self:PA&;

  local this;
  match this , %THIS;
    match proc (args) , PA;
      this.proc args;

    else match proc () , PA;
      this.proc;

    end match;

  end match;

end macro;


; ---   *   ---   *   ---
; ^set/unset instance (%ICE)

macro iceset name:ret;

  match =ret , name;
    restore %ICE;
    restore %THIS;

  else match ice , name;
    %ICE equ ice;

    match cas , %CAS;
      %THIS equ cas.ice;

    else;
      %THIS equ ice;

    end match;

  end match;

end macro;


; ---   *   ---   *   ---
; set/unset current addressing space (%CAS)

macro casset name:ret;

  match =ret , name;
    restore %CAS;
    restore %CCI;

  else match cas , name;
    %CAS equ cas;

    match ice , %ICE;
      %THIS equ cas.ice;

    else;
      %THIS equ cas;

    end match;

  end match;

end macro;


; ---   *   ---   *   ---
; now we begin the motherscope proper
;
; *everything* the user ever wants to do should go
; on a namespace under non

  $non:
  namespace $non;

  postpone;
    end namespace; $non

  end postpone;


; ---   *   ---   *   ---
; dependencies can be modular!

macro MODULAR_DEP flag,default,needs;

  ; set default value if none set
  if ~definite flag;
    flag=default;

  end if;

  ; fetch required files!
  if flag;
    irp fpath , needs;
      include fpath;

    end irp;

  end if;

end macro;


; ---   *   ---   *   ---
; deps

  MODULAR_DEP USE_IMPORTER,1,\
    <'PKG.inc','IMP.inc'>;

  MODULAR_DEP USE_EMITTER,1,\
    <'LIST.inc','TAB.inc','UID.inc','EMAN.inc'>;


; ---   *   ---   *   ---
; FOOT

$non.loaded = 1;
end if; $non.loaded


; ---   *   ---   *   ---
