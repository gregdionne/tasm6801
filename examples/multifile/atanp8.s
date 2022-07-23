.MODULE Atanp8
;	add ACCA * atan(1/8) to accumulator
atanp8
	jsr	atninit
	jsr	addang
_again	ldd	coeff_r
	addd	#2
	std	coeff_r
	jsr	newang8
	jsr	newtrm8
	jsr	subtrm
	jsr	tsttrm
	ldd	coeff_r
	addd	#2
	std	coeff_r
	jsr	newang8
	jsr	newtrm8
	jsr	addtrm
	jsr	tsttrm
	bne	_again
	rts
