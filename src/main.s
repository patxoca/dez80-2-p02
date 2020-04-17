
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
_p02r11_loop_1:
    ld a, #0x88                 ; patró
_p02r11_loop_2:
    ld (hl), a
    ld b, #32                   ; espera 32 halts, aprox 0.1 seg
    call wait
    srl a                       ; desplaça patró: 88 -> 44 -> 22 -> 11 -> 8
    cp #8
    jr nz, _p02r11_loop_2
    jr _p02r11_loop_1           ; quan arribem a 8 tornem a 88


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
