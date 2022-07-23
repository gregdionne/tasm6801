;***************************************
;* MC10 ROTATING ZOOMING CHESSBOARD
;* (C)2016 SIMON JONASSEN
;*
;* ALL CODE IS PUBLIC DOMAIN AND FREE 
;* FOR ANY USE YOU SEE FIT....
;*
;* IF YOU DO USE ANY OF THIS, THEN 
;* PLEASE GIVE CREDIT WHERE IT'S DUE
;***************************************
		.msfirst
		.org		$4800
start		sei

		ldaa	#$28		;set videomode
		staa	$bfff		;128*64*4color
outloop		ldx	#$4000		;screen start	


;***************************************
;* WORK OUT THE DELTAX/Y
;***************************************

		clra
cosptr		ldab	costab		;(angle in LSB 0..255)
		bpl	noex1
		eora	#$ff		;sign extend for 16bit math
noex1

		std	ca1+1
		std	ca2+1
		std	ca3+1
		std	ca4+1
		std	ca5+1
		std	ca6+1
		std	ca7+1
		std	ca8+1
		std	ca9+1
		std	ca10+1
		std	ca11+1
		std	ca12+1
		std	ca13+1
		std	ca14+1
		std	ca15+1
		std	ca16+1
		std	ca17+1
		std	ca18+1
		std	ca19+1
		std	ca20+1
		std	ca21+1
		std	ca22+1
		std	ca23+1
		std	ca24+1
		std	ca25+1
		std	ca26+1
		std	ca27+1
		std	ca28+1
		std	ca29+1
		std	ca30+1
		std	ca31+1
		std	ca32+1

	
		clra	
		asld			;*2 for WORD lookup
		addd	#MUL16
		std	lookup1+1

lookup1		ldd	>$0000
		std	d4+1	
		asld			;double the value for the Y
		std	d1+1	
		
		clra
sinptr		ldab	sintab		;(angle in LSB 0..255)
		bpl	noex2
		eora	#$ff
noex2		
		std	sa1+1
		std	sa2+1
		std	sa3+1
		std	sa4+1
		std	sa5+1
		std	sa6+1
		std	sa7+1
		std	sa8+1
		std	sa9+1
		std	sa10+1
		std	sa11+1
		std	sa12+1
		std	sa13+1
		std	sa14+1
		std	sa15+1
		std	sa16+1
		std	sa17+1
		std	sa18+1
		std	sa19+1
		std	sa20+1
		std	sa21+1
		std	sa22+1
		std	sa23+1
		std	sa24+1
		std	sa25+1
		std	sa26+1
		std	sa27+1
		std	sa28+1
		std	sa29+1
		std	sa30+1
		std	sa31+1
		std	sa32+1



		clra	
		asld				;*2 for WORD lookup
		addd	#MUL16
		std	lookup2+1

lookup2		ldd	>$0000
		std	d2+1
		asld
		std	d3+1			

d2		ldd	#0
d1		subd	#0		
		std	yca1+1

		ldd	#0
d3		subd	#0		
d4		subd	#0
		std	ysa1+1

;***************************************
;* YLOOP
;***************************************
yloop		cpx    #$4800		;screen end
		bne	ysa1		
		jmp	out

ysa1		ldd	#0		;ysa		;xrot=ysa
		std	xr1+1
		addd	sa1+1
		std	ysa1+1

yca1		ldd	#0		;yca		;yrot=yca
		std	yr1+1
		addd	ca1+1
		std	yca1+1



;***************************************
;xloop
;***************************************
xr1		ldd #0	; xrot

ca1		addd	#0
		staa 	xk1+1
ca2		addd	#0
		staa 	xk2+1
ca3		addd	#0
		staa 	xk3+1
ca4		addd	#0
		staa 	xk4+1
ca5		addd	#0
		staa 	xk5+1
ca6		addd	#0
		staa 	xk6+1
ca7		addd	#0
		staa 	xk7+1
ca8		addd	#0
		staa 	xk8+1
ca9		addd	#0
		staa 	xk9+1
ca10		addd	#0
		staa 	xk10+1
ca11		addd	#0
		staa 	xk11+1
ca12		addd	#0
		staa 	xk12+1
ca13		addd	#0
		staa 	xk13+1
ca14		addd	#0
		staa 	xk14+1
ca15		addd	#0
		staa 	xk15+1
ca16		addd	#0
		staa 	xk16+1
ca17		addd	#0
		staa 	xk17+1
