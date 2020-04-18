;;; ======================================================================
;;;
;;; Part 2, repte 2
;;;
;;; ======================================================================

    .include "macros.s"

    .area _CODE

;;; ======================================================================
;;; Part 2, repte 2.1:
;;;
;;; animar un dispar de laser

p02r21::
    ld hl, #0xc003
    ld (hl), #0x00
    ld hl, #0xc000
    ld (hl), #0xff
    WAIT #32

    ld hl, #0xc000
    ld (hl), #0x00
    ld hl, #0xc001
    ld (hl), #0xff
    WAIT #32

    ld hl, #0xc001
    ld (hl), #0x00
    ld hl, #0xc002
    ld (hl), #0xff
    WAIT #32

    ld hl, #0xc002
    ld (hl), #0x00
    ld hl, #0xc003
    ld (hl), #0xff
    WAIT #32

    jr p02r21
    ret

;;; ======================================================================
;;; data

    .area _DATA
