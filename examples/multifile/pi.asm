
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
