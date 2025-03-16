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

define @CAS $non;
define %ICE @CAS;
macro self:PA&;

  match ice , %ICE;
    match =-=> proc (args) , PA;
      ice.proc ice,args;

    else match =-=> proc () , PA;
      ice.proc ice;

    else match cas , @CAS;
      %ICE equ cas.PA;

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
    <'TAB.inc','UID.inc','EMAN.inc'>;


; ---   *   ---   *   ---
; FOOT

$non.loaded = 1;
end if; $non.loaded


; ---   *   ---   *   ---
