;***********************************
; BARREL ROLL LOGO
; SIMON JONASSEN 2015
;***********************************
	.msfirst
start	.org	$5000

	jsr	setup

loop

	inc	y1+2
	inc	y2+2
	inc	y3+2
	inc	y4+2
	inc	y5+2
	inc	y6+2
	inc	y7+2
	inc	y8+2
	inc	y9+2
	inc	y10+2
	inc	y11+2
	inc	y12+2
	inc	y13+2
	inc	y14+2
	inc	y15+2
	inc	y16+2
	inc	y17+2
	inc	y18+2
	inc	y19+2
	inc	y20+2

	jsr	rotate
;***********************************
; BIG FAT DELAY
;***********************************


	ldx	#$600
delay	dex
	bne	delay


	jmp	loop


;***********************************
; JUMP THE GRAPHICS 
;***********************************
jump	ldx	#$400

pl1	ldd	img		
	std	,x
	inx
	inx	
	ldd	pl1+1
	addd	#2
	std	pl1+1
pl2	cpx	#$6c0
	bne	pl1

	ldd	#img
	std	pl1+1
	rts

;***********************************
; ROTATE ABOUT X AXIS
;***********************************
	
rotate	ldx	#ytab		
y1	ldab	sintab			
	aslb			
	stab	pt1+1
pt1	ldx	128,x		
ip	ldd	img		
	std	,x		
	ldd	img+2		
	std	2,x		
	ldd	img+4		
	std	4,x		
	ldd	img+6		
	std	6,x		
	ldd	img+8		
	std	8,x		
	ldd	img+10		
	std	10,x		
	ldd	img+12		
	std	12,x		
	ldd	img+14		
	std	14,x		
	ldd	img+16		
	std	16,x		
	ldd	img+18		
	std	18,x		
	ldd	img+20		
	std	20,x		
	ldd	img+22		
	std	22,x		
	ldd	img+24		
	std	24,x		
	ldd	img+26		
	std	26,x		
	ldd	img+28		
	std	28,x		
	ldd	img+30		
	std	30,x		

	ldx	#ytab
y2	ldab	sintab+2
	aslb
	stab	pt2+1
pt2	ldx	128,x
	ldd	img+32
	std	,x
	ldd	img+34
	std	2,x
	ldd	img+36
	std	4,x
	ldd	img+38
	std	6,x
	ldd	img+40
	std	8,x
	ldd	img+42
	std	10,x
	ldd	img+44
	std	12,x
	ldd	img+46
	std	14,x
	ldd	img+48
	std	16,x
	ldd	img+50
	std	18,x
	ldd	img+52
	std	20,x
	ldd	img+54
	std	22,x
	ldd	img+56
	std	24,x
	ldd	img+58
	std	26,x
	ldd	img+60
	std	28,x
	ldd	img+62
	std	30,x


	ldx	#ytab
y3	ldab	sintab+4
	aslb
	stab	pt3+1
pt3	ldx	128,x
	ldd	img+64
	std	,x
	ldd	img+66
	std	2,x
	ldd	img+68
	std	4,x
	ldd	img+70
	std	6,x
	ldd	img+72
	std	8,x
	ldd	img+74
	std	10,x
	ldd	img+76
	std	12,x
	ldd	img+78
	std	14,x
	ldd	img+80
	std	16,x
	ldd	img+82
	std	18,x
	ldd	img+84
	std	20,x
	ldd	img+86
	std	22,x
	ldd	img+88
	std	24,x
	ldd	img+90
	std	26,x
	ldd	img+92
	std	28,x
	ldd	img+94
	std	30,x


	ldx	#ytab
y4	ldab	sintab+6
	aslb
	stab	pt4+1
pt4	ldx	128,x
	ldd	img+96
	std	,x
	ldd	img+98
	std	2,x
	ldd	img+100
	std	4,x
	ldd	img+102
	std	6,x
	ldd	img+104
	std	8,x
	ldd	img+106
	std	10,x
	ldd	img+108
	std	12,x
	ldd	img+110
	std	14,x
	ldd	img+112
	std	16,x
	ldd	img+114
	std	18,x
	ldd	img+116
	std	20,x
	ldd	img+118
	std	22,x
	ldd	img+120
	std	24,x
	ldd	img+122
	std	26,x
	ldd	img+124
	std	28,x
	ldd	img+126
	std	30,x

	ldx	#ytab
