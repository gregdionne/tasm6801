;***********************************
; MC10 (6803)
; VECTOR MASHUP BY THE INVISIBLE MAN
; (AKA SIMON JONASSEN)
; (c) 2018 - free for all 
; use as you see fit 
; give credit where it's due
;***********************************
		.msfirst
		.org 	$5000
START		sei
 		jsr	setup2		

;**********************************
; process endpoints of figure
;
; eg. apply z,x,y rotations
; of given endpoint
;**********************************
main
;**********************************
; UPDATE X,Y,Z ANGLES
;**********************************
		ldaa	xangle+1
		adda	#4		; X angle rotation
		staa	xangle+1
		ldaa	yangle+1
		adda	#2		; Y angle rotation
		staa	yangle+1
		ldaa	zangle+1
		adda	#-5		; Z angle rotation
		staa	zangle+1
;**********************************
; Process the vectors
;**********************************
dolines		ldd	#newpoints	;rotated point list
		std	disbit+1	;save for later	
figloop		ldx	#figure		;object
		ldd	,x		;grab x/y
		bne	roto		;if not 0 then we have more points to process
		ldd	#figure		;reset the object list pointer
		std	figloop+1
		jmp	connect		;go connect the dots
;**********************************
; ROTATE
;**********************************
roto		inx			;update the object pointer (we grabbed x/y)
		inx
		std	xp		;stuff x/y into the temp vars
		ldaa	,x		;grab z
		inx			;update the object pointer for Z
		stx	figloop+1	;store the new object pointer location	
		staa	zp		;store the z value
;**********************************
; ROTATION ROUTINES
;**********************************
rotate
;**********************************
;rotate about z axis
;
; x' = x*cos (angle) - y*sin (angle)
; y' = x*sin (angle) + y*cos (angle) 
; z' = z
;**********************************
		ldd	xp		;grab x/y
		std	x2
zangle		ldaa	#0		;angle
		jsr	makerot		;rotate this point
		ldd	x		;save rotated points (x/y) 
		std	xp
;**********************************
; ROTATE AROUND X AXIS
; y' = y*cos (angle) - z*sin (angle)
; z' = y*sin (angle) + z*cos (angle)
; x' = x
;**********************************
		ldaa	zp
		ldab	yp
		std	x2
xangle		ldaa	#0		;angle to rotate about
		jsr	makerot		;rotate this point
		ldd	x		;save rotated points (z/y)
		staa	zp
		stab	yp
;**********************************
; ROTATE AROUND Y AXIS
; z' = z*cos (angle) - x*sin (angle)
; x' = z*sin (angle) + x*cos (angle)
; y' = y
;**********************************
		ldaa	xp
		ldab	zp
		std	x2
yangle		ldaa	#0
		jsr	makerot	
		ldd	x		;save rotated points (z/x)
		staa	xp
		stab	zp
;**********************************
; convert 3d to 2d
;**********************************
c3d2d		ldaa	zp		; get 1st value
		staa	z1+2
z1		ldaa	ztab	
		bmi	F120_5		; if negative, go change sign
		ldab	xp		; get 2nd value
		bmi	F112_5		; if negative , go change sign 
		mul     		; multiply them
		bra   	F200_5		; out of smul (+ x +)
F120_5		nega          		; change sign of 1st value
		ldab	xp		; get 2nd value
		bpl	F113_5		; if positive go to different sign
F122_5		negb         		; change sign of 2nd value
		mul          		; multiply them
		bra   	F200_5 		; out of smul ( - x -)
F112_5		negb         		; change sign of 2nd value
F113_5		mul          		; multiply them
		nega 			; negate
		negb 			; result
		sbca	#0		; add any carry to the result


;**********************************
F200_5	
		asld			; scaling (only one shift because of aspect ratio) 
		staa	xp
;**********************************
		ldaa	zp		; get 1st value
		staa	z2+2
z2		ldaa	ztab
		bmi	F120_6		; if negative, go change sign
		ldab	yp		; get 2nd value 
		bmi	F112_6		; if negative , go change sign 
		mul     		; multiply them
		bra   	F200_6		; out of smul (+ x +)
