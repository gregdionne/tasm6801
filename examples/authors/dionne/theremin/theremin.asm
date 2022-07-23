	.org $5000

	clr 0
	ldaa #$ff
	staa $bfff
loop	ldx #$4000
again	ldaa 2
	staa 0,x
	inx
	cpx #$5000
	bne again
	bra loop
	.end
