	.module ghosts

; ENTRY
;   X - has ghost table
gdrawg	ldd	$02,x
	std	whorow
	ldd	$04,x
	std	whodir
gdraw	bsr	_gd1
;	@ LM 00 01 02 03 10 11 12 13 20 21 22 23 30 31 32 33
	.hex 00 00 07 01 04 04 05 03 07 05 06 06 01 03 02 02
_gd1
	pulx
	ldab	whodir		; transform direction xxyy to zzz
	abx			;
	ldab	,x		;
	stab	eyedir		;
	ldaa	whoclr		; draw monster bits (with color) into dp
	suba	#$04
	bhs	_gd2
	ldaa	#$03
_gd2
	staa	tmpst1
	ldab	#0011q
	mul
	stab	mn00
	ldaa	tmpst1
	ldab	#0111q
	mul
	stab	mn10
	stab	mn40
	stab	mn50
	ldaa	tmpst1
	ldab	#0100q
	mul
	stab	mn20
	stab	mn30
	ldaa	tmpst1
	ldab	#1110q
	mul
	stab	mn01
	ldaa	tmpst1
	ldab	#1111q
	mul
	stab	mn11
	stab	mn41
	stab	mn51
	ldaa	tmpst1
	ldab	#1001q
	mul
	stab	mn21
	stab	mn31
	ldab	whorow		; draw bottom of monster sheet
	eorb	whocol
	andb	#$02
	beq	_shtr
	ldaa	tmpst1
	ldab	#0110q
	mul
	stab	mn60
	ldaa	tmpst1
	ldab	#1101q
	mul
	stab	mn61
	bra	_eyes
_shtr	ldaa	tmpst1
	ldab	#0101q
	mul
	stab	mn60
	ldaa	tmpst1
	ldab	#1011q
	mul
	stab	mn61
_eyes	bsr	_geyes
	.quat	00010100	; UP
	.quat	00000000
	.quat	00010010	; UR
	.quat	00000000
	.quat	00010010	; RT
	.quat	00010010
	.quat	00000000	; DR
	.quat	00010010
	.quat	00000000	; DN
	.quat	00010100
	.quat	00000000	; DL
	.quat	00100100
	.quat	00100100	; LT
	.quat	00100100
	.quat	00100100	; UL
	.quat	00000000
_geyes
	pulx
	ldab	eyedir
	lslb
	lslb
	abx
	clra
	ldab	whoclr
	cmpb	#$02
	beq	_pupil
	inca
	cmpb	#$03
	beq	_pupil
	inca
	cmpb	#$04
	blo	_pupil		; was bls... want disembodied pupils
	inca
_pupil	staa	tmpst1
	ldab	0,x
	mul
	ldaa	tmpst1
	orab	mn20
	stab	mn20
	ldab	1,x
	mul
	ldaa	tmpst1
	orab	mn21
	stab	mn21
	ldab	2,x
	mul
	ldaa	tmpst1
	orab	mn30
	stab	mn30
	ldab	3,x
	mul
	orab	mn31
	stab	mn31
	bsr	_eballs		; now do the eyeballs
	.quat	00100010	; up
	.quat	00110110
	.quat	00100100	; ur
	.quat	00110110
	.quat	00100100	; rt
	.quat	00100100
	.quat	00110110	; dr
	.quat	00100100
	.quat	00110110	; dn
	.quat	00100010
	.quat	00110110	; dl
	.quat	00010010
	.quat	00010010	; lt
	.quat	00010010
	.quat	00010010	; ul
	.quat	00110110
_eballs
	pulx
	ldab	eyedir
	lslb
	lslb
	abx
	ldab	whoclr
	bitb	#$01
	bne	_mask		; green eyes for 1, 3, and 5
	ldd	0,x
	oraa	mn20
	orab	mn21
	std	mn20
	ldd	2,x
	oraa	mn30
	orab	mn31
	std	mn30
