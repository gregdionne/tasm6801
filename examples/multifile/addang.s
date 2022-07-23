.MODULE AddAng
;	add angular power to accumulator
addang
	sts	svstack
	ldx	ang_lsb
	lds	acc_lsb
	clc
	tpa
_again	des
	pulb
	tap
	adcb	,x
	tpa
	pshb
	dex
	cpx	ang_msb
	bhs	_again
	lds	svstack
	rts
