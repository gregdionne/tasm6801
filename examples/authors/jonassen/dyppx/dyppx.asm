;***********************************
;
; HIRES SINUS SCROLL
; MADE BY SIMON JONASSEN (2014)
;
; THIS VERSION WORKS ON PAL & NTSC
;
; THIS WILL NUKE YOUR DOS AS THE 
; SCREEN OFFSET HASN*T BEEN ADJUSTED
;
;***********************************
		.msfirst
		
#define EQU     .EQU
#define ORG     .ORG
#define RMB     .BLOCK
#define FCC     .TEXT
#define FDB     .WORD
#define END	.END

#define equ     .EQU
#define org     .ORG
#define rmb     .BLOCK
#define fcc     .TEXT
#define fdb     .WORD
#define	end	.END

start	org	$5000

scrofs	equ	$4c00		;(end of 3k screen for scroll buffer)
	
	ldaa	#$74		;($74/$78)
	staa	$bfff



	jsr	setup
loop	
	jsr	plotter		;plot char

	jsr 	scroll		;scroll invisible area 1px
	jsr	makeit		;calc new tops


	ldx	#$800		;DELAY (irq music will take care of this)
lll	dex
	bne	lll

	ldaa	zzz+2
	adda	#-5		;y speed (remember to increase delete -5)
	staa	zzz+2


	jmp	loop


;***********************************
;MAKE A NEW SET OF COORDINATES
;FOR THE NEXT FRAME (ONLY TOPS)
;***********************************
makeit	ldx	#tops
spos	ldab	sintab
	ldaa	#16
doit	mul
	addd	#$4280
	std	,x
	inx
	inx
	ldaa	>spos+2
	adda	#-2		;Frequency (2)
	staa	>spos+2
	cpx	#tops+32
	bne	spos
zzz	ldd	#sintab
	std	>spos+1

	rts	
;***********************************
; SCROLL THE INVISIBLE AREA 1PX
; USING ROL (CARRY FALLS OFF)
;***********************************

scroll	
	ldx	#scrofs	
	ldaa	#16		;(16 lines)
	tab
rolit	clc

	rol	15,x
	rol	14,x
	rol	13,x
	rol	12,x
	rol	11,x
	rol	10,x
	rol	9,x
	rol	8,x
	rol	7,x
	rol	6,x
	rol	5,x
	rol	4,x
	rol	3,x
	rol	2,x
	rol	1,x
	rol	,x
	abx		;leax 32,x (next row)
	deca
	bne	rolit

	dec	xptr
	bne	out

	stab	xptr
	jsr	newchar
out	rts


;***********************************
; PLOT A NEW CHAR FROM THE TEXT
; WHEN 16 PIXELS ARE DONE
;***********************************

newchar	ldx	#chars

tptr	ldab	text
	bpl	nxt
	ldd	#text		;end of scroll ($ff)

	std	tptr+1
	bra	tptr
	
nxt	subb	#32
	aslb	
	abx

line0	ldd	,x
	std	scrofs+14

	ldab	#120
	abx

line1	ldd	,x
	std	scrofs+30
	ldab	#120
	abx


line2	ldd	,x
	std	scrofs+46
	ldab	#120
	abx

line3	ldd	,x
	std	scrofs+62
	ldab	#120
	abx

line4	ldd	,x
	std	scrofs+78
	ldab	#120
	abx

line5	ldd	,x
	std	scrofs+94
	ldab	#120
	abx

line6	ldd	,x
	std	scrofs+110
	ldab	#120
	abx

line7	ldd	,x
	std	scrofs+126
	ldab	#120
	abx

line8	ldd	,x
	std	scrofs+142
	ldab	#120
	abx

line9	ldd	,x
	std	scrofs+158
	ldab	#120
	abx

linea	ldd	,x
	std	scrofs+174
	ldab	#120
	abx

lineb	ldd	,x
	std	scrofs+190
	ldab	#120
	abx

linec	ldd	,x
	std	scrofs+206
	ldab	#120
	abx

lined	ldd	,x
	std	scrofs+222
	ldab	#120
	abx

linee	ldd	,x
	std	scrofs+238
	ldab	#120
	abx

linef	ldd	,x
	std	scrofs+254

	inc	tptr+2		;next char
	rts





;***********************************
; MASSIVE PLOT ROUTINE
;***********************************