F120_6		nega          		; change sign of 1st value
		ldab	yp		; get 2nd value 
		bpl	F113_6		; if positive go to different sign
F122_6		negb         		; change sign of 2nd value
		mul          		; multiply them
		bra   	F200_6 		; out of smul ( - x -)
F112_6		negb         		; change sign of 2nd value
F113_6		mul          		; multiply them
		nega 			; negate
		negb 			; result
		sbca	#0		; add any carry to the result
;**********************************
F200_6		asld			;scaling
		asld
		staa	yp
		ldd	xp		;grab new scaled x/y 
;**********************************
; add centers
; A=64
; B=96		
;**********************************
		addd	#$4060		;CENTER OF SCREEN
disbit		ldx	#$0000		;list of rotated points
		std	,x		;stuff into rotated/centered point table
		inx			;next entry in rotated/scaled/centered
		inx			;point list
		stx	disbit+1	;store our pointer	
		jmp	figloop		;over again
;**********************************
; PLAY CONNECT THE DOTS
; USING THE TABLE OF DOTS AND 
; DESC OF WHICH ONES TO CONNECT
;**********************************
connect		ldx	#vertfig	;point to list of points to connect		
		ldd	,x		;grab a point descriptor
		bpl	nxt		;if +ve then not at end of list
		ldd 	#vertfig	;reset list pointer	
		std	connect+1
;**********************************
;delete
;**********************************
wait		ldx	#$1200		;lets wait about for a bit 
w1		dex			;the mc10 can't double buffer
		bne	w1		;so don't delete the image too soon
delete		ldx	#$4335		;start of delete area
dlp		ldd	#$0000		;value to fill with
		std	,x		;go delete a word
		std	2,x		;then another
		std	4,x		;same deal
		ldab	#16		;add 16 to the X pointer (next line)
		abx
		clrb			;reset our store value to 0
		std	,x
		std	2,x
		std	4,x
		ldab	#16
		abx
		clrb
		std	,x
		std	2,x
		std	4,x
		ldab	#16
		abx
		clrb
		std	,x
		std	2,x
		std	4,x
		cpx	#$48c0		; done with deleting ??
		bhi	out		; yes - so go back and start over
		jmp	dlp		; delete some more
out		jmp	main		; repeat vector rotation
;**********************************
; CONTINUE CONNECTING DOTS
;**********************************
nxt		inx
		inx	
		stx	connect+1	;update our table pointer
		asld			;*2 - word lookup
		staa	ptr1+1		;give us our indicies to the newpoints table
		stab 	ptr2+1	
		ldx	#newpoints	;point to rotated points table
ptr1		ldx	15,x		;get the indexed rotated points
		stx	x0y0		;put first set of coords into the line routine
		ldx	#newpoints	;point to rotated points table
ptr2		ldx	15,x		;change to LDX for dots
		stx	x1y1		;second set of coords for line routine
		jsr	line		;JMP/JMP (faster than jsr/rts)
		bra	connect
;**********************************
; rotation routine sin/cos
; generic for x/y/z depends on
; whats in x2/y2
;**********************************
makerot		staa	sinlook+2	;index into sin/cos
		staa	coslook+2
sinlook		ldaa	sintab3		;grab sin value
coslook		ldab	costab3		;grab cos value
		std	sinv		;store it for rotates (sin/cos)
;**********************************
; X * cos(angle)
;**********************************
smul		ldaa	x2		; get 1st value
		bmi	F120		; if negative, go change sign
cos1		ldab	cosv		; get 2nd value (cos)
		bmi	F112		; if negative , go change sign 
		mul     		; multiply them
		bra   	F200		; out of smul (+ x +)
F120		nega          		; change sign of 1st value
cos2		ldab	cosv		; get 2nd value (cos)
		bpl	F113		; if positive go to different sign
F122		negb         		; change sign of 2nd value
		mul          		; multiply them
		bra   	F200 		; out of smul ( - x -)
