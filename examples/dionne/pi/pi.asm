
svstack	.equ	$c0	; temporary save for stack
tmpcnt	.equ	$c2	; temporary storage for counter
numdig	.equ	$c4	; number of desired digits
regsiz	.equ	$c6	; size (in bytes) of acc, ang, trm multi-byte registers
acc_msb	.equ	$c8	; accumulator most significant byte
acc_lsb	.equ	$ca	; accumulator least significant byte
ang_msb	.equ	$cc	; angular power most significant byte
ang_lsb	.equ	$ce	; angular power least significant byte
ang_lzb	.equ	$d0	; angular power leading zero byte
trm_msb	.equ	$d2	; term most significant byte
trm_lsb	.equ	$d4	; term least significant byte
trm_lzb	.equ	$d6	; term leading zero byte
angsq_r	.equ	$d8	; (squared) angular reciprocal
coeff_r	.equ	$da	; reciprocal of term coefficient

tabltop	.equ	$4360   ; start of registers


; Program start
	.org	$8000

	ldx	$f4	; get next token after EXEC
	ldaa	,x
	cmpa	#':'	; is it a ':' (?)
	beq	getdigs	; get digits
	ldx	#usage	; otherwise display usage
	jmp	$e7a8	; print null-terminated	string
usage	.strz	"?USE 'EXEC:N' TO COMPUTE N DIGITS OF PI. (N <= 10000)"

getdigs	inx
	stx	$f4
	jsr	$ef4c	; evaluate integer expresion, return in X
	cpx	#10000	; see if it's less than or equal to 10000
	bls	dodigs	;
	ldx	#toomany; complain
	jmp	$e7a8	; print null-terminated string
toomany	.strz	"?THAT WAS TOO MANY DIGITS.\rUSE 10,000 OR LESS."

	; store desired number of digits and compute register size in bytes
	;   regsiz = numdig * log(10) / log(256) = 0.415 * numdig
	;   we approximate via N * (1/2-1/16) = 0.43 * numdig 
	;   with nine bytes of padding

dodigs	stx	numdig	; store desired number of digits.
	ldd	numdig	;
	lsrd		; 
	std	regsiz 	; regsiz = 0.5 numdig.
	lsrd		;
	lsrd		;
	lsrd		;
	subd	regsiz	; D = -0.435*numdig
	coma
	comb
	addd	#10	; D = 0.435*numdig + 9.
	std	regsiz	; store result.

	; allocate registers
	ldd	#tabltop
	std	acc_msb	
	addd	regsiz	
	std	ang_msb	
	addd	regsiz	
	std	trm_msb	
	addd	regsiz	
	subd	#1	
	std	trm_lsb	
	subd	regsiz	
	std	ang_lsb	
	subd	regsiz	
	std	acc_lsb	

	; put MC6847 into RG6 mode (256x192)
	ldaa	#$7f	
	staa	$bfff

	; clear accumulator
	ldx	acc_msb	
	jsr	clear	

	; add 6 * arctan(8) to accumulator
	ldd	#8	
	std	angsq_r
	ldaa	#6
	jsr	atanp8

	; add 2 * arctan(57) to accumulator
	ldd	#57	
	std	angsq_r
	ldaa	#2
	jsr	atanp

	; add 1 * arctan(239) to accumulator
	ldd	#239	
	std	angsq_r
	ldaa	#1
	jsr	atanp
	
	; multiply accumulator by 4
	jsr	dblacc	
	jsr	dblacc

	; display results 
	clr	$bfff	; restore SG4 mode of MC6847
	jsr	display	; display the accumulator
	rts		; return to BASIC


.MODULE Addang
;	add angular power to accumulator
addang
	sts	svstack
	ldx	ang_lsb
	lds	acc_lsb
	clc
	tpa
_again	des
	pulb
	tap
	adcb	,x
	tpa
	pshb
	dex
	cpx	ang_msb
	bhs	_again
	lds	svstack
	rts


.MODULE	Tsttrm
;	set Z flag if term is zero
tsttrm
	ldx	trm_lsb
_again	tst	,x
	bne	_rts
	dex
	cpx	trm_msb
	bhs	_again
	tst	$0100
_rts	rts