plotter	ldx	tops
	ldab	#16
	clra
	staa	,x
	abx
	staa	,x
	abx
	staa	,x
	abx
	staa	,x	
	abx
	staa	,x	

	ldaa	scrofs
	staa	,x

	ldaa	scrofs+16
	abx
	staa	,x
	ldaa	scrofs+32
	abx
	staa	,x
	ldaa	scrofs+48
	abx
	staa	,x
	ldaa	scrofs+64
	abx
	staa	,x
	ldaa	scrofs+80
	abx
	staa	,x
	ldaa	scrofs+96
	abx
	staa	,x
	ldaa	scrofs+112
	abx
	staa	,x
	ldaa	scrofs+128
	abx
	staa	,x
	ldaa	scrofs+144
	abx
	staa	,x
	ldaa	scrofs+160
	abx
	staa	,x
	ldaa	scrofs+176
	abx
	staa	,x
	ldaa	scrofs+192
	abx	
	staa	,x
	ldaa	scrofs+208
	abx
	staa	,x
	ldaa	scrofs+224
	abx
	staa	,x
	ldaa	scrofs+240
	abx	
	staa	,x
	clra
	abx
	staa	,x
	abx
	staa	,x
	abx
	staa	,x
	abx
	staa	,x


;***********************************

	ldx	tops+2

	clra
	staa	1,x
	abx
	staa	1,x
	abx
	staa	1,x
	abx
	staa	1,x	
	abx
	staa	1,x	


	ldaa	scrofs+1
	staa	1,x
	ldaa	scrofs+16+1
	abx
	staa	1,x
	ldaa	scrofs+32+1
	abx
	staa	1,x
	ldaa	scrofs+48+1
	abx
	staa	1,x
	ldaa	scrofs+64+1
	abx
	staa	1,x
	ldaa	scrofs+80+1
	abx
	staa	1,x
	ldaa	scrofs+96+1
	abx
	staa	1,x
	ldaa	scrofs+112+1
	abx
	staa	1,x
	ldaa	scrofs+128+1
	abx
	staa	1,x
	ldaa	scrofs+144+1
	abx
	staa	1,x
	ldaa	scrofs+160+1
	abx
	staa	1,x
	ldaa	scrofs+176+1
	abx
	staa	1,x
	ldaa	scrofs+192+1
	abx	
	staa	1,x
	ldaa	scrofs+208+1
	abx
	staa	1,x
	ldaa	scrofs+224+1
	abx
	staa	1,x
	ldaa	scrofs+240+1
	abx	
	staa	1,x
	clra
	abx
	staa	1,x
	abx
	staa	1,x
	abx
	staa	1,x
	abx
	staa	1,x

;***********************************

	ldx	tops+4
	clra
	staa	2,x
	abx
	staa	2,x
	abx
	staa	2,x
	abx
	staa	2,x	
	abx
	staa	2,x	

	ldaa	scrofs+2
	staa	2,x
	ldaa	scrofs+16+2
	abx
	staa	2,x
	ldaa	scrofs+32+2
	abx
	staa	2,x
	ldaa	scrofs+48+2
	abx
	staa	2,x
	ldaa	scrofs+64+2
	abx
	staa	2,x
	ldaa	scrofs+80+2
	abx
	staa	2,x
	ldaa	scrofs+96+2
	abx
	staa	2,x
	ldaa	scrofs+112+2
	abx
	staa	2,x
	ldaa	scrofs+128+2
	abx
	staa	2,x
	ldaa	scrofs+144+2
	abx
	staa	2,x
	ldaa	scrofs+160+2
	abx
	staa	2,x
	ldaa	scrofs+176+2
	abx
	staa	2,x
	ldaa	scrofs+192+2
	abx	
	staa	2,x
	ldaa	scrofs+208+2
	abx
	staa	2,x
	ldaa	scrofs+224+2
	abx
	staa	2,x
	ldaa	scrofs+240+2
	abx	
	staa	2,x
	clra
	abx
	staa	2,x
	abx
	staa	2,x
	abx
	staa	2,x
	abx
	staa	2,x



;***********************************

	ldx	tops+6
	clra
	staa	3,x
	abx
	staa	3,x
	abx
	staa	3,x
	abx
	staa	3,x	
	abx
	staa	3,x	


	ldaa	scrofs+3
	staa	3,x
	ldaa	scrofs+16+3
	abx
	staa	3,x
	ldaa	scrofs+32+3
	abx
	staa	3,x
	ldaa	scrofs+48+3
	abx
	staa	3,x
	ldaa	scrofs+64+3
	abx
	staa	3,x
	ldaa	scrofs+80+3
	abx
	staa	3,x
	ldaa	scrofs+96+3
	abx
	staa	3,x
	ldaa	scrofs+112+3
	abx
	staa	3,x
	ldaa	scrofs+128+3
	abx
	staa	3,x
	ldaa	scrofs+144+3
	abx
	staa	3,x
	ldaa	scrofs+160+3
	abx
	staa	3,x
	ldaa	scrofs+176+3
	abx
	staa	3,x
	ldaa	scrofs+192+3
	abx	
	staa	3,x
	ldaa	scrofs+208+3
	abx
	staa	3,x
	ldaa	scrofs+224+3
	abx
	staa	3,x
	ldaa	scrofs+240+3
	abx	
	staa	3,x
	clra
	abx
	staa	3,x
	abx
	staa	3,x
	abx
	staa	3,x

	abx
	staa	3,x

