.MODULE TstTrm
;	set Z flag if term is zero
tsttrm
	ldx	trm_lsb
_again	tst	,x
	bne	_rts
	dex
	cpx	trm_msb
	bhs	_again
	tst	$0100
_rts	rts
