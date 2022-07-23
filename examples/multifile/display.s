.MODULE Display
;	print accumulator to screen
display 
	ldx	ang_msb
	stx	ang_lzb
	ldx	trm_msb
	stx	trm_lzb
	ldx	acc_msb
	ldaa	,x
	adda	#'0'
	jsr	spita
	ldaa	#'.'
	jsr	spita
	bra	_disp
_again	ldx	acc_msb
	ldaa	,x
	adda	#'0'
	jsr	spita
_disp	ldx	acc_msb
	clr	,x
	jsr	acc2trm	
	jsr	dblacc
	jsr	dblacc
	jsr	addtrm
	jsr	dblacc
	ldx	numdig
	dex
	stx	numdig
	bne	_again
	rts

spita	.equ	$f9c6

; for writing to both printer and screen
;spita	com	$00e8
;	jsr	$f9c6
;	com	$00e8
;	jmp	$f9c6

