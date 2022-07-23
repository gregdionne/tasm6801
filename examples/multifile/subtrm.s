.MODULE SubTrm
;	subtract term from accumulator
subtrm
	sts	svstack
	ldx	trm_lsb
	lds	acc_lsb
	clc
	tpa
_again	des
	pulb
	tap
	sbcb	,x
	tpa
	pshb
	dex
	cpx	trm_lzb
	bhs	_again
	tap
	bcc	_done
	cpx	trm_msb
	bhs	_again
_done	lds	svstack
	rts
