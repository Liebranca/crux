; ---   *   ---   *   ---
; MACRO PACKAGE
; Imp's book keeper
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

if ~definite $non.loaded.PKG;
  $non.PKG.cclan equ $non;
  $non.PKG.cpkg equ;


; ---   *   ---   *   ---
; associate values to package!

macro $non.PKG.NEW_FIELD line;

  match f v , line;
    $pkg.f equ v;

    match <any> , $pkg.field;
      $pkg.field reequ <any,f>;
    else;
      $pkg.field reequ <f>;

    end match;

  end match;

end macro;


; ---   *   ---   *   ---
; begin/terminate package scope

macro TITLE name;

  if ~definite $non.loaded.name;

    local parent;
    match any:path , $non.PKG.cclan;
      $non.PKG.cclan equ any.path:name;
      parent         equ any.path;

    else match any , $non.PKG.cclan;
      $non.PKG.cclan equ any:name;
      parent         equ any;

    end match;

    $non.PKG.cpkg equ name;
    $non.loaded.name = 1;

    $non.name:
    namespace $non.name;
    %ICE  equ $non.name;

    $pkginfo.OWN equ name;
    $pkginfo.PAR equ parent;
    $pkginfo.fields equ;

end macro;

macro EOF;
    end namespace;
    restore %ICE;
    restore $non.PKG.cpkg;
    restore $non.PKG.cclan;
  end if;

end macro;


; ---   *   ---   *   ---
; declaring package data

macro VERSION number;
  $non.PKG.NEW_FIELD version number;

end macro;

macro AUTHOR name;
  $non.PKG.NEW_FIELD author name;

end macro;


; ---   *   ---   *   ---
; ^an example of usage:

  TITLE     PKG;

  VERSION   v0.01.3;
  AUTHOR    'IBN-3DILA';

  EOF;


; ---   *   ---   *   ---
; save/load the current clan
;
; this is used to wrap 'include', so that
; a package's namespace is not nested within
; another -- to do that, you have to manually
; specify it through parent.child.gchild syntax
;
; the importer uses this protection by default,
; you bypass it by simply using 'include' yourself!

macro $non.PKG.backup_path dst;

  match any:name , $non.PKG.cclan;
    dst equ name;
    end namespace;

  else;
    dst equ;

  end match;

end macro;

macro $non.PKG.restore_path src;
  match any , src;
    namespace any;

  end match;

end macro;


; ---   *   ---   *   ---
; ^iface

macro $non.PKG.include fpath;

  local cpkg;

  $non.PKG.backup_path cpkg;
  include `fpath;

  $non.PKG.restore_path cpkg;

end macro;


; ---   *   ---   *   ---
; print info for package!

macro $non.PKG.printx name,field;

  display $0A,`name,$0A;

  irp f , field;
    match value , name.$pkginfo.f;
      display '  ',`f,' ',`value,$0A;

    end match;

  end irp;
  display $0A;

end macro;

macro $non.PKG.printall name;
  match <list> , name.$pkginfo.field;
    PKG.printx name,<list>;

  end match;

end macro;

macro $non.PKG.print name:;
  match any , name;
    PKG.printall any;

  else match any , PKG.cpkg;
    PKG.printall any;

  end match;

end macro;


; ---   *   ---   *   ---
; FOOT

end if; $non.loaded.PKG


; ---   *   ---   *   ---
