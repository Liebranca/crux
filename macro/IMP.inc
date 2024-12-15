; ---   *   ---   *   ---
; MACRO IMP
; Depsearchin devil
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; info

  TITLE     IMP;

  VERSION   v0.00.2a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; adds library to search path

macro $non.lib NAP&;

  match name =at path , NAP;
    TAB.set $non.LIBPATH,name,path;

  end match;

end macro;


; ---   *   ---   *   ---
; ^fetch from!

macro $non.use NP&;

  local full;
  full equ;

  match name:path , NP;
    TAB.get full,$non.LIBPATH,name;
    full equ full/path;

  else match any , NP;
    full equ any;

  end match;


  match any , full;
    PKG.include any;

  end match;

end macro;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
