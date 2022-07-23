;*******************************
; MC10 SG4 CHESSBOARD
; 2015 Simon Jonassen
;*******************************

screen	.equ	$4000	

	.org	$5000


	ldx	#screen
	ldd	#$8080
lp1	std	,x
	inx
	inx
	cpx	#screen+512
	bne	lp1




yloop	
	jsr	chess
	jsr	ystuff
	jsr	sin1
	jmp	yloop



chess
	ldx	#funk
nextx	ldaa	#16		;32
	staa	xcnt

xloop	

;*******************************
;first half
;*******************************
	ldd	xscan
	addd	xscale
	std	xscan			
	anda	#1
	lsla
	staa	mya+2
	adda	#4
	staa	mya2+2

	ldd	xscan
	addd	xscale
	std	xscan			
	anda	#1
	oraa	mya+2
	staa	mya+2
	adda	#4
	staa	mya2+2

;*******************************
;second half
;*******************************
	ldd	xscan
	addd	xscale
	std	xscan			
	anda	#1
	lsla	
	staa	myb+2
	adda	#4
	staa	myb2+2
	ldd	xscan
	addd	xscale
	std	xscan
	anda	#1
	oraa	myb+2
	staa	myb+2
	adda	#4
	staa	myb2+2


;*******************************
; 0,1,2,3 dependant upon position
; least significant byte
; gets modded by above code
;*******************************
mya	ldaa	sgtab1
myb	ldab	sgtab1	
	std	1,x

mya2	ldaa	sgtab2
myb2	ldab	sgtab2	
	std	$81,x

	ldab	#5
	abx

	dec	xcnt
	bne	xloop

	rts



ystuff
;*******************************
; Y AXIS STUFF
;*******************************
;NUMBER OF LINES
;*******************************
	ldaa	#16	
;*******************************
	staa	ycnt

;*******************************
;screen pointer
;*******************************
poo	ldx	#screen
;*******************************
yscan	ldd	#0
yscale	addd	#0
	std	yscan+1
	anda	#1
	beq	oddy
	jsr	funk2
	bra	eveny
oddy	jsr	funk
	
eveny	ldab	#32
	abx
	dec	ycnt
	bne	yscan
	rts

;*******************************	
; center board and zoom using 
; sin table
;*******************************	


sin1	ldab	sintab
	clra

	lslb

	stab	yscale+2
	lsrb
	stab	xscale+1
	aslb
	rola

	aslb
	rola

	aslb
	rola


	aslb
	rola

	aslb
	rola



	std	temp
	
	ldd	#$400
	subd	temp

	std	xscan
	asra
	rorb
	std	yscan+1

;*******************************
; SPEED
;*******************************

	ldaa	sin1+2
	adda	#-1		
	staa	sin1+2
	rts



	.ORG  (($+0FFH) & 0FF00H)


sintab
	.byte	32,32,33,34,35,35,36,37,38,38,39,40,41,41,42,43
	.byte	44,44,45,46,46,47,48,48,49,50,50,51,51,52,53,53
	.byte	54,54,55,55,56,56,57,57,58,58,59,59,59,60,60,60
	.byte	61,61,61,61,62,62,62,62,62,63,63,63,63,63,63,63
	.byte	63,63,63,63,63,63,63,63,62,62,62,62,62,61,61,61
	.byte	61,60,60,60,59,59,59,58,58,57,57,56,56,55,55,54
	.byte	54,53,53,52,51,51,50,50,49,48,48,47,46,46,45,44
	.byte	44,43,42,41,41,40,39,38,38,37,36,35,35,34,33,32
	.byte	32,31,30,29,28,28,27,26,25,25,24,23,22,22,21,20
	.byte	19,19,18,17,17,16,15,15,14,13,13,12,12,11,10,10
	.byte	9,9,8,8,7,7,6,6,5,5,4,4,4,3,3,3
	.byte	2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1
	.byte	1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2
	.byte	2,3,3,3,4,4,4,5,5,6,6,7,7,8,8,9
	.byte	9,10,10,11,12,12,13,13,14,15,15,16,17,17,18,19
	.byte	19,20,21,22,22,23,24,25,25,26,27,28,28,29,30,31

	
funk	ldd	#$6060
	std	0,x
	ldd	#$6060
	std	2,x
	ldd	#$6060
	std	4,x
	ldd	#$6060
	std	6,x
	ldd	#$6060
	std	8,x
	ldd	#$6060
	std	10,x
	ldd	#$6060
	std	12,x
	ldd	#$6060
	std	14,x
	ldd	#$6060
	std	16,x
	ldd	#$6060
	std	18,x
	ldd	#$6060
	std	20,x
	ldd	#$6060
	std	22,x
	ldd	#$6060
	std	24,x
	ldd	#$6060
	std	26,x
	ldd	#$6060
	std	28,x
	ldd	#$6060
	std	30,x
	rts

	.ORG  funk+128

funk2	ldd	#$6060
	std	0,x
	ldd	#$6060
	std	2,x
	ldd	#$6060
	std	4,x
	ldd	#$6060
	std	6,x
	ldd	#$6060
	std	8,x
	ldd	#$6060
	std	10,x
	ldd	#$6060
	std	12,x
	ldd	#$6060
	std	14,x
	ldd	#$6060
	std	16,x
	ldd	#$6060
	std	18,x
	ldd	#$6060
	std	20,x
	ldd	#$6060
	std	22,x
	ldd	#$6060
	std	24,x
	ldd	#$6060
	std	26,x
	ldd	#$6060
	std	28,x
	ldd	#$6060
	std	30,x
	rts
	

	.ORG  (($+0FFH) & 0FF00H)

sgtab1	.byte	$80,$85,$8a,$60
sgtab2	.byte	$60,$8a,$85,$80


xcnt	.byte	0
ycnt	.byte	0
xscan	.word	0
xscale	.word	0
temp	.word	0





	.end