.MODULE Atninit
;	initialize new arctanget
atninit
	ldx	ang_msb
	psha
	jsr	clear
	pula
	ldx	ang_msb
	stx	ang_lzb
	staa	,x
	ldx	trm_msb
	stx	trm_lzb
	jsr	newang
	ldd	angsq_r
	tba
	mul
	std	angsq_r
	ldd	#1
	std	coeff_r
	rts


.MODULE Atanp
;	add  ACCA * arctan( 1 / angsq_r ) to accumulator
atanp
	bsr	atninit
	bsr	addang
_again	ldd	coeff_r
	addd	#2
	std	coeff_r
	jsr	newang
	bsr	newtrm
	jsr	subtrm
	ldd	coeff_r
	addd	#2
	std	coeff_r
	jsr	newang	
	bsr	newtrm
	jsr	addtrm
	jsr	tsttrm
	bne	_again
divrts	rts


.MODULE Newtrm
;	compute new term  (angular power / coeff_r)
;	
;	
newtrm
	sts	svstack
	lds	trm_lsb
	ldx	ang_lsb
_num21	ldaa	,x
	psha
	dex
	cpx	ang_lzb
	bhs	_num21
	lds	svstack

	ldx	trm_lzb
_trm_lzb	tst	,x
	bne	_resn
	tst	1,x
	bne	_resn
	inx
	stx	trm_lzb
	bra	_trm_lzb
_resn	clra
	ldab	,x
	clr	,x
_byte	inx	
	cpx	trm_lsb	
	bls	_bit0
	rts	
_bit0	lsl	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit1
	addd	coeff_r	
_bit1	rol	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit2
	addd	coeff_r	
_bit2	rol	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit3
	addd	coeff_r	
_bit3	rol	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit4
	addd	coeff_r	
_bit4	rol	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit5
	addd	coeff_r	
_bit5	rol	,x
	rolb	
	rola
	subd	coeff_r	
	bhs	_bit6
	addd	coeff_r	
_bit6	rol	,x
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit7
	addd	coeff_r	
_bit7	rol	,x	
	rolb	
	rola	
	subd	coeff_r	
	bhs	_bit8
	addd	coeff_r	
_bit8	rol	,x
	com	,x
	bra	_byte


.MODULE NewAng
;	compute new angle power 
;	angle /= angsqr_r
newang
	ldx	ang_lzb
_ang_lzb	tst	,x
	bne	_numn
	tst	1,x
	bne	_numn
	inx
	stx	ang_lzb
	bra	_ang_lzb
_numn	clra
	ldab	,x
	clr	,x
_byte	inx
	cpx	ang_lsb
	bls	_bit0
	rts
_bit0	lsl	,x	;6
	rolb		;2
	rola		;2
	bcc	_bat0	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit1	;3
_bat0	subd	angsq_r	;5
	bhs	_bit1	;3
	addd	angsq_r	;5
_bit1	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat1	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit2	;3
_bat1	subd	angsq_r	;5
	bhs	_bit2	;3
	addd	angsq_r	;5
_bit2	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat2	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit3	;3
_bat2	subd	angsq_r	;5
	bhs	_bit3	;3
	addd	angsq_r	;5
_bit3	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat3	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit4	;3
_bat3	subd	angsq_r	;5
	bhs	_bit4	;3
	addd	angsq_r	;5
_bit4	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat4	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit5	;3
_bat4	subd	angsq_r	;5
	bhs	_bit5	;3
	addd	angsq_r	;5
_bit5	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat5	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit6	;3
_bat5	subd	angsq_r	;5
	bhs	_bit6	;3
	addd	angsq_r	;5
_bit6	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat6	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit7	;3
_bat6	subd	angsq_r	;5
	bhs	_bit7	;3
	addd	angsq_r	;5
_bit7	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat7	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit8	;3
_bat7	subd	angsq_r	;5
	bhs	_bit8	;3
	addd	angsq_r	;5
_bit8	rol	,x	;6
	com	,x	;6
	jmp	_byte


.MODULE Atanp8
;	add ACCA * atan(1/8) to accumulator
atanp8
	jsr	atninit
	jsr	addang
_again	ldd	coeff_r
	addd	#2
	std	coeff_r
	bsr	newang8
	bsr	newtrm8
	jsr	subtrm
	jsr	tsttrm
	ldd	coeff_r
	addd	#2
	std	coeff_r
	bsr	newang8
	bsr	newtrm8
	jsr	addtrm
	jsr	tsttrm
	bne	_again
	rts