F112		negb         		; change sign of 2nd value
F113		mul          		; multiply them
		nega 			; negate
		negb 			; result
		sbca	#0		; add any carry to the result (adcb#0)
;**********************************
; cheaper way of /128 (>>7)
;**********************************
F200		asld
		staa	sub+1		; use regA as (regD/128) at destination
;**********************************
; Y * sin(angle)
;**********************************
		ldaa	y2		; get 1st value
		bmi	F120_1		; if negative, go change sign
sin1		ldab	sinv		; get 2nd value (sin)
		bmi	F112_1 		; if negative , go change sign 
		mul          		; multiply them
		bra	F200_1		; out of smul (+ x +)
F120_1		nega          		; change sign of 1st value
sin2		ldab	sinv		; get 2nd value (sin)
		bpl	F113_1		; if positive go to different sign
F122_1		negb         		; change sign of 2nd value
		mul          		; multiply them
		bra	F200_1 		; out of smul ( - x -)
F112_1		negb         		; change sign of 2nd value
F113_1		mul          		; multiply them
		nega 			; negate
		negb			; result
		sbca	#0		; add any carry to the result
F200_1		asld
;**********************************
; x' = x*cos (angle) - y*sin (angle)
;**********************************
sub		suba	#0		; Y*sin(angle)-X*cos(angle)
		staa	x		; save result
;**********************************
; X * sin(angle)
;**********************************
		ldaa	x2		; get 1st value
		bmi	F120_2		; if negative, go change sign
		ldab	sinv		; get 2nd value (sin)
		bmi	F112_2 		; if negative , go change sign 
		mul         		; multiply them
		bra	F200_2		; out of smul (+ x +)
F120_2		nega          		; change sign of 1st value
		ldab	sinv		; get 2nd value (sin)
		bpl	F113_2		; if positive go to different sign
F122_2		negb         		; change sign of 2nd value
		mul          		; multiply them
		bra	F200_2 		; out of smul ( - x -)
F112_2		negb         		; change sign of 2nd value
F113_2		mul          		; multiply them
		nega 			; negate
		negb 			; result
		sbca	#0		; add any carry to the result
F200_2		asld
		staa	add+1		; use regA as (regD/128) at destination
;**********************************
; Y * cos(angle)
;**********************************
		ldaa	y2		; get 1st value
		bmi	F120_3		; if negative, go change sign
		ldab	cosv		; get 2nd value (cos)
		bmi	F112_3 		; if negative , go change sign 
		mul          		; multiply them
		bra	F200_3		; out of smul (+ x +)
F120_3		nega          		; change sign of 1st value
		ldab	cosv		; get 2nd value (cos)
		bpl	F113_3		; if positive go to different sign
F122_3		negb         		; change sign of 2nd value
		mul          		; multiply them
		bra	F200_3 		; out of smul ( - x -)
F112_3		negb         		; change sign of 2nd value
F113_3		mul          		; multiply them
		nega 			; negate
		negb 			; result
		sbca	#0		; add any carry to the result
F200_3		asld
;**********************************
; y' = x*sin (angle) + y*cos (angle) 
;**********************************
add		adda	#0		; X*sin(angle)+Y*cos(angle)
		staa	y		; save result
		rts			; return
;**********************************
;SETUP GFX, CLS ETC
;**********************************
setup2		ldx 	#$4000		;screen area
		ldd	#$0000		;fill value
clrlp2		std 	,x		;fill a word
		inx			
		inx	
		cpx 	#$5000		;done filling ??
		blo 	clrlp2
		ldaa 	#$b4		;enable 128*192 videomode (3072 bytes)
		staa	$bfff		;store to videomode register
		rts
	
;**********************************
; DRAW LINE
;**********************************
line
;**********************************
; if x0>x1 then swap(x0,y0) & (y0,y1)
;**********************************
		ldaa 	x0		;grab x coords and flip if necessary
		cmpa 	x1
		bls 	noswap
		ldab 	x1
		staa 	x1
		stab 	x0
		ldaa 	y0
		ldab 	y1
		staa 	y1
		stab 	y0
noswap

