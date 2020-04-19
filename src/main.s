
    .include "p02r1.h.s"
    .include "p02r2.h.s"

    .area _CODE

_main::
    call p02r23
loop:
   jr    loop