;***********************************

	ldx	tops+8
	clra
	staa	4,x
	abx
	staa	4,x
	abx
	staa	4,x
	abx
	staa	4,x	
	abx
	staa	4,x	

	ldaa	scrofs+4
	staa	4,x
	ldaa	scrofs+16+4
	abx
	staa	4,x
	ldaa	scrofs+32+4
	abx
	staa	4,x
	ldaa	scrofs+48+4
	abx
	staa	4,x
	ldaa	scrofs+64+4
	abx
	staa	4,x
	ldaa	scrofs+80+4
	abx
	staa	4,x
	ldaa	scrofs+96+4
	abx
	staa	4,x
	ldaa	scrofs+112+4
	abx
	staa	4,x
	ldaa	scrofs+128+4
	abx
	staa	4,x
	ldaa	scrofs+144+4
	abx
	staa	4,x
	ldaa	scrofs+160+4
	abx
	staa	4,x
	ldaa	scrofs+176+4
	abx
	staa	4,x
	ldaa	scrofs+192+4
	abx	
	staa	4,x
	ldaa	scrofs+208+4
	abx
	staa	4,x
	ldaa	scrofs+224+4
	abx
	staa	4,x
	ldaa	scrofs+240+4
	abx	
	staa	4,x
	clra
	abx
	staa	4,x
	abx
	staa	4,x
	abx
	staa	4,x

	abx
	staa	4,x


;***********************************

	ldx	tops+10

	clra
	staa	5,x
	abx
	staa	5,x
	abx
	staa	5,x
	abx
	staa	5,x	
	abx
	staa	5,x	
	ldaa	scrofs+5
	staa	5,x
	ldaa	scrofs+16+5
	abx
	staa	5,x
	ldaa	scrofs+32+5
	abx
	staa	5,x
	ldaa	scrofs+48+5
	abx
	staa	5,x
	ldaa	scrofs+64+5
	abx
	staa	5,x
	ldaa	scrofs+80+5
	abx
	staa	5,x
	ldaa	scrofs+96+5
	abx
	staa	5,x
	ldaa	scrofs+112+5
	abx
	staa	5,x
	ldaa	scrofs+128+5
	abx
	staa	5,x
	ldaa	scrofs+144+5
	abx
	staa	5,x
	ldaa	scrofs+160+5
	abx
	staa	5,x
	ldaa	scrofs+176+5
	abx
	staa	5,x
	ldaa	scrofs+192+5
	abx	
	staa	5,x
	ldaa	scrofs+208+5
	abx
	staa	5,x
	ldaa	scrofs+224+5
	abx
	staa	5,x
	ldaa	scrofs+240+5
	abx	
	staa	5,x
	clra
	abx
	staa	5,x
	abx
	staa	5,x
	abx
	staa	5,x
	abx
	staa	5,x


;***********************************

	ldx	tops+12

	clra
	staa	6,x
	abx
	staa	6,x
	abx
	staa	6,x
	abx
	staa	6,x	
	abx
	staa	6,x	


	ldaa	scrofs+6
	staa	6,x
	ldaa	scrofs+16+6
	abx
	staa	6,x
	ldaa	scrofs+32+6
	abx
	staa	6,x
	ldaa	scrofs+48+6
	abx
	staa	6,x
	ldaa	scrofs+64+6
	abx
	staa	6,x
	ldaa	scrofs+80+6
	abx
	staa	6,x
	ldaa	scrofs+96+6
	abx
	staa	6,x
	ldaa	scrofs+112+6
	abx
	staa	6,x
	ldaa	scrofs+128+6
	abx
	staa	6,x
	ldaa	scrofs+144+6
	abx
	staa	6,x
	ldaa	scrofs+160+6
	abx
	staa	6,x
	ldaa	scrofs+176+6
	abx
	staa	6,x
	ldaa	scrofs+192+6
	abx	
	staa	6,x
	ldaa	scrofs+208+6
	abx
	staa	6,x
	ldaa	scrofs+224+6
	abx
	staa	6,x
	ldaa	scrofs+240+6
	abx	
	staa	6,x
	clra
	abx
	staa	6,x
	abx
	staa	6,x
	abx
	staa	6,x

	abx
	staa	6,x

;***********************************

	ldx	tops+14

	clra
	staa	7,x
	abx
	staa	7,x
	abx
	staa	7,x
	abx
	staa	7,x	
	abx
	staa	7,x	

	ldaa	scrofs+7
	staa	7,x
	ldaa	scrofs+16+7
	abx
	staa	7,x
	ldaa	scrofs+32+7
	abx
	staa	7,x
	ldaa	scrofs+48+7
	abx
	staa	7,x
	ldaa	scrofs+64+7
	abx
	staa	7,x
	ldaa	scrofs+80+7
	abx
	staa	7,x
	ldaa	scrofs+96+7
	abx
	staa	7,x
	ldaa	scrofs+112+7
	abx
	staa	7,x
	ldaa	scrofs+128+7
	abx
	staa	7,x
	ldaa	scrofs+144+7
	abx
	staa	7,x
	ldaa	scrofs+160+7
	abx
	staa	7,x
	ldaa	scrofs+176+7
	abx
	staa	7,x
	ldaa	scrofs+192+7
	abx	
	staa	7,x
	ldaa	scrofs+208+7
	abx
	staa	7,x
	ldaa	scrofs+224+7
	abx
	staa	7,x
	ldaa	scrofs+240+7
	abx	
	staa	7,x
	clra
	abx
	staa	7,x
	abx
	staa	7,x
	abx
	staa	7,x

	abx
	staa	7,x