;**********************************
; calculate start address
;**********************************
		ldd	x0y0		;get x/y
		lsra			;8 pix per byte - so 3 shifts
		lsra			;will tell us which byte 
		lsra			;the pixel resides in on a scanline	
		staa	xval+2
		ldaa	#16		;now lets find the Y location (16 bytes pr scanline) 
		mul			;
		addd	scraddr		;add the initial screen pointer	
xval		addd	#0		;add the X value
		std	myx+1		;now put that in X 	
myx		ldx	#$0000
;**********************************
; get start pixel
;**********************************
		ldaa 	x0		;make sure we only have 0..7
		anda 	#7
		staa	px1+2		;stuff into pointer
px1		ldaa	pixtab		;pointer (page aligned (we fiddle LSB))
		staa 	pixel+1		;put that into our cyclic rotation
		staa	pixel2+1
;**********************************
; dx = (x1-x0)
;**********************************
		ldaa 	x1
		suba 	x0
		staa	dx

;**********************************
; dy = abs(y1-y0)
; also determine y increment
;**********************************
		clr	ystep+1		;this is a +ve # so lets clr the -ve on the 16bit pointer
		clr	xstep+1
		ldab 	#16		;Y offsets (16 bytes per scanline)
		ldaa 	y1
		suba 	y0
		bpl 	dypos
		nega
		negb
		dec	ystep+1		;this is a -ve value so lets decrement
		dec	xstep+1		;eg dec $00=$ff (now our 16bit is -ve)
dypos		staa 	dy
;**********************************
; do steep line if (dy > dx)
;**********************************
		cmpa 	dx
		bhi 	steep
;**********************************
; draw shallow line
; (x increments every loop)
;**********************************
; setup
;**********************************
		stab 	ystep+2		; B is 16 or -16 (eg Y step)
		ldd 	dxdy
		staa 	dxmod+1		; error correction terms for line
		stab 	dymod+1
		staa 	lcount
;**********************************
; error = dx/2
;**********************************
                ldab 	dx
		lsrb
lloop0		ldaa 	,x
lloop1
pixel		oraa 	#0
dymod		subb 	#0		; subb dy
		bpl 	noystep1
dxmod		addb 	#0		; addb dx
		staa	,x
		stab	oldab+1
		stx	oldx+1
oldx		ldd	#$0000
ystep		addd	#$0000
		std	newx+1
newx		ldx	#$0000
oldab		ldab	#0
noystep0	lsr 	pixel+1		; cyclic rotation
		bcc 	nocy0
		ror 	pixel+1		; put carry back in so it's cyclic
		inx			; next byte please
nocy0		dec 	lcount
		bpl 	lloop0		; use bne instead to skip last pixel
		rts


noystep1	lsr 	pixel+1		; cyclic rotation (128,64,32,16,8,4,2,1)
		bcc 	nocy2
		ror 	pixel+1		; make sure it's cyclic 
		staa	,x
		inx			; step in X direction (next screen byte)
nocy1		dec 	lcount
		bpl 	lloop0		; use bne instead to skip last pixel
		rts
	

nocy2		dec 	lcount
		bpl 	lloop1		; use bne instead to skip last pixel
		staa	,x
		rts

;**********************************
; draw steep line
; (y increments every loop)
;**********************************

;**********************************
; setup
;**********************************
steep		stab 	xstep+2
		ldd 	dxdy
		staa 	dxmod2+1
		stab 	dymod2+1
		stab 	lcount
		
;**********************************
; error = dy/2
;**********************************
		lsrb
lloop2
pixel2		ldaa 	#0
		oraa 	,x		; save whats already in the byte
		staa 	,x		; draw pixel
dxmod2		subb 	#0		; subb dx
		bpl 	noxstep
dymod2		addb 	#0		; addb dy
		lsr 	pixel2+1
		bcc 	noxstep
		ror 	pixel2+1
		inx

noxstep		stab	oldab2+1	; save B as we need it
		stx	oldx2+1		; basically we do X -> D
