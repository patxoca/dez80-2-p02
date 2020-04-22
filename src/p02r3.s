;;; ======================================================================
;;;
;;; Part 2, repte 3
;;;
;;; ======================================================================

    .include "macros.s"

    .area _CODE

;;; ======================================================================
;;; Part 2, repte 3.1:
;;;
;;; dibuixar el terra
;;;
;;; # roig (11), @ groc (10), % cyan (01), . blau (00)
;;; #### -> 1111 1111 -> FF
;;; @%@% -> 1010 0101 -> A5
;;; %@%@ -> 0101 1010 -> 5A
;;; #### -> 1111 1111 -> FF

p02r31::
    ld hl, #0xc000
    ld de, #terra
    ld a, (de)
    ld b, a                     ; B comptador de línies;
    inc de
_p02r31_loop:
    ld a, (de)                  ; A píxels
    inc de
    ld (hl), a
    ld a, h
    add a, #8
    ld h, a
    ld l, #0
    djnz _p02r31_loop
    ret

    ret

;;; ======================================================================
;;; data

    .area _DATA


terra:
    ;; comptador de linies + 1 byte de colors per linia
    .db 4, 0xff, 0xa5, 0x5a, 0xff