;***********************************

	ldx	tops+16

	clra
	staa	8,x
	abx
	staa	8,x
	abx
	staa	8,x
	abx
	staa	8,x	
	abx
	staa	8,x	

	ldaa	scrofs+8
	staa	8,x
	ldaa	scrofs+16+8
	abx
	staa	8,x
	ldaa	scrofs+32+8
	abx
	staa	8,x
	ldaa	scrofs+48+8
	abx
	staa	8,x
	ldaa	scrofs+64+8
	abx
	staa	8,x
	ldaa	scrofs+80+8
	abx
	staa	8,x
	ldaa	scrofs+96+8
	abx
	staa	8,x
	ldaa	scrofs+112+8
	abx
	staa	8,x
	ldaa	scrofs+128+8
	abx
	staa	8,x
	ldaa	scrofs+144+8
	abx
	staa	8,x
	ldaa	scrofs+160+8
	abx
	staa	8,x
	ldaa	scrofs+176+8
	abx
	staa	8,x
	ldaa	scrofs+192+8
	abx	
	staa	8,x
	ldaa	scrofs+208+8
	abx
	staa	8,x
	ldaa	scrofs+224+8
	abx
	staa	8,x
	ldaa	scrofs+240+8
	abx	
	staa	8,x
	clra
	abx
	staa	8,x
	abx
	staa	8,x
	abx
	staa	8,x
	abx
	staa	8,x
	

;***********************************

	ldx	tops+18

	clra
	staa	9,x
	abx
	staa	9,x
	abx
	staa	9,x
	abx
	staa	9,x	
	abx
	staa	9,x	

	ldaa	scrofs+9
	staa	9,x
	ldaa	scrofs+16+9
	abx
	staa	9,x
	ldaa	scrofs+32+9
	abx
	staa	9,x
	ldaa	scrofs+48+9
	abx
	staa	9,x
	ldaa	scrofs+64+9
	abx
	staa	9,x
	ldaa	scrofs+80+9
	abx
	staa	9,x
	ldaa	scrofs+96+9
	abx
	staa	9,x
	ldaa	scrofs+112+9
	abx
	staa	9,x
	ldaa	scrofs+128+9
	abx
	staa	9,x
	ldaa	scrofs+144+9
	abx
	staa	9,x
	ldaa	scrofs+160+9
	abx
	staa	9,x
	ldaa	scrofs+176+9
	abx
	staa	9,x
	ldaa	scrofs+192+9
	abx	
	staa	9,x
	ldaa	scrofs+208+9
	abx
	staa	9,x
	ldaa	scrofs+224+9
	abx
	staa	9,x
	ldaa	scrofs+240+9
	abx	
	staa	9,x
	clra
	abx
	staa	9,x
	abx
	staa	9,x
	abx
	staa	9,x
	abx
	staa	9,x


;***********************************

	ldx	tops+20


	clra
	staa	10,x
	abx
	staa	10,x
	abx
	staa	10,x
	abx
	staa	10,x	
	abx
	staa	10,x	


	ldaa	scrofs+10
	staa	10,x
	ldaa	scrofs+16+10
	abx
	staa	10,x
	ldaa	scrofs+32+10
	abx
	staa	10,x
	ldaa	scrofs+48+10
	abx
	staa	10,x
	ldaa	scrofs+64+10
	abx
	staa	10,x
	ldaa	scrofs+80+10
	abx
	staa	10,x
	ldaa	scrofs+96+10
	abx
	staa	10,x
	ldaa	scrofs+112+10
	abx
	staa	10,x
	ldaa	scrofs+128+10
	abx
	staa	10,x
	ldaa	scrofs+144+10
	abx
	staa	10,x
	ldaa	scrofs+160+10
	abx
	staa	10,x
	ldaa	scrofs+176+10
	abx
	staa	10,x
	ldaa	scrofs+192+10
	abx	
	staa	10,x
	ldaa	scrofs+208+10
	abx
	staa	10,x
	ldaa	scrofs+224+10
	abx
	staa	10,x
	ldaa	scrofs+240+10
	abx	
	staa	10,x
	clra
	abx
	staa	10,x
	abx
	staa	10,x
	abx
	staa	10,x
	abx
	staa	10,x