oldx2		ldd	#$0000
xstep		addd	#$0000		; this is a funky bit it will contain
		std	newx2+1		; either 16 (d=$0010) or -16 (d=$fff6)
newx2		ldx	#$0000		; our new additive value is the new x pointer
oldab2		ldab	#0

		dec 	lcount
		bpl 	lloop2		
		rts


;***************************************************
; LINE VARS
;***************************************************
x0y0
x0		.byte 	1
y0		.byte 	1
x1y1
x1		.byte 	1
y1		.byte 	1
dxdy
dx		.byte 	1
dy		.byte 	1
lcount		.byte 	1
scraddr		.word	$4000
;***************************************************
; vector vars
;***************************************************
xp		.byte	0
yp		.byte	0
zp		.byte	0
sinv		.byte	0
cosv		.byte	0
x2		.byte	0
y2		.byte	0
x		.byte	0
y		.byte	0



counter2	.byte	$ff
;***************************************************
; pixel lookup table
;***************************************************
		.ORG  (($+0FFH) & 0FF00H)
pixtab		.byte 	128,64,32,16,8,4,2,1

;***************************************************
; sin/cos tables 
;
;FOR s = -128 TO 127
;   a1=cint(127 * sin(s * PI / 128)) 
;NEXT 
;***************************************************
		.ORG  (($+0FFH) & 0FF00H)
;***************************************************
sintab3
	.byte	0,3,6,9,12,16,19,22,25,28,31,34,37,40,43,46
	.byte	49,51,54,57,60,63,65,68,71,73,76,78,81,83,85,88
	.byte	90,92,94,96,98,100,102,104,106,107,109,111,112,113,115,116
	.byte	117,118,120,121,122,122,123,124,125,125,126,126,126,127,127,127
	.byte	127,127,127,127,126,126,126,125,125,124,123,122,122,121,120,118
	.byte	117,116,115,113,112,111,109,107,106,104,102,100,98,96,94,92
	.byte	90,88,85,83,81,78,76,73,71,68,65,63,60,57,54,51
	.byte	49,46,43,40,37,34,31,28,25,22,19,16,12,9,6,3

	.byte	0,-3,-6,-9,-12,-16,-19,-22,-25,-28,-31,-34,-37,-40,-43,-46
	.byte	-49,-51,-54,-57,-60,-63,-65,-68,-71,-73,-76,-78,-81,-83,-85,-88
	.byte	-90,-92,-94,-96,-98,-100,-102,-104,-106,-107,-109,-111,-112,-113,-115,-116
	.byte	-117,-118,-120,-121,-122,-122,-123,-124,-125,-125,-126,-126,-126,-127,-127,-128
	.byte	-128,-128,-127,-127,-126,-126,-126,-125,-125,-124,-123,-122,-122,-121,-120,-118
	.byte	-117,-116,-115,-113,-112,-111,-109,-107,-106,-104,-102,-100,-98,-96,-94,-92
	.byte	-90,-88,-85,-83,-81,-78,-76,-73,-71,-68,-65,-63,-60,-57,-54,-51
	.byte	-49,-46,-43,-40,-37,-34,-31,-28,-25,-22,-19,-16,-12,-9,-6,-3

;***************************************************
; DO THE MATH !
;***************************************************