ca18		addd	#0
		staa 	xk18+1
ca19		addd	#0
		staa 	xk19+1
ca20		addd	#0
		staa 	xk20+1
ca21		addd	#0
		staa 	xk21+1
ca22		addd	#0
		staa 	xk22+1
ca23		addd	#0
		staa 	xk23+1
ca24		addd	#0
		staa 	xk24+1
ca25		addd	#0
		staa 	xk25+1
ca26		addd	#0
		staa 	xk26+1
ca27		addd	#0
		staa 	xk27+1
ca28		addd	#0
		staa 	xk28+1
ca29		addd	#0
		staa 	xk29+1
ca30		addd	#0
		staa 	xk30+1
ca31		addd	#0
		staa 	xk31+1
ca32		addd	#0
		staa 	xk32+1




yr1		ldd	#0
sa1		subd	#0
		std	yr2+1
xk1		adda	#0
		staa	store1+2
store1		ldaa	coltab
		staa	,x


yr2		ldd	#0
sa2		subd	#0
		std	yr3+1
xk2		adda	#0
		staa	store2+2
store2		ldaa	coltab
		staa	1,x

yr3		ldd	#0
sa3		subd	#0
		std	yr4+1
xk3		adda	#0
		staa	store3+2
store3		ldaa	coltab
		staa	2,x

yr4		ldd	#0
sa4		subd	#0
		std	yr5+1
xk4		adda	#0
		staa	store4+2
store4		ldaa	coltab
		staa	3,x



yr5		ldd	#0
sa5		subd	#0
		std	yr6+1
xk5		adda	#0
		staa	store5+2
store5		ldaa	coltab
		staa	4,x


yr6		ldd	#0
sa6		subd	#0
		std	yr7+1
xk6		adda	#0
		staa	store6+2
store6		ldaa	coltab
		staa	5,x


yr7		ldd	#0
sa7		subd	#0
		std	yr8+1
xk7		adda	#0
		staa	store7+2
store7		ldaa	coltab
		staa	6,x


yr8		ldd	#0
sa8		subd	#0
		std	yr9+1
xk8		adda	#0
		staa	store8+2
store8		ldaa	coltab
		staa	7,x

yr9		ldd	#0
sa9		subd	#0
		std	yr10+1
xk9		adda	#0
		staa	store9+2
store9		ldaa	coltab
		staa	8,x

yr10		ldd	#0
sa10		subd	#0
		std	yr11+1
xk10		adda	#0
		staa	store10+2
store10		ldaa	coltab
		staa	9,x

yr11		ldd	#0
sa11		subd	#0
		std	yr12+1
xk11		adda	#0
		staa	store11+2
store11		ldaa	coltab
		staa	10,x


yr12		ldd	#0
sa12		subd	#0
		std	yr13+1
xk12		adda	#0
		staa	store12+2
store12		ldaa	coltab
		staa	11,x


yr13		ldd	#0
sa13		subd	#0
		std	yr14+1
xk13		adda	#0
		staa	store13+2
store13		ldaa	coltab
		staa	12,x



yr14		ldd	#0
sa14		subd	#0
		std	yr15+1
xk14		adda	#0
		staa	store14+2
store14		ldaa	coltab
		staa	13,x


yr15		ldd	#0
sa15		subd	#0
		std	yr16+1
xk15		adda	#0
		staa	store15+2
store15		ldaa	coltab
		staa	14,x


yr16		ldd	#0
sa16		subd	#0
		std	yr17+1
xk16		adda	#0
		staa	store16+2
store16		ldaa	coltab
		staa	15,x


yr17		ldd	#0
sa17		subd	#0
		std	yr18+1
xk17		adda	#0
		staa	store17+2
store17		ldaa	coltab
		staa	16,x

yr18		ldd	#0
sa18		subd	#0
		std	yr19+1
xk18		adda	#0
		staa	store18+2
store18		ldaa	coltab
		staa	17,x


yr19		ldd	#0
sa19		subd	#0
		std	yr20+1
xk19		adda	#0
		staa	store19+2
store19		ldaa	coltab
		staa	18,x


yr20		ldd	#0
sa20		subd	#0
		std	yr21+1
xk20		adda	#0
		staa	store20+2
store20		ldaa	coltab
		staa	19,x


yr21		ldd	#0
sa21		subd	#0
		std	yr22+1
xk21		adda	#0
		staa	store21+2
store21		ldaa	coltab
		staa	20,x