;***********************************

	ldx	tops+22

	clra
	staa	11,x
	abx
	staa	11,x
	abx
	staa	11,x
	abx
	staa	11,x	
	abx
	staa	11,x	

	ldaa	scrofs+11
	staa	11,x
	ldaa	scrofs+16+11
	abx
	staa	11,x
	ldaa	scrofs+32+11
	abx
	staa	11,x
	ldaa	scrofs+48+11
	abx
	staa	11,x
	ldaa	scrofs+64+11
	abx
	staa	11,x
	ldaa	scrofs+80+11
	abx
	staa	11,x
	ldaa	scrofs+96+11
	abx
	staa	11,x
	ldaa	scrofs+112+11
	abx
	staa	11,x
	ldaa	scrofs+128+11
	abx
	staa	11,x
	ldaa	scrofs+144+11
	abx
	staa	11,x
	ldaa	scrofs+160+11
	abx
	staa	11,x
	ldaa	scrofs+176+11
	abx
	staa	11,x
	ldaa	scrofs+192+11
	abx	
	staa	11,x
	ldaa	scrofs+208+11
	abx
	staa	11,x
	ldaa	scrofs+224+11
	abx
	staa	11,x
	ldaa	scrofs+240+11
	abx	
	staa	11,x
	clra
	abx
	staa	11,x
	abx
	staa	11,x
	abx
	staa	11,x
	abx
	staa	11,x

;***********************************

	ldx	tops+24

	clra
	staa	12,x
	abx
	staa	12,x
	abx
	staa	12,x
	abx
	staa	12,x	
	abx
	staa	12,x	

	ldaa	scrofs+12
	staa	12,x
	ldaa	scrofs+16+12
	abx
	staa	12,x
	ldaa	scrofs+32+12
	abx
	staa	12,x
	ldaa	scrofs+48+12
	abx
	staa	12,x
	ldaa	scrofs+64+12
	abx
	staa	12,x
	ldaa	scrofs+80+12
	abx
	staa	12,x
	ldaa	scrofs+96+12
	abx
	staa	12,x
	ldaa	scrofs+112+12
	abx
	staa	12,x
	ldaa	scrofs+128+12
	abx
	staa	12,x
	ldaa	scrofs+144+12
	abx
	staa	12,x
	ldaa	scrofs+160+12
	abx
	staa	12,x
	ldaa	scrofs+176+12
	abx
	staa	12,x
	ldaa	scrofs+192+12
	abx	
	staa	12,x
	ldaa	scrofs+208+12
	abx
	staa	12,x
	ldaa	scrofs+224+12
	abx
	staa	12,x
	ldaa	scrofs+240+12
	abx	
	staa	12,x
	clra
	abx
	staa	12,x
	abx
	staa	12,x
	abx
	staa	12,x

	abx
	staa	12,x

;***********************************

	ldx	tops+26
	clra
	staa	13,x
	abx
	staa	13,x
	abx
	staa	13,x
	abx
	staa	13,x	
	abx
	staa	13,x	

	ldaa	scrofs+13
	staa	13,x
	ldaa	scrofs+16+13
	abx
	staa	13,x
	ldaa	scrofs+32+13
	abx
	staa	13,x
	ldaa	scrofs+48+13
	abx
	staa	13,x
	ldaa	scrofs+64+13
	abx
	staa	13,x
	ldaa	scrofs+80+13
	abx
	staa	13,x
	ldaa	scrofs+96+13
	abx
	staa	13,x
	ldaa	scrofs+112+13
	abx
	staa	13,x
	ldaa	scrofs+128+13
	abx
	staa	13,x
	ldaa	scrofs+144+13
	abx
	staa	13,x
	ldaa	scrofs+160+13
	abx
	staa	13,x
	ldaa	scrofs+176+13
	abx
	staa	13,x
	ldaa	scrofs+192+13
	abx	
	staa	13,x
	ldaa	scrofs+208+13
	abx
	staa	13,x
	ldaa	scrofs+224+13
	abx
	staa	13,x
	ldaa	scrofs+240+13
	abx	
	staa	13,x
	clra
	abx
	staa	13,x
	abx
	staa	13,x
	abx
	staa	13,x
	abx
	staa	13,x

;***********************************

	ldx	tops+28

	clra
	staa	14,x
	abx
	staa	14,x
	abx
	staa	14,x
	abx
	staa	14,x	
	abx
	staa	14,x	

	ldaa	scrofs+14
	staa	14,x
	ldaa	scrofs+16+14
	abx
	staa	14,x
	ldaa	scrofs+32+14
	abx
	staa	14,x
	ldaa	scrofs+48+14
	abx
	staa	14,x
	ldaa	scrofs+64+14
	abx
	staa	14,x
	ldaa	scrofs+80+14
	abx
	staa	14,x
	ldaa	scrofs+96+14
	abx
	staa	14,x
	ldaa	scrofs+112+14
	abx
	staa	14,x
	ldaa	scrofs+128+14
	abx
	staa	14,x
	ldaa	scrofs+144+14
	abx
	staa	14,x
	ldaa	scrofs+160+14
	abx
	staa	14,x
	ldaa	scrofs+176+14
	abx
	staa	14,x
	ldaa	scrofs+192+14
	abx	
	staa	14,x
	ldaa	scrofs+208+14
	abx
	staa	14,x
	ldaa	scrofs+224+14
	abx
	staa	14,x
	ldaa	scrofs+240+14
	abx	
	staa	14,x

	clra
	abx
	staa	14,x
	abx
	staa	14,x
	abx
	staa	14,x
	abx
	staa	14,x

