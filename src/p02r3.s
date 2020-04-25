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

;;; ======================================================================
;;; Part 2, repte 3.2:
;;;
;;; dibuixar el terra ocupant tot l'ample de la pantalla
;;;

p02r32::
    ld de, #terra               ; DE punter al sprite
    ld a, (de)
    inc de
    ld c, a                     ; C nombre de línies del sprite
    ld hl, #0xc000              ; HL adreça de vídeo
_p02r32_loop1:
    ld a, (de)                  ; A bytes del sprite
    inc de
    ld b, #0x50                 ; B nombre de repeticions (dins la línia)
_p02r32_loop2:
    ld (hl), a                  ; emplena la fila amb A
    inc l                       ; avança HL
    djnz _p02r32_loop2
    ld a, h                     ; mou HL al principi de la línia següent
    add a, #8
    ld h, a
    ld l, #0
    dec c                       ; decrementa el comptador de línies
    jr nz, _p02r32_loop1
    ret

;;; ======================================================================
;;; data

    .area _DATA


terra:
    ;; comptador de linies + 1 byte de colors per linia
    .db 6, 0xff, 0xa5, 0x5a, 0xa5, 0x5a, 0xff
