	.module	music
jingle
	ldaa	pltlft
	cmpa	#$C6
	bne	_delay
	ldaa	lvlcnt
	beq	_song
	ldx	#$FFFF
_delay	tst	$00,x
	tst	$00,x
	tst	$00,x
	dex
	bne	_delay
	rts

_song	ldaa	sndchr		; get current contents of sound/video char
	ldx	#_openup	; load theme song table
	ldab	,x		; and get the first note
_next	stx	wholoc		; recycle the ghost location 'wholoc' for table ptr
	lslb			; lookup the note timing value in the jnotes table
	ldx	#jnotes		;
	abx			;
	ldd	,x		;
	std	tmpst1		; save it
	subd	#14		; ? subtract off 14 cycles for the first half-cycle
	std	tmpst3		; ? (the subtraction is actually not required)
	ldx	tmpst3		; ? probably can safely delete these lines...
	ldd	$09		; read the free-running counter
	tst	0008		; dummy read the timer status (to help clear OCF)
	adda	#$60		; add 6*16*256 = 24576 cycles ( /0.89 MHz = 27.6 ms )
	std	$0B		; store in output compare register (which clears OCF)
	ldaa	sndchr		;
	bra	_flip2		; ? (probably not needed, see above)
_flip	ldx	tmpst1		;[4]
_flip2	eora	gameon		;[2] (set to $80 when playing $00 when not)
	staa	$BFFF		;[4] (upper bit toggles sound port)
_jfl	dex			;{3}	  cyc = [4 + 2 + 4 + 3 + 2 + 3] + {3 + 3}*X = [18] + {6}*X
	bne	_jfl		;{3}   originally used B register and 'decb' which was 18 + 5*B
	ldab	$08		;[3] read timer status
	andb	#$40		;[2]   bit 6 (OCF) is set if we reached our desired compare
	beq	_flip		;[3]   keep toggling speaker coil if not.
	staa	sndchr		; save contents of sound/video char
	ldx	wholoc		; get next note
	inx			;
	ldab	,x		;
	bpl	_next		; go until end-of-notes reached ($FF).
	rts

;Sub Foo()
;    Dim x As Double
;    Dim iX As Long
;    x = &H440 * 5 + 16
;    For i = 0 To 49
; iX = x / 2 ^ (i / 12)
; Debug.Print Hex((iX - 18) / 5); " ";
;    Next
;    Debug.Print
;End Sub



jnotes	.word	$1000
	;	root min2 maj2 min3 maj3 prf4 aug4 per5 min6 maj6 min7 maj7	1  -  2  -  3  4  -  5	-  6  -  7
	.hex	0440 0402 03C9 0392 035E 032E 0300 02D5 02AC 0285 0261 023E ;0 01 02 03 04 05 06 07 08 09 0A 0B 0C
	.hex	021E 01FF 01E2 01C7 01AD 0195 017E 0169 0154 0141 012F 011D ;1 0D 0E 0F 10 11 12 13 14 15 16 17 18
	.hex	010D 00FE 00EF 00E2 00D5 00C9 00BD 00B2 00A8 009F 0096 008D ;2 19 1A 1B 1C 1D 1E 1F 20 21 22 23 24
	.hex	0085 007D 0076 006F 0069 0063 005D 0057 0052 004E 0049 0045 ;3 25 26 27 28 29 2A 2B 2C 2D 2E 2F 30
	.hex	0041 003D						    ;4 31 32

_openup	.hex	01
	.hex	25252525 31313131 2C2C2C2C 08292901
	.hex	31312C2C 2C2C2C2C 25252525 09000002
	.hex	26262626 32323232 2D2D2D2D 092A2A02
	.hex	32322D2D 2D2D2D2D 26262626 08000001
	.hex	25252525 31313131 2C2C2C2C 08292901
	.hex	31312D2C 2C2C2C2C 25252525 0800000A
	.hex	29292A2A 2C2C2C0A 2A2A2C2C 2E2E2E0C
	.hex	2C2C2E2E 3030300D 31313131 FF

jinterm	.hex	0D0D2525 25252525 0D252525 0D0D2525
	.hex	0D0D2525 25252525 0D222222 0D0D2020
	.hex	0D0D2525 0D252525 25252525 11112929
	.hex	29292929 12121212 13131313 14141414

	.hex	0D0D2525 25252525 0D252525 0D0D2525
	.hex	0D0D2525 25252525 0D222222 0D0D2020
	.hex	0D0D2525 0D252525 25252525 11112222
	.hex	22222222 12121212 13131313 14141414

	.hex	0D0D2525 25252525 0D252525 0D0D2525
	.hex	0D0D2525 25252525 0D222222 0D0D2020
	.hex	0D0D2525 0D252525 25252525 11052929
	.hex	29292929 12121212 13131313 14142A2A

	.hex	192C2C2C 182C2C2C 162A2A2A 142A2A2A
	.hex	12292929 11292929 0F252525 0D252525
	.hex	0C292929 0A292929 0C292929 0D0D2525
	.hex	25252525 25252525 25252525 25252525
	.hex	FF

	; these routines really aren't music...
	; maybe move to the sound module

spacdie	ldx	#_deadsnd
	abx
	ldaa	sndchr
	ldab	$01,x
	stab	>sndcnt
_die	bsr	_eight
	ldab	sndval
	addb	,x
	stab	sndval
	dec	sndcnt
	bne	_die
	rts

_eight	bsr	_four
_four	bsr	_two
_two	bsr	_fund
_harm	ldab	sndval
	lsrb
	bra	_click
_fund	ldab	sndval
_click	decb
	bne	_click
	eora	gameon
	staa	$BFFF
	rts

_ss16p	bsr	_ss16
	bsr	_ss1
_ss1	bsr	_ss2
_ss2	bsr	_ss3
_ss3	bsr	_ss4
_ss4	bra	_fund
_ss16	bsr	_ss5
_ss5	bsr	_ss6
_ss6	bsr	_ss7
_ss7	bsr	_ss8
_ss8	bsr	_ss9
_ss9	bra	_harm

smunch	ldaa	sndchr
	ldab	#$70
_munch	stab	sndval
	ldab	#$10
	stab	sndcnt
	bsr	_ss16p
	ldab	sndval
	decb
	bitb	#$3F
	bne	_munch
	rts

_deadsnd
	.word $FF20 ;0
	.word $0220 ;1
	.word $FF1F ;2
	.word $021F ;3
	.word $FF1E ;4
	.word $021E ;5
	.word $FF1C ;6
	.word $021C ;7
	.word $FF18 ;8
	.word $0218 ;9
	.word $FF10 ;A
	.word $0210 ;B
	.word $FF20 ;C
	.word $0220 ;D
	.word $FF20 ;E
	.word $0220 ;F