.MODULE NewAng8
;	compute new angular power
;	    ang = ang / (8^2)
newang8
	ldx	ang_lzb
_again	ldd	,x
	tsta
	bne	_done
	inx
	cpx	ang_lsb
	beq	_donex
	stx	ang_lzb
	bra	_again
_done	lsrd
	lsrd
	lsrd
	lsrd
	lsrd
	lsrd
	std	,x
	rts
_donex	clra
	staa	,x
	rts


.MODULE NewTrm8
;	compute new term in expansion of arctan(1/8)
newtrm8
	ldd	ang_lzb
	addd	regsiz
	std	trm_lzb
	ldx	ang_lzb
	ldd	,x
	ldx	trm_lzb
	std	,x
	tsta
	bne	_nonz
	inx
_nonz	cpx	trm_lsb
	bhi	_rts
	ldaa	#8
	staa	tmpcnt
	ldd	#0
_nxs8	lsl	,x
	rolb
	rola
	subd	coeff_r
	blo	_ndv8
	lsr	,x
	sec
	rol	,x
	dec	tmpcnt
	bne	_nxs8
	bra	_byte
_ndv8	addd	coeff_r
	dec	tmpcnt
	bne	_nxs8
_byte	inx
	cpx	trm_lsb
	bls	_bit0
_rts	rts
_bit0	lsl	,x	;6
	lsld		;3
	subd	coeff_r	;5
	bhs	_bit1	;3
	addd	coeff_r	;5
_bit1	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit2
	addd	coeff_r
_bit2	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit3
	addd	coeff_r
_bit3	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit4
	addd	coeff_r
_bit4	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit5
	addd	coeff_r
_bit5	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit6
	addd	coeff_r
_bit6	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit7
	addd	coeff_r
_bit7	rol	,x
	lsld
	subd	coeff_r
	bhs	_bit8
	addd	coeff_r
_bit8	rol	,x
	com	,x
	bra	_byte


.MODULE Display
;	print accumulator to screen
display 
	ldx	ang_msb
	stx	ang_lzb
	ldx	trm_msb
	stx	trm_lzb
	ldx	acc_msb
	ldaa	,x
	adda	#'0'
	jsr	spita
	ldaa	#'.'
	jsr	spita
	bra	_disp
_again	ldx	acc_msb
	ldaa	,x
	adda	#'0'
	jsr	spita
_disp	ldx	acc_msb
	clr	,x
	bsr	acc2trm	
	bsr	dblacc
	bsr	dblacc
	bsr	addtrm
	bsr	dblacc
	ldx	numdig
	dex
	stx	numdig
	bne	_again
	rts

spita	.equ	$f9c6

; for writing to both printer and screen
;spita	com	$00e8
;	jsr	$f9c6
;	com	$00e8
;	jmp	$f9c6


.MODULE Acc2Trm
;	copy accumulator to term register
acc2trm
	sts	svstack
	lds	trm_lsb
	ldx	acc_lsb
_again	ldaa	,x	;5
	psha		;2
	dex		;3
	cpx	acc_msb	;6
	bhs	_again	;3
	lds	svstack
	rts


.MODULE DblAcc
;	double the accumulator
dblacc
	ldx	acc_lsb
	clc
	tpa
_again	tap
	rol	,x
	tpa
	dex
	cpx	acc_msb
	bhs	_again
	rts


.MODULE AddTrm
;	add term to accumulator
addtrm
	sts	svstack
	ldx	trm_lsb
	lds	acc_lsb
	clc
	tpa
_again	des
	pulb
	tap
	adcb	,x
	tpa
	pshb
	dex
	cpx	trm_lzb
	bhs	_again
	tap
	bcc	_done
	cpx	trm_msb
	bhs	_again
_done	lds	svstack
	rts


.MODULE subtrm
;	subtract term from accumulator
subtrm
	sts	svstack
	ldx	trm_lsb
	lds	acc_lsb
	clc
	tpa
_again	des
	pulb
	tap
	sbcb	,x
	tpa
	pshb
	dex
	cpx	trm_lzb
	bhs	_again
	tap
	bcc	_done
	cpx	trm_msb
	bhs	_again
_done	lds	svstack
	rts


.MODULE Clear
;	clear register in ACCX
clear
	stx	svstack
	ldd	svstack
	addd	regsiz
	std	svstack
_again	clr	,x
	inx
	cpx	svstack
	bne	_again
	rts