y5	ldab	sintab+8
	aslb	
	stab	pt5+1
pt5	ldx	128,x
	ldd	img+128
	std	,x
	ldd	img+130
	std	2,x
	ldd	img+132
	std	4,x
	ldd	img+134
	std	6,x
	ldd	img+136
	std	8,x
	ldd	img+138
	std	10,x
	ldd	img+140
	std	12,x
	ldd	img+142
	std	14,x
	ldd	img+144
	std	16,x
	ldd	img+146
	std	18,x
	ldd	img+148
	std	20,x
	ldd	img+150
	std	22,x
	ldd	img+152
	std	24,x
	ldd	img+154
	std	26,x
	ldd	img+156
	std	28,x
	ldd	img+158
	std	30,x


	ldx	#ytab
y6	ldab	sintab+10
	aslb
	stab	pt6+1
pt6	ldx	128,x
	ldd	img+160
	std	,x
	ldd	img+162
	std	2,x
	ldd	img+164
	std	4,x
	ldd	img+166
	std	6,x
	ldd	img+168
	std	8,x
	ldd	img+170
	std	10,x
	ldd	img+172
	std	12,x
	ldd	img+174
	std	14,x
	ldd	img+176
	std	16,x
	ldd	img+178
	std	18,x
	ldd	img+180
	std	20,x
	ldd	img+182
	std	22,x
	ldd	img+184
	std	24,x
	ldd	img+186
	std	26,x
	ldd	img+188
	std	28,x
	ldd	img+190
	std	30,x
	

	ldx	#ytab
y7	ldab	sintab+12
	aslb
	stab	pt7+1
pt7	ldx	128,x
	ldd	img+192
	std	,x
	ldd	img+194
	std	2,x
	ldd	img+196
	std	4,x
	ldd	img+198
	std	6,x
	ldd	img+200
	std	8,x
	ldd	img+202
	std	10,x
	ldd	img+204
	std	12,x
	ldd	img+206
	std	14,x
	ldd	img+208
	std	16,x
	ldd	img+210
	std	18,x
	ldd	img+212
	std	20,x
	ldd	img+214
	std	22,x
	ldd	img+216
	std	24,x
	ldd	img+218
	std	26,x
	ldd	img+220
	std	28,x
	ldd	img+222
	std	30,x


	ldx	#ytab
y8	ldab	sintab+14
	aslb
	stab	pt8+1
pt8	ldx	128,x
	ldd	img+224
	std	,x
	ldd	img+226
	std	2,x
	ldd	img+228
	std	4,x
	ldd	img+230
	std	6,x
	ldd	img+232
	std	8,x
	ldd	img+234
	std	10,x
	ldd	img+236
	std	12,x
	ldd	img+238
	std	14,x
	ldd	img+240
	std	16,x
	ldd	img+242
	std	18,x
	ldd	img+244
	std	20,x
	ldd	img+246
	std	22,x
	ldd	img+248
	std	24,x
	ldd	img+250
	std	26,x
	ldd	img+252
	std	28,x
	ldd	img+254
	std	30,x

	ldx	#ytab
y9	ldab	sintab+16
	aslb
	stab	pt9+1
pt9	ldx	128,x
	ldd	img+256
	std	,x
	ldd	img+258
	std	2,x
	ldd	img+260
	std	4,x
	ldd	img+262
	std	6,x
	ldd	img+264
	std	8,x
	ldd	img+266
	std	10,x
	ldd	img+268
	std	12,x
	ldd	img+270
	std	14,x
	ldd	img+272
	std	16,x
	ldd	img+274
	std	18,x
	ldd	img+276
	std	20,x
	ldd	img+278
	std	22,x
	ldd	img+280
	std	24,x
	ldd	img+282
	std	26,x
	ldd	img+284
	std	28,x
	ldd	img+286
	std	30,x

	ldx	#ytab
y10	ldab	sintab+18
	aslb
	stab	pt10+1
