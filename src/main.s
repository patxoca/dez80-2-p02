
    .area _DATA

    .area _CODE

_main::
    call p02r12
loop:
   jr    loop

;;; ======================================================================
;;; Part 2, repte 1.1:
;;;
;;; animar un pixel que es mou horitzontalment 4 pixels

p02r11:
    ld hl, #0xc000
_p02r11_loop_1:
    ld a, #0x88                 ; patró
_p02r11_loop_2:
    ld (hl), a
    ld b, #32                   ; espera 32 halts, aprox 0.1 seg
    call wait
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
;;; input:
;;; - C: color
;;;
;;; output:
;;; cap
;;;
;;; altera:
;;; - A, B, C, D, HL: en acabar val 0
;;; - flag Z: val 1

_p02r12_sub:
    ld hl, #0xc000
    ld d, #0b10001000            ; mascara
_p02r12_sub_loop:
    ld a, d
    cpl                         ; mascara invertida
    and (hl)                    ; fica els bits a zero
    or c                        ; fica els bits de color a 1
    ld (hl), a                  ; actualitza el pixel
    ld b, #32
    call wait                   ; espera 32 halts
    srl c                       ; desplaça el color
    srl d                       ; desplaça la mascara
    ld a, d
    cp #8                       ; la mascara val: 88 -> 44 -> 22 -> 11 -> 8
                                ; en 8 cal parar
    jr nz, _p02r12_sub_loop
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
;;; - B: en acavar val 0
;;; - flag Z: val 1

wait:
    halt
    djnz wait
    ret
