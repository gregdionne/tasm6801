.MODULE NewAng8
;	compute new angular power
;	    ang = ang / (8^2)
newang8
	ldx	ang_lzb
_again	ldd	,x
	tsta
	bne	_done
	inx
	cpx	ang_lsb
	beq	_donex
	stx	ang_lzb
	bra	_again
_done	lsrd
	lsrd
	lsrd
	lsrd
	lsrd
	lsrd
	std	,x
	rts
_donex	clra
	staa	,x
	rts
