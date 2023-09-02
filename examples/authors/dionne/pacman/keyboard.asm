	.module keyboard
; bits 02:
;
; FFFFEDB7
; EDB7FFFF
; --------+
; @ABCDEFG|BIT0]01
; HIJKLMNO|BIT1]02
; PQRSTUVW|BIT2]04 READ $BFFF
; XYZ...es|BIT3]08
; 01234567|BIT4]10
; 89:;,-./|BIT5]20

; pr/c out|BIT0]
; c.b....s|BIT1]02 READ $03
; rs232 in|BIT2]
; rs232 in|BIT3]
; cass. in|BIT4]

; ldaa #$7F  SHIFT
; ldaa #$FB  BREAK
; ldaa #$FE  CNTRL
; staa 02
; ldaa $03   ~02 IF PRESSED


mrky	bsr	_mkey
	.word	$7F04, $FB08, $FD01, $F704
;msky
	bsr	_mkey
	.word	$FE04, $BF20, $EF02, $7F20
_mkey	pulx
	clra
_nxtdir staa	keydir
	ldd	,x
	bsr	_tst
	beq	_rts
	inx
	inx
	ldaa	keydir
	inca
	cmpa	#$04
	bne	_nxtdir
	staa	keydir
_rts	rts
_tst	staa	$02
	bitb	$BFFF
	rts

mrkey	tst	gameon
	bne	mrky
	bsr	kany
	bne	_manual
	jmp	autopilot
_manual
	pulx
	pulx
	ldaa	#$80
	staa	gameon
	jmp	newgame

kany	ldaa	#$38
	staa	$02
	ldaa	$BFFF
	coma
	bne	_anyrt
	clra
	staa	$02
	ldaa	$BFFF
	coma
	anda	#$F7
	bne	_anyrt
	ldaa	$03
	coma
	anda	#$02
_anyrt	rts

kpause	ldd	#$027F
	stab	$02
	bita	$03
	bne	_rts
	ldab	#$FE
	stab	$02
	bita	$03
	bne	_rts

	ldd	#$02FD
	stab	$02
	bita	$BFFF
	beq	_inv

	ldd	#$04BF
	stab	$02
	bita	$BFFF
	beq	_vul

	ldd	#$04FE
	stab	$02
	bita	$BFFF
	beq	_pat

	ldaa	#$FB
	staa	$02
	ldaa	$BFFF
	bita	#$04
	beq	_adv
	ldaa	$03
	bita	#$02
	bne	_rts
_loop	ldaa	$03
	bita	#$02
	beq	_loop
	rts

knone	bsr	kany
	bne	knone
	rts

_adv	jmp	newlevel	; allgone
_inv	ldaa	$39
	bra	_vul1
_vul	ldaa	$38
_vul1
	staa	geaten
	ldaa	#$7A		; dec
	staa	gdeclv
	ldd	#retry
	std	gretry
	rts

_pat	ldaa	#$7D		; tst
	staa	gdeclv
	ldd	#startlv
	std	gretry
	rts

kbreak	ldaa	#$FB
	staa	$02
	ldaa	$03
	bita	#$02
	rts
