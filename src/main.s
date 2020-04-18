
    .area _DATA

    .area _CODE

_main::
    call p02r12
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
;;; funcions d'utilitat

;;; ----------------------------------------------------------------------
;;; wait: espera basada en halt
;;;
;;; input:
;;; - B: nombre de halts que cal executar
;;;
;;; output:
;;; cap
;;;
;;; altera:
;;; - B: en acabar val 0
;;; - flag Z: val 1

wait:
    halt
    djnz wait
    ret
