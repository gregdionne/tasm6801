
hi  .equ $C9
lo  .equ $CB
hi1 .equ $CD
lo1 .equ $D6

	.org $8000

	ldd  #$4000
	ldx  #$41ff
qsort	std  lo
	stx  hi
	ldab ,x
	ldx  lo
	ldaa ,x
	cba
	bls  getmed
	stab ,x
	ldx  hi
	staa ,x
getmed
	ldd  hi
	subd lo
	lsrd
	bne  getm1
	rts
getm1	addd lo
	std  hi1
	ldx  hi1
	ldaa ,x
	ldx  lo
	cmpa ,x
	bhs  getm2
	ldaa ,x
getm2	ldx  hi
	cmpa ,x
	bls  crawl
	ldaa ,x
crawl
	ldx  hi
	stx  hi1
	ldx  lo
	stx  lo1
w200	ldx  lo1
w201	cmpa ,x
	bls  w220
	inx
	bra  w201
w220	stx  lo1
	ldx  hi1
w221	cpx  lo1
	beq  w270
	cmpa ,x
	bhi  w250
	dex
	bra  w221
w250	stx  hi1
	psha
	ldaa ,x
	ldx  lo1
	ldab ,x
	staa ,x
	ldx  hi1
	stab ,x
	pula
	bra w200
w270	
	ldx  lo
w271	cmpa ,x
	bne  w290
	cpx  hi
	beq  w290
	inx
	bra  w271
w290	stx  lo
	cpx  lo1
	bls  w300
	stx  lo1
w300	ldx  hi
	pshx
	ldx  lo1
	pshx
	ldd  lo
	jsr  qsort
	pula
	pulb
	pulx
	jmp  qsort
	.end
