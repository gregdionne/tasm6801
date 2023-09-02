	.module letters
_symbols
	.quat	0000		; !"#$%&'()*+,-./
	.quat	0000
	.quat	0000
	.quat	0000
	.quat	0000

	.quat	0010		; !
	.quat	0010
	.quat	0010
	.quat	0000
	.quat	0010

	.quat	0101		; "
	.quat	0101
	.quat	0000
	.quat	0000
	.quat	0000

	.quat	0111		; #
	.quat	0111
	.quat	0111
	.quat	0111
	.quat	0111

	.fill	5		; $
	.fill	5		; %
	.fill	5		; &

	.quat	0010		; '
	.quat	0010
	.quat	0000
	.quat	0000
	.quat	0000

	.quat	0111		; (
	.quat	1101
	.quat	1011
	.quat	1101
	.quat	0111

	.quat	0000		; )
	.quat	1000
	.quat	1000
	.quat	1000
	.quat	0000

	.quat	0000		; *
	.quat	0111
	.quat	0111
	.quat	0111
	.quat	0000

	.quat	0000		; +
	.quat	0000
	.quat	0010
	.quat	0000
	.quat	0000

	.quat	0000		; ,
	.quat	0000
	.quat	0000
	.quat	0010
	.quat	0100

	.quat	0000		; -
	.quat	0000
	.quat	0111
	.quat	0000
	.quat	0000

	.quat	0000		; .
	.quat	0000
	.quat	0000
	.quat	0000
	.quat	0010

	.quat	0001		; /
	.quat	0001
	.quat	0010
	.quat	0100
	.quat	0100

numbers	.quat	0010
	.quat	0101
	.quat	0101
	.quat	0101
	.quat	0010

	.quat	0010
	.quat	0010
	.quat	0010
	.quat	0010
	.quat	0010

	.quat	0111
	.quat	0001
	.quat	0111
	.quat	0100
	.quat	0111

	.quat	0110
	.quat	0001
	.quat	0010
	.quat	0001
	.quat	0110

	.quat	0101
	.quat	0101
	.quat	0111
	.quat	0001
	.quat	0001

	.quat	0111
	.quat	0100
	.quat	0111
	.quat	0001
	.quat	0111

	.quat	0011
	.quat	0100
	.quat	0110
	.quat	0101
	.quat	0010

	.quat	0111
	.quat	0001
	.quat	0001
	.quat	0001
	.quat	0001

	.quat	0010
	.quat	0101
	.quat	0010
	.quat	0101
	.quat	0010

	.quat	0010
	.quat	0101
	.quat	0011
	.quat	0001
	.quat	0010
wchar	ldd	#$0401
	ldx	#$4126
	jsr	_text
	.text 	"CHARACTER / NICKNAME", 0
	rts

