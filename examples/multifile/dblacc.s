.MODULE DblAcc
;	double the accumulator
dblacc
	ldx	acc_lsb
	clc
	tpa
_again	tap
	rol	,x
	tpa
	dex
	cpx	acc_msb
	bhs	_again
	rts
