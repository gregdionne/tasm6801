	.module	text

_score	.quat	0220 0220 0200 2200 2220
	.quat	2000 2000 2020 2020 2000
	.quat	0200 2000 2020 2200 2200
	.quat	0020 2000 2020 2020 2000
	.quat	2200 0220 0200 2020 2220

_level	.quat	2000 2220 2020 2220 2000
	.quat	2000 2000 2020 2000 2000
	.quat	2000 2200 2020 2200 2000
	.quat	2000 2000 0200 2000 2000
	.quat	2220 2220 0200 2220 2220

_lines	.quat	2000 2220 2020 2220 0220
	.quat	2000 0200 2220 2000 2000
	.quat	2000 0200 2220 2200 0200
	.quat	2000 0200 2220 2000 0020
	.quat	2220 2220 2020 2220 2200

_game	.quat	32300230320202000232
	.quat	23032303030003032323
	.quat	32020200020002003232
	.quat	23030303030303032323
	.quat	32303202020202000232

_over	.quat	32303202020002003232
	.quat	23030303030323030323
	.quat	32020202020032003232
	.quat	23030320230323030323
	.quat	32303230320002020232

numbers	.quat	0100
	.quat	1010
	.quat	1010
	.quat	1010
	.quat	0100

	.quat	0100
	.quat	0100
	.quat	0100
	.quat	0100
	.quat	0100

	.quat	1110
	.quat	0010
	.quat	1110
	.quat	1000
	.quat	1110

	.quat	1110
	.quat	0010
	.quat	1110
	.quat	0010
	.quat	1110

	.quat	1010
	.quat	1010
	.quat	1110
	.quat	0010
	.quat	0010

	.quat	1110
	.quat	1000
	.quat	1110
	.quat	0010
	.quat	1110

	.quat	1110
	.quat	1000
	.quat	1110
	.quat	1010
	.quat	1110

	.quat	1110
	.quat	0010
	.quat	0010
	.quat	0010
	.quat	0010

	.quat	1110
	.quat	1010
	.quat	1110
	.quat	1010
	.quat	1110

	.quat	1110
	.quat	1010
	.quat	1110
	.quat	0010
	.quat	1110

drgover	ldx	#_game
	ldd	#$4590
	bsr	_drtxt
	ldx	#_over
	ldd	#$4595
	bra	_drtxt

drtext	ldx	#_score
	ldd	#$4300
	bsr	_drtxt
	ldx	#_level
	ldd	#$4600
	bsr	_drtxt
	ldx	#_lines
	ldd	#$4900
_drtxt	stx 	TMPLD2
	std	TMPLD1
	ldab	#$05
	stab	TMPCNT
_drtxt1	ldab	#$05
_drtxt2	ldx	TMPLD2
	ldaa	,x
	inx
	stx	TMPLD2
	ldx	TMPLD1
	staa	,x
	inx
	stx	TMPLD1
	decb
	bne	_drtxt2
	ldd	TMPLD1
	addd	#$001B
	std	TMPLD1
	dec	TMPCNT
	bne	_drtxt1
	RTS
