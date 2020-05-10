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
;;; Part 2, repte 3.3:
;;;
;;; dibuixar el terra ocupant tot l'ample de la pantalla
;;;

p02r33::
    call setup

    ld de, #sostre              ; DE punter al sprite
    ld hl, #0xc000              ; HL adreça de vídeo
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
    push hl
_dib_sprite8_loop2:
    ld (hl), a                  ; emplena la fila amb A
    inc hl                      ; avança HL
    djnz _dib_sprite8_loop2
    pop hl

    ;; TODO: açò sembla que gestiona correctament el canvi de fila,
	;; encara que canviï de línia. Valorar alternatives:
    ;;
    ;; - sumar 0xc850 a HL (add HL, DE)
    ;;
    ;; Al valorar cal tindre en compte el cost per iteració i el cost
	;; total (si una braca té poc cost la majoria de vegades però un cost
	;; elevat una de cada N vs. un cost mig totes les iteracions).

    ld a, h
    add a, #8                   ; passa a la fila següent
    jp nc, _foo                 ; travessa el límit de línia?
                                ; sí, cal ajustar HL sumant-li 0xc850
	                            ; però ja hem sumat 0x08 a H
    add a, #0xc0                ; només cal sumar 0xc0
    ld h, a
    ld a, l                     ; i 0x50 a L
    add a, #0x50
    ld l, a
    jp nc, _bar                 ; cal tindre en compte el carry i propagar-lo a H
    inc h
    jp _bar
_foo:                           ; no travessa la línia
    ld h, a                     ; H és vàlid
_bar:
    dec c                       ; decrementa el comptador de línies
    jr nz, _dib_sprite8_loop1
    ret

;;; ----------------------------------------------------------------------
;;; setup: configura el programa

setup:
    ;; desactiva les interrucions
    ld  a, #0xc9                ; C9 == ret
    di
    ld (#0x38), a
    ei

    ;; configura el color del border
    ;; http://www.cpcwiki.eu/index.php/Gate_Array#Controlling_the_Gate_Array
	ld bc, #0x7F00              ; port del gate array
	ld a, #0x10                 ; comanda seleccionar border (0b00001000)
	out (c), a                  ; envia comanda
	ld a, #0x40                 ; comanda seleccionar color (0b01000000)
	out (c), a                  ; envia comanda
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
sostre:
    .db 16
    .db 0xf0, 0x5a, 0xa5, 0x1e, 0x0a, 0x05, 0x08, 0x01
    .db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
