	.org $8000

	ldx	#$41FF
	stx	cmploc+1
stcmp:	ldx	#$4000
nxcmp:	ldd	,x
	cba
	bls	noswap
	stab	,x
	staa	1,x
noswap:	inx
cmploc:	cpx	#0000
	blo	nxcmp
	dex
	stx	cmploc+1
	cpx	#$4000
	bhi	stcmp
	rts
	.end
