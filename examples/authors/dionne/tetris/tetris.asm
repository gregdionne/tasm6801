	.org	$80

PLOC	.block	2	;$80
PSHAPE	.block	1	;$82
PFLIP	.block	1	;$83
COLOR01	.block	2	;$84
COLOR23	.block	2	;$86
OFFSET	.block	2	;$88
KEYSTR	.block	1	;$8A
KEYCOM	.block	1	;$8B
TMPCNT	.block	1	;$8C
FSAVE	.block	1	;$8D
LSAVE	.block	2	;$8E
LVLTIM	.block	2	;$90
LVLCMP	.block	2	;$92
TMPLD1	.block	2	;$94
TMPLD2	.block	2	;$96
	.block	2	;$98 (unused)
NSHAPE	.block	1	;$9A
LVLCNT	.block	1	;$9B
HGTCNT	.block	1	;$9C
SBYTE	.block	1	;$9D
SOUND	.block	2	;$9E
SOUNDE	.block	2	;$A0
SLID	.block	2	;$A2

NLOC	.equ	$4004
TLOC	.equ	$3FB2

	.module tetris
	.org	$4C00

_newscn	ldaa	#$64
	staa	$BFFF
	ldx	#$4000
	ldd	#$0000
_newnxt	std	,x
	inx
	inx
	cpx	#$4C00
	bne	_newnxt
	ldaa	#&2222
	ldx	#$4010
_box1	staa	,x
	inx
	cpx	#$401A
	bne	_box1
	ldx	#$4BB0
_box2	staa	,x
	inx
	cpx	#$4BBA
	bne	_box2
	ldx	#$400F
	ldaa	#&0002
_box3	ldab	#&2000
	staa	$00,x
	stab	$0B,x
	ldab	#$20
	abx
	cpx	#$4BB0
	blo	_box3
	ldx	#$4002
	ldd	#$F5AF
	std	$01,x
	std	$04,x
	ldd	#$5AC0
	staa	$03,x
	std	$06,x
	stab	$27,x
	stab	$C7,x
	stab	$E7,x
	ldd	#$0A04
	staa	$00,x
	stab	$20,x
	stab	$40,x
	stab	$E0,x
	ldd	#$0C04
	staa	$60,x
	staa	$80,x
	stab	$A0,x
	stab	$C0,x
	ldd	#$4080
	staa	$47,x
	staa	$67,x
	stab	$87,x
	stab	$A7,x
	ldx	#$4102
	staa	$07,x
	staa	$27,x
	stab	$47,x
	stab	$67,x
	staa	$C7,x
	staa	$E7,x
	ldd	#$040C
	staa	$00,x
	stab	$20,x
	stab	$40,x
	stab	$E0,x
	staa	$A0,x
	staa	$C0,x
	ldd	#$08C0
	staa	$60,x
	staa	$80,x
	stab	$87,x
	stab	$A7,x
	ldx	#$4202
	ldd	#$0E97
	std	$00,x
	stab	$04,x
	ldd	#$E97E
	std	$02,x
	std	$05,x
	ldd	#$8000
	std	$07,x
	jsr	drtext
	jsr	clscore
	clra
	jsr	lvl0
	clr	NSHAPE
	clr	PSHAPE
	jsr	_getnew

_newone	jsr	_getnew
	jsr	_tstloc
	beq	_newdrw
	jmp	_gameover
_newdrw	jsr	_drwloc

_nxtone	jsr	_keyscn
	jsr	_mvdwn
	beq	_nxtone
	jsr	dorndm
	tst	SLID
	beq	_nxtbad
	jsr	doslide
_nxtbad	jsr	_ckifbad
	bhs	_nxtchk
	jsr	douhoh
_nxtchk	bsr	_cklines
	beq	_newone
	jsr	adjstatus
	ldaa	#$08
	staa	TMPCNT
_nxtflp	bsr	_fplines
	ldx	#$3000
_waste1	dex
	bne	_waste1
	dec	TMPCNT
	bne	_nxtflp
	bsr	_rmlines
	bra	_newone

_cklines
	ldx	#$4030
	clr	TMPCNT
_cknlin	ldd	#$010A
_cknloc	tst	,x
	bne	_cknl1
	clra
_cknl1	inx
	decb
	bne	_cknloc
	adda	TMPCNT
	staa	TMPCNT
	ldab	#$76
	abx
	cpx	#$4BB0
	bne	_cknlin
	tsta
	rts

_fplines
	ldx	#$4030
_fpnln1	stx	PLOC
	ldd	#$010A
_fpnlc1	tst	$20,x
	bne	_fpnxl1
	clra
_fpnxl1	inx
	decb
	bne	_fpnlc1
	tsta
	beq	_fpnli2
	LDX	PLOC
	ldab	#$0A
