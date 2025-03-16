; ---   *   ---   *   ---
; UID
; Ice boxing
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; info

  TITLE     UID;

  VERSION   v0.00.2a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; get unique id
;
; doesn't make sense,
; but it works ;>

macro new dst,prefix,_nullarg&;


  ; generate symbol?
  local UID;
  if ~definite $non.UID.prefix.UIDCNT;
    $non.UID.prefix.UIDCNT=0;

  ; ^reuse and up the count
  else;
    $non.UID.prefix.UIDCNT=$non.UID.prefix.UIDCNT+1;

  end if;

  ; make link to current value of symbol
  repeat 1, i:$non.UID.prefix.UIDCNT;
    UID equ i;

  end repeat;

  ; ^append value to prefix
  match n pre, UID prefix;
    dst equ pre#n;

  end match;

end macro;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