_mask	ldd	whorow
	jsr	rc2scn
	pshb
	psha
	pulx
	ldaa	whodir
	bita	#$02
	beq	_ga
	jmp	_lnr
_ga
	ldab	whocol
	bitb	#$02
	beq	_gb
	jmp	_pupndn
_gb
	bita	#$01
	bne	_dn
	bsr	_upndn
	ldd	whorow
	bita	#$03
	bne	_upa
	adda	#$04
	pshx
	jsr	rc2mazx
	ldab	$00,x
	andb	#$40
	pulx
	bra	_gup
_upa	clrb
_gup
	ldaa	$E0,x
	anda	#$C0
	std	$E0,x
	rts
_dn	ldd	whorow
	bita	#$03
	bne	_dna
	pshx
	suba	#$04
	jsr	rc2mazx
	ldab	$00,x
	andb	#$40
	pulx
	bra	_dnb
_dna	clrb
_dnb
	ldaa	$00,x
	anda	#$C0
	std	$00,x
_upndn	ldab	#$20
	abx
	ldaa	$00,x
	anda	#$C0
	oraa	mn00
	ldab	mn01
	std	$00,x
	ldaa	$20,x
	anda	#$C0
	oraa	mn10
	ldab	mn11
	std	$20,x
	ldaa	$40,x
	anda	#$C0
	oraa	mn20
	ldab	mn21
	std	$40,x
	ldaa	$60,x
	anda	#$C0
	oraa	mn30
	ldab	mn31
	std	$60,x
	ldaa	$80,x
	anda	#$C0
	oraa	mn40
	ldab	mn41
	std	$80,x
	ldaa	$A0,x
	anda	#$C0
	oraa	mn50
	ldab	mn51
	std	$A0,x
	ldaa	$C0,x
	anda	#$C0
	oraa	mn60
	ldab	mn61
	std	$C0,x
	rts
_pupndn	psha
	ldaa	#$01
	staa	whodir
	ldd	#30000000q
	std	mn03
	std	mn13
	std	mn23
	std	mn33
	std	mn43
	std	mn53
	std	mn63
	ldaa	#0333q
	bsr	_lnrp
	pula
	staa	whodir
	bita	#$01
	bne	_pdn
	ldd	whorow
	cmpa	#$18
	beq	_pclose
	ldd	#$FC0F
	anda	$E0,x
	staa	$E0,x
	clr	$E1,x
	andb	$E2,x
	stab	$E2,x
	rts
_pdn	ldaa	whorow
	cmpa	#$28
	beq	_pclose
	pshx
	pula
	pulb
	subd	#$20
	pshb
	psha
	pulx
	ldd	#$FC0F
	anda	$00,x
	staa	$00,x
	clr	$01,x
	andb	$02,x
	stab	$02,x
	rts
_pclose	ldd	#22211111q
	std	$450D
	ldaa	#1122q
	staa	$450F
	rts
_lnr	ldd	#30000033q
	std	mn03
	ldd	#00000003q
	std	mn13
	std	mn23
	std	mn33
	std	mn43
	std	mn53
	std	mn63
	ldd	#33330000q
_lnrp	staa	mn05
	staa	mn15
	staa	mn25
	staa	mn35
	staa	mn45
	staa	mn55
	staa	mn65
	stab	mn02
	stab	mn12
	stab	mn22
	stab	mn32
	stab	mn42
	stab	mn52
	stab	mn62
	ldaa	whodir
	bita	#$01
	bne	_gnor
	jsr	_rorm
_gnor
	ldaa	whocol
	anda	#$03
	staa	>tmpcnt
	beq	_ltnrt
_rloop	jsr	_ror
	dec	tmpcnt
	bne	_rloop
_ltnrt	ldab	#$20
	abx
	ldab	whocol
	cmpb	#$6C
	bls	_gnotun
	jmp	_tunnel
_gnotun
	ldaa	whodir
	anda	#$01
	bne	_gnoa		; go if going right
	addb	#$08
