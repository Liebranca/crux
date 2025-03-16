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

  VERSION   v0.00.3a;
  AUTHOR    'IBN-3DILA';


; ---   *   ---   *   ---
; s-consts

  $non.NULL equ $3B0ABEE7;


; ---   *   ---   *   ---
; GBL

  EMAN.CCAPT    equ;
  EMAN.CLVL     equ 0;

  EMAN.BLK_LIST equ 'match','macro','if';


; ---   *   ---   *   ---
; recognize block/end block

macro parseblk.inner \
  $non_EMAN_parseblk_inner_ok,\
  $non_EMAN_parseblk_inner_keyw;

  $non_EMAN_parseblk_inner_ok equ 0;

  ; does keyword end the current block?
  if `$non_EMAN_parseblk_inner_keyw = 'end';
    $non_EMAN_parseblk_inner_ok equ 2;

  ; does keyword begin a new block?
  else;
    match _LIST , EMAN.BLK_LIST;
      irp _K , _LIST;
        if _K = `$non_EMAN_parseblk_inner_keyw;
          $non_EMAN_parseblk_inner_ok equ 1;
          break;

        end if;

      end irp;

    end match;

  end if;

end macro;


; ---   *   ---   *   ---
; detect blk beg/end lines and
; redirect them to offbuf

macro parseblk \
  $non_EMAN_parseblk_out,\
  $non_EMAN_parseblk_line&;

  match keyw argline , $non_EMAN_parseblk_line;

    local ok;
    EMAN.parseblk.inner ok,keyw;


    ; begin new block?
    match =1 , ok;

      $non_EMAN_parseblk_out equ 0;

      local uid;
      UID.new uid,$non.EMAN.BLK;

      match id , uid;

        EMAN.catline.inner EMAN.CCAPT,\
          CATBLK (id) keyw argline;

        EMAN.CLVL  equ id;
        id.codestr equ <0:>;

      end match;

    ; ^end of current block
    else match =2 , ok;
      $non_EMAN_parseblk_out equ 0;
      restore EMAN.CLVL;

    end match;


  end match;

end macro;


; ---   *   ---   *   ---
; cat line to buf

macro catline.inner \
  $non_EMAN_catline_inner_dst,\
  $non_EMAN_catline_inner_line&;

  match <len:any> , \
    $non_EMAN_catline_inner_dst;

    $non_EMAN_catline_inner_dst reequ\
      <len+1:any $non.NULL \
       $non_EMAN_catline_inner_line>;

  else match <len:> , \
    $non_EMAN_catline_inner_dst;

    $non_EMAN_catline_inner_dst reequ\
      <len+1:$non_EMAN_catline_inner_line>;

  end match;

end macro;


; ---   *   ---   *   ---
; cat line to captured code

macro catline $non_EMAN_catline_line&;

  ; get which block to cat to
  local ok;
  ok equ 1;

  EMAN.parseblk ok,$non_EMAN_catline_line;

  ; cat to main block?
  match =1 =0 , ok EMAN.CLVL;
    EMAN.catline.inner EMAN.CCAPT,\
      $non_EMAN_catline_line;

  ; ^cat to nested block?
  else match =1 dst , ok EMAN.CLVL;
    EMAN.catline.inner dst.codestr,\
      $non_EMAN_catline_line;

  end match;

end macro;

; ---   *   ---   *   ---
; confused yet? ;>
;
; this simply copies processed lines into the
; generated macro after capture is done

macro pasteline.proc.inner:\
  $non_EMAN_pasteline_inner_line,\
  $non_EMAN_pasteline_inner_left,\
  $non_EMAN_pasteline_inner_src;

  $non_EMAN_pasteline_inner_src reequ\
    $non_EMAN_pasteline_inner_left;

  match line , $non_EMAN_pasteline_inner_line;
    esc line;

  end match;

end macro;


; ---   *   ---   *   ---
; ^the line-processing in question

