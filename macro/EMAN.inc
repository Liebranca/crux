; ---   *   ---   *   ---
; EMAN
; 'emit' was already taken ;>
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; info

  TITLE     EMAN;

  VERSION   v0.00.2a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; s-consts

  $non.NULL equ $3B0ABEE7;


; ---   *   ---   *   ---
; cat line to captured code

macro $non.cmacro.catline line&;

  match <len:any> , $non.cmacro.CCAPT;
    $non.cmacro.CCAPT reequ\
      <len+1:any $non.NULL line>;

  else match <len:> , $non.cmacro.CCAPT;
    $non.cmacro.CCAPT reequ <len+1:line>;

  end match;

end macro;


; ---   *   ---   *   ---
; generate contex-rich macro with captured code ;>

macro $non.cmacro.paste scope,name,argline&;

  match <CODE> , $non.cmacro.CCAPT;
  match len:code , CODE;
    macro name argline;
    macro_scope scope;

      local buf;
      buf equ code;

      repeat len;
        match any =$non.NULL left , buf;
          any;
          buf equ left;

        else match any , buf;
          any;

        end match;

      end repeat;

    end macro_scope;
    end macro;

  end match;
  end match;

end macro;


; ---   *   ---   *   ---
; adds context data to macros
;
; this makes it so you don't have to
; write the full path to find a macro
; from within another, when called from
; a different namespace

macro $non.macro_scope path;
  $non.EMAN.MACROSCOPE equ path;

end macro;

macro end?.macro_scope;
  restore $non.EMAN.MACROSCOPE;

end macro;


; ---   *   ---   *   ---
; ^such context-rich macros have to
; ^be invoked as such...

macro $non.cmcall name,args&;
  match path , $non.EMAN.MACROSCOPE;
    path.name args;

  end match;

end macro;


; ---   *   ---   *   ---
; ^AND must be defined as such...

macro $non.cmacro! NA&;

  ; parse args
  local _name;
  local _argline;
  local _scope;

  match name argline , NA;
    _name    equ name;
    _argline equ argline;

  else match name , NA;
    _name    equ name;
    _argline equ nullargs:;

  end match;

  ; get scope in which macro is defined!
  match par own , $pkginfo.PAR $pkginfo.OWN;
    _scope equ par.own;

  end match;


  ; begin capture
  $non.cmacro.CCAPT equ <0:>;

  macro ?! line&;
  match (scope) name argline ,\
        (_scope) _name _argline;

    ; terminate capture?
    if `line = 'end cmacro';
      $non.cmacro.paste scope,name,argline;
      restore $non.cmacro.CCAPT;
      purge   ?;

    ; append line to result?
    else match nblank , line;
      $non.cmacro.catline nblank;

    end match;

  end match;
  end macro;

end macro;


; ---   *   ---   *   ---
; default line processing during capture

macro $non.capture.asis ok,dst,src;
  ok  equ 1;
  dst equ src;

end macro;


; ---   *   ---   *   ---
; default for capture beg

macro $non.capture.pre;
end macro;


; ---   *   ---   *   ---
; default for capture end

macro $non.capture.post id,pre,argline:;

  pre;
  display `id,' ',`argline;

end macro;


; ---   *   ---   *   ---
; map clines to proc

macro $non.capture name,O:$non.NULL;

  ; make 'end [name]' the default block term
  local ender_s;
  match any , name;
    ender_s equ end any;

  end match;

  ; generate new macro!
  macro name id,argline&;

    ; default options
    local DEFAULT;
    match s , ender_s;
      DEFAULT equ proc:$non.capture.asis,\
                  ender:`s,\
                  pre:$non.capture.pre,\
                  post:$non.capture.post;

    end match;

    ; ^replace defaults with passed values!
    local opt;
    ODEF  opt,<DEFAULT>,<O>;


    ; begin capture block
    $non.cmacro.CCAPT equ <0:>;
    macro ?! line&;
    match (pre)(proc)(ender)(post) ,\
          (opt.pre)(opt.proc)(opt.ender)(opt.post);

      ; terminate block?
      if `line = ender;

        post    id,pre,argline;

        restore $non.cmacro.CCAPT;
        purge   ?;

      ; ^process next line
      else;

        local ok;
        local eline;
        proc  ok,eline,line;

        ; append line to result?
        match =1 nblank , ok eline;
          $non.cmacro.catline nblank;

        end match;

      end if;

    end match; ODEF
    end macro; capture

  end macro;

end macro;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
