	.module intermissions

intermissions
	.word	_inter0, _inter1, _inter2, _inter2, _inter2

_inter0
	ldd	#$2802
	std	$4EC2
	ldab	#$0A
	std	$4ED2
	ldab	#$62
	std	$4EE2
	ldab	#$6A
	std	$4EF2
	ldab	#$12
	std	pacrow
	ldab	#$5A
	std	msprow
	ldd	#$0F00
	std	$4EC4
	incb
	std	$4ED4
	ldd	#$0A02
	std	$4EE4
	incb
	std	$4EF4
	ldd	#$2040
	staa	pltlft
	stab	cntnrm
	bsr	_pacs
_redoit
	tst	pltlft
	beq	_move
	inc	paccol
	dec	mspcol
	dec	pltlft
	bne	_move
	jsr	fdheart
	ldab	#$06
	stab	$4EC5
	stab	$4ED5
	stab	$4EE5
	stab	$4EF5
	ldd	$4EC2
	ldx	$4EE2
	std	$4EE2
	stx	$4EC2
	ldd	$4ED2
	ldx	$4EF2
	stx	$4ED2
	std	$4EF2

_move	inc	$4EC3
	inc	$4ED3
	dec	$4EE3
	dec	$4EF3

	jsr	drawmrp
	jsr	drawmsp

	ldx	#ghost1
	jsr	gdrawg

	ldx	#ghost2
	jsr	gdrawg

	ldx	#ghost3
	jsr	gdrawg

	ldx	#ghost4
	jsr	gdrawg

	bsr	_song8
	dec	cntnrm
	bne	_redoit
	jmp	startlv

_pacs	ldd	#$0302
	staa	pacdir
	stab	mspdir
	rts

_song8	bsr	_song4
_song4	bsr	_song2
_song2	bsr	_song1
_song1	bsr	_song
	bpl	_rts
	ldx	#jinterm
	stx	sndloc
_rts	rts

_song	ldx	sndloc
	ldab	,x
	bpl	_next
	rts
_next	lslb			; similar logic in music.asm
	ldx	#jnotes		; maybe they should be combined
	abx			;
	ldd	,x		;
	std	tmpst3		;
	ldx	tmpst3		;
	ldd	$09		;
	tst	0008		;
	adda	#$30		;
	std	$0B		;
	ldaa	sndchr		;
	bra	_flip2		;
_flip	ldx	tmpst3		;
_flip2	eora	gameon		; 3 cyc = (4+3+4)+b*5+3+2+3
	staa	$BFFF		; 4	=     11 + b*5 + 8
_flip3
	dex			; 2	=     19 + b*5
	bne	_flip3		; 3
	ldab	$08		; 3
	andb	#$40		; 2
	beq	_flip		; 3
	staa	sndchr		;
	ldx	sndloc		;
	inx			;
	stx	sndloc
	clra
	rts

_song8d jsr	drawmrp
	jsr	drawmsp
	jmp	_song8
_inter1
_inter2
	ldd	#$281C
	std	pacrow
	ldab	#$50
	std	msprow
	bsr	_pacs
	jsr	fdheart
	ldaa	#$15
	staa	pltlft
_move1	dec	pltlft
	beq	_move2s
	inc	paccol
	dec	mspcol
	bsr	_song8d
	bra	_move1

_move2s	ldaa	#$08
	staa	pltlft
	clr	mspdir
_move2	dec	pltlft
	beq	_move3s
	inc	paccol
	dec	msprow
	jsr	_song8d
	bra	_move2

_move3s	ldd	#$0902
	staa	pltlft
	stab	mspdir
_move3	dec	pltlft
	beq	_move4s
	inc	paccol
	dec	mspcol
	jsr	_song8d
	bra	_move3

_bsong4	jsr	drawmrb
	jsr	drawmsp
	jmp	_song4

_move4s	ldd	#$0801
	staa	pltlft
	stab	mspdir
_move4	ldaa	pltlft
	deca
	staa	pltlft
	beq	_move5s
	bita	#$03
	bne	_move4a
	inc	paccol
_move4a	inc	msprow
	bsr	_bsong4
	bra	_move4

_move5s	ldd	#$1403		;$3803
	staa	pltlft
	stab	mspdir
_move5	ldaa	pltlft
	deca
	staa	pltlft
	beq	_move6s
	bita	#$03
	bne	_move5a
	inc	paccol
_move5a	inc	mspcol
	bsr	_bsong4
	bra	_move5

_move6s	ldd	pacrow
	jsr	rc2scn
	std	bpcspd
	ldx	#deadpac
	jsr	killmsk

_move6	jsr	killbpc
	stx	rndnum
	ldx	bpcspd
	jsr	killdrw
	inc	mspcol
	jsr	drawmsp
	jsr	_song4
	inc	mspcol
	jsr	drawmsp
	jsr	_song4
	ldab	#$0E
	ldx	rndnum
	abx
	cpx	#offsts1
	bne	_move6

	jmp	startlv
