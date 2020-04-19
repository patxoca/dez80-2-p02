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
;;; Part 2, repte 2.3:
;;;
;;; animar una pilota rebotant

;;; .##. -> 0110 0110 -> 66
;;; #@@# -> 1111 1001 -> F9
;;; #@@# -> 1111 1001 -> F9
;;; .##. -> 0110 0110 -> 66

    .macro P02R23_DIB_BOLA addr
    ld hl, #addr
    ld (hl), #0x66
    foo .equ (>#addr + #8)
    ld h, #foo
    ld (hl), #0xf9
    foo .equ (>#addr + #16)
    ld h, #foo
    ld (hl), #0xf9
    foo .equ (>#addr + #24)
    ld h, #foo
    ld (hl), #0x66
    .endm

    .macro P02R23_ESBORRAR addr
    ld hl, #addr
    ld (hl), #0
    .endm

p02r23::
    P02R23_DIB_BOLA 0xc000
    WAIT #48

    P02R23_ESBORRAR 0xc000
    P02R23_DIB_BOLA 0xc800
    WAIT #48

    P02R23_ESBORRAR 0xc800
    P02R23_ESBORRAR 0xd000
    P02R23_DIB_BOLA 0xd800
    WAIT #48

    P02R23_ESBORRAR 0xe800
    P02R23_ESBORRAR 0xf000
    P02R23_DIB_BOLA 0xc800
    WAIT #48

    P02R23_ESBORRAR 0xe000
    jr p02r23

    ret

;;; ======================================================================
;;; data

    .area _DATA