_letters
	.quat	0010
	.quat	0101
	.quat	0111
	.quat	0101
	.quat	0101

	.quat	0110
	.quat	0101
	.quat	0110
	.quat	0101
	.quat	0110

	.quat	0011
	.quat	0100
	.quat	0100
	.quat	0100
	.quat	0011

	.quat	0110
	.quat	0101
	.quat	0101
	.quat	0101
	.quat	0110

	.quat	0111
	.quat	0100
	.quat	0110
	.quat	0100
	.quat	0111

	.quat	0111
	.quat	0100
	.quat	0110
	.quat	0100
	.quat	0100

	.quat	0011
	.quat	0100
	.quat	0101
	.quat	0101
	.quat	0010

	.quat	0101
	.quat	0101
	.quat	0111
	.quat	0101
	.quat	0101

	.quat	0111
	.quat	0010
	.quat	0010
	.quat	0010
	.quat	0111

	.quat	0001
	.quat	0001
	.quat	0101
	.quat	0101
	.quat	0010

	.quat	0101
	.quat	0110
	.quat	0100
	.quat	0110
	.quat	0101

	.quat	0100
	.quat	0100
	.quat	0100
	.quat	0100
	.quat	0111

	.quat	0101
	.quat	0111
	.quat	0111
	.quat	0101
	.quat	0101

	.quat	0101
	.quat	0111
	.quat	0111
	.quat	0111
	.quat	0101

	.quat	0010
	.quat	0101
	.quat	0101
	.quat	0101
	.quat	0010

	.quat	0110
	.quat	0101
	.quat	0110
	.quat	0100
	.quat	0100

	.quat	0010
	.quat	0101
	.quat	0101
	.quat	0111
	.quat	0010

	.quat	0110
	.quat	0101
	.quat	0110
	.quat	0101
	.quat	0101

	.quat	0011
	.quat	0100
	.quat	0010
	.quat	0001
	.quat	0110

	.quat	0111
	.quat	0010
	.quat	0010
	.quat	0010
	.quat	0010

	.quat	0101
	.quat	0101
	.quat	0101
	.quat	0101
	.quat	0010

	.quat	0101
	.quat	0101
	.quat	0101
	.quat	0010
	.quat	0010

	.quat	0101
	.quat	0101
	.quat	0111
	.quat	0111
	.quat	0101

	.quat	0101
	.quat	0101
	.quat	0010
	.quat	0101
	.quat	0101

	.quat	0101
	.quat	0101
	.quat	0010
	.quat	0010
	.quat	0010

	.quat	0111
	.quat	0001
	.quat	0010
	.quat	0100
	.quat	0111


wshadow	ldd     #$0402
	ldx	#$4246
	jsr	_text
	.text	"-SHADOW", 0
	rts
wspeedy	ldd     #$0402
	ldx	#$4386
	jsr	_text
	.text	"-SPEEDY", 0
	rts
wbashfl	ldd     #$0402
	ldx	#$44C6
	jsr	_text
	.text	"-BASHFUL", 0
	rts
wpokey	ldd	#$0402
	ldx	#$4606
	jsr	_text
	.text	"-POKEY", 0
	rts


wblinky	ldd     #$0402
	ldx	#$4251
	jsr	_text
	.text	"\"BLINKY\"", 0
	rts
wpinky	ldd	#$0402
	ldx	#$4391
	jsr	_text
	.text	"\"PINKY\"", 0
	rts
winky	ldd	#$0402
	ldx	#$44D1
	jsr	_text
	.text	"\"INKY\"", 0
	rts
wclyde	ldd	#$0402
	ldx	#$4611
	jsr	_text
	.text	"\"CLYDE\"", 0
	rts
wcopyrt	ldd	#$0100
	ldx	#$4B46
	jsr	_text
	.text	"()", 0
	ldd	#$0101
	ldx	#$4B49
	jsr	_text
	.text	"2006 GREG DIONNE", 0
	rts
wpellet	ldd	#$0101
	ldx	#$494C
	jsr	_text
	.text	"+ 10 PTS", 0
	ldd	#$0101
	ldx	#$4A0E
	bsr	_text
	.text	"50 PTS", 0
	rts
wpillon	ldd	#$0101
	ldx	#$4A0C
	bsr	_text
	.text	"*", 0
	ldaa	pacdir
	cmpa	#$03
	beq	_pillrt
	ldd	#$0101
	ldx	#$47C3
	bsr	_text
	.text	"*", 0
_pillrt	rts
wpillof	ldd	#$0100
	ldx	#$4A0C
	bsr	_text
	.text	"*", 0
	ldd	#$0100
	ldx	#$47C3
	bsr	_text
	.text	"*", 0
	rts

wready	ldd	#$0401
	ldx	#$474B
	bsr	_text
	.text	"READY!", 0
	rts
wornot	ldd	#$0400
	ldx	#$474B
	bsr	_text
	.text	"######", 0
	rts

