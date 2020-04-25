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
    ld hl, #0xc000              ; HL adreça de vídeo
    jp dib_sprite8

;;; ======================================================================
;;; Part 2, repte 3.2:
;;;
;;; dibuixar el terra ocupant tot l'ample de la pantalla
;;;

p02r33::
    ld de, #sostre1             ; DE punter al sprite
    ld hl, #0xc000              ; HL adreça de vídeo
    call dib_sprite8

    ld de, #sostre2             ; DE punter al sprite
    ld hl, #0xc050              ; HL adreça de vídeo
    call dib_sprite8

    ld de, #terra               ; DE punter al sprite
    ld hl, #0xc0f0              ; HL adreça de vídeo
    jp dib_sprite8

;;; ======================================================================
;;; Funcions auxiliars

;;; ----------------------------------------------------------------------
;;; dib_sprite8: dibuixa un sprite repetit a l'ample de la pantalla.
;;;
;;; Dibuixa un sprite repetit a tot l'ample. Cal que el sprite estigui
;;; contingut dins una única línia (màxim 8 bytes d'alçada) ja que els
;;; càlculs no tenen en compte el canvi de línia.
;;;
;;; input:
;;; - DE: adreça del sprite
;;; - HL: adreça de vídeo on pintar
;;;
;;; output:
;;; cap
;;;
;;; altera:
;;; - A, B, C, D, E, HL
;;; - flags
;;;

dib_sprite8:
    ld a, (de)
    inc de
    ld c, a                     ; C nombre de línies del sprite
_dib_sprite8_loop1:
    ld a, (de)                  ; A bytes del sprite
    inc de
    ld b, #0x50                 ; B nombre de repeticions (dins la línia)
_dib_sprite8_loop2:
    ld (hl), a                  ; emplena la fila amb A
    inc hl                      ; avança HL
    djnz _dib_sprite8_loop2

    ;; TODO: si no suposa un cost elevat mirar de generalitzar-ho per
    ;; poder travesar els límits de les línies de caràcters

    ld a, l                     ; mou HL al principi de la línia següent
    sub #0x50
    ld l, a
    ld a, h
    sbc a, #0                   ; ajusta H si la resta anterior dona negatiu
    add a, #8
    ld h, a

    dec c                       ; decrementa el comptador de línies
    jr nz, _dib_sprite8_loop1
    ret

;;; ======================================================================
;;; data

    .area _DATA

    ;; Sprites
    ;;
    ;; Cada sprite es representa amb un byte pel nombre de linies + 1
    ;;	byte pels colors per cada línia.
    ;;
    ;; El l'art ASCII que mostra els sprites s'utilitza la codificació:
    ;;
    ;; # roig (11), @ groc (10), % cyan (01), . blau (00)

    ;; #### -> 1111 1111 -> FF
    ;; @%@% -> 1010 0101 -> A5
    ;; %@%@ -> 0101 1010 -> 5A
    ;; #### -> 1111 1111 -> FF
    ;;
terra:
    .db 6, 0xff, 0xa5, 0x5a, 0xa5, 0x5a, 0xff

    ;; @@@@ -> 1111 0000 -> F0
    ;; %@%@ -> 0101 1010 -> 5A
    ;; @%@% -> 1010 0101 -> A5
    ;; %%%@ -> 0001 1110 -> 1E
    ;; %.%. -> 0000 1010 -> 0A
    ;; .%.% -> 0000 0101 -> 05
    ;; %... -> 0000 1000 -> 08
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;;
sostre1:
    .db 8
    .db 0xf0, 0x5a, 0xa5, 0x1e, 0x0a, 0x05, 0x08, 0x00
sostre2:
    .db 8
    .db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
