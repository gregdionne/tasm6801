	.module	attractscreen
_pausekey
	ldx	#$6000
_getany	jsr	kany
	bne	_trybreak
	dex
	bne	_getany
	rts

_trybreak
	jsr	kbreak
	bne	_gotbreak
	jsr	wscroll
	bra	_getany
_gotbreak
	ldaa	#$80
	staa	gameon
	pulx
	rts

credits
	ldaa	#$24
	staa	$BFFF
	jsr	knone
	jsr	clrmaz
	jsr	clrmz
	jsr	sshow
	jsr	wchar
	ldd	#$0810
	std	whorow
	ldd	#$0700
	std	whodir
	jsr	gdraw
	jsr	_pausekey
	jsr	wshadow
	jsr	_pausekey
	jsr	wblinky
	jsr	_pausekey
	ldd	#$1210
	std	whorow
	ldd	#$0701
	std	whodir
	jsr	gdraw
	jsr	_pausekey
	jsr	wspeedy
	jsr	_pausekey
	jsr	wpinky
	jsr	_pausekey
	ldd	#$1C10
	std	whorow
	ldd	#$0702
	std	whodir
	jsr	gdraw
	jsr	_pausekey
	jsr	wbashfl
	jsr	_pausekey
	jsr	winky
	jsr	_pausekey
	ldd	#$2610
	std	whorow
	ldd	#$0703
	std	whodir
	jsr	gdraw
	jsr	_pausekey
	jsr	wpokey
	jsr	_pausekey
	jsr	wclyde
	jsr	_pausekey
	jsr	wpellet
	jsr	wpillon
	ldd	#$0300
	ldx	#$501A
	jsr	drawwho
	jsr	wcopyrt

	ldx	#$3440
	stx	pacrow
	ldd	#$0200
	std	pacdir
	ldx	#ghost1
	ldd	#$3450
	std	$02,x
	ldd	#$0A00
	std	$04,x
	ldx	#ghost2
	ldd	#$3458
	std	$02,x
	ldd	#$0A01
	std	$04,x
	ldx	#ghost3
	ldd	#$3460
	std	$02,x
	ldd	#$0A02
	std	$04,x
	ldx	#ghost4
	ldd	#$3468
	std	$02,x
	ldd	#$0A03
	std	$04,x

	ldd	#$0001
	std	cntmr1
	std	cntpw1
	stab	ghost1
	stab	pwrvis
	ldaa	#$01
	staa	eatscr
_loop
	jsr	kany
	beq	_pacm
	rts
_pacm	ldx	cntmr1
	dex
	stx	cntmr1
	beq	_c1
	jmp	_ghst
_c1
	ldx	pacrow
	ldaa	pacdir
	jsr	drawwho
	ldaa	pacdir
	ldab	paccol
	cmpb	#$10
	bne	_pac1
	ldaa	#$03
	staa	pacdir
	ldd	#$0F06
	ldx	#ghost1
	STd	$04,x
	ldx	#ghost2
	std	$04,x
	ldx	#ghost3
	std	$04,x
	ldx	#ghost4
	std	$04,x
_pac1	cmpa	#$03
	bne	_b4gh
	ldx	#ghost1
	cmpb	#$1E
	beq	_clgh
	ldx	#ghost2
	cmpb	#$32
	beq	_clgh
	ldx	#ghost3
	cmpb	#$40
	beq	_clgh
	ldx	#ghost4
	cmpb	#$54
	beq	_clgh
	cmpb	#$58
	bne	_b4gh
	rts
_clgh	lsrb
	lsrb
	stx	whorow
	ldx	#$47BF
	abx
	stx	whodir
	jsr	_clx
	ldaa	eatscr
	adda	eatscr
	daa
	staa	eatscr
	clrb
	jsr	sshowg
	jsr	_pausekey
	ldx	whodir
	jsr	_clx
	ldaa	#$04
	ldx	whorow
	staa	$05,x
_b4gh	ldx	#$012C
	stx	cntmr1
	ldaa	pacdir
	anda	#$01
	lsla
	suba	#$01
	adda	paccol
	staa	paccol
_ghst	ldx	#ghost1
	ldd	,x
	subd	#$0001
	std	,x
	bne	_flash
	ldaa	#$01
	staa	,x
	ldaa	pacdir
	anda	#$01
	ldab	#$FF
	mul
	stab	$01,x
	bsr	_drg
	ldx	#ghost2
	bsr	_drg
	ldx	#ghost3
	bsr	_drg
	ldx	#ghost4
	bsr	_drg
_flash	ldd	cntpw1
	subd	#$0001
	std	cntpw1
	bne	_jloop
	ldd	#$0800
	std	cntpw1
	ldaa	pwrvis
	eora	#$01
	staa	pwrvis
	bne	_pillo
	jsr	wpillof
	bra	_jloop
_pillo	jsr	wpillon
_jloop	jmp	_loop

_drg	ldd	3,x
	andb	#$01
	lslb
	subb	#$01
	aba
	staa	3,x
	ldaa	5,x
	cmpa	#$04
	beq	_drgr
	jsr	gdrawg
_drgr	rts

_clx	pshx
	pshx
	pula
	pulb
	subd	#$0020
	pshb
	psha
	pulx
	ldd	#$0000
	std	$00,x
	std	$02,x
	std	$20,x
	std	$22,x
	std	$40,x
	std	$42,x
	std	$60,x
	std	$62,x
	std	$80,x
	std	$82,x
	std	$A0,x
	std	$A2,x
	std	$C0,x
	std	$C2,x
	pulx
	rts
