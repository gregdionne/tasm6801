.MODULE Atanp
;	add  ACCA * arctan( 1 / angsq_r ) to accumulator
atanp
	jsr	atninit
	jsr	addang
_again	ldd	coeff_r
	addd	#2
	std	coeff_r
	jsr	newang
	jsr	newtrm
	jsr	subtrm
	ldd	coeff_r
	addd	#2
	std	coeff_r
	jsr	newang	
	jsr	newtrm
	jsr	addtrm
	jsr	tsttrm
	bne	_again
	rts
