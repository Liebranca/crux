; ---   *   ---   *   ---
; INFO
; Book-keeping
;
; LIBRE SOFTWARE
; Licensed under GNU GPL3
; be a bro and inherit
;
; CONTRIBUTORS
; lyeb,

; ---   *   ---   *   ---
; HEAD

if ~defined loaded.INFO;


; ---   *   ---   *   ---
; quick and dirty namespace aggregation ;>

define INFO_FIELDS;
macro  INFO_FIELD line {

  match module field value , this.module line \{
    define module\#.\#field value;

    match any , INFO_FIELDS \\{
      if ~(field in <any>);
        INFO_FIELDS equ any,field;

      end if;

    \\};

    match , INFO_FIELDS \\{
      INFO_FIELDS equ field;

    \\};

  \};

};


; ---   *   ---   *   ---
; ^please only aggregate to it this way

macro TITLE name {
  match any , name \{

    if ~defined loaded.\#any;
    define this.module  any;
    define loaded.\#any 1;

  \};

};

macro VERSION number {
  INFO_FIELD version number;

};

macro AUTHOR name {
  INFO_FIELD author name;

};


; ---   *   ---   *   ---
; terminate scope

macro EOF {
  restore this.#module;
  end if;

};


; ---   *   ---   *   ---
; an example of usage:

  TITLE     INFO;

  VERSION   v0.01.2;
  AUTHOR    'IBN-3DILA';

  EOF;


; ---   *   ---   *   ---
; print info for module!

macro INFO.printx name,[field] {

  common display $0A,`name,$0A;

  forward match value , name#.#field \{
    display '  ',`field,' ',\`value,$0A;

  \};

  common display $0A;

};

macro INFO.printall name {
  match list , INFO_FIELDS \{
    INFO.printx name,list;

  \};

};

macro INFO.print name= {

  local ok;
  ok equ 0;

  match any , name \{
    INFO.printall any;
    ok equ 1;

  \};

  match =0 any , ok this.module \{
    INFO.printall any;

  \};

};


; ---   *   ---   *   ---
; FOOT

end if; loaded


; ---   *   ---   *   ---
