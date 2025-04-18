; ---   *   ---   *   ---
; MACRO LIST
; Token sequences
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; info

  TITLE     LIST;

  VERSION   v0.00.2a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; adds values to end of list

macro LIST.push dst,ar&;

  match <left> e , dst ar;
    dst equ <left,e>;
  else;
    dst equ <ar>;

  end match;

end macro;


; ---   *   ---   *   ---
; ^adds to beg

macro LIST.unshift dst,ar&;

  match <left> e , dst ar;
    dst equ <e,left>;
  else;
    dst equ <ar>;

  end match;

end macro;


; ---   *   ---   *   ---
; gives last value in list

macro LIST.pop dst,src;

  match <left,last> , src;
    dst equ last;
    src equ <left>;

  else match <last> , src;
    dst equ last;
    src equ;

  end match;

end macro;


; ---   *   ---   *   ---
; ^gives first value!

macro LIST.shift dst,src;

  match <first,left> , src;
    dst equ first;
    src equ <left>;

  else match <first> , src;
    dst equ first;
    src equ;

  end match;

end macro;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
