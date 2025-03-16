; ---   *   ---   *   ---
; MACRO TAB
; Who needs hashing?
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; info

  TITLE     TAB;

  VERSION   v0.00.2a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; sets value on table

macro TAB.set dst,key,e;

  match <any> , dst;

    ; ^{...},key:value,{...}
    match rem=,=key:value=,rem2 , any;
      dst equ <rem,key:e,rem2>

    ; ^key:value,{...}
    else match =key:value=,rem , any;
      dst equ <key:e,rem>

    ; ^{...},key:value
    else match rem=,=key:value , any;
      dst equ <rem,key:e>

    ; ^key:value
    else match =key:value , any;
      dst equ <key:e>;

    else;
      dst equ <any,key:e>;

    end match;

  else;
    dst equ <key:e>;

  end match;

end macro;


; ---   *   ---   *   ---
; ^fetch

macro TAB.get dst,src,key;

  match <any> , src;

    ; ^{...},key:value,{...}
    match rem=,=key:value=,rem2 , any;
      dst equ value;

    ; ^key:value,{...}
    else match =key:value=,rem , any;
      dst equ value;

    ; ^{...},key:value
    else match rem=,=key:value , any;
      dst equ value;

    ; ^key:value
    else match =key:value , any;
      dst equ value;

    end match;

  end match;

end macro;


; ---   *   ---   *   ---
; ^removes value from tab!

macro TAB.del dst,key;

  match <any> , dst;

    ; ^{...},key:value,{...}
    match rem=,=key:value=,rem2 , any;
      dst equ <rem,rem2>

    ; ^key:value,{...}
    else match =key:value=,rem , any;
      dst equ <rem>

    ; ^{...},key:value
    else match rem=,=key:value , any;
      dst equ <rem,key:e>

    ; ^key:value
    else match =key:value , any;
      dst equ;

    end match;

  end match;

end macro;


; ---   *   ---   *   ---
; guts v, fills out optional value list
;
; [0] namespace root to write values to
; [1] <key:value> list of possible options 'D'
; [2] <key:value> list of passed values 'P'
;
; [<] fill out dst with the passed value if present
;     else fall back to default value!

macro TAB.defnit.inner dst,DP&;

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

macro TAB.defnit dst,default,passed:nullargs;
  match <D> , <default>;
    TAB.defnit.inner dst,<D> <passed>;

  end match;

end macro;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