yr22		ldd	#0
sa22		subd	#0
		std	yr23+1
xk22		adda	#0
		staa	store22+2
store22		ldaa	coltab
		staa	21,x

yr23		ldd	#0
sa23		subd	#0
		std	yr24+1
xk23		adda	#0
		staa	store23+2
store23		ldaa	coltab
		staa	22,x


yr24		ldd	#0
sa24		subd	#0
		std	yr25+1
xk24		adda	#0
		staa	store24+2
store24		ldaa	coltab
		staa	23,x

yr25		ldd	#0
sa25		subd	#0
		std	yr26+1
xk25		adda	#0
		staa	store25+2
store25		ldaa	coltab
		staa	24,x


yr26		ldd	#0
sa26		subd	#0
		std	yr27+1
xk26		adda	#0
		staa	store26+2
store26		ldaa	coltab
		staa	25,x

yr27		ldd	#0
sa27		subd	#0
		std	yr28+1
xk27		adda	#0
		staa	store27+2
store27		ldaa	coltab
		staa	26,x


yr28		ldd	#0
sa28		subd	#0
		std	yr29+1
xk28		adda	#0
		staa	store28+2
store28		ldaa	coltab
		staa	27,x


yr29		ldd	#0
sa29		subd	#0
		std	yr30+1
xk29		adda	#0
		staa	store29+2
store29		ldaa	coltab
		staa	28,x


yr30		ldd	#0
sa30		subd	#0
		std	yr31+1
xk30		adda	#0
		staa	store30+2
store30		ldaa	coltab
		staa	29,x

yr31		ldd	#0
sa31		subd	#0
		std	yr32+1
xk31		adda	#0
		staa	store31+2
store31		ldaa	coltab
		staa	30,x

yr32		ldd	#0
sa32		subd	#0
xk32		adda 	#0
		staa	store32+2
store32		ldaa	coltab
plot32		staa	31,x		

		ldab	#32
		abx
;***************************************
;* bottom of yloop
;***************************************
		jmp	yloop
;***************************************
;* yloop done
;***************************************
out		ldaa	cosptr+2	;angle=angle+1
		adda	#1
		staa	cosptr+2

		ldaa	sinptr+2	;angle=angle+3
		adda	#3
		staa	sinptr+2
		jmp	outloop	
;***************************************
		.ORG  (($+0FFH) & 0FF00H)

		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
coltab
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa
		.byte	$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa,$00,$aa





		.ORG  (($+0FFH) & 0FF00H)