_gnoa
	subb	#$04
	pshx
	ldaa	whorow
	jsr	rc2mazx
	ldab	,x
	pulx
	andb	#$C0
	bpl	_gnoclr
	clrb
_gnoclr
	ldaa	whodir
	anda	#$01
	beq	_gdo32
	orab	mn30
	stab	mn30
	bra	_drlr
_gdo32
	orab	mn32
	stab	mn32
_drlr	ldd	$00,x
	anda	mn03
	andb	mn04
	oraa	mn00
	orab	mn01
	std	$00,x
	ldaa	$02,x
	anda	mn05
	oraa	mn02
	staa	$02,x
	ldd	$20,x
	anda	mn13
	andb	mn14
	oraa	mn10
	orab	mn11
	std	$20,x
	ldaa	$22,x
	anda	mn15
	oraa	mn12
	staa	$22,x
	ldd	$40,x
	anda	mn23
	andb	mn24
	oraa	mn20
	orab	mn21
	std	$40,x
	ldaa	$42,x
	anda	mn25
	oraa	mn22
	staa	$42,x
	ldd	$60,x
	anda	mn33
	andb	mn34
	oraa	mn30
	orab	mn31
	std	$60,x
	ldaa	$62,x
	anda	mn35
	oraa	mn32
	staa	$62,x
	ldd	$80,x
	anda	mn43
	andb	mn44
	oraa	mn40
	orab	mn41
	std	$80,x
	ldaa	$82,x
	anda	mn45
	oraa	mn42
	staa	$82,x
	ldd	$A0,x
	anda	mn53
	andb	mn54
	oraa	mn50
	orab	mn51
	std	$A0,x
	ldaa	$A2,x
	anda	mn55
	oraa	mn52
	staa	$A2,x
	ldd	$C0,x
	anda	mn63
	andb	mn64
	oraa	mn60
	orab	mn61
	std	$C0,x
	ldaa	$C2,x
	anda	mn65
	oraa	mn62
	staa	$C2,x
	rts
_ror	bsr	_ror1
_ror1
	ldd	mn00
	lsrd
	std	mn00
	ror	mn02
	ldd	mn10
	lsrd
	std	mn10
	ror	mn12
	ldd	mn20
	lsrd
	std	mn20
	ror	mn22
	ldd	mn30
	lsrd
	std	mn30
	ror	mn32
	ldd	mn40
	lsrd
	std	mn40
	ror	mn42
	ldd	mn50
	lsrd
	std	mn50
	ror	mn52
	ldd	mn60
	lsrd
	std	mn60
	ror	mn62
_rorp	sec
	ldd	mn03
	rora
	rorb
	std	mn03
	ror	mn05
	sec
	ldd	mn13
	rora
	rorb
	std	mn13
	ror	mn15
	sec
	ldd	mn23
	rora
	rorb
	std	mn23
	ror	mn25
	sec
	ldd	mn33
	rora
	rorb
	std	mn33
	ror	mn35
	sec
	ldd	mn43
	rora
	rorb
	std	mn43
	ror	mn45
	sec
	ldd	mn53
	rora
	rorb
	std	mn53
	ror	mn55
	sec
	ldd	mn63
	rora
	rorb
	std	mn63
	ror	mn65
	rts
_rorm
	bsr	_rorm1
_rorm1	bsr	_rorp
	bra	_rorp

_tunnel
	cmpb	#$70
	bhs	_tnn2
	ldd	$00,x
	anda	mn03
	andb	mn04
	oraa	mn00
	orab	mn01
	std	$00,x
	ldd	$20,x
	anda	mn13
	andb	mn14
	oraa	mn10
	orab	mn11
	std	$20,x
	ldd	$40,x
	anda	mn23
	andb	mn24
	oraa	mn20
	orab	mn21
	std	$40,x
	ldd	$60,x
	anda	mn33
	andb	mn34
	oraa	mn30
	orab	mn31
	std	$60,x
	ldd	$80,x
	anda	mn43
	andb	mn44
	oraa	mn40
	orab	mn41
	std	$80,x
	ldd	$A0,x
	anda	mn53
	andb	mn54
	oraa	mn50
	orab	mn51
	std	$A0,x
	ldd	$C0,x
	anda	mn63
	andb	mn64
	oraa	mn60
	orab	mn61
	std	$C0,x
	rts
