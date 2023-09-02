	.module	maze

_fruits	.quat	00000000	; cherry
	.quat	00000220
	.quat	00002020
	.quat	01330020
	.quat	03331330
	.quat	03303330
	.quat	00003300

	.quat	00022000	; strawberry
	.quat	03323300
	.quat	33131330
	.quat	31333130
	.quat	03313300
	.quat	00333000
	.quat	00030000

	.quat	00000000	; peach
	.quat	00002000
	.quat	00112200
	.quat	01112100
	.quat	01311110
	.quat	01111110
	.quat	00111100

	.quat	00020200	; apple
	.quat	03332200
	.quat	33332330
	.quat	33133330
	.quat	33333330
	.quat	33333330
	.quat	03303300

	.quat	00200000	; pineapple
	.quat	00022200
	.quat	00002000
	.quat	00021200
	.quat	00212120
	.quat	00121210
	.quat	00012100

	.quat	20030020	; galaxian flagship
	.quat	21333120
	.quat	21131120
	.quat	02111200
	.quat	00212000
	.quat	00010000
	.quat	00010000

	.quat	00011000	; bell
	.quat	00122100
	.quat	01211110
	.quat	01211110
	.quat	01211110
	.quat	01111110
	.quat	01221210

	.quat	00000000	; key
	.quat	00000000
	.quat	22200000
	.quat	20211110
	.quat	20201010
	.quat	22200010
	.quat	00000000

_heart	.quat	00000000	; heart
	.quat	03303300
	.quat	33333330
	.quat	33333330
	.quat	03333300
	.quat	00333000
	.quat	00030000

fdheart	ldaa	#$07
	staa	>tmpcnt
	ldx	#_heart
	bsr	_dhrt1
	clr	$4DAD
	rts

_dhrt1	sts	tmpst1
	txs
	ldx	#$452D
	bra	_draw1

fdraw	ldx	#_fruits
	ldaa	#$07
	staa	tmpcnt
	lsla
	ldab	frtlvl
	mul
	abx
	sts	tmpst1
	txs
	ldx	#$472D
_draw1	pulb
	pshb
	clra
	lsld
	lsld
	oraa	$00,x
	staa	$00,x
	pula
	pulb
	lsld
	lsld
	oraa	$01,x
	orab	$02,x
	std	$01,x
	ldab	#$20
	abx
	dec	tmpcnt
	bne	_draw1
	lds	tmpst1
	ldaa	$4DAD
	oraa	#$40
	staa	$4DAD
	rts

fclear	ldd	#$0000
	staa	$472D
	std	$472E
	staa	$474D
	std	$474E
	staa	$476D
	std	$476E
	staa	$478D
	std	$478E
	staa	$47AD
	std	$47AE
	staa	$47CD
	std	$47CE
	staa	$47ED
	std	$47EE
	ldaa	$4DAD
	anda	#$BF
	staa	$4DAD
	rts

_side	tst	gameon
	bne	_fon
	rts
_fon
	sts	tmpst1
	ldaa	lvlcnt
	suba	#$0B
	bpl	_fnoclr
	clra
_fnoclr
	ldx	#$401E
_sidef	stx	whoscn
	staa	tmpcnt
	cmpa	lvlcnt
	bls	_ftogo
	lds	tmpst1
	rts
_ftogo
	cmpa	#$14
	bls	_fok
	ldaa	#$14
_fok
	ldab	#$04
	mul
	ldx	#levels
	abx
	ldab	$00,x
	ldaa	#$0E
	mul
	ldx	#_fruits
	abx
	txs
	ldaa	#$07
	ldx	whoscn
_siden	pulb
	stab	$00,x
	pulb
	stab	$01,x
	ldab	#$20
	abx
	deca
	bne	_siden
	abx
	ldaa	tmpcnt
	inca
	bra	_sidef

_pill1	.equ	$4C83
_pill2	.equ	$4C98
_pill3	.equ	$4E43
_pill4	.equ	$4E58

_pill1a	.equ	$42E3
_pill1b	.equ	$4303
_pill1c	.equ	$4323
_pill2a	.equ	$42F8
_pill2b	.equ	$4318
_pill2c	.equ	$4338
_pill3a	.equ	$49E3
_pill3b	.equ	$4A03
_pill3c	.equ	$4A23
_pill4a	.equ	$49F8
_pill4b	.equ	$4A18
_pill4c	.equ	$4A38

