.MODULE NewTrm
;	compute new term  (angular power / coeff_r)
;	
;	
newtrm
	sts	svstack
	lds	trm_lsb
	ldx	ang_lsb
_num21	ldaa	,x
	psha
	dex
	cpx	ang_lzb
	bhs	_num21
	lds	svstack

	ldx	trm_lzb
_trm_lzb	tst	,x
	bne	_resn
	tst	1,x
	bne	_resn
	inx
	stx	trm_lzb
	bra	_trm_lzb
_resn	clra
	ldab	,x
	clr	,x
_byte	inx	
	cpx	trm_lsb	
	bls	_bit0
	rts	
_bit0	lsl	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit1
	addd	coeff_r	
_bit1	rol	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit2
	addd	coeff_r	
_bit2	rol	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit3
	addd	coeff_r	
_bit3	rol	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit4
	addd	coeff_r	
_bit4	rol	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit5
	addd	coeff_r	
_bit5	rol	,x
	rolb	
	rola
	subd	coeff_r	
	bhs	_bit6
	addd	coeff_r	
_bit6	rol	,x
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit7
	addd	coeff_r	
_bit7	rol	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit8
	addd	coeff_r	
_bit8	rol	,x
	com	,x
	bra	_byte