_tnn2	cmpb	#$74
	bhs	_tnn3
	ldaa	$00,x
	anda	mn03
	oraa	mn00
	staa	$00,x
	ldaa	$20,x
	anda	mn13
	oraa	mn10
	staa	$20,x
	ldaa	$40,x
	anda	mn23
	oraa	mn20
	staa	$40,x
	ldaa	$60,x
	anda	mn33
	oraa	mn30
	staa	$60,x
	ldaa	$80,x
	anda	mn43
	oraa	mn40
	staa	$80,x
	ldaa	$A0,x
	anda	mn53
	oraa	mn50
	staa	$A0,x
	ldaa	$C0,x
	anda	mn63
	oraa	mn60
	staa	$C0,x
_erexit	rts
_tnn3	ldx	#$45A0
	cmpb	#$78
	blo	_erexit
	cmpb	#$7C
	bhs	_tnn4
	ldaa	$00,x
	anda	mn05
	oraa	mn02
	staa	$00,x
	ldaa	$20,x
	anda	mn15
	oraa	mn12
	staa	$20,x
	ldaa	$40,x
	anda	mn25
	oraa	mn22
	staa	$40,x
	ldaa	$60,x
	anda	mn35
	oraa	mn32
	staa	$60,x
	ldaa	$80,x
	anda	mn45
	oraa	mn42
	staa	$80,x
	ldaa	$A0,x
	anda	mn55
	oraa	mn52
	staa	$A0,x
	ldaa	$C0,x
	anda	mn65
	oraa	mn62
	staa	$C0,x
	rts
_tnn4	ldd	$00,x
	anda	mn04
	oraa	mn01
	andb	mn05
	orab	mn02
	std	$00,x
	ldd	$20,x
	anda	mn14
	oraa	mn11
	andb	mn15
	orab	mn12
	std	$20,x
	ldd	$40,x
	anda	mn24
	oraa	mn21
	andb	mn25
	orab	mn22
	std	$40,x
	ldd	$60,x
	anda	mn34
	oraa	mn31
	andb	mn35
	orab	mn32
	std	$60,x
	ldd	$80,x
	anda	mn44
	oraa	mn41
	andb	mn45
	orab	mn42
	std	$80,x
	ldd	$A0,x
	anda	mn54
	oraa	mn51
	andb	mn55
	orab	mn52
	std	$A0,x
	ldd	$C0,x
	anda	mn64
	oraa	mn61
	andb	mn65
	orab	mn62
	std	$C0,x
	rts

;TGHOST ghost table offsets:
; 00: CT	- move when 0.
; 01: ID	- ghost ID	(8=BLINKY 4=PINKY 2=INKY 1=CLYDE)
; 02: SLOC	- screen location of ghost
; 04: DIR	- direction (looking) (moving) if sign bit set, then monster is cornering
; 05: COLOR	- "color" of ghost (0=BLINKY 1=PINKY 2=INKY 3=CLYDE 4=EYES 5=WHITE 6=BLUE)
; 06: TRACKER	- address of ghost tracking routine
; 08: CRNR	- home corner of ghost (BLINKY=NE, PINKY=NW, INKY=SE, CLYDE=SW)
; 0A: ESC count - ghost can leave pen when zero
; 0B: ESC reset - # of bounces off top pen before ghost can leave


;goghost
	dec	$00,x		; currently dead code
	beq	goghst		; sped up by decrementing in caller via
	rts			; extended addressing rather than indexed