pt10	ldx	128,x
	ldd	img+288
	std	,x
	ldd	img+290
	std	2,x
	ldd	img+292
	std	4,x
	ldd	img+294
	std	6,x
	ldd	img+296
	std	8,x
	ldd	img+298
	std	10,x
	ldd	img+300
	std	12,x
	ldd	img+302
	std	14,x
	ldd	img+304
	std	16,x
	ldd	img+306
	std	18,x
	ldd	img+308
	std	20,x
	ldd	img+310
	std	22,x
	ldd	img+312
	std	24,x
	ldd	img+314
	std	26,x
	ldd	img+316
	std	28,x
	ldd	img+318
	std	30,x


	ldx	#ytab
y11	ldab	sintab+20
	aslb
	stab	pt11+1
pt11	ldx	128,x
	ldd	img+320
	std	,x
	ldd	img+322
	std	2,x
	ldd	img+324
	std	4,x
	ldd	img+326
	std	6,x
	ldd	img+328
	std	8,x
	ldd	img+330
	std	10,x
	ldd	img+332
	std	12,x
	ldd	img+334
	std	14,x
	ldd	img+336
	std	16,x
	ldd	img+338
	std	18,x
	ldd	img+340
	std	20,x
	ldd	img+342
	std	22,x
	ldd	img+344
	std	24,x
	ldd	img+346
	std	26,x
	ldd	img+348
	std	28,x
	ldd	img+350
	std	30,x


	ldx	#ytab
y12	ldab	sintab+22
	aslb
	stab	pt12+1
pt12	ldx	128,x
	ldd	img+352
	std	,x
	ldd	img+354
	std	2,x
	ldd	img+356
	std	4,x
	ldd	img+358
	std	6,x
	ldd	img+360
	std	8,x
	ldd	img+362
	std	10,x
	ldd	img+364
	std	12,x
	ldd	img+366
	std	14,x
	ldd	img+368
	std	16,x
	ldd	img+370
	std	18,x
	ldd	img+372
	std	20,x
	ldd	img+374
	std	22,x
	ldd	img+376
	std	24,x
	ldd	img+378
	std	26,x
	ldd	img+380
	std	28,x
	ldd	img+382
	std	30,x


	ldx	#ytab
y13	ldab	sintab+24
	aslb
	stab	pt13+1
pt13	ldx	128,x
	ldd	img+384
	std	,x
	ldd	img+386
	std	2,x
	ldd	img+388
	std	4,x
	ldd	img+390
	std	6,x
	ldd	img+392
	std	8,x
	ldd	img+394
	std	10,x
	ldd	img+396
	std	12,x
	ldd	img+398
	std	14,x
	ldd	img+400
	std	16,x
	ldd	img+402
	std	18,x
	ldd	img+404
	std	20,x
	ldd	img+406
	std	22,x
	ldd	img+408
	std	24,x
	ldd	img+410
	std	26,x
	ldd	img+412
	std	28,x
	ldd	img+414
	std	30,x


	ldx	#ytab
y14	ldab	sintab+26
	aslb
	stab	pt14+1
pt14	ldx	128,x
	ldd	img+416
	std	,x
	ldd	img+418
	std	2,x
	ldd	img+420
	std	4,x
	ldd	img+422
	std	6,x
	ldd	img+424
	std	8,x
	ldd	img+426
	std	10,x
	ldd	img+428
	std	12,x
	ldd	img+430
	std	14,x
	ldd	img+432
	std	16,x
	ldd	img+434
	std	18,x
	ldd	img+436
	std	20,x
	ldd	img+438
	std	22,x
	ldd	img+440
	std	24,x
	ldd	img+442
	std	26,x
	ldd	img+444
	std	28,x
	ldd	img+446
	std	30,x


	ldx	#ytab
y15	ldab	sintab+28
	aslb
	stab	pt15+1
pt15	ldx	128,x
	ldd	img+448
	std	,x
	ldd	img+450
	std	2,x
	ldd	img+452
	std	4,x
	ldd	img+454
	std	6,x
	ldd	img+456
	std	8,x
	ldd	img+458
	std	10,x
	ldd	img+460
	std	12,x
	ldd	img+462
	std	14,x
	ldd	img+464
	std	16,x
	ldd	img+466
	std	18,x
	ldd	img+468
	std	20,x
	ldd	img+470
	std	22,x
	ldd	img+472
	std	24,x
	ldd	img+474
	std	26,x
	ldd	img+476
	std	28,x
	ldd	img+478
	std	30,x


	ldx	#ytab