drawpellets
	ldaa	#$24		; $2C for debug
	staa	$BFFF
	jsr	clrmaz
	jsr	_tiledot
	clra
	clrb
	std	$4A09
	clr	$4A0B
	std	$4A12
	clr	$4A14
	rts

clearbox
	ldx	#$4388
	ldaa	#$0B
_drp4	ldab	#$0E
_drp5	clr	,x
	inx
	decb
	bne	_drp5
	ldab	#$72
	abx
	deca
	bne	_drp4
	clra
	clrb
	std	$4600
	std	$4602
	std	$461A
	std	$461C
	std	$4B0E
	rts

clearborders
	ldx	#$4C00
_clrbrd	clr	$00,x
	inx
	cpx	#$4EC0
	bne	_clrbrd
	rts

storeborders
	sts	$80
	lds	#$4100
	ldx	#$4C00
_store1	ldab	#$20
_store2	pula
	clr	,x
	cmpa	#$40
	beq	_snodec
	dec	,x
_snodec
	inx
	decb
	bne	_store2
	sts	$82
	ldd	$82
	addd	#$0060
	std	$82
	lds	$82
	cpx	#$4EC0
	bne	_store1
	clr	$4D5D
	clr	$4D5E
	clr	$4D5F
	lds	$80
	rts

storepellets
	clr	pltlft
	sts	tmpst1
	lds	#$4100
	ldx	#$4C00
_store3	ldab	#$1E
_store4	pula
	cmpa	#$40
	bne	_store5
	staa	,x
	inc	pltlft
_store5	inx
	decb
	bne	_store4
	sts	tmpst3
	ldd	tmpst3
	addd	#$0062
	std	tmpst3
	lds	tmpst3
	inx
	inx
	cpx	#$4EC0
	bne	_store3
	lds	tmpst1
	clra
	staa	pwrvis
	rts

flashpower
	com	pwrvis
	bne	_fnoclr1
	jmp	_clrpwr
_fnoclr1
	ldaa	_pill1
	bita	#$40
	beq	_fp2
	ldd	_pill1a
	oraa	#$01
	orab	#$50
	std	_pill1a
	ldd	_pill1b
	oraa	#$01
	orab	#$50
	std	_pill1b
	ldd	_pill1c
	oraa	#$01
	orab	#$50
	std	_pill1c
_fp2
	ldaa	_pill2
	bita	#$40
	beq	_fp3
	ldd	_pill2a
	oraa	#$01
	orab	#$50
	std	_pill2a
	ldd	_pill2b
	oraa	#$01
	orab	#$50
	std	_pill2b
	ldd	_pill2c
	oraa	#$01
	orab	#$50
	std	_pill2c
_fp3
	ldaa	_pill3
	bita	#$40
	beq	_fp4
	ldd	_pill3a
	oraa	#$01
	orab	#$50
	std	_pill3a
	ldd	_pill3b
	oraa	#$01
	orab	#$50
	std	_pill3b
	ldd	_pill3c
	oraa	#$01
	orab	#$50
	std	_pill3c
_fp4
	ldaa	_pill4
	bita	#$40
	beq	_frts
	ldd	_pill4a
	oraa	#$01
	orab	#$50
	std	_pill4a
	ldd	_pill4b
	oraa	#$01
	orab	#$50
	std	_pill4b
	ldd	_pill4c
	oraa	#$01
	orab	#$50
	std	_pill4c
_frts
	rts

_clrpwr	ldaa	_pill1
	bita	#$40
	beq	_cp2
	ldd	_pill1a
	anda	#$FE
	andb	#$AF
	std	_pill1a
	ldd	_pill1b
	anda	#$FE
	andb	#$AF
	std	_pill1b
	ldd	_pill1c
	anda	#$FE
	andb	#$AF
	std	_pill1c
_cp2
	ldaa	_pill2
	bita	#$40
	beq	_cp3
	ldd	_pill2a
	anda	#$FE
	andb	#$AF
	std	_pill2a
	ldd	_pill2b
	anda	#$FE
	andb	#$AF
	std	_pill2b
	ldd	_pill2c
	anda	#$FE
	andb	#$AF
	std	_pill2c
