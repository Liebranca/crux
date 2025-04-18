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
  $non.PKG.cpkg  equ;
  $non.PKG.foot  equ;


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
; begin package scope

macro TITLE name;

  if ~definite $non.loaded.name;


    ; collect info about current/parent package
    local parent;
    match any:path , $non.PKG.cclan;
      $non.PKG.cclan equ any.path:name;
      parent         equ any.path;

    else match any , $non.PKG.cclan;
      $non.PKG.cclan equ any:name;
      parent         equ any;

    end match;


    ; begin new scope
    $non.PKG.cpkg equ name;
    $non.loaded.name = 1;

    $non.name:
    namespace $non.name;
    iceset    name;

    $pkginfo.OWN equ name;
    $pkginfo.PAR equ parent;
    $pkginfo.field equ;


    ; generate %[name] F(args) selfwrap
    match any , name;
      macro $non.%#any:PA&;


        ; need to set scope for call?
        local unset;
        unset equ 0;

        match ice , %ICE;
          if `any <> `ice;
            iceset any;
            unset  equ 1;

          end if;

        end match;

        ; ^make call and unset if need
        self PA;
        match =1 , unset;
          iceset ret;

        end match;

      end macro;

    end match;

end macro;


; ---   *   ---   *   ---
; Q methods to be run on EOF for [every] package
; that includes the calling package
;
; list is walked through in reverse!

macro FOOT proclist&;
match ice , %ICE;

  irp proc , proclist;
    LIST.unshift $non.PKG.foot,ice:proc;

  end irp;

end match;
end macro;


; ---   *   ---   *   ---
; ^terminate

macro EOF;


    ; make footer calls!
    match calls , $non.PKG.foot;
      irp c , calls;
        match pkg =: proc , c;
          iceset pkg;
          self   proc();
          iceset ret;

        end match;

      end irp;

    end match;


    ; ^then terminate scope proper
    iceset  ret;
    end     namespace;
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

  VERSION   v0.01.4;
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
; print package field value

macro $non.PKG.printx name,field;

  irp f , field;
    match value , name.$pkg.f;
      display '  ',`f,' ',`value,$0A;

    end match;

  end irp;
  display $0A;

end macro;


; ---   *   ---   *   ---
; ^print all fields!

macro $non.PKG.printall name;
  display 'package ',`name,':',$0A;
  match <list> , name.$pkg.field;
    self printx(name,<list>);

  end match;

end macro;


; ---   *   ---   *   ---
; ^entry

macro $non.PKG.print name:;
  match any , name;
    self printall(any);

  else match any , PKG.cpkg;
    self printall(any);

  end match;

end macro;


; ---   *   ---   *   ---
; FOOT

end if; $non.loaded.PKG


; ---   *   ---   *   ---