y16	ldab	sintab+30
	aslb
	stab	pt16+1
pt16	ldx	128,x
	ldd	img+480
	std	,x
	ldd	img+482
	std	2,x
	ldd	img+484
	std	4,x
	ldd	img+486
	std	6,x
	ldd	img+488
	std	8,x
	ldd	img+490
	std	10,x
	ldd	img+492
	std	12,x
	ldd	img+494
	std	14,x
	ldd	img+496
	std	16,x
	ldd	img+498
	std	18,x
	ldd	img+500
	std	20,x
	ldd	img+502
	std	22,x
	ldd	img+504
	std	24,x
	ldd	img+506
	std	26,x
	ldd	img+508
	std	28,x
	ldd	img+510
	std	30,x


	ldx	#ytab
y17	ldab	sintab+32
	aslb
	stab	pt17+1
pt17	ldx	128,x
	ldd	img+512
	std	,x
	ldd	img+514
	std	2,x
	ldd	img+516
	std	4,x
	ldd	img+518
	std	6,x
	ldd	img+520
	std	8,x
	ldd	img+522
	std	10,x
	ldd	img+524
	std	12,x
	ldd	img+526
	std	14,x
	ldd	img+528
	std	16,x
	ldd	img+530
	std	18,x
	ldd	img+532
	std	20,x
	ldd	img+534
	std	22,x
	ldd	img+536
	std	24,x
	ldd	img+538
	std	26,x
	ldd	img+540
	std	28,x
	ldd	img+542
	std	30,x


	ldx	#ytab
y18	ldab	sintab+34
	aslb
	stab	pt18+1
pt18	ldx	128,x
	ldd	img+544
	std	,x
	ldd	img+546
	std	2,x
	ldd	img+548
	std	4,x
	ldd	img+550
	std	6,x
	ldd	img+552
	std	8,x
	ldd	img+554
	std	10,x
	ldd	img+556
	std	12,x
	ldd	img+558
	std	14,x
	ldd	img+560
	std	16,x
	ldd	img+562
	std	18,x
	ldd	img+564
	std	20,x
	ldd	img+566
	std	22,x
	ldd	img+568
	std	24,x
	ldd	img+570
	std	26,x
	ldd	img+572
	std	28,x
	ldd	img+574
	std	30,x



	ldx	#ytab
y19	ldab	sintab+36
	aslb
	stab	pt19+1

pt19	ldx	128,x
	ldd	img+576
	std	,x
	ldd	img+578
	std	2,x
	ldd	img+580
	std	4,x
	ldd	img+582
	std	6,x
	ldd	img+584
	std	8,x
	ldd	img+586
	std	10,x
	ldd	img+588
	std	12,x
	ldd	img+590
	std	14,x
	ldd	img+592
	std	16,x
	ldd	img+594
	std	18,x
	ldd	img+596
	std	20,x
	ldd	img+598
	std	22,x
	ldd	img+600
	std	24,x
	ldd	img+602
	std	26,x
	ldd	img+604
	std	28,x
	ldd	img+606
	std	30,x


	ldx	#ytab
y20	ldab	sintab+38
	aslb
	stab	pt20+1
pt20	ldx	128,x
	ldd	img+608
	std	,x
	ldd	img+610
	std	2,x
	ldd	img+612
	std	4,x
	ldd	img+614
	std	6,x
	ldd	img+616
	std	8,x
	ldd	img+618
	std	10,x
	ldd	img+620
	std	12,x
	ldd	img+622
	std	14,x
	ldd	img+624
	std	16,x
	ldd	img+626
	std	18,x
	ldd	img+628
	std	20,x
	ldd	img+630
	std	22,x
	ldd	img+632
	std	24,x
	ldd	img+634
	std	26,x
	ldd	img+636
	std	28,x
	ldd	img+638
	std	30,x


	rts

;***********************************
; SETUP CLS ETC
;***********************************
setup   ldaa	#64
	staa	lines
	ldaa	#$28		;CG2			
	staa	$bfff
	
	ldx	#$4000
	ldd	#0
cls	std	,x
	inx	
	inx	
	cpx	#$4c00
	bne	cls

	ldx	#ytab
	ldd	#$4000
makey	std	,x
	inx
	inx
	addd	#32
	dec	lines
	bne	makey	
	rts

