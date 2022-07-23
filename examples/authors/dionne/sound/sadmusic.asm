; play a somber tune on the MC-10

sndprt	.equ $BFFF
note	.equ $4000
dur	.equ $4003
btab	.equ $4005
table	.equ $4008

	.org $8000

	jsr $fbd4
restart:
	ldx #notes
	dex
	dex
	dex
	stx note
nxtnote:
	ldx note
	inx
	inx
	inx
pause	dec dur
	bne pause
	stx note
	ldaa 2,x
	staa dur
	ldx ,x
	beq restart
	stx btab

startnote:
	dec dur		; 6
	beq nxtnote	; 3
	ldx btab	; 5
	dex		; 3
	dex		; 3
	stx table	; 5
	ldd #$8000	; 4

pospulse:
        ldx table	; 5
	inx		; 3
	inx		; 3
	stx table	; 5
	ldx ,x		; 5
	beq startnote	; 5
	staa sndprt	; 4  (30 = 5.5*6)
loop1	dex		; 3
	bne loop1	; 3  (6)

; negpulse:
	ldx table	; 5
	inx		; 3
	inx		; 3
	stx table	; 5
	ldx ,x		; 5
	stab sndprt	; 5 (26 = 4.333*6)
loop2	dex		; 3
	bne loop2	; 3
	bra pospulse	; 3 (+3)

notes:
	fdb nFD
	fcb 30
	fdb nFD
	fcb 20
	fdb nFD
	fcb 10
	fdb nFD
	fcb 30
	fdb nAF
	fcb 20
	fdb nGE
	fcb 10
	fdb nGE
	fcb 20
	fdb nFD
	fcb 10
	fdb nFD
	fcb 20
	fdb nECs
	fcb 10
	fdb nFD
	fcb 60
	fdb bigrest
	fcb 10
	fdb 0

bigrest	fdb 10000,10000,0
nAF	fdb 54,54,7,42,54,54,54,31,18,54,55,54,54,1,54,54,54,54,18,31,54,54,54,42,7,54,54,54,54,7,42,54,54,55,30,19,54,54,54,54,1,54,54,54,54,19,30,54,54,54,42,7,54,54,0
nGE	fdb 57,55,1,57,58,57,48,4,57,57,57,43,10,57,57,57,37,15,57,57,58,31,21,57,57,57,26,26,58,57,57,20,32,57,57,58,14,38,57,57,57, 9,43,57,58,57,3,49,57,57,57,1,55,57,0
nFD	fdb 65,61,1,64,65,65,55,5,64,65,65,49,11,64,65,65,43,17,65,64,65,36,24,65,64,65,30,30,65,64,65,24,36,65,64,65,17,43,65,65,64,11,49,65,65,64,5,55,65,65,64,1,61,65,0
nECs	fdb 69,65,1,69,69,69,58,6,68,69,69,52,12,69,69,69,45,19,69,69,69,38,26,68,69,69,32,32,69,69,69,25,39,69,69,69,18,46,68,69,69,12,52,69,69,69,5,59,69,69,69,1,65,69,0

	fdb 0
	.end

