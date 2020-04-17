
    .area _DATA

    .area _CODE

_main::
    call p02r11
loop:
   jr    loop

;;; ======================================================================
;;; Part 2, repte 1.1:
;;;
;;; animar un pixel que es mou horitzontalment 4 pixels

p02r11:
    ld hl, #0xc000
_p02r11_loop:
    ld (hl), #0x88
    ld b, #32
    call wait
    ld (hl), #0x44
    ld b, #32
    call wait
    ld (hl), #0x22
    ld b, #32
    call wait
    ld (hl), #0x11
    ld b, #32
    call wait
    jr _p02r11_loop
    ret


;;; ======================================================================
;;; funcions d'utilitat

;;; wait: espera basada en halt
;;;
;;; input:
;;; - B: nombre de halts que cal executar
;;;
;;; output:
;;; cap
;;;
;;; altera:
;;; - B: en acavar val 0
;;; - flag Z: val 1

wait:
    halt
    djnz wait
    ret
