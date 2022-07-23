.MODULE NewTrm8
;	compute new term in expansion of arctan(1/8)
newtrm8
	ldd	ang_lzb
	addd	regsiz
	std	trm_lzb
	ldx	ang_lzb
	ldd	,x
	ldx	trm_lzb
	std	,x
	tsta
	bne	_nonz
	inx
_nonz	cpx	trm_lsb
	bhi	_rts
	ldaa	#8
	staa	tmpcnt
	ldd	#0
_nxs8	lsl	,x
	rolb
	rola
	subd	coeff_r
	blo	_ndv8
	lsr	,x
	sec
	rol	,x
	dec	tmpcnt
	bne	_nxs8
	bra	_byte
_ndv8	addd	coeff_r
	dec	tmpcnt
	bne	_nxs8
_byte	inx
	cpx	trm_lsb
	bls	_bit0
_rts	rts
_bit0	lsl	,x	;6
	lsld		;3
	subd	coeff_r	;5
	bhs	_bit1	;3
	addd	coeff_r	;5
_bit1	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit2
	addd	coeff_r
_bit2	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit3
	addd	coeff_r
_bit3	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit4
	addd	coeff_r
_bit4	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit5
	addd	coeff_r
_bit5	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit6
	addd	coeff_r
_bit6	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit7
	addd	coeff_r
_bit7	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit8
	addd	coeff_r
_bit8	rol	,x
	com	,x
	bra	_byte