goghst	stx	tghost
	ldd	$02,x		; get row,col
	std	whorow		;
	jsr	rc2maz		; get mazeloc
	std	wholoc		;
	ldd	$04,x		; get dir,color
	anda	#$0F		; mask off turn info
	std	whodir		;
	ldaa	$01,x		; get ghost id
	staa	mn00		;
	coma			; clear ghost off board
	ldx	wholoc		;
	anda	,x		;
	staa	,x		;
	ldaa	whodir		; now get new row and col
	jsr	applyd
	jsr	rc2maz
	std	wholoc
	ldx	wholoc
	ldaa	,x		; put ghost back on board
	oraa	mn00
	staa	,x
	jsr	gdraw		; draw the ghost
	ldx	tghost
	ldd	whorow		; save the new location
	std	$02,x
	ldaa	cntnrm		; normal ghost speed
	staa	$00,x		;
	ldaa	whoclr		; get ghost color
	cmpa	#$04
	bls	_gnotblue	; skip if not blue
	ldaa	cntblu		; reset with blue speed
	staa	$00,x		;
_gnotblue
	ldd	whorow		; check if in tunnel
	jsr	_slwdwn
	bne	_gnotunn
	ldaa	cnttnl		; reset counter with tunnel speed
	staa	$00,x
_gnotunn
	ldaa	whoclr		; check if eaten
	cmpa	#$04
	bne	_gnoreset
	ldaa	#$60		; reset counter with eaten speed
	staa	$00,x
_gnoreset
	ldd	whorow

; now do monster movement

	cmpb	#$36		; check if center column
	bne	_sidesq		; try the sides...
	cmpa	#$18		; above monster pen?
	beq	_toppen		; go if so
	blo	_rts		; leave if above pen
	cmpa	#$28
	bhi	_rts		; leave if below pen
	ldab	whodir
	bitb	#$02		; inside pen and just moved there from left or right?
	beq	_gnotup		; skip if not...
	clrb			; so go up
	bra	_dir
_gnotup
	cmpa	#$28		; at bottom of pen?
	bne	_addorq		; no - see if time to leave?
	ldab	whoclr		; check color
	cmpb	#$04
	bne	_goup
	ldab	$01,x		; check ghost
	ldaa	#$04
_getclr	deca
	lsrb
	bne	_getclr
	cmpa	#$02
	bhs	_olorr
	staa	$05,x		; its binky or pinky so store color
_goup	clrb			; now go up
	bra	_dir
_addorq	cmpa	#$20		; test door of pen...
	bne	_rts		; leave if not there
	ldaa	whoclr		; test color
	cmpa	#$04		; check if bodied
	beq	_rts		; leave if not
	tst	$0A,x
	bne	_dwn		; always go dn...
	rts			; keep going up and get out
_toppen	ldaa	whoclr
	cmpa	#$04
	beq	_dwn		; eyes above pen - go down.
	ldaa	$04,x
	bita	#$02
	bne	_rts
	ldab	#$0F		; normal/blue monster just escaped pen - go right.
	bra	_dir
_dwn	ldab	#$05		; eyes above pen - go down.
_dir	stab	$04,x
_rts	rts

_sidesq	cmpa	#$20
	blo	_dpntq
	cmpa	#$28
	bhi	_dpntq
	cmpb	#$2E
	beq	_ckpen1
	blo	_dpntq
	cmpb	#$3E
	bhi	_dpntq
	bne	_rts
_ckpen1	cmpa	#$20
	beq	_dwn
	cmpa	#$28
	blo	_retcq
	ldaa	whoclr
	cmpa	#$04
	bne	_goup
	lsrb			; eyes touched walls
	lsrb			; re-animate "blue" or "orange" ghost
	lsrb
	lsrb
	stab	$05,x
	bra	_goup

_retcq	tst	$0A,x		; is it time to return to center column?
	bne	_rts		; no?
	lsrb			; go toward center
	lsrb
	lsrb
	lsrb
	tba
	eora	#$01
	bra	_olorr

_dpntq	bita	#$03		; leave if not at decision point
	bne	_rts1
	bitb	#$03
	beq	_gnorts