_cp3
	ldaa	_pill3
	bita	#$40
	beq	_cp4
	ldd	_pill3a
	anda	#$FE
	andb	#$AF
	std	_pill3a
	ldd	_pill3b
	anda	#$FE
	andb	#$AF
	std	_pill3b
	ldd	_pill3c
	anda	#$FE
	andb	#$AF
	std	_pill3c
_cp4
	ldaa	_pill4
	bita	#$40
	beq	_crts
	ldd	_pill4a
	anda	#$FE
	andb	#$AF
	std	_pill4a
	ldd	_pill4b
	anda	#$FE
	andb	#$AF
	std	_pill4b
	ldd	_pill4c
	anda	#$FE
	andb	#$AF
	std	_pill4c
_crts
	rts

pwpillq
	cpx	#_pill1
	beq	_eatit
	cpx	#_pill2
	beq	_eatit
	cpx	#_pill3
	beq	_eatit
	cpx	#_pill4
	beq	_eatit
	rts
_eatit	jmp	geatpill

;	   00001111222233
;	   048C048C048C04

;	  0123456789ABCDE
;4C00 4100+--------------00
;4C20 4180|**************01 00
;4C40 4200|*+---+*++*+---02 04
;4C60 4280|*+---+*||*+--+03 08
;4C80 4300|***X***||****|04 0C
;4CA0 4380|*+---+*|+--+ |05 10
;4CC0 4400|*+---+*|+--+ +06 14
;4CE0 4480|*******||	 07 18
;4D00 4500+--+*++*|| +---08 1C
;4D20 4580---+*||*++ |	 09 20
;4D40 4600    *||*   |	 0A 24
;4D60 4680---+*||*++ |	 0B 28
;4D80 4700+--+*++*|| +---0C 2C
;4DA0 4780|*******||	 0D 30
;4DC0 4800|*+---+*|| +---0E 34
;4DE0 4880|*+---+*++ +--+0F 38
;4E00 4900|*************|10 3C
;4E20 4980|*++*++*+---+*|11 40
;4E40 4A00|*||x||*|   |*|12 44
;4E60 4A80|*++*||*+---+*+13 48
;4E80 4B00|****||******* 14 4C
;4EA0 4B80+----++--------15 50
;	  DCBA9876543210F

;	   66665555444433
;	   C840C840C840C8
_borders
	.hex	06 0009 0308 0000 1D
	.hex	0A 000B 030C 0015 0511 0615 17
	.hex	04 0E08 0B0C 12
	.hex	06 0F06 0E03 0B02 12
	.hex	06 0F13 0E0F 0B0E 12
	.hex	09 0802 0905 0C06 0909 0802
	.hex	05 080B 090F 080B
	.hex	05 0811 0C13 0811
	.hex	05 0202 0603 0202
	.hex	05 0205 0606 0205
	.hex	05 020E 060F 020E
	.hex	05 0211 0313 0211
	.hex	05 0508 060C 0508
	.hex	00

_mzptr		.equ $80
_lftrg		.equ $82
_rgtrg		.equ $84
_cntdn		.equ $86
_nblks		.equ $87

drawmaze
	ldx	#_borders
	bsr	_drm2
	ldd	#$AA80
	staa	$4580
	stab	$459D
	staa	$4680
	stab	$469D
	staa	$450B
	stab	$4512
	staa	$470B
	stab	$4712
	ldd	#$A955
	std	$450D
	ldaa	#$5A
	staa	$450F
_drts	rts
_drm1	ldx	_mzptr
	inx
	inx
_drm2	stx	_mzptr
	ldaa	,x
	beq	_drts
	staa	_cntdn
	ldab	2,x
	ldaa	#$80
	mul
	addb	1,x
	adca	#$41
	std	_lftrg
	eorb	#$1F
	subb	#$02
	std	_rgtrg
_drrl	ldx	_mzptr
	inx
	stx	_mzptr
	dec	 _cntdn
	beq	 _drm1
	ldx	_mzptr
	ldab	2,x
	subb	,x
	blo	_drih
	ldx	_rgtrg
	bsr	_drlt
	stx	_rgtrg
	ldx	_lftrg
	bsr	_drrt
	stx	_lftrg
	bra	_drud
