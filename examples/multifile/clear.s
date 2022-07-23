.MODULE Clear
;	clear register in ACCX
clear
	stx	svstack
	ldd	svstack
	addd	regsiz
	std	svstack
_again	clr	,x
	inx
	cpx	svstack
	bne	_again
	rts
