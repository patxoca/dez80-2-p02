
    .include "p02r1.h.s"

    .area _CODE

_main::
    call p02r13
loop:
   jr    loop
