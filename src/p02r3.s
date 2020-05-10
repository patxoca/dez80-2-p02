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
;;; Part 2, repte 3.4:
;;;
;;; dibuixar el monigot, anima el dispar i l'explosió
;;;

p02r34::
    call setup

    ld de, #sostre              ; DE punter al sprite
    ld hl, #0xc000              ; HL adreça de vídeo
    call dib_sprite8

    ld hl, #jugador             ; DE punter al sprite
    ld de, #0xc0a0              ; HL adreça de vídeo
    call dib_sprite

    ld de, #terra               ; DE punter al sprite
    ld hl, #0xc0f0              ; HL adreça de vídeo
    call dib_sprite8


_p02r34_loop:                   ; bucle infinit de l'animació
    ld hl, #0xd8a2              ; adreça d'inici del dispar
    ld b, #77                   ; nombre de iteracions: ample - 2
                                ; bytes del personatge - 1 byte per
                                ; l'explosió

_p02r34_loop_dispar:            ; bucle per animar el dispar
    ld (hl), #0x64              ; pinta el dispar: .#@. -> 0110 0100 -> 64
    ld a, b                     ; B és destruit per WAIT, el preservem
    WAIT #5
    ld b, a                     ; recupera B
    ld (hl), #0                 ; esborra el dispar
    inc hl                      ; avança el dispar un byte
    djnz _p02r34_loop_dispar    ; repeteix

    ld (#_p02r34_loop_explosio + 1), hl
                                ; guarda on ha acabat el dispar

                                ; prepara animació explosió
    ld b, #5                    ; nombre de frames de l'animació
    ld hl, #explosio1           ; adreça del primer sprite

_p02r34_loop_explosio:
    ;; WARNING: el correcte funcionament depen de que dib_sprite deixi
    ;; HL apuntant al primer byte després del sprite (al primer bytes
    ;; del sprite següent)

    ld de, #0x0000              ; codi modificable, carrega en DE
                                ; l'adreça on pintar l'explosió
    push bc                     ; preserva B
    call dib_sprite
    WAIT #26
    pop bc                      ; recupera B
    djnz _p02r34_loop_explosio  ; nombre fotogrames exhaurit?

    jp _p02r34_loop             ; repeteix dispar + explosió
    ret

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
;;; dib_sprite: dibuixa un sprite
;;;
;;; input:
;;; - HL: adreça del sprite
;;; - DE: adreça de vídeo on pintar
;;;
;;; output:
;;; cap
;;;
;;; altera:
;;; - A, B, C, D, E, H i L
;;; - HL queda apuntant al primer bytes després del sprite
;;; - flags
;;;

dib_sprite:
    ld a, (hl)                  ; el primer byte és l'ample del sprite
    inc hl
    ld (#_dib_sprite_ample + 1), a
                                ; modifica la instrucció
    ld a, (hl)                  ; el segon byte és l'alt del sprite
    inc hl
    ld c, a                     ; C nombre de línies del sprite
_dib_sprite_loop:
    push bc
    push de
_dib_sprite_ample:
    ld bc, #0x0000              ; B nombre de repeticions, el valor
                                ; s'estableix al principi de la funció
    ldir

    pop de
    pop bc

    ld a, d
    add a, #8                   ; passa a la fila següent
    jp nc, _dib_sprite_foo      ; travessa el límit de línia?
                                ; sí, cal ajustar DE sumant-li 0xc850
	                            ; però ja hem sumat 0x08 a D
    add a, #0xc0                ; només cal sumar 0xc0
    ld d, a
    ld a, e                     ; i 0x50 a E
    add a, #0x50
    ld e, a
    jp nc, _dib_sprite_bar      ; cal tindre en compte el carry i propagar-lo a D
    inc d
    jp _dib_sprite_bar
_dib_sprite_foo:                ; no travessa la línia
    ld d, a                     ; D és vàlid
_dib_sprite_bar:
    dec c                       ; decrementa el comptador de línies
    jr nz, _dib_sprite_loop
    ret

;;; ----------------------------------------------------------------------
;;; setup: configura el programa

setup:
    ;; desactiva les interrucions
    di
    im 1
    ld  a, #0xfb                ; FB == ei
    ld (#0x38), a
    ld  a, #0xc9                ; C9 == ret
    ld (#0x39), a
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

    ;; Aquests sprites no es repeteixen, els dos primers bytes
    ;; determinen l'ample i l'alt.

    ;; .@@@@... -> 0111 0000  1000 0000 -> 70 80
    ;; @#.#.... -> 1101 0101  0000 0000 -> D5 00
    ;; .###%... -> 0111 0111  0000 1000 -> 77 08
    ;; .%.%%### -> 0000 0101  0111 1111 -> 05 7F
    ;; .%%..%.. -> 0000 0110  0000 0100 -> 06 04
    ;; .@@@@... -> 0111 0000  1000 0000 -> 70 80
    ;; .@..@... -> 0100 0000  1000 0000 -> 40 80
    ;; .@@.@@.. -> 0110 0000  1100 0000 -> 60 C0


jugador:
    .db 2, 8
    .db 0x70, 0x80, 0xd5, 0x00, 0x77, 0x08, 0x05, 0x7f
    .db 0x06, 0x04, 0x70, 0x80, 0x40, 0x80, 0x60, 0xc0

    ;; .... -> 0000 0000 -> 00
    ;; .##. -> 0110 0110 -> 66
    ;; .##. -> 0110 0110 -> 66
    ;; .... -> 0000 0000 -> 00
dispar:
    .db 1, 4, 0x00, 0x66, 0x66, 0x00

    ;; #..# -> 1001 1001 -> 99
    ;; .#@. -> 0110 0100 -> 64
    ;; .@#. -> 0110 0010 -> 62
    ;; #..# -> 1001 1001 -> 99
explosio1:
    .db 1, 4, 0x99, 0x64, 0x62, 0x99

    ;; #..@ -> 1001 1000 -> 98
    ;; .@%. -> 0100 0010 -> 42
    ;; .%@. -> 0010 0100 -> 24
    ;; @..# -> 0101 0001 -> 51
explosio2:
    .db 1, 4, 0x98, 0x42, 0x24, 0x51

    ;; @..% -> 1000 0001 -> 81
    ;; .½.. -> 0000 0100 -> 04
    ;; ..½. -> 0000 0010 -> 02
    ;; %..@ -> 0001 1000 -> 18
explosio3:
    .db 1, 4, 0x81, 0x04, 0x02, 0x18

    ;; %... -> 0000 1000 -> 08
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;; ...% -> 0000 0001 -> 01
explosio4:
    .db 1, 4, 0x08, 0x00, 0x00, 0x01

    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
    ;; .... -> 0000 0000 -> 00
explosio5:
    .db 1, 4, 0x00, 0x00, 0x00, 0x00
