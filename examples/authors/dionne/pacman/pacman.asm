	.org $80

mn00	.block	1	; 80 7x6 monster drawing scratch table
mn01	.block	1	; 81
mn02	.block	1	; 82
mn03	.block	1	; 83
mn04	.block	1	; 84
mn05	.block	1	; 85
mn10	.block	1	; 86
mn11	.block	1	; 87
mn12	.block	1	; 88
mn13	.block	1	; 89
mn14	.block	1	; 8A
mn15	.block	1	; 8B
mn20	.block	1	; 8C
mn21	.block	1	; 8D
mn22	.block	1	; 8E
mn23	.block	1	; 8F
mn24	.block	1	; 90
mn25	.block	1	; 91
mn30	.block	1	; 92
mn31	.block	1	; 93
mn32	.block	1	; 94
mn33	.block	1	; 95
mn34	.block	1	; 96
mn35	.block	1	; 97
mn40	.block	1	; 98
mn41	.block	1	; 99
mn42	.block	1	; 9A
mn43	.block	1	; 9B
mn44	.block	1	; 9C
mn45	.block	1	; 9D
mn50	.block	1	; 9E
mn51	.block	1	; 9F
mn52	.block	1	; A0
mn53	.block	1	; A1
mn54	.block	1	; A2
mn55	.block	1	; A3
mn60	.block	1	; A4
mn61	.block	1	; A5
mn62	.block	1	; A6
mn63	.block	1	; A7
mn64	.block	1	; A8
mn65	.block	1	; A9
pacrow	.block	1	; AA
paccol	.block	1	; AB
pacdir	.block	1	; AC
keydir	.block	1	; AD
whomsk	.block	1	; AE
whoms1	.block	1	; AF
wholoc	.block	2	; B0
whoscn	.block	2	; B2
whorow	.block	1	; B4
whocol	.block	1	; B5
whodir	.block	1	; B6
whoclr	.block	1	; B7
tmpcnt	.block	1	; B8
paccrn	.block	2	; B9 pac corner (erroneously 2 wide)
eyedir	.block	1	; BB
cntmr1	.block	1	; BC
cntmr2	.block	1	; BD
cntpw1	.block	1	; BE
cntpw2	.block	1	; BF
tmpst1	.block	1	; C0
tmpst2	.block	1	; C1
tmpst3	.block	2	; C2
bstdis	.block	2	; C4
pltlft	.block	1	; C6
pltelr	.block	1	; C7
pwrvis	.block	1	; C8
sndchr	.block	1	; C9
sndcnt	.block	1	; CA
sndval	.block	1	; CB
cntnrm	.block	1	; CC
cntblu	.block	1	; CD
cnttnl	.block	1	; CE
cntel1	.block	1	; CF
cntel2	.block	1	; D0
cntglt	.block	1	; D1
cntcnr	.block	1	; D2
cnteat	.block	1	; D3
tghost	.block	2	; D4
score3	.block	1	; D6
score2	.block	1	; D7
score1	.block	1	; D8
score0	.block	1	; D9
lvlcnt	.block	1	; DA
frtlvl	.block	1	; DB
frtval	.block	2	; DC
eatscr	.block	1	; DE
eatcnt	.block	1	; DF
rndnum	.block	2	; E0
bpcspd	.block	2	; E2
nlives	.block	1	; E4
xtrlif	.block	1	; E5
cntatk	.block	2	; E6
gameon	.block	1	; E8
cntpnr	.block	1	; E9
	.block	6	; erroneously skipped EA-EF
cntpbl	.block	1	; F0
cntfrt	.block	1	; F1
sndloc	.block	2	; F2
sndfrt	.block	2	; F4
msprow	.block	1	; F6
mspcol	.block	1	; F7
mspdir	.block	1	; F8

ghost1	.equ	$4EC0
ghost2	.equ	$4ED0
ghost3	.equ	$4EE0
ghost4	.equ	$4EF0

	.org	$5000
	.module pacman
	jsr	clrscn
restart
	clr	gameon
	jsr	credits
newgame
	clr	lvlcnt
	tst	gameon
	bne	_init
	ldaa	#$FF
	bra	_skip
_init	jsr	sclear
	ldaa	#2
_skip	staa	nlives
	staa	xtrlif
	jmp	startlv

_fruits	.word $0100, $0300, $0500, $0700, $1000, $2000, $3000, $5000
	.word fscherry, fsstraw, fspeach, fsapple, fspine, fsgalax, fsbell, fskey

	;	PNPB 1S2N GNGB GT (pac norm/blue, elroy 1/2, ghost norm/blue/tunnel)
_speeds	.hex	8072 8089 89CDFF	;cherry
	.hex	726C 6C72 78BAE4	;mid-frui
	.hex	6666 6266 6CABCD	;apple
	.hex	7272 6266 6CE4CD	;9th key

	;	FRSP CEBT (fruit, speed, cruise elroy count, blue time)
