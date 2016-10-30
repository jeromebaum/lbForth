\ Compilation to a target image.

\ Define a target image, and words to access its contents.

\ The image can be divided into sections, each with their own address
\ range.  ORG sets the dictionary pointer, and also creates a new section.


0 value t-size
0 value t-image

\ The currently active section.

variable prev  0 prev !
variable start  0 start !
variable t-dp  0 t-dp !
variable t-delta

\ Store current section and start a new one.

: prev,   here prev @ , prev ! ;
: start,   start @ , ;
: end,   t-dp @ , ;
: delta,   t-delta @ , ;
: section,   prev, start, end, delta, ;

\ Access fields in a stored section.

: start@   cell+ @ ;
: end@   2 cells + @ ;
: delta@   3 cells + @ ;
: range@   dup start@ swap end@ ;

\ Translate a target address to a host address.  This requires finding
\ the section which contains the target address.

variable stop  0 stop !
: section?   2dup range@ within ;
: ?section   section? if delta@ + stop then ;
: search   prev begin @ ?dup while ?section repeat ;
: t-end   t-image t-size + t-delta @ - ;
: current?   start @ t-end within ;
: >host   dup current? if t-delta @ + else search then ;

\ Read and write a target character.

: t-c@   >host c@ ;
: t-c!   >host c! ;

\ Move the target dicionary pointer, and start a new section.

: delta!   t-dp @ over - t-delta +! ;
: start!   dup t-dp ! start ! ;
: t-org   section, delta! start! ;

\ Save target image.

: target-region ( -- a u ) t-image t-dp @ >host over - ;

[defined] write-file [if]
variable f
: ?error   abort" write" ;
: ?size   target-region nip <> abort" size" ;
: open-image   s" image" w/o create-file abort" open" f ! ;
: write-image   target-region f @ write-file ?error ?size ;
: save-target   open-image write-image f @ close-file ;
[else]
: save-target   target-region type ;
[then]

: 0image   t-image t-size erase  t-image t-delta ! ;
: t-allot ( u -- ) to t-size  here to t-image  t-size allot  0image ;

\ Define a word to cross compile to the target image.

require lib/cross.fth
: section: ( u1 u2 "name" -- ) >r ['] t-org ['] t-dp ['] t-c! ['] t-c@ r> image: ;
