
    .area _CODE

_main::
    call p02r13
loop:
   jr    loop

;;; ======================================================================
;;; Macros

;;; ----------------------------------------------------------------------
;;; WAIT: espera basada en halt
;;;
;;; input:
;;; - N: nombre de halts que cal executar
;;;
;;; output:
;;; cap
;;;
;;; altera:
;;; - B: en acabar val 0
;;; - flag Z: val 1
;;;
;;; rationale:
;;;   utilitzar una funció requereix 5 bytes per preparar el call, la
;;;   macro requereix 5 bytes.
;;;
    .macro WAIT, N
    ld b, N
    halt
    djnz . - 1
    .endm

;;; ======================================================================
;;; Part 2, repte 1.1:
;;;
;;; animar un píxel que es mou horitzontalment 4 píxels

p02r11:
    ld hl, #0xc000
_p02r11_loop_1:
    ld a, #0x88                 ; patró
_p02r11_loop_2:
    ld (hl), a
    WAIT #32
    srl a                       ; desplaça patró: 88 -> 44 -> 22 -> 11 -> 8
    cp #8
    jr nz, _p02r11_loop_2
    jr _p02r11_loop_1           ; quan arribem a 8 tornem a 88


;;; ======================================================================
;;; Part 2, repte 1.2:
;;;
;;; dibuixar una barra de progrés

p02r12:
    ld c, #0b10001000           ; roig
    call _p02r12_sub
    ld c, #0b10000000           ; groc
    call _p02r12_sub
    ld c, #0b00001000           ; cian
    call _p02r12_sub
    ld c, #0b00000000           ; blau
    call _p02r12_sub
    jr p02r12
    ret

;;; ----------------------------------------------------------------------
;;; subrutina auxiliar que emplena la barra de progrés amb un color
;;;
;;; input:
;;; - C: color
;;;
;;; output:
;;; cap
;;;
;;; altera:
;;; - A, B, C, D, E, HL
;;; - flag Z: val 1

_p02r12_sub:
    ld e, c                     ; preserva el color (C)
    ld hl, #0xc000
_p02r12_sub_loop1:
    ;; el bucle extern es repeteix per cada grup de 4 píxels (1 bytes)
    ld c, e                     ; restaura el color
    ld d, #0b10001000           ; màscara
_p02r12_sub_loop2:
    ;; el bucle intern es repeteix per cada píxel individual dins el
    ;; grup de 4, assignant-li el color
    ld a, d
    cpl                         ; màscara invertida
    and (hl)                    ; fica els bits del píxel a 0
    or c                        ; activa els bits del píxel en funció del color
    ld (hl), a                  ; actualitza el píxel
    WAIT #32                    ; espera 32 halts
    srl c                       ; desplaça el color
    srl d                       ; desplaça la màscara
    ld a, d
    cp #8                       ; la màscara val: 88 -> 44 -> 22 -> 11 -> 8
                                ; en 8 cal parar
    jr nz, _p02r12_sub_loop2
    inc l
    ld a, l
    cp #2                       ; la barra ocupa 8 píxels (2 bytes),
                                ; 0xc000 i 0xc001. En 0xc002 cal parar
    jr nz, _p02r12_sub_loop1
    ret

;;; ======================================================================
;;; Part 2, repte 1.3:
;;;
;;; animar una cara

;;; . fons (00), # groc (10), @ cian (01), - roig (11)
;;;
;;; 1: .######. -> 0111 0000  1110 0000 -> 70 E0
;;; 2: .#@##@#. -> 0101 0010  1010 0100 -> 52 A4
;;; 3: ######## -> 1111 0000  1111 0000 -> F0 F0
;;; 4: ######## -> 1111 0000  1111 0000 -> F0 F0
;;; 5: .##-###. -> 0111 0001  1110 0000 -> 71 E0
;;; 6: .######. -> 0111 0000  1110 0000 -> 70 E0
;;;
;;; Animació dels llavis:
;;;
;;; fotograma 1:
;;;
;;; 4: ######## -> 1111 0000  1111 0000 -> F0 F0
;;; 5: .##-###. -> 0111 0001  1110 0000 -> 71 E0
;;;
;;; fotograma 2:
;;;
;;; 5: .##--##. -> 0111 0001  1110 1000 -> 71 E8
;;;
;;; fotograma 3:
;;;
;;; 4: ##-##-## -> 1111 0010  1111 0100 -> F2 F4

p02r13:
    ld hl, #0xc000              ; HL adreça de vídeo
    ld de, #_p02r13_sprite      ; DE adreça del sprite
    ld b, #6                    ; B  nombre de files

_p02r13_draw:                   ; pinta la cara completa
    ld a, (de)
    inc de
    ld (hl), a                  ; pinta el primer píxel
    inc l
    ld a, (de)
    inc de
    ld (hl), a                  ; pinta el segon píxel
    ld a, h
    add #8
    ld h, a
    ld l, #0                    ; HL apunta al principi de la línia següent
    djnz _p02r13_draw           ; si queden files (B) repetim

    WAIT #64

_p02r13_anim:                   ; bucle d'animació
    ;; pinta el fotograma 2
    ld hl, #0xe000
    ld (hl), #0x71
    inc l
    ld (hl), #0xe8

    WAIT #64

    ;; pinta el fotograma 3
    ld hl, #0xd800
    ld (hl), #0xf2
    inc l
    ld (hl), #0xf4

    WAIT #64

    ;; pinta el fotograma 1 (restaura la imatge original)
    ld hl, #0xd800
    ld (hl), #0xf0
    inc l
    ld (hl), #0xf0
    ld hl, #0xe000
    ld (hl), #0x71
    inc l
    ld (hl), #0xe0

    WAIT #64

    ;; repeteix
    jr _p02r13_anim
    ret

;;; ======================================================================
;;; data

    .area _DATA

_p02r13_sprite:
    .db 0x70, 0xE0
    .db 0x52, 0xA4
    .db 0xF0, 0xF0
    .db 0xF0, 0xF0
    .db 0x71, 0xE0
    .db 0x70, 0xE0