_rts1
	rts
_gnorts
	ldd	$04,x		; get direction info
	bpl	_mpen		; not turning...
	anda	#$0C		; straighten out
	lsra
	lsra
_olorr	ldab	#$05
	mul
	stab	$04,x
_rts2	rts

_mpen	jsr	_inpenq
	beq	_rts2
	ldab	whoclr
	cmpb	#$04
	blo	_normal		; normal monsters
	bhi	_random		; blue/yellow monsters
	ldd	#$1836		; target monster pen
	bra	_gdest		; go to destination

_nrteeq	ldd	whorow
	cmpa	#$18
	beq	_nrtee1
	cmpa	#$4C
	bne	_nrrts
_nrtee1	cmpb	#$2C
	blo	_nrrts
	cmpb	#$40
	bhi	_nrrts
	cmpa	whorow		; set z bit.
_nrrts	rts

_random	ldd	whorow
	std	tmpst1
	ldab	rndnum		; random number generator
	ldaa	#$05		; rng = 5*rng+1 mod 256
	mul			; has full period length (256)
	incb
	stab	rndnum
	ldx	#$E000		; use it to look up a byte in e000-e0ff
	abx
	ldab	,x
	andb	#$03		; now get a direction
	lslb
	ldx	#offsts4	; get the offset for it
	abx
	ldd	,x
	addd	tmpst1		; add it to the target
	bra	_gdest

_normal	; normal monsters (d holds dir,color info)
	bsr	_nrteeq
	bne	_elroyq
	ldaa	whodir
	jsr	_trydir		; try to go straight if near center tees
	ldx	tghost
	staa	$04,x
	rts

_elroyq	tst	$05,x		; see if we have a 'cruise elroy'
	bne	_nrmmov		; leave if we're not binky
	ldaa	pltlft		; are we cruisin?
	cmpa	pltelr
	blo	_celroy		; yes we are.  attack at warp speed.
	; normal movement
_nrmmov	tst	eatcnt
	bne	_corner
	tst	cntcnr
	beq	_attack
_corner	ldd	$08,x
	bra	_gdest
_celroy	lsla
	cmpa	pltelr
	blo	_celry2
	ldaa	cntel1
	bra	_celry3
_celry2	ldaa	cntel2
_celry3	staa	$00,x
_attack	ldd	pacrow
	std	tmpst1		; target in tmpst1
	ldx	$06,x
	jsr	$00,x
_gdest	std	tmpst1
	ldaa	whodir
	jsr	applyd4		; update to next position
	bsr	gtarget
	ldx	tghost
	staa	$04,x
	rts

; blinky
gtrymv1	rts			; target pac-man position

; pinky
gtrymv2	ldab	pacdir
	lslb
	ldx	#offstsg
	abx
	ldd	,x
	adda	tmpst1
	addb	tmpst2
	andb	#$7F		; target now 4 pellets in front of pac-man
	rts

; inky
gtrymv3	ldab	pacdir
	lslb
	ldx	#offsts8
	abx
	ldd	,x
	adda	tmpst1
	addb	tmpst2		; target is now 2 pellets in front of pac-man
	lsla
	lslb
	suba	whorow
	subb	whocol		; target is now offset by binky's position
	andb	#$7F
	rts

; clyde
gtrymv4	suba	whorow
	subb	whocol		; check distance
	jsr	_getdis
	subd	#$0400		; are we within eight dots?
	bhs	_gok
	ldd	#$4000		; too close, retreat to corner
	rts
_gok
	ldd	tmpst1
	rts

gtarget	ldaa	whodir
	eora	#$01
	anda	#$03
	staa	tmpcnt		; tmpcnt has reverse dir.
	staa	eyedir
	ldd	#$FFFF
	std	bstdis		; namco pacman checks in order rt dn lt up.
	bsr	_gtgt
	.byte	$03,$00,$04	; right
	.byte	$01,$04,$00	; down
	.byte	$02,$00,$FC	; left
	.byte	$00,$FC,$00	; up
