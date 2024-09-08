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

define VERSION v0.00.1b;
define AUTHOR  'IBN-3DILA';


; ---   *   ---   *   ---
; get unique id
;
; doesn't make sense,
; but it works ;>

macro uid.new dst,prefix,_nullarg& {
  local UID;
  dst equ prefix#UID;

};


; ---   *   ---   *   ---