_fpnlc2	com	$00,x
	com	$20,x
	com	$40,x
	com	$60,x
	inx
	decb
	bne	_fpnlc2
_fpnli2	ldab	#$76
	abx
	cpx	#$4BB0
	bne	_fpnln1
	rts

_rmlines
	ldx	#$4B30
_rmnln1	ldd	#$010A
_rmnlc1	tst	$00,x
	bne	_rmnl1
	clra
_rmnl1	inx
	decb
	bne	_rmnlc1
	bsr	_rmdex
	beq	_rtopln
	tsta
	beq	_rmnln1
_rmnln2	ldab	#$0A
_rmnlc2	ldaa	$00,x
	staa	$80,x
	ldaa	$20,x
	staa	$A0,x
	ldaa	$40,x
	staa	$C0,x
	ldaa	$60,x
	staa	$E0,x
	inx
	decb
	bne	_rmnlc2
	bsr	_rmdex
	bne	_rmnln2
	ldaa	#$01
_rtopln	ldab	#$0A
_rmntop	clr	$00,x
	clr	$20,x
	clr	$40,x
	clr	$60,x
	inx
	decb
	bne	_rmntop
	tsta
	bne	_rmlines
	rts

_rmdex	stx	PLOC
	psha
	ldd	PLOC
	subd	#$008A
	std	PLOC
	pula
	ldx	PLOC
	cpx	#$4030
	rts

_getnew	ldaa	NSHAPE
	staa	PSHAPE
	ldd	#NLOC
	std	PLOC
	clr	PFLIP
	jsr	_clrloc
	ldx	#$E000
_getr7	ldd	$09
	abx
	ldaa	,x
	anda	#$07
	beq	 _getr7
	deca
	staa	PSHAPE
	jsr	_drwloc
	ldaa	PSHAPE
	ldab	NSHAPE
	stab	PSHAPE
	staa	NSHAPE
	ldd	#TLOC
	std	PLOC
	rts

_mvdwn	jsr	_clrloc
	ldd	PLOC
	std	LSAVE
	addd	#$0080
	std	PLOC
	jsr	_tstloc
	beq	 _mvdraw
_mvstop	ldd	LSAVE
	std	PLOC
	ldaa	#$01
_mvdraw	tpa
	psha
	jsr	_drwloc
	pula
	tap
	rts

_ckifbad
	ldd	PLOC
	std	LSAVE
	addd	#$0080
	std	PLOC
	jsr	_tstloc
	psha
	ldd	LSAVE
	std	PLOC
	pula
	cmpa	#$03
	rts

_keystrobe
	psha
	tpa
	lsra
	anda	#$02
	oraa	KEYSTR
	lsla
	staa	KEYSTR
	pula
	rts

_keyscn	clr	SLID
	ldd	LVLTIM
	std	LVLCMP
_kloop	ldaa	KEYSTR
	coma
	staa	KEYCOM
	clr	KEYSTR
	ldaa	#$7F
	staa	$02
	ldaa	$BFFF
	bita	#$08		;SPC
	bsr	_keystrobe
	bita	#$04		;W
	bsr	_keystrobe
	ldaa	#$FB
	staa	$02
	ldaa	$BFFF
	bita	#$08		;Z
	bsr	_keystrobe
	ldaa	#$FD
	staa	$02
	ldaa	$BFFF
	bita	#$01		;A
	bsr	_keystrobe
	ldaa	#$F7
	staa	$02
	ldaa	$BFFF
	bita	#$04
	bsr	_keystrobe	;S
	ldaa	#$EF
	staa	$02
	ldaa	$BFFF
	bita	#$02
	bsr	_keystrobe	;L
	ldaa	KEYSTR
	anda	KEYCOM
	staa	KEYCOM

	ldx	PLOC
	stx	LSAVE
	ldab	PFLIP
	stab	FSAVE

	bita	#$40		;check w
	beq	 _kynxt1
	jsr	_clrloc
	ldaa	PFLIP
	deca
	bra	_kyftst
_kynxt1	bita	#$20		;check Z
	beq	 _kynxt2
	jsr	_clrloc
	ldaa	PFLIP
	inca
_kyftst	anda	#$03
	staa	PFLIP
	jsr	_tstloc
	beq	_keydrw
	ldab	FSAVE
	stab	PFLIP
	bra	_keydrw
_kynxt2	bita	#$10		;check A
	beq	 _kynxt3
	inc	SLID
	jsr	_clrloc
	ldd	PLOC
	subd	#$0001
	bra	_kyptst
_kynxt3	bita	#$08		;check S
	beq	 _kynxt4
	inc	SLID
	jsr	_clrloc
	ldd	PLOC
	addd	#$0001