wgameover
	ldd	#$4003		; pos, color
	ldx	#$4749
	bsr	_text
	.text	"GAME", 0
	ldd	#$0403		; pos, color
	ldx	#$474F
	bsr	_text
	.text	"OVER", 0
	rts

_text	std	whomsk		; a=01 04 10 40 b=0 1 2 3
	ldab	#0003q
	mul
	stab	whodir		; dir holds mask
	ldd	whomsk
	mul
	stab	whoclr		; clr holds mul
	pula
	pulb
	subd	#$0001
	std	tmpst1
	stx	whoscn

_next	ldx	tmpst1
	inx
	ldab	$00,x
	stx	tmpst1
	tstb
	beq	_writert
	bsr	_wascii
	bra	_next

_wascii	sts	tmpst3
	ldx	#_letters	; entry
	subb	#$41		;      b - holds ascii char
	bhs	_write		; whoscn - screen location
	addb	#$21		; whodir - holds mask
	bmi	_writep		; whoclr - holds multiplier
	ldx	#_symbols
_write	ldaa	#$05
	staa	tmpcnt
	mul
	abx
	txs
_nextln	ldx	whoscn
	ldaa	#$05
	suba	tmpcnt
	ldab	#$20
	mul
	abx
	ldaa	whodir
	pulb
	pshb
	mul
	coma
	comb
	anda	$00,x
	andb	$01,x
	std	whomsk
	ldaa	whoclr
	pulb
	mul
	oraa	whomsk
	orab	whoms1
	std	$00,x
	dec	tmpcnt
	bne	_nextln
	ldx	whoscn
	inx
	stx	whoscn
	lds	tmpst3
	rts

_writert
	ldx	tmpst1
	jmp	$01,x

_writep	jmp	panic
	;	 0123456789ABCDEF0123456789ABCDEF
_creds	.text	"DEVELOPED USING JAMES THE ANIMAL TAMER'S VIRTUAL MC-10"
	.text	"   PLAYTESTED BY MARK SABBATINI"
	.text	"   SPECIAL THANKS TO"
	.text	"   CRAZY OTTO, MS. PAC-MAN, PAC-MAN AND THE FOLKS AT"
	.text	" GENERAL COMPUTER CORPORATION, MIDWAY, AND NAMCO."
	.text	"                    VERSION 0.1"
	.byte	0

_left	bsr	_left1
_left1	ldx	#$4BFF
_leftb	ldaa	#$20
	clc
_lefta	rol	,x
	dex
	deca
	bne	_lefta
	cpx	#$4B40
	bhs	_leftb
	rts

wscroll	ldx	#_creds
_scr2	stx	wholoc
	ldab	,x
	beq	_scroff
	ldx	#_letters
	subb	#$41
	bhs	_scr1
	addb	#$21
	ldx	#_symbols
_scr1	ldaa	#$05
	mul
	abx
	ldd	$00,x
	std	mn00
	ldd	$02,x
	std	mn02
	ldaa	$04,x
	ldab	#$04
	std	mn04

_scr3	bsr	_left
	ldx	#$4B5F
	stx	whoscn
	ldx	#mn00
	stx	tmpst1
	ldaa	#$05
	staa	mn10
_scr4	bsr	_shift
	dec	mn10
	bne	_scr4
	bsr	_delay
	dec	mn05
	bne	_scr3
	ldx	wholoc
	inx
	bra	_scr2

_scroff	ldaa	#$80
	staa	tmpcnt
_scrf1	bsr	_left
	bsr	_delay
	dec	tmpcnt
	bne	_scrf1
	rts

_shift	ldx	tmpst1
	ldab	,x
	clra
	lsld
	lsld
	ldx	whoscn
	oraa	,x
	staa	,x
	ldx	tmpst1
	stab	,x
	inx
	stx	tmpst1
	ldd	whoscn
	addd	#$0020
	std	whoscn
	rts

_delay	ldx	#$0100
_del1	dex
	bne	_del1
	rts
