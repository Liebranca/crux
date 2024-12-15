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

  TITLE     uid;

  VERSION   v0.00.2a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; get unique id
;
; doesn't make sense,
; but it works ;>

macro new dst,prefix,_nullarg&;
  local UID;
  dst equ prefix#UID;

end macro;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