_kyptst	std	PLOC
	jsr	_tstloc
	beq	_keydrw
	ldd	LSAVE
	std	PLOC
_keydrw	jsr	_drwloc
	bra	_keyrts
_kynxt4 bita	#$80		;check ' '
	beq	_kynxt5
	jsr	_clrloc
	clr	SLID
	clr	HGTCNT
_dagain	inc	HGTCNT
	ldd	PLOC
	std	LSAVE
	addd	#$0080
	std	PLOC
	jsr	_tstloc
	beq	_dagain
	jsr	_mvstop
	jsr	_cklines
	bne	_dbonus
	rts
_dbonus	ldaa	HGTCNT
	deca
	clrb
	pshb
	pshb
	pshb
	pshb
_dscr1	suba	#$0A
	incb
	bhs	_dscr1
	adda	#$0A
	decb
	pshb
	psha
	jmp	adjscr
_kynxt5	bita	#$04		;check L
	beq	 _keyrts
	jsr	levelup
_keyrts	ldx	LVLCMP
	dex
	stx	LVLCMP
	bne	_keylp
	rts
_keylp	jmp	_kloop

_shapes	.hex 40414243 024282C2 40414243 024282C2 ; l
	.hex 41428182 41428182 41428182 41428182 ; o
	.hex 41808182 418182C1 808182C1 418081C1 ; y
	.hex 40414280 00014181 02404142 01418182 ;
	.hex 40414282 01418081 00404142 01024181 ;
	.hex 40418182 418180C0 40418182 418180C0
	.hex 41428081 408081C1 41428081 408081C1

_colors	.quat 2323 3232 2323 3232
	.quat 1111 1221 1221 1111
	.quat 1111 1331 1331 1111
	.quat 2222 2112 2112 2222
	.quat 2222 2332 2332 2222
	.quat 3333 3113 3113 3333
	.quat 3333 3223 3223 3333

_icolor	ldab	PSHAPE
	lslb
	lslb
	ldx	#_colors
	abx
	ldd	$00,x
	std	COLOR01
	ldd	$02,x
	std	COLOR23

_getshp	ldab	PSHAPE
	lslb
	lslb
	addb	PFLIP
	lslb
	lslb
	ldx	#_shapes
	abx
	stx	>OFFSET
	rts

_drwloc	bsr	_icolor
	clrb
_drwnxt	stab	TMPCNT
	ldx	OFFSET
	abx
	ldab	,x
	ldx	PLOC
	abx
	andb	#$FC
	abx
	ldd	COLOR01
	staa	$00,x
	stab	$20,x
	ldd	COLOR23
	staa	$40,x
	stab	$60,x
	ldab	TMPCNT
	incb
	cmpb	#$04
	blo	_drwnxt
	rts

_clrloc	bsr	_icolor
	clra
	clrb
_clrnxt	stab	TMPCNT
	ldx	OFFSET
	abx
	ldab	,x
	ldx	PLOC
	abx
	andb	#$FC
	abx
	staa	$00,x
	staa	$20,x
	staa	$40,x
	staa	$60,x
	ldab	TMPCNT
	incb
	cmpb	#$04
	blo	 _clrnxt
	rts

_tstloc	bsr	_getshp
	clra
	clrb
_tstnxt	stab	TMPCNT
	ldx	OFFSET
	abx
	ldab	,x
	ldx	PLOC
	abx
	andb	#$FC
	abx
	tst	,x
	beq	 _tempty
	inca
_tempty	ldab	TMPCNT
	incb
	cmpb	#$04
	blo	_tstnxt
	tsta
	rts

_gameover
	jsr	donice
	ldx	#$4030
	stx	TMPLD1
	ldx	#$4B70
	stx	TMPLD2
_game2	ldab	#$0A
	stab	TMPCNT
	ldx	#_colors
	ldd	$00,x
_game1	ldx	TMPLD1
	staa	$00,x
	stab	$20,x
	inx
	stx	TMPLD1
	ldx	TMPLD2
	staa	$00,x
	stab	$20,x
	inx
	stx	TMPLD2
	dec	TMPCNT
	bne	_game1
	ldab	#$36
	ldx	TMPLD1
	abx
	stx	TMPLD1
	ldd	TMPLD2
	subd	#$004A
	std	TMPLD2
	ldx	#$4800
_game3	dex
	bne	_game3
	subd	TMPLD1
	bhs	_game2
	jsr	drgover
_game4	bsr	_spaceq
	beq	 _game4
_game5	bsr	_spaceq
	bne	_game5
_game6	bsr	_spaceq
	beq	 _game6
	jmp	_newscn
_spaceq	ldaa	#$7F
	staa	$02
	ldaa	$BFFF
	bita	#$08		;SPC
	rts
