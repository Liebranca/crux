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
; HEAD

if ~definite $non.loaded.TAB;


; ---   *   ---   *   ---
; ^sets value on table

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
; FOOT

$non.loaded.TAB = 1;
end if; $non.loaded.TAB


; ---   *   ---   *   ---