macro pasteline.proc:\
  $non_EMAN_pasteline_proc_line,\
  $non_EMAN_pasteline_proc_left,\
  $non_EMAN_pasteline_proc_src

  ; input is F ARGS;
  match keyw argline , \
        $non_EMAN_pasteline_proc_line;

    ; pasting an entire block? then recurse
    if `keyw = 'CATBLK';
      match (id) blk args , argline;

        match <len:code> , id.codestr;
          blk args;
            EMAN.paste <code>,len;

          end blk;

        end match;

      end match;


    ; ^nope, pasting single-line
    else;
      EMAN.pasteline.proc.inner \
        <$non_EMAN_pasteline_proc_line>,\
        <$non_EMAN_pasteline_proc_left>,\
        <$non_EMAN_pasteline_proc_src>;

    end if;


  ; ^input is just plain F;
  else;
    EMAN.pasteline.proc.inner \
      <$non_EMAN_pasteline_proc_line>,\
      <$non_EMAN_pasteline_proc_left>,\
      <$non_EMAN_pasteline_proc_src>;

  end match;

end macro;


; ---   *   ---   *   ---
; ^entrypoint for line processing

macro pasteline:\
  $non_EMAN_pasteline_src,\
  $non_EMAN_pasteline_term;

  local line,left;

  ; line TERM {...}
  match <line =$non_EMAN_pasteline_term left> ,\
        <$non_EMAN_pasteline_src>;

    EMAN.pasteline.proc \
      <line>,<left>,<$non_EMAN_pasteline_src>

  ; ^last line
  else match <line> , <$non_EMAN_pasteline_src>;

    EMAN.pasteline.proc \
      <line>,<>,<$non_EMAN_pasteline_src>

  ; ^empty buffer, term outer loop
  else;
    break;

  end match;

end macro;


; ---   *   ---   *   ---
; iterates over captured lines and
; pastes them into calling scope

macro paste:\
  $non_EMAN_paste_code,\
  $non_EMAN_paste_len,\
  $non_EMAN_paste_nullargs&;

  local buf;
  local term;

  buf  equ $non_EMAN_paste_code;
  term equ $non.NULL;

  ; this is the outer loop we break out of from
  ; inside pasteline
  match T , term;

    repeat $non_EMAN_paste_len;
      EMAN.pasteline <buf>,T;

    end repeat;

  end match;

end macro;


; ---   *   ---   *   ---
; default line processing during capture

macro $non.capture.asis ok,dst,src&;
  ok  equ 1;
  dst equ src;

end macro;


; ---   *   ---   *   ---
; paste wrapper

macro $non.capture.post \
  $non_capture_post_proc,\
  $non_capture_post_procargs,\
  $non_capture_post_argline&;

  match <CODE> , EMAN.CCAPT;
    match <len:code> , <CODE>;
      $non_capture_post_proc <code>,len,\
        <$non_capture_post_procargs>,\
        $non_capture_post_argline;

    end match;

  end match;

end macro;


; ---   *   ---   *   ---
; map clines to proc

macro $non.capture \
  $non_capture_name,\
  $non_capture_procargs,\
  $non_capture_O:$non.NULL;

  ; make 'end [name]' the default block term
  local ender_s;
  match any , $non_capture_name;
    ender_s equ end any;

  end match;

  ; generate new macro!
  macro $non_capture_name $non_capture_argline&;

    ; default options
    local DEFAULT;
    match s , ender_s;
      DEFAULT equ lproc:$non.capture.asis,\
                  cproc:EMAN.paste,\
                  ender:`s;

    end match;

    ; ^replace defaults with passed values!
    local      opt;
    TAB.defnit opt,<DEFAULT>,<$non_capture_O>;


    ; begin capture block
    EMAN.CCAPT equ <0:>;

    macro ?! line&;
    match (lproc)(cproc)(ender) ,\
          (opt.lproc)(opt.cproc)(opt.ender);

      ; terminate block?
      if `line = ender;

        $non.capture.post \
          cproc,<$non_capture_procargs>,\
                $non_capture_argline;

        restore EMAN.CCAPT;
        purge   ?;

      ; ^process next line
      else;

        local ok;
        local eline;
        lproc ok,eline,line;

        ; append line to result?
        match =1 nblank , ok eline;
          EMAN.catline nblank;

        end match;

      end if;

    end match; defnit
    end macro; capture

  end macro;

end macro;


; ---   *   ---   *   ---
; FOOT

EOF;


; ---   *   ---   *   ---