;***********************************

	ldx	tops+30
	clra
	staa	15,x
	abx
	staa	15,x
	abx
	staa	15,x
	abx
	staa	15,x	
	abx
	staa	15,x	

	ldaa	scrofs+15
	staa	15,x
	ldaa	scrofs+16+15
	abx
	staa	15,x
	ldaa	scrofs+32+15
	abx
	staa	15,x
	ldaa	scrofs+48+15
	abx
	staa	15,x
	ldaa	scrofs+64+15
	abx
	staa	15,x
	ldaa	scrofs+80+15
	abx
	staa	15,x
	ldaa	scrofs+96+15
	abx
	staa	15,x
	ldaa	scrofs+112+15
	abx
	staa	15,x
	ldaa	scrofs+128+15
	abx
	staa	15,x
	ldaa	scrofs+144+15
	abx
	staa	15,x
	ldaa	scrofs+160+15
	abx
	staa	15,x
	ldaa	scrofs+176+15
	abx
	staa	15,x
	ldaa	scrofs+192+15
	abx	
	staa	15,x
	ldaa	scrofs+208+15
	abx
	staa	15,x
	ldaa	scrofs+224+15
	abx
	staa	15,x
	ldaa	scrofs+240+15
	abx	
	staa	15,x
	clra
	abx
	staa	15,x
	abx
	staa	15,x
	abx
	staa	15,x
	abx
	staa	15,x


	rts

;***********************************
; SETUP CLS ETC
;***********************************
setup	ldx	#$4000
	ldd	#0
cls	std	,x
	inx
	inx	
	cpx	#$4000+3072
	bne	cls

	rts

;***********************************
;VARS
;***********************************
xptr	.byte	16



;***********************************
; PAGE ALIGNED 256 BYTE SINUstaaBLE
;***********************************
	.ORG  (($+0FFH) & 0FF00H)

sintab	.byte		32,32,33,34,35,35,36,37,38,38,39,40,41,41,42,43
	.byte		44,44,45,46,46,47,48,48,49,50,50,51,51,52,53,53
	.byte		54,54,55,55,56,56,57,57,58,58,59,59,59,60,60,60
	.byte		61,61,61,61,62,62,62,62,62,63,63,63,63,63,63,63
	.byte		63,63,63,63,63,63,63,63,62,62,62,62,62,61,61,61
	.byte		61,60,60,60,59,59,59,58,58,57,57,56,56,55,55,54
	.byte		54,53,53,52,51,51,50,50,49,48,48,47,46,46,45,44
	.byte		44,43,42,41,41,40,39,38,38,37,36,35,35,34,33,32

	.byte		32,31,30,29,28,28,27,26,25,25,24,23,22,22,21,20
	.byte		19,19,18,17,17,16,15,15,14,13,13,12,12,11,10,10
	.byte		9,9,8,8,7,7,6,6,5,5,4,4,4,3,3,3
	.byte		2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1
	.byte		1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2
	.byte		2,3,3,3,4,4,4,5,5,6,6,7,7,8,8,9
	.byte		9,10,10,11,12,12,13,13,14,15,15,16,17,17,18,19
	.byte		19,20,21,22,22,23,24,25,25,26,27,28,28,29,30,31


;***********************************
; CHARSET 16*16 px
;***********************************