costab3

	.byte	-128,-128,-127,-127,-126,-126,-126,-125,-125,-124,-123,-122,-122,-121,-120,-118
	.byte	-117,-116,-115,-113,-112,-111,-109,-107,-106,-104,-102,-100,-98,-96,-94,-92
	.byte	-90,-88,-85,-83,-81,-78,-76,-73,-71,-68,-65,-63,-60,-57,-54,-51
	.byte	-49,-46,-43,-40,-37,-34,-31,-28,-25,-22,-19,-16,-12,-9,-6,-3
	.byte	0,3,6,9,12,16,19,22,25,28,31,34,37,40,43,46
	.byte	49,51,54,57,60,63,65,68,71,73,76,78,81,83,85,88
	.byte	90,92,94,96,98,100,102,104,106,107,109,111,112,113,115,116
	.byte	117,118,120,121,122,122,123,124,125,125,126,126,126,127,127,127

	.byte	127,127,127,127,126,126,126,125,125,124,123,122,122,121,120,118
	.byte	117,116,115,113,112,111,109,107,106,104,102,100,98,96,94,92
	.byte	90,88,85,83,81,78,76,73,71,68,65,63,60,57,54,51
	.byte	49,46,43,40,37,34,31,28,25,22,19,16,12,9,6,3
	.byte	0,-3,-6,-9,-12,-16,-19,-22,-25,-28,-31,-34,-37,-40,-43,-46
	.byte	-49,-51,-54,-57,-60,-63,-65,-68,-71,-73,-76,-78,-81,-83,-85,-88
	.byte	-90,-92,-94,-96,-98,-100,-102,-104,-106,-107,-109,-111,-112,-113,-115,-116
	.byte	-117,-118,-120,-121,-122,-122,-123,-124,-125,-125,-126,-126,-126,-127,-127,-128


;***************************************************
; PERSPECTIVE TABLE
;
;FOR s = -128 TO 127
;   a1=cint(127 * (1/s)) 
;NEXT 
;***************************************************
ztab
	.byte	48,48,49,49,49,49,50,50,50,50,51,51,51,51,52,52
	.byte	52,53,53,53,54,54,54,55,55,55,56,56,56,57,57,57
	.byte	58,58,58,59,59,59,60,60,61,61,61,62,62,63,63,64
	.byte	64,64,65,65,66,66,67,67,68,68,69,69,70,70,71,71
	.byte	72,73,73,74,74,75,76,76,77,77,78,79,79,80,81,82
	.byte	82,83,84,85,85,86,87,88,89,89,90,91,92,93,94,95
	.byte	96,97,98,99,100,101,102,104,105,106,107,108,110,111,112,114
	.byte	115,117,118,120,121,123,125,126,127,127,127,127,127,127,127,127

	.byte	29,29,29,29,29,29,29,29,30,30,30,30,30,30,30,30
	.byte	30,30,31,31,31,31,31,31,31,31,31,31,32,32,32,32
	.byte	32,32,32,32,32,33,33,33,33,33,33,33,33,34,34,34
	.byte	34,34,34,34,34,35,35,35,35,35,35,35,35,36,36,36
	.byte	36,36,36,36,37,37,37,37,37,37,37,38,38,38,38,38
	.byte	38,39,39,39,39,39,39,40,40,40,40,40,40,41,41,41
	.byte	41,41,42,42,42,42,42,42,43,43,43,43,43,44,44,44
	.byte	44,45,45,45,45,45,46,46,46,46,47,47,47,47,48,48



 
;***************************************************
;OBJECT(S) - DONT GO TOO BIG OR BOOM ! 
;
;MAX (ROTATAED SIZE) IS +/- 63
;***************************************************
figure		.byte 		+32,+32,+32		;0
		.byte 		+32,+32,-32		;1
		.byte 		+32,-32,+32		;2
		.byte 		+32,-32,-32		;3
		.byte 		-32,+32,+32		;4
		.byte 		-32,+32,-32		;5
		.byte 		-32,-32,+32		;6
		.byte 		-32,-32,-32		;7


		.byte		0,0,0			;END OF LIST


;***************************************************
; BUFFER FOR ROTATED CENTERED POINTS
;***************************************************
newpoints	.byte		0,0
		.byte		0,0
		.byte		0,0
		.byte		0,0
		.byte		0,0
		.byte		0,0
		.byte		0,0
		.byte		0,0

		.byte		$ff

;***************************************************
; WHICH POINTS TO CONNECT TO DESCRIBE OBJECT
;***************************************************
; CUBE VERTICIES		
;***************************************************
vertfig		.byte		0,1
		.byte		1,3
		.byte		3,2
		.byte		2,0
		.byte		2,6
		.byte		6,4
		.byte		4,5
		.byte		5,1
		.byte		4,0
		.byte		6,7
		.byte		7,5
		.byte		3,7

		.byte		$80			;end line list


		.end	START