_gtgt
	pulx
	ldd	#$0403		; 4 is count of directions.  3-length of direction table
_trynx	bsr	_tryx
	abx
	deca
	bne	_trynx
	ldaa	eyedir
	ldab	tmpcnt
	eorb	#$01
	lsla
	lsla
	aba
	rts

_tryx	pshx
	pshb
	psha
	ldaa	,x
	cmpa	tmpcnt
	beq	 _tryrts
	ldd	1,x
	adda	whorow
	addb	whocol
	andb	#$7F
	jsr	 rc2mazx
	tst	,x
	bmi	 _tryrts
	tsx
	ldx	2,x
	psha
	ldaa	,x
	eora	#$01
	cmpa	tmpcnt
	beq	_gnoset
	ldaa	eyedir
	oraa	#$20
	staa	eyedir
_gnoset
	pula
	suba	tmpst1
	subb	tmpst2
	bsr	_getdis
	subd	bstdis
	bhi	_tryrts
	addd	bstdis
	std	bstdis
	ldaa	eyedir
	anda	#$20
	oraa	,x
	staa	eyedir
_tryrts	pula
	pulb
	pulx
	rts

_getdis	tsta			; compute ACCD = ACCA^2 + ACCB^2
	bpl	_gposa
	nega
_gposa
	tstb
	bpl	_gposb
	negb
_gposb
	pshb
	tab
	mul
	std	tmpst3
	pulb
	tba
	mul
	addd	tmpst3
	rts

_slwdwn	cmpa	#$24
	bne	_srts
	cmpb	#$0C
	bhs	_gzing
_slwyes	clrb
	rts
_gzing
	cmpb	#$64
	bhs	_slwyes
_srts	rts

gmknrm	ldab	cntpnr
	clra
	std	bpcspd
	ldx	#ghost1
	bsr	_mknrmg
	ldaa	#$01
	ldx	#ghost2
	bsr	_mknrmg
	ldaa	#$02
	ldx	#ghost3
	bsr	_mknrmg
	ldaa	#$03
	ldx	#ghost4
_mknrmg	ldab	$05,x
	cmpb	#$04
	beq	_mknrmr
	staa	$05,x
	jsr	goghst
_mknrmr	rts

gflash	ldx	#ghost1
	bsr	_flashg
	ldx	#ghost2
	bsr	_flashg
	ldx	#ghost3
	bsr	_flashg
	ldx	#ghost4
_flashg	ldaa	$05,x
	cmpa	#$04
	bls	_frts
	eora	#$03
	staa	$05,x
_frts	rts

geatpill
	ldaa	cnteat
	staa	eatcnt
	ldx	#ghost1
	bsr	_blueq
	ldx	#ghost2
	bsr	_blueq
	ldx	#ghost3
	bsr	_blueq
	ldx	#ghost4
	bsr	_blueq
	ldd	#$0050
	jsr	splusd
	ldaa	#$01
	staa	eatscr
	clra
	rts
_blueq	bsr	_revgst
	tst	eatcnt
	beq	_pillrt
	ldab	cntpbl
	clra
	std	bpcspd
	ldx	tghost
	ldaa	whoclr
	cmpa	#$04
	beq	_pillrt
	ldaa	#$06
	staa	$05,x
_pillrt	rts

gallrev	ldx	#ghost1
	bsr	_revgst
	ldx	#ghost2
	bsr	_revgst
	ldx	#ghost3
	bsr	_revgst
	ldx	#ghost4
_revgst	stx	tghost
	ldd	$04,x
	std	whodir
	ldd	$02,x
	std	whorow
	jsr	_inpenq
	beq	_revrt1
	bsr	_tryrev
	ldx	tghost
	staa	$04,x
_revrt1	rts

_tryrev	ldaa	whodir
	eora	#$01
