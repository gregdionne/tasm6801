	.module	score

clscore	ldx	#_score
	ldd	#$000C
_cr1	staa	,x
	inx
	decb
	bne	_cr1
	std	_level
	clr	LVLCNT
	jsr	_drscore
	jmp	_drlvl

_lvlsnds
	.word	 dorndm 	;0
	.word	 dorndm 	;1
	.word	 dorndm 	;2
	.word	 dotaunt	;3
	.word	 dohasta	;4

adjstatus
	psha
	tab
	lslb
	ldx	#_lvlsnds
	abx
	ldx	,x
	jsr	,x
	pula
	psha
	jsr	_adjscore
	jsr	_drscore
	pula
	bsr	_adjlines
	ldx	#_lines		;adjust level
	tst	$0,x
	bne	_lvlrts
	ldd	$1,x
	bsr	_ln2lvl
	cmpa	LVLCNT
	bls	_lvlrts
levelup	ldaa	LVLCNT
	inca
	cmpa	#$1E
	bhi	_lvlrts
lvl0	staa	LVLCNT
	tab
	clra
_lvl1	inca
	subb	#$0A
	bhs	_lvl1
	deca
	addb	#$0A
	std	_level
	ldaa	LVLCNT
	nega
	adda	#$1E		;was 20
	tab
	mul
	addd	#$0080
	std	LVLTIM
_drlvl	ldx	#_level
	stx	TMPLD2
	ldx	#$4606
	stx	TMPLD1
	ldab	#$02
	stab	TMPCNT
	jsr	_drscr0
	ldaa	LVLCNT
	eora	#$01
	anda	#$01
	ldab	#$40
	mul
	orab	#$24
	stab	$BFFF
_lvlrts	rts

_ln2lvl	pshb
	ldab	#$0A
	mul
	pula
	aba
	rts

_adjlines
	ldab	#$04
	stab	TMPCNT
	ldx	#_lines
_nxtlin	adda	$3,x
	daa
	tab
	anda	#$0F
	staa	$3,x
	clra
	bitb	#$10
	BEQ	_nxtl1
	inca
_nxtl1	dex
	dec	TMPCNT
	bne	_nxtlin
	ldx	#_lines
	stx	TMPLD2
	ldx	#$4906
	stx	TMPLD1
	ldab	#$04
	stab	TMPCNT
	bra	_drscr0

_adjscore
	ldab	LVLCNT		;B = LEVEL + 1
	incb			;A = # of lines cleared
_adjsc1	pshb
	psha
	bsr	 _doscore
	pula
	pulb
	decb
	bne	_adjsc1		;keep adding score by level
	rts

_doscore
	tab			;OFFSET = _sctbl + 4*LINES CLEARED
	lslb
	lslb
	ldx	#_sctbl
	abx
	clra
	psha			;push byte5 (0)
	psha			;push byte4 (0)
	ldd	$00,x
	psha			;push byte3
	pshb			;push byte2
	ldd	$02,x
	psha			;push byte1
	pshb			;push byte0
adjscr	ldx	#_score		;now add the six bytes on the stack to the score.
	ldab	#$06
	stab	TMPCNT
	decb
	abx
	clc
_adjadd	pula
	adca	$00,x
	daa
	tab
	andb	#$0F
	stab	$00,x
	dex
	suba	#$10
	suba	#$10
	dec	TMPCNT
	bne	_adjadd
	rts

_drscore
	ldx	#_score
	stx	TMPLD2
	ldx	#$4306
	stx	TMPLD1
	ldab	#$06		; there are 6 bytes to draw
	stab	>TMPCNT		; store 6 into TMPCNT
_drscr0	ldx	TMPLD2		;get byte
_drscr1	ldab	$00,x		;
	lslb			; x5
	lslb			;
	addb	$00,x		;
	ldx	#numbers	; get NUMBERS + 5 B
	abx			;
	ldd	$00,x		; get number
	psha
	pshb
	ldd	$02,x
	psha
	pshb
	ldaa	$04,x
	ldx	TMPLD1		; now store it to the screen loc
	staa	$80,x		;
	pula
	staa	$60,x
	pula
	staa	$40,x
	pula
	staa	$20,x
	pula
	staa	$00,x
	inx
	stx	TMPLD1		; now increment the screen pointer
	ldx	TMPLD2		; increment the number pointer
	inx
	stx	TMPLD2
	dec	TMPCNT		; decrement the temp count
	bne	_drscr1		; go until done.
	rts

_sctbl	.hex	00000000
	.hex	00000400
	.hex	00010000
	.hex	00030000
	.hex	01020000

_score	.hex	0000 0000 0000
_lines	.hex	0000 0000
_level	.hex	0000