_drih	negb
	ldx	_lftrg
	bsr	_drlt
	stx	_lftrg
	ldx	_rgtrg
	bsr	_drrt
	stx	_rgtrg
_drud	ldx	_mzptr
	inx
	stx	_mzptr
	dec	_cntdn
	beq	_drm1
	ldab	2,x
	subb	,x
	blo	_driv
	ldx	_lftrg
	bsr	_drdn
	stx	_lftrg
	ldx	_rgtrg
	bsr	_drdn
	stx	_rgtrg
	bra	_drrl
_driv	negb
	ldx	_lftrg
	bsr	_drup
	stx	_lftrg
	ldx	_rgtrg
	bsr	_drup
	stx	_rgtrg
	bra	_drrl
_drrt	pshb
	ldaa	#$2A
	staa	,x
	ldaa	#$AA
	bra	_dr1
_drr1	staa	,x
_dr1
	inx
	decb
	bne	_drr1
	clr	,x
	pulb
	rts
_drlt	pshb
	ldaa	#$AA
	clr	,x
_drl1	dex
	staa	,x
	decb
	bne	_drl1
	ldaa	#$2A
	staa	,x
	pulb
	rts
_drdn	pshb
	stab	_nblks
	ldd	#$8020
	bra	_dd1
_drd1	staa	,x
_dd1
	abx
	staa	,x
	abx
	staa	,x
	abx
	staa	,x
	abx
	dec	_nblks
	bne	_drd1
	pulb
	rts
_drup	pshb
	pshx
	tsx
	ldaa	#$80
	mul
	subd	,x
	coma
	comb
	std	,x
	pulx
	inx
	pulb
	pshx
	bsr	_drdn

	pulx
	rts

mredraw	tst gameon
	beq	_mred2
	jsr	clrscn
	bra	_mred1
_mred2	jsr	clrmaz
_mred1	jsr	drawmaze
	ldx	#$4C00
_mrdrw3	ldaa	$00,x
	bmi	_mrdrw2
	anda	#$40
	staa	$00,x		; remove pac and monsters (but leave pellets and fruit)
	beq	_mrdrw2
	cpx	#$4DAD
	beq	_mrdrw2		; skip fruit
	stx	tmpst1
	ldd	tmpst1
	subd	#$4C00
	lsld
	lsld
	lsld
	lsla
	lsla
	lsrd
	lsrd
	lsrd
	addd	#$4101
	std	tmpst3
	ldaa	#$40
	ldx	tmpst3
	staa	$00,x
	ldx	tmpst1
_mrdrw2	inx
	cpx	#$4EC0
	bne	_mrdrw3
	clr	pwrvis
	jsr	flashpower
	tst	cntfrt
	beq	_mrdrw4
	jsr	fdraw
_mrdrw4	jsr	_side
	jsr	sshow
	jmp	drawlives

clrscn	sts	tmpst1		; for everyone
	lds	#$0000
	ldx	#$4000
	ldab	#$02
_csloop	sts	,x
	abx
	cpx	#$4C00
	bne	_csloop
	lds	tmpst1
	rts

clrmz	sts	tmpst1		; for everyone
	lds	#$0000
	ldx	#$4C00
	ldab	#$02
_cmloop	sts	,x
	abx
	cpx	#$5000
	bne	_cmloop
	lds	tmpst1
	rts

_tiledot
	sts	tmpst1
	lds	#$4040
	ldx	#$4100
	clra
_tiled0	ldab	#$02
_tiled1	inca
	bita	#$0F
	beq	_tiled2
	sts	,x
	abx
	bra	_tiled1
_tiled2	ldab	#$62
	abx
	cpx	#$4C00
	bne	_tiled0
	lds	tmpst1
	rts

clrmaz	sts	tmpst1		; for intermission
	lds	#$0000
	ldx	#$4000
	ldd	#$0002
_cmaz1	inca
	bita	#$0F
	beq	_cmaz2
	sts	,x
	abx
	bra	_cmaz1
_cmaz2	abx
	cpx	#$4C00
	bne	_cmaz1
	lds	tmpst1
	rts