_trydir	anda	#$03
	staa	whodir
	bsr	_checkd
	bpl	_dontp
	ldaa	whodir		; can't recover last dir
	eora	#$02		; try another?
	staa	whodir
	bsr	_checkd
	bpl	_dontp
	ldaa	whodir
	eora	#$01
	staa	whodir
	bsr	_checkd
	bpl	_dontp
	jsr	panic		; this shouldn't happen
_dontp	bsr	_update
	ldaa	whodir
	bsr	_check4
	bmi	_cantgo
	ldaa	whodir
	ldab	#$05
	mul
	tba
	rts
_cantgo	ldaa	whodir
	eora	#$02
	staa	eyedir
	bsr	_check4
	bpl	_gotdir
	ldaa	eyedir
	eora	#$01
	bra	_gkeepeye
_gotdir	ldaa	eyedir
_gkeepeye
	lsla
	lsla
	adda	whodir
	eora	#$80
	rts

_checkd	ldx	#offstsp
	bra	_gcheck
_check4	ldx	#offsts4
_gcheck
	tab
	lslb
	abx
	ldd	whorow
	adda	$00,x
	addb	$01,x
	andb	#$7F
	jsr	rc2mazx
	tst	,x
	rts

_update	ldx	#offsts1
	ldab	whodir
	lslb
	abx
	ldd	whorow
_ck4ag	adda	$00,x
	addb	$01,x
	bita	#$03
	bne	_ck4ag
	bitb	#$03
	bne	_ck4ag
	andb	#$7F
	std	whorow
	rts

;_panic
	ldd	whorow
	jsr	panic
	ldd	whodir
	jsr	panic
	ldaa	#$2C
	staa	$BFFF
_p1	ldaa	,x
	eora	#$FF
	staa	,x
	bra	_p1

gtagged	bita	#$08
	beq	_tag1
	ldx	#ghost1
	bsr	_tag
_tag1
	bita	#$04
	beq	_tag2
	ldx	#ghost2
	bsr	_tag
_tag2
	bita	#$02
	beq	_tag3
	ldx	#ghost3
	bsr	_tag
_tag3
	bita	#$01
	beq	_tag4
	ldx	#ghost4
	bsr	_tag
_tag4
	rts

_tag	ldab	$05,x
	cmpb	#$04
	blo	geaten
	beq	_trts
	ldab	#$04		; eat ghost
	stab	$05,x
	ldab	$0B,x
	stab	$0A,x
	psha
	jsr	sclrc2
	ldaa	eatscr
	adda	eatscr
	daa
	staa	eatscr
	clrb
	jsr	sshowc
	ldaa	eatscr
	clrb
	jsr	splusd
	jsr	smunch
	jsr	sclrc
	clr	cntglt
	pula
_trts	rts

geaten	pulx
	ldaa	#$06
	bsr	gdelay
	jsr	mredraw
	tst	gameon
	bne	_gkillpac
	jsr	wgameover
_gkillpac
	jsr	killpac
gdeclv	dec	nlives
	bmi	_ggover
	.byte	$7E		; jmp
gretry	.word	retry
_ggover
	jsr	wgameover
	ldaa	#$10
	bsr	gdelay
;	inc	panicb
	jmp	restart

gdelay	ldx	#$0000
_delay	dex
	bne	_delay
	deca
	bne	_delay
	rts

gpenck	ldx	#ghost1
	bsr	_penckg
	ldx	#ghost2
	bsr	_penckg
	ldx	#ghost3
	bsr	_penckg
	ldx	#ghost4
	bsr	_penckg
	rts

_penckg	tst	$0A,x
	beq	_penrt
	dec	$0A,x
	pulx
_penrt	rts

_inpenq	ldd	whorow
	cmpa	#$18
	blo	_inrts
	bne	_inpen1
	cmpa	#$36
	bne	_inrts
_inpen1	cmpa	#$2C
	bhi	_inrts
	cmpb	#$2C
	blo	_inrts
	cmpb	#$40
	bhi	_inrts
	cmpa	whorow		; in pen, so set z code.
_inrts	rts