levels	.hex	0000 14FF ;cherry (1)
	.hex	0101 1ED7 ;straw  (2)
	; chase [act 1 they meet]
	.hex	0201 28AC ;orange (3)
	.hex	0201 2881 ;orange (4) pretz
	.hex	0302 2856 ;apple  (5)
	; pin [act 2 the chase]
	.hex	0302 32D7 ;apple  (6) pear
	.hex	0402 3256 ;pine   (7) banana
	.hex	0402 3256 ;pine   (8)
	.hex	0502 3C2B ;gala   (9)
	; patched [act 3 junior]
	.hex	0502 3CD7 ;gala  (10)
	.hex	0602 3C56 ;bell  (11)
	.hex	0602 502B ;bell  (12)
	.hex	0702 502B ;key1  (13)
	; patched [act 3 junior]
	.hex	0702 5081 ;key2  (14)
	.hex	0702 642B ;key3  (15)
	.hex	0702 642B ;key4  (16)
	.hex	0702 6400 ;key5  (17)
	; patched [act 3 junior]
	.hex	0702 642B ;key6  (18)
	.hex	0702 7800 ;key7  (19)
	.hex	0702 7800 ;key8  (20)
	.hex	0703 7800 ;key9  (21)


	;	where	ct+id  sloc   dr&c   tracker  crnr   escape
_ghosts	.word	ghost1, $0008, $1835, $0F00, gtrymv1, $0870, $0000
	.word	ghost2, $0004, $2336, $0501, gtrymv2, $0800, $0000
	.word	ghost3, $0002, $252E, $0002, gtrymv3, $4070, $8080
	.word	ghost4, $0001, $253E, $0003, gtrymv4, $4000, $A0A0

newlevel
	ldab	lvlcnt
	incb
	stab	lvlcnt
	subb	#2
	beq	_interm
	blo	startlv
	incb
	bitb	#$03
	bne	startlv
	lsrb
	cmpb	#$08
	bhs	startlv
_interm	pshb
	jsr	clrmaz
	jsr	clearborders
	ldx	#jinterm
	stx	sndloc
	pulb
	ldx	#intermissions
	abx
	ldx	,x
	jmp	,x
startlv	jsr	drawpellets
	jsr	drawmaze
	jsr	storeborders
	jsr	clearbox
	jsr	drawmaze
	jsr	storepellets
	ldx	#levels
	ldaa	#4
	ldab	lvlcnt
	cmpb	#$14
	bls	_stmul
	ldab	#$14
_stmul	mul
	abx

	ldd	2,x
	staa	pltelr
	stab	cnteat

	ldd	,x
	staa	frtlvl
	ldaa	#$07
	mul
	ldx	#_speeds
	abx
	ldd	,x
	std	cntpnr ;nrm blu
	ldd	2,x
	std	cntel1
	ldd	4,x
	std	cntnrm ;nrm blu
	ldaa	6,x
	staa	cnttnl

	ldab	frtlvl
	ldx	#_fruits
	lslb
	abx
	ldd	,x
	std	frtval
	ldd	$10,x
	std	sndfrt

retry
	clra
	clrb
	std	cntatk
	staa	cntfrt
	staa	cntglt
	staa	eatcnt
	ldab	cntpnr
	std	bpcspd
	ldab	#$FF
	std	rndnum
	stab	cntcnr
	jsr	fclear
	jsr	mredraw
	ldx	#$4C36
	stx	pacrow
	ldaa	#2
	staa	pacdir
	jsr	drawwho

	sts	tmpst1
	ldaa	#4
	staa	tmpst3
	ldx	#_ghosts
	txs
_init1	pulx
	ldab	#$0C
_init2	pula
	staa	,x
	inx
	decb
	bne	_init2
	dec	tmpst3
	bne	_init1
	lds	tmpst1

	;namco escape counts: 0 %30 %60, 0 0 %50, 0, 0, 0
	;namco unknown id:  %240 or %180 on 1st apple (escape speed?)

	ldaa	lvlcnt
	beq	_clrcnts
	cmpa	#1
	beq	_justg3
	ldx	#ghost4
	clr	$0A,x
	clr	$0B,x
_justg3	ldx	#ghost3
	clr	$0A,x
	clr	$0B,x

_clrcnts
	ldaa	cntnrm
	staa	ghost1
	staa	ghost2
	staa	ghost3
	staa	ghost4

	ldx	#1
	stx	cntmr1
	ldx	#$0101
	stx	cntpw1
	ldd	#$2410 ;2c10
	std	sndchr
	clr	sndval
	tst	gameon
	bne	_lready
	jsr	wgameover
	bra	_qsong
_lready	jsr	wready
_qsong	jsr	jingle
	jsr	wornot

	ldx	#fspellet
	stx	sndloc

_mainloop
	dec	cntmr2
	bne	_doghst
	ldx	bpcspd
	stx	cntmr1
	jsr	kpause
_again	jsr	gomrpac
	tst	paccrn
	beq	_doghst
	dec	paccrn
	bra	_again
_doghst	dec	ghost4
	bne	_g4
	ldx	#ghost4
	jsr	goghst
_g4
	bsr	_sndchk

	dec	ghost3
	bne	_g3
	ldx	#ghost3
	jsr	goghst
_g3
	dec	ghost2
	bne	_g2
	ldx	#ghost2
	jsr	goghst
_g2
	bsr	_sndchk

	dec	ghost1
	bne	_ckpwr
	ldx	#ghost1
	jsr	goghst

_ckpwr	dec	cntpw2
	bne	_sndch1
	dec	cntpw1
	bne	_sndch1
	jsr	flashpower
	ldx	#$0800
	stx	cntpw1
	bra	_mainloop

_sndch1	bsr	_sndchk
	bra	_mainloop

_sndchk	dec	sndcnt
	beq	_sndck1
	rts
_sndck1	tst	sndval
	bne	_sndrtn
	rts

_sndrtn	ldaa	sndchr
	eora	gameon
	ldx	sndloc
	inx
	stx	sndloc
	ldab	,x
	beq	_sndclr

	std	sndchr
	staa	$BFFF
	rts

_sndclr	clr	sndval
	ldx	#fspellet
	stx	sndloc
	rts