;***********************************
;VARS
;***********************************
lines	.byte	$00

;***********************************
; PAGE ALIGNED 256 BYTE SINUSTABLE
;***********************************
	.ORG  (($ + 0FFH) & 0FF00H)

	.byte		32,32,33,34,35,35,36,37,38,38,39,40,41,41,42,43
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
sintab	.byte		1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2
	.byte		2,3,3,3,4,4,4,5,5,6,6,7,7,8,8,9
	.byte		9,10,10,11,12,12,13,13,14,15,15,16,17,17,18,19
	.byte		19,20,21,22,22,23,24,25,25,26,27,28,28,29,30,31




;***********************************
img
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,63,255,192,0,255,192,0,0,3,255,255
	.byte	0,255,252,0,0,0,0,0,0,0,0,3,255,252,0,0,0
	.byte	0,0,255,255,213,85,127,3,85,255,255,192,61,85,85,255
	.byte	85,87,255,252,0,255,255,192,15,255,255,85,87,240,0,0
	.byte	0,15,85,85,218,170,87,3,106,85,85,112,245,170,169,117
	.byte	106,167,85,87,15,85,85,240,61,85,87,106,165,112,0,0
	.byte	0,61,106,170,85,170,167,3,106,170,170,92,218,149,90,150
	.byte	170,145,170,165,253,106,170,92,214,170,165,90,170,112,0,0
	.byte	0,246,170,170,149,170,167,3,86,170,170,151,218,149,170,149
	.byte	106,150,165,169,246,170,170,151,90,170,170,118,170,112,0,0
	.byte	0,218,170,170,165,170,159,0,246,170,170,167,106,166,170,159
	.byte	106,150,154,170,90,170,170,165,106,170,170,86,169,240,0,0
	.byte	3,90,170,170,165,170,156,0,54,169,86,169,106,165,106,95
	.byte	106,154,106,170,90,170,170,165,170,170,170,150,169,192,0,0
	.byte	3,106,149,86,165,170,159,255,246,169,245,169,106,165,85,127
	.byte	106,153,106,169,106,149,90,165,169,85,106,150,169,255,255,0
	.byte	3,105,127,246,165,170,95,85,118,169,207,105,90,170,170,159
	.byte	106,169,90,149,105,127,246,166,165,255,90,150,165,245,87,192
	.byte	3,105,192,61,165,170,118,170,149,169,195,106,117,85,106,167
	.byte	106,170,165,127,105,192,53,166,159,3,218,118,167,106,169,192

	.byte	3,105,127,246,149,106,90,170,157,169,195,106,85,87,106,167
	.byte	106,170,170,95,105,127,214,150,167,255,90,118,165,170,169,192
	.byte	3,106,85,90,159,106,90,170,157,169,253,106,106,169,106,167
	.byte	106,149,170,167,106,85,90,150,169,85,169,118,165,170,169,192
	.byte	3,106,170,170,95,106,150,166,149,170,86,170,170,169,106,165
	.byte	90,167,106,165,106,170,170,93,170,170,169,245,169,106,89,192
	.byte	3,90,170,170,125,106,149,90,86,170,170,169,170,169,234,165
	.byte	170,167,90,169,90,170,170,125,170,170,165,213,169,85,105,192
	.byte	0,218,170,169,246,170,170,170,90,170,170,165,106,149,106,157
	.byte	170,165,106,169,218,170,169,255,106,170,167,218,170,170,165,192
	.byte	0,246,170,165,246,170,170,169,90,170,170,87,90,85,170,93
	.byte	85,165,170,169,246,170,165,195,90,170,95,218,170,170,167,0
	.byte	0,61,106,151,61,85,85,85,213,85,85,124,213,170,149,253
	.byte	125,85,85,85,253,106,95,0,213,169,124,213,85,85,95,0
	.byte	0,15,213,124,15,255,255,255,63,255,255,192,63,85,95,195
	.byte	195,255,255,255,15,213,124,0,61,87,192,63,255,255,252,0
	.byte	0,0,255,240,0,0,0,0,0,0,0,0,3,255,240,0	
	.byte	0,0,0,0,0,255,192,0,3,255,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
endimg

ytab 	.ORG    $+128		;reserve space for lookup


;***********************************
;END DIRECTIVE
;***********************************
	.end	