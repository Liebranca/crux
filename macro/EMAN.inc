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

  VERSION   v0.00.4a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; GBL

  define CCAPT;


; ---   *   ---   *   ---
; during capture, the line processing and wrapper
; default to these noops
;
; you can change either behavior through the
; 'lproc' and 'wrap' optional arguments, respectively

macro asis ok,dst,src&;
  ok=1;
  dst equ `src;

end macro;

macro wrapless dst,argline&;
end macro;


; ---   *   ---   *   ---
; saves the final buffer!

macro capt.save src;
match this , %THIS;

  match id , src;
    match left <any> , this.CCAPT id.ct;
      this.CCAPT equ left,any;

    else match <any> , id.ct;
      this.CCAPT equ any;

    end match;

  end match;

end match;
end macro;


; ---   *   ---   *   ---
; ^evals it; be mindful of scope when you call this!

macro capt.eval;
match this , %THIS;

  match any , this.CCAPT;
    eval any;
    this.CCAPT equ;

  end match;

end match;
end macro;


; ---   *   ---   *   ---
; yep, it ends here ;>

FOOT capt.eval;
EOF;


; ---   *   ---   *   ---
; map clines to proc

macro capture name,O:;

  ; make 'end [name]' the default block term
  local ender_s;
  match any , name;
    ender_s equ end any;

  end match;


  ; generate new macro!
  macro name argline&;

    ; default options
    local DEFAULT;
    match s , ender_s;
      DEFAULT equ lproc:$non.EMAN.asis,\
                  wrap:$non.EMAN.wrapless,\
                  ender:`s;

    end match;

    ; ^replace defaults with passed values!
    local      opt;
    TAB.defnit opt,<DEFAULT>,<O>;


    ; prepare buffer switching vars
    ; we use this to cat nested blocks together!
    local buf,nest,nestargs;

    UID.new buf,$non.capture.buf;

    match id , buf;
      id.ct equ;

    end match;

    nestargs equ argline;
    nest=0;


    ; begin capture block
    macro ?! line&;
    match (lproc)(wrap)(ender) ,\
          (opt.lproc)(opt.wrap)(opt.ender);


      ; terminate block?
      if `line = ender;

        ; first off run the wrapper for this block
        match id , buf;
          wrap id.ct,nestargs;

        end match;


        ; top level? then end capture!
        if nest = 0;
          %EMAN capt.save(buf);
          purge ?;

        ; ^nope, nesting! append to prev
        else;

          ; once you have the id of the current buf,
          ; you switch to the previous one
          match id , buf;
            restore buf;

            ; ^and so we cat the two bufs together ;>
            match dst|<any> , buf|id.ct;
              LIST.push dst.ct,any;

            end match;
            restore nestargs;

          end match;
          nest=nest-1;

        end if;


      ; ^process next line
      else;

        local ok;
        ok=1;

        ; ^recurse?
        match first left , line;

          if `first = `name;
            ok   = 0;
            nest = nest+1;

            nestargs equ left;
            UID.new buf,$non.capture.buf;
            match id , buf;
              id.ct equ;

            end match;

          end if;

        end match;


        ; ^nope, common line!
        if ok = 1;

          local eline;
          ok=0;

          lproc ok,eline,line;


          ; append line to result?
          if ok=1;
            match id | nblank , buf|eline;
              LIST.push id.ct,nblank,$0A;

            end match;

          end if;

        end if;

      end if;

    end match; defnit
    end macro; capture

  end macro;

end macro;


; ---   *   ---   *   ---
; here's a test for a capture macro
;
; first we have the post-capture proc

macro cmacro.wrap dst,line&;

  ; have args?
  local macroline;
  match name (args) { , line;
    macroline equ 'macro ',`name,' ',`args;

  ; ^argless
  else match name () { , line;
    macroline equ 'macro ',`name;

  ; ^bad cmacro!
  else;
    err 'invalid cmacro <',`line,'>';

  end match;


  ; add wrapper lines
  match macroline , macroline;
    LIST.unshift <dst>,\
      macroline,$0A,\
      'match this , %THIS',$0A;

    LIST.push <dst>,\
      'end match',$0A,\
      'end macro',$0A;

  end match;

end macro;


; ---   *   ---   *   ---
; ^then the decl

capture cmacro,<wrap:cmacro.wrap,ender:'}'>;


; ---   *   ---   *   ---