;**********************************************************
;* aligned fixed point sin/cos tables 
;* with zoom (1.2 is scale)
;*
;* formula:
;*
;*  cint(32 * SIN(s * PI / 64) * (COS(s * PI / 64) + 1.2)
;*  cint(32 * COS(s * PI / 64) * (COS(s * PI / 64) + 1.2)
;**********************************************************

costab	.byte	70,70,70,69,68,67,66,65,63,61,59,56,54,51,49,46
	.byte	43,40,37,34,31,28,25,22,19,17,14,11,9,6,4,2
	.byte	0,-2,-3,-5,-6,-7,-8,-9,-10,-11,-11,-11,-11,-12,-11,-11
	.byte	-11,-11,-11,-10,-10,-9,-9,-9,-8,-8,-7,-7,-7,-7,-7,-6
	.byte	-6,-6,-7,-7,-7,-7,-7,-8,-8,-9,-9,-9,-10,-10,-11,-11
	.byte	-11,-11,-11,-12,-11,-11,-11,-11,-10,-9,-8,-7,-6,-5,-3,-2
	.byte	0,2,4,6,9,11,14,17,19,22,25,28,31,34,37,40
	.byte	43,46,49,51,54,56,59,61,63,65,66,67,68,69,70,70
	.byte	70,70,70,69,68,67,66,65,63,61,59,56,54,51,49,46
	.byte	43,40,37,34,31,28,25,22,19,17,14,11,9,6,4,2
	.byte	0,-2,-3,-5,-6,-7,-8,-9,-10,-11,-11,-11,-11,-12,-11,-11
	.byte	-11,-11,-11,-10,-10,-9,-9,-9,-8,-8,-7,-7,-7,-7,-7,-6
	.byte	-6,-6,-7,-7,-7,-7,-7,-8,-8,-9,-9,-9,-10,-10,-11,-11
	.byte	-11,-11,-11,-12,-11,-11,-11,-11,-10,-9,-8,-7,-6,-5,-3,-2
	.byte	0,2,4,6,9,11,14,17,19,22,25,28,31,34,37,40
	.byte	43,46,49,51,54,56,59,61,63,65,66,67,68,69,70,70


sintab
	.byte	0,3,7,10,14,17,20,23,26,29,31,34,36,38,40,42
	.byte	43,44,45,46,47,47,47,47,47,46,46,45,44,43,41,40
	.byte	38,37,35,33,32,30,28,26,24,22,21,19,17,16,14,13
	.byte	11,10,9,8,7,6,5,4,3,3,2,2,1,1,1,0
	.byte	0,0,-1,-1,-1,-2,-2,-3,-3,-4,-5,-6,-7,-8,-9,-10
	.byte	-11,-13,-14,-16,-17,-19,-21,-22,-24,-26,-28,-30,-32,-33,-35,-37
	.byte	-38,-40,-41,-43,-44,-45,-46,-46,-47,-47,-47,-47,-47,-46,-45,-44
	.byte	-43,-42,-40,-38,-36,-34,-31,-29,-26,-23,-20,-17,-14,-10,-7,-3
	.byte	0,3,7,10,14,17,20,23,26,29,31,34,36,38,40,42
	.byte	43,44,45,46,47,47,47,47,47,46,46,45,44,43,41,40
	.byte	38,37,35,33,32,30,28,26,24,22,21,19,17,16,14,13
	.byte	11,10,9,8,7,6,5,4,3,3,2,2,1,1,1,0
	.byte	0,0,-1,-1,-1,-2,-2,-3,-3,-4,-5,-6,-7,-8,-9,-10
	.byte	-11,-13,-14,-16,-17,-19,-21,-22,-24,-26,-28,-30,-32,-33,-35,-37
	.byte	-38,-40,-41,-43,-44,-45,-46,-46,-47,-47,-47,-47,-47,-46,-45,-44
	.byte	-43,-42,-40,-38,-36,-34,-31,-29,-26,-23,-20,-17,-14,-10,-7,-3


	.ORG  (($+0FFH) & 0FF00H)
;**********************************************************
;* Multiplicaton table as 6803 MUL is unsigned
;*
;* this also serves as translation from cartesian to
;* screen coordinates at the same time
;*
;* formula:
;*
;* FOR m = -128 TO 127
;*   m16(m)=cint(m * 16) 
;* NEXT
;*
;**********************************************************

MUL16	.word	-2048,-2032,-2016,-2000,-1984,-1968,-1952,-1936,-1920,-1904,-1888,-1872,-1856,-1840,-1824,-1808
	.word	-1792,-1776,-1760,-1744,-1728,-1712,-1696,-1680,-1664,-1648,-1632,-1616,-1600,-1584,-1568,-1552
	.word	-1536,-1520,-1504,-1488,-1472,-1456,-1440,-1424,-1408,-1392,-1376,-1360,-1344,-1328,-1312,-1296
	.word	-1280,-1264,-1248,-1232,-1216,-1200,-1184,-1168,-1152,-1136,-1120,-1104,-1088,-1072,-1056,-1040
	.word	-1024,-1008,-992,-976,-960,-944,-928,-912,-896,-880,-864,-848,-832,-816,-800,-784
	.word	-768,-752,-736,-720,-704,-688,-672,-656,-640,-624,-608,-592,-576,-560,-544,-528
	.word	-512,-496,-480,-464,-448,-432,-416,-400,-384,-368,-352,-336,-320,-304,-288,-272
	.word	-256,-240,-224,-208,-192,-176,-160,-144,-128,-112,-96,-80,-64,-48,-32,-16
	.word	0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240
	.word	256,272,288,304,320,336,352,368,384,400,416,432,448,464,480,496
	.word	512,528,544,560,576,592,608,624,640,656,672,688,704,720,736,752
	.word	768,784,800,816,832,848,864,880,896,912,928,944,960,976,992,1008
	.word	1024,1040,1056,1072,1088,1104,1120,1136,1152,1168,1184,1200,1216,1232,1248,1264
	.word	1280,1296,1312,1328,1344,1360,1376,1392,1408,1424,1440,1456,1472,1488,1504,1520
	.word	1536,1552,1568,1584,1600,1616,1632,1648,1664,1680,1696,1712,1728,1744,1760,1776
	.word	1792,1808,1824,1840,1856,1872,1888,1904,1920,1936,1952,1968,1984,2000,2016,2032





	.end 	start