chars	.byte	0,0,3,192,14,56,0,0,1,192,0,4,0,0,1,192
	.byte   1,240,7,192,1,0,0,0,0,0,0,0,0,0,0,16
	.byte 	7,224,0,192,7,224,127,224,120,30,127,254,7,224,127,224
	.byte	7,224,7,224,0,0,0,0,0,0,0,0,0,0,15,240
	.byte	0,0,0,112,127,128,7,224,127,0,7,224,7,224,7,224
	.byte	120,30,63,252,3,254,120,30,120,0,127,224,127,224,7,224
	.byte	127,224,7,224,127,224,15,240,63,252,120,30,120,30,120,30
	.byte	120,30,60,60,127,254,0,0,0,0,7,224,31,124,0,0
	.byte	1,192,28,14,6,0,3,224,3,224,3,224,3,128,3,192
	.byte	0,0,0,0,0,0,0,56,31,248,3,192,31,248,127,248
	.byte	120,30,127,254,31,248,127,248,31,248,31,248,0,0,0,0
	.byte	0,0,0,0,0,0,63,252,7,192,1,252,127,224,31,248
	.byte	127,192,31,248,31,248,31,248,120,30,63,252,3,254,120,30
	.byte	120,0,127,248,127,248,31,248,127,248,31,248,127,248,63,240
	.byte	63,252,120,30,120,30,123,222,120,30,60,60,127,254,0,0
	.byte	0,0,7,224,31,124,0,0,15,248,62,31,31,128,3,224
	.byte	7,192,1,240,51,152,3,192,0,0,0,0,0,0,0,124	
	.byte	60,60,15,192,60,60,0,60,120,30,120,0,60,60,127,252
	.byte	60,60,60,60,0,0,0,0,0,24,0,0,0,0,63,252
	.byte	28,112,3,252,112,240,60,60,113,224,60,60,60,60,60,60
	.byte	120,30,3,192,3,254,120,60,120,0,127,252,127,252,60,60	
	.byte	120,60,60,60,120,60,124,0,0,0,120,30,120,30,123,222
	.byte	124,62,60,60,0,30,0,0,0,0,7,224,31,124,0,0
	.byte	31,252,62,62,63,192,3,224,7,192,1,240,59,184,3,192
	.byte	0,0,0,0,0,0,0,254,56,28,15,192,56,30,0,28
	.byte	120,30,120,0,56,28,127,252,56,28,56,28,1,192,1,192
	.byte	0,24,255,254,28,112,127,254,48,24,7,30,112,112,56,28
	.byte	112,112,56,28,56,28,56,28,120,30,3,192,0,30,120,124
	.byte	120,0,120,60,120,60,56,28,120,30,56,28,120,30,120,0
	.byte	0,0,120,30,120,30,123,222,60,60,60,60,0,60,0,0
	.byte	0,0,7,192,15,60,0,0,31,252,62,124,48,192,1,224
	.byte	15,128,0,248,31,240,3,192,0,0,0,0,0,0,1,252	
	.byte	120,30,3,192,0,30,0,30,120,30,120,0,120,0,0,62
	.byte	120,30,56,30,3,224,3,224,0,24,255,254,34,136,120,30
	.byte	38,8,14,30,112,112,120,30,112,56,120,28,120,14,120,14
	.byte	120,30,3,192,0,30,121,248,120,0,120,30,120,30,120,30	
	.byte	120,30,120,30,120,30,120,0,30,0,120,30,120,30,123,222
	.byte	62,124,62,60,0,248,0,0,0,0,7,128,6,24,0,0
	.byte	29,192,28,248,48,6,0,192,15,128,0,248,15,224,3,192
	.byte	0,0,0,0,0,0,3,248,120,30,3,192,0,60,0,62
	.byte	120,30,120,0,124,0,0,30,124,62,60,62,3,224,3,224
	.byte	0,24,255,254,89,100,0,30,108,12,28,30,112,224,120,30
	.byte	112,28,120,60,120,14,120,14,120,30,3,192,0,30,127,240
	.byte	120,0,123,222,120,30,120,30,120,30,120,30,120,30,120,0
	.byte	30,0,120,30,120,30,123,222,31,56,31,252,3,240,0,0
	.byte	0,0,7,128,12,48,0,0,31,248,1,240,24,6,1,128
	.byte	15,128,0,248,63,248,127,254,0,0,127,255,0,0,7,240
	.byte	120,30,3,192,0,248,7,252,127,254,127,192,127,224,0,30
	.byte	63,252,31,254,3,224,3,224,6,24,255,254,80,68,0,28
	.byte	72,4,56,30,127,240,120,0,120,28,127,248,127,224,120,0	
	.byte	127,254,3,192,0,30,127,224,124,0,123,222,120,30,120,30
	.byte	120,60,120,30,120,62,60,0,30,0,120,30,120,30,123,222
	.byte	31,152,31,252,7,192,0,0,0,0,7,128,0,0,0,0
	.byte	31,252,3,224,63,238,0,0,15,128,0,248,127,252,127,254
	.byte	0,0,127,255,0,0,15,224,124,30,3,192,7,240,7,240	
	.byte	127,254,127,248,127,248,0,30,31,248,7,254,1,192,1,192
	.byte	6,24,0,0,64,4,0,60,64,4,56,30,127,248,124,0
	.byte	124,30,127,240,127,224,124,254,127,254,7,192,0,62,127,128
	.byte	126,0,123,222,120,30,120,30,127,248,120,30,127,252,31,224
	.byte	31,0,124,30,124,30,123,222,15,192,15,252,15,0,0,0
	.byte	0,0,3,0,0,0,0,0,15,252,7,192,63,236,0,0
	.byte	15,128,0,248,63,248,127,254,3,128,127,255,0,0,31,192
	.byte	126,30,3,192,31,192,7,252,0,126,1,252,120,60,0,62
	.byte	63,252,0,30,0,0,0,0,6,120,255,254,32,8,3,248
	.byte	64,4,120,30,124,60,126,0,124,30,127,192,126,0,126,254
	.byte	126,30,15,192,0,126,127,224,126,0,123,222,120,30,120,30
	.byte	127,224,124,222,127,248,7,248,31,128,126,30,62,60,120,30
	.byte	7,240,3,188,30,0,0,0,0,0,0,0,0,0,62,56
	.byte	1,220,15,156,120,28,0,0,15,128,0,248,15,224,127,254
	.byte	7,192,127,255,0,0,63,128,126,30,3,192,62,0,0,126
	.byte	0,126,0,126,120,60,0,126,120,30,120,30,1,192,1,192
	.byte	6,248,255,254,16,16,3,224,96,12,124,30,124,30,126,30	
	.byte	124,30,124,0,126,0,126,30,126,30,15,192,120,126,127,240
	.byte	126,0,123,222,120,30,124,30,126,0,124,254,127,240,0,124
	.byte	31,128,126,30,63,124,120,62,51,248,0,124,62,0,0,0
	.byte	0,0,0,0,0,0,51,108,31,252,31,62,120,28,0,0
	.byte	15,128,0,248,31,240,3,192,7,192,0,0,3,128,127,0
	.byte	126,62,3,192,60,0,0,126,0,126,0,62,120,60,0,126
	.byte	120,30,120,62,3,224,3,224,6,248,255,254,8,32,0,0
	.byte	32,40,126,30,124,30,126,62,124,62,126,0,126,0,126,62
	.byte	126,30,15,192,124,126,120,248,126,0,123,222,124,30,124,62
	.byte	126,0,124,124,126,248,0,62,31,252,126,62,31,248,127,254
	.byte	57,252,0,252,62,0,0,0,0,0,3,0,0,0,51,108
	.byte	31,252,62,62,127,252,0,0,7,192,1,240,59,184,3,192
	.byte	7,192,0,0,7,192,254,0,63,252,31,248,127,254,127,252
	.byte	0,126,127,254,63,252,0,126,63,252,63,252,3,224,3,224
	.byte	30,112,255,254,4,64,3,192,48,24,126,30,127,254,63,252
	.byte	127,252,63,254,126,0,63,252,126,62,63,252,63,252,120,124
	.byte	63,254,123,222,126,30,63,252,126,0,63,252,126,124,127,254
	.byte	15,252,63,252,15,240,127,252,124,252,63,248,127,254,0,0
	.byte	0,0,7,128,0,0,59,56,15,248,124,62,63,254,0,0
	.byte	7,192,1,240,51,152,3,192,3,192,0,0,7,192,124,0
	.byte	63,252,31,248,127,254,127,252,0,126,127,254,63,252,0,126
	.byte	63,252,63,252,3,224,3,224,62,0,0,0,2,128,3,192
	.byte	28,112,127,222,127,254,63,252,127,252,63,254,126,0,63,252
	.byte	126,62,63,252,63,252,120,124,63,254,123,222,126,30,63,252
	.byte	126,0,63,252,126,62,127,252,15,252,63,252,7,224,127,252
	.byte	126,126,63,248,127,254,0,0,0,0,7,128,0,0,59,0,1
	.byte	192,56,28,63,246,0,0,3,224,3,224,3,128,3,192,1	
	.byte	128,0,0,7,192,56,0,31,248,31,248,127,254,127,248,0
	.byte	126,127,252,31,248,0,126,31,248,31,248,1,192,1,224,62
	.byte	0,0,0,1,0,3,192,7,192,127,222,127,252,31,248,127
	.byte	248,31,254,126,0,31,248,126,62,63,252,31,248,120,62,31
	.byte	254,123,222,126,30,31,248,126,0,31,254,126,62,127,248,7
	.byte	252,31,248,3,192,127,248,124,62,63,240,127,254,0,0
	.byte	0,0,3,0,0,0,59,124,1,192,16,0,15,230,0,0
	.byte	1,240,7,192,1,0,3,192,3,0,0,0,3,128,16,0
	.byte	7,224,31,248,127,254,127,224,0,126,127,240,7,224,0,126
	.byte	7,224,7,224,0,0,0,192,28,0,0,0,0,0,3,192
	.byte	0,0,63,222,127,240,7,224,127,224,7,254,126,0,7,224
	.byte	126,62,63,252,7,224,120,62,7,254,123,222,126,30,7,224
	.byte	126,0,7,142,126,62,127,224,3,252,7,224,1,128,127,224
	.byte	124,62,63,192,127,254,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,128
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;***********************************
; PAGE ALIGNED TEXT STRING
;***********************************
	.ORG  (($+0FFH) & 0FF00H)
	
text	
	fcc	" ........ TESTING THE MC10 SINUS SCROLLER...... "
	fcc	"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.,:;()*?-+/!#%& "

	.byte	$ff,$ff

tops	rmb	64
;***********************************
;END DIRECTIVE
;***********************************
	end	start