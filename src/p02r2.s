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
;;; Part 2, repte 2.2:
;;;
;;; animar una mena de trampa/pistó

;;; # roig (11), @ groc (10), . fons (00)
;;;
;;; ##@# -> 1111 1101 -> FD
;;; #@## -> 1111 1011 -> FB
;;;
;;; .#@@ -> 0111 0100 -> 74
;;; ##@@ -> 1111 1100 -> FC
;;;
;;; @@@@ -> 1111 0000 -> F0
;;; @@@@ -> 1111 0000 -> F0

    ;; sembla que funciona però no m'agrada definir "foo"
    ;; TODO: la documentació és frustrant, retroman crec que té un
	;; vídeo sobre macros

    .macro P02R22_DIB_PUNTA addr
    ld hl, #addr
    ld (hl), #0x74
    foo .equ (>#addr + #8)
    ld h, #foo
    ld (hl), #0xfc
    .endm

    .macro P02R22_DIB_BARRA addr
    ld hl, #addr
    ld (hl), #0xf0
    foo .equ (>#addr + #8)
    ld h, #foo
    ld (hl), #0xf0
    .endm

    .macro P02R22_ESBORRAR addr
    ld hl, #addr
    ld (hl), #0x00
    foo .equ (>#addr + #8)
    ld h, #foo
    ld (hl), #0x00
    .endm

p02r22::
    ld hl, #0xc000
    ld (hl), #0xfd
    ld h, #0xc8
    ld (hl), #0xfb

_p02r22_loop:
    P02R22_DIB_PUNTA 0xc003
    WAIT #32

    P02R22_DIB_PUNTA 0xc002
    P02R22_DIB_BARRA 0xc003
    WAIT #32

    P02R22_DIB_PUNTA 0xc001
    P02R22_DIB_BARRA 0xc002
    WAIT #32

    P02R22_ESBORRAR 0xc001
    P02R22_DIB_PUNTA 0xc002
    WAIT #32

    P02R22_ESBORRAR 0xc002
    P02R22_DIB_PUNTA 0xc003
    WAIT #32

    jr nz, _p02r22_loop

    ret

;;; ======================================================================
;;; data

    .area _DATA
