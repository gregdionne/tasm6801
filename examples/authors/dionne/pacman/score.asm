	.module	score
; digit A to screen at X
_dig2scn
	sts	tmpst1
	stx	tmpst3
	ldab	#$05
	mul
	ldx	#numbers
	abx
	txs
	ldx	tmpst3
	pula
	staa	$00,x
	pula
	staa	$20,x
	pula
	staa	$40,x
	pula
	staa	$60,x
	pula
	staa	$80,x
	lds	tmpst1
	rts

; digits a to screen at x
_num2scn
	psha
	lsra
	lsra
	lsra
	lsra
	bsr	_dig2scn
	inx
	pula
	anda	#$0F
	bra	_dig2scn

; leading digits a to screen at x
_lnm2scn
	bita	#$F0
	bne	_num2scn
	clr	$00,x
	clr	$20,x
	clr	$40,x
	clr	$60,x
	clr	$80,x
	inx
	anda	#$0F
	bne	_dig2scn
	clr	$00,x
	clr	$20,x
	clr	$40,x
	clr	$60,x
	clr	$80,x
	rts

sshow	ldx	#$4000
	ldaa	score3
	bsr	_lnm2scn
	bne	_show2
	inx
	ldaa	score2
	bsr	_lnm2scn
	bne	_show1
	inx
	ldaa	score1
	bsr	_lnm2scn
	bne	_show0
	inx
	ldaa	score0
	bsr	_lnm2scn
	beq	_dig2scn
	rts
_show2	inx
	ldaa	score2
	bsr	_num2scn
_show1	inx
	ldaa	score1
	bsr	_num2scn
_show0	inx
	ldaa	score0
	bra	_num2scn

; d+score->score
splusd	tst	gameon
	bne	_son
	rts
_son
	psha
	tba
	adda	score0
	daa
	staa	score0
	pula
	adca	score1
	daa
	staa	score1
	bcc	_nolif2
	tst	xtrlif
	beq	_nolif1
	clr	xtrlif
	inc	nlives
	jsr	drawlives
_nolif1	sec
_nolif2	ldaa	#$00		; clra resets the carry bit
	adca	score2
	daa
	staa	score2
	ldaa	#$00		; clra resets the carry bit
	adca	score3
	daa
	staa	score3
	jmp	sshow

sclear	clr	score3
	clr	score2
	clr	score1
	clr	score0
	rts

sshowc	ldx	#$474C
sshowg	pshb
	bsr	_lnm0scn
	pula
	inx
	bra	_num0scn

_lnm0scn
	bita	#$F0
	bne	_num0scn
	inx
	anda	#$0F
	bne	_dig0scn
	rts

; digits a to screen at x
_num0scn
	psha
	lsra
	lsra
	lsra
	lsra
	bsr	_dig0scn
	inx
	pula
	anda	#$0F
	bra	_dig0scn

; digit a overlaid at screen at x
_dig0scn
	sts	tmpst1
	stx	tmpst3
	ldab	#$05
	mul
	ldx	#numbers
	abx
	txs
	ldx	tmpst3
	pula
	oraa	$00,x
	staa	$00,x
	pula
	oraa	$20,x
	staa	$20,x
	pula
	oraa	$40,x
	staa	$40,x
	pula
	oraa	$60,x
	staa	$60,x
	pula
	oraa	$80,x
	staa	$80,x
	lds	tmpst1
	rts

sclrc2	ldd	#$0000
	stab	$474D
	std	$474E
	stab	$476D
	std	$476E
	stab	$478D
	std	$478E
	stab	$47AD
	std	$47AE
	stab	$47CD
	std	$47CE
	rts

sclrc	ldd	#$0000
	std	$474C
	std	$474E
	std	$476C
	std	$476E
	std	$478C
	std	$478E
	std	$47AC
	std	$47AE
	std	$47CC
	std	$47CE
	rts

drawlives
	ldx	#$4009
	ldaa	nlives
	beq	_dlifer
	bpl	_dlives
_dlifer	rts
_dlives	bsr	_lifel
	deca
	beq	_dlifer
	bsr	_lifer
	deca
	beq	_dlifer
	bsr	_lifel
	deca
	beq	_dlifer
	bra	_lifer
_lifel	ldab	#0111q
	stab	$00,x
	stab	$80,x
	ldab	#1111q
	stab	$20,x
	stab	$60,x
	ldab	#1110q
	stab	$40,x
	ldab	#1000q
	stab	$21,x
	stab	$61,x
	rts
_lifer	ldab	#1011q
	stab	$21,x
	stab	$61,x
	ldab	#0011q
	stab	$41,x
	ldab	#0001q
	stab	$01,x
	stab	$81,x
	ldab	#1100q
	stab	$02,x
	stab	$82,x
	ldab	#1110q
	stab	$22,x
	stab	$62,x
	ldab	#1000q
	stab	$42,x
	inx
	inx
	inx
	rts

