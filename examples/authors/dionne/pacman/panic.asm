	.module	panic

_ccrdump
	rora
	blo	_cc1
	ldab	#$2E
_cc1
	stab	,x
	dex
	rts

panic	pshx			;
	psha			; s
	pshb			;
	tpa			; 0    1 2 34 56
	psha			; ccr a b x [pc]
	tsx
	clr	$BFFF
	ldd	#$1003 		; 'pc'
	std	$4000
	ldd	#$2013
	std	$4006
	ldab	#$18
	std	$400C
	ldab	#$04
	std	$4012
	ldab	#$20
	std	$4018
	ldaa	0,x 		; ccr
	ldx	#$401F
	ldab	#$03		; 'c'
	bsr	_ccrdump
	ldab	#$16		; 'v'
	bsr	_ccrdump
	ldab	#$1A		; 'z'
	bsr	_ccrdump
	ldab	#$0E		; 'n'
	bsr	_ccrdump
	ldab	#$09		; 'i'
	bsr	_ccrdump
	ldab	#$08		; 'h'
	bsr	_ccrdump
	tsx
	ldaa	1,x
	bsr	_hexify
	std	$4016
	ldaa	2,x
	bsr	_hexify
	std	$4014
	ldaa	3,x
	bsr	_hexify
	std	$400E
	ldaa	4,x
	bsr	_hexify
	std	$4010
	ldaa	5,x
	bsr	_hexify
	std	$4002
	ldaa	6,x
	bsr	_hexify
	std	$4004
	ldab	#$06
	abx
	pshx
	tsx
	ldaa	0,x
	bsr	_hexify
	std	$4008
	ldaa	1,x
	bsr	_hexify
	std	$400A
	pulx
	bra	_brkout
_hexify	clrb
	lsrd
	lsrd
	lsrd
	lsrd
	lsrb
	lsrb
	lsrb
	lsrb
	addd	#$3030
	cmpa	#$3A
	blo	_c2
	suba	#$39
_c2
	cmpb	#$3A
	blo	_c3
	subb	#$39
_c3
	rts
_brkout	ldaa	#$7F
	staa	$02
	ldaa	$03
	bita	#$02
	beq	_brkbye
	ldaa	#$FB
	staa	$02
_brklp1	ldaa	$03
	bita	#$02
	bne	_brklp1
_brklp2	ldaa	$03
	bita	#$02
	beq	_brklp2
_brkbye	ldaa	#$2C		;24
	staa	$BFFF
	rti

;pause
	pshx
	psha
	pshb
	tpa
	psha
	bra	_brkout
