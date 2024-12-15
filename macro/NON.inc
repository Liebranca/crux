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
; ^deps

  MODULAR_DEP USE_IMPORTER,1,\
    <'TAB.inc','PKG.inc','IMP.inc'>;

  MODULAR_DEP USE_EMITTER,1,<'EMAN.inc'>;


; ---   *   ---   *   ---
; guts v, fills out optional value list
;
; [0] namespace root to write values to
; [1] <key:value> list of possible options 'D'
; [2] <key:value> list of passed values 'P'
;
; [<] fill out dst with the passed value if present
;     else fall back to default value!

macro ODEF.inner dst,DP&;

  ; unroll args
  local left;
  match id <def> <pass> , dst DP;
    left equ pass;

    ; walk the default value list
    irp d , def;
      match dkey:dvalue , d;

        ; set default value, then pluck from passed;
        ; if found, it will overwrite default!
        local elem;
        elem equ dvalue;

        ; ^{...},key:value,{...}
        match rem=,=dkey:value=,rem2 , left;
          elem reequ value;
          left reequ rem,rem2

        ; ^key:value,{...}
        else match =dkey:value=,rem , left;
          elem reequ value;
          left reequ rem;

        ; ^{...},key:value
        else match rem=,=dkey:value , left;
          elem reequ value;
          left reequ rem;

        ; ^key:value
        else match =dkey:value , left;
          elem reequ value;

        end match;


        ; ^assign either passed or default ;>
        id.dkey equ elem;

      end match;

    end irp;

  end match;

end macro;


; ---   *   ---   *   ---
; ^interface

macro ODEF dst,default,passed:nullargs;
  match <D> , <default>;
    $non.ODEF.inner dst,<D> <passed>;

  end match;

end macro;


; ---   *   ---   *   ---
; FOOT

$non.loaded = 1;
end if; $non.loaded


; ---   *   ---   *   ---
