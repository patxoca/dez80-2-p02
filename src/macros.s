;;; ======================================================================
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
;;;   utilitzar una funció requereix 5 bytes només per preparar cada
;;;   call (més 4 de la propia funció), la macro requereix 4 bytes.

    .macro WAIT, N
    ld b, N
    halt
    djnz . - 1
    .endm
