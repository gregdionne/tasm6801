; ********************************************************************************************************
; ZX SPECCY *the music studio* engine for mc10
; 
; (C) Simon Jonassen 2021 - free for all, use as you see fit
;
; remember where it came from and give credit where due
; ********************************************************************************************************
		PROCESSOR	6803
                ORG	$5000

start		sei
		jsr	initvu
		ldd	#PATTERNDATA 		; Get start address of pattern data
		pshb
		psha
		pulx
		stx	nextpat+1
		addd	MUSICDATA		; Add loop start point to the pattern data start address
		ldd	#PATTERNDATA 		; Get start address of pattern data
		addd	MUSICDATA+2		; Add song length to the pattern data loop start address
		std	patloopend+1		; Set pattern data loop end address
		

; ********************************************************************************************************
; * NEXT_PATTERN
; ********************************************************************************************************
nextpat		ldx	#0000
		ldx	,x
		ldaa	,x			; X = Pattern data pointer 
		staa	qtempo+1
		inx
playnote	ldd	,x
		cmpa	#$fe			; $FE indicates end of pattern
		bne	continue

		ldx	nextpat+1
		inx
		inx
		stx	nextpat+1


patloopend	cpx	#0000			; Check for end of pattern loop
		blo	nextpat
		cli
		jsr	initvu
		rts

; ********************************************************************************************************
; * NOTE ROUTINE
; ********************************************************************************************************

continue	staa	ch1freq+1
		stab	ch2freq+1
noteptr		inx
		inx				; Increment the note pointer by 2 (one note per chan)

qtempo		ldd	#0000			; A = Tempo | B = 0
		std	tempc
		stab	bord1+1
		stab	bord2+1			; So now tempb = 0, tempc = Tempo | bord1 & bord2 = 0

outputnote

		ldab	ch1freq+1		; Put note frequency for chan 1 into IXH
		stab	ch1ix+1
		stab	ch1count
		decb
		stab	ltemp1
		beq	continue1


		ldab	#128
continue1	stab	xore1+1
		stab	xore1b+1

		ldab	ch2freq+1		; Put note frequency for chan 2 into IXL
		stab	ch2ix+1
		stab	ch2count
		stab	ltemp2
		decb
		stab	ltemp2
		beq	continue2

		ldab	#128
continue2	stab	xore2+1
		stab	xore2b+1

continue3
bord1		ldaa	#00
		dec	ch1count		; Dec H, which also holds the frequency value
		bne	l8055
xore1		eora	#00
		staa	bord1+1
ch1freq		ldab	#00
		stab	ch1count

ch1ix		ldab	#00
		cmpb	#$20
		bcc	l8055			; if B  $20 then this is not a drum effect, skip the INC D
		inc	ch1freq+1		; create the "fast falling pitch" percussion effect
l8055		dec	ltemp1
		bne	bord2
xore1b		eora	#00
		staa	bord1+1

		ldab	ch1freq+1
		decb
		stab	ltemp1

bord2		adda	#00			;adda
		staa	$bfff
		dec	ch2count
		bne	l806d
		ldaa	bord2+1
xore2		eora	#00
		staa	bord2+1
ch2freq		ldab	#00
		stab	ch2count
ch2ix		ldab	#00
		cmpb	#$20
		bcc	l806d			; if A  $20 then this is not a drum effect, skip the INC D
		inc	ch2freq+1		; create the "fast falling pitch" percussion effect

l806d		dec	ltemp2
		bne	l8073
		ldaa	bord2+1
xore2b		eora	#00
		staa	bord2+1
		ldab	ch2freq+1
		decb
		stab	ltemp2
l8073		dec	tempb
		bne	continue3
		stx	oldx+1
		jsr	vu
		jsr	vu2
oldx		ldx	#$0000
		dec	tempc
		bne	continue3
		jmp	playnote

; ********************************************************************************************************
; FAKE VU METER CODE
; ********************************************************************************************************
initvu		clr	target			; VU METER
		clr	target2
		ldd	#$800f
		stab	current
		stab	current2
		jsr	cls
		rts

vu		ldaa	#132			;ch1
		ldx	#$40e0
		ldab	current
		abx
		cmpb	target
		blo	up
		bhi	down

		ldab	ch1freq+1
		addb	ch1ix+1
		lsrb
		lsrb	
		lsrb
		stab	target
		rts

up		cmpb	#16 
		blo	green
		ldaa	#148

green		cmpb	#24
		blo	yella1
		ldaa	#180
yella1		staa	,x
		incb
		stab	current
		rts

down		ldaa	#$80
		staa	,x
		decb
		stab	current
		rts


vu2		ldaa	#129			;ch2
		ldx	#$4100
		ldab	current2
		abx
		cmpb	target2
		blo	up2
		bhi	down2

		ldab	ch2freq+1
		addb	ch2ix+1
		lsrb
		lsrb	
		lsrb
		stab	target2
		rts

up2		cmpb	#16 
		blo	green2
		ldaa	#145

green2		cmpb	#24
		blo	yella2
		ldaa	#177
yella2		staa	,x
		incb
		stab	current2
		rts

down2		ldaa	#$80
		staa	,x
		decb
		stab	current2
		rts

cls		ldx	#$4000
nxt		staa	,x
		inx
		cpx	#$41ff
		bls	nxt
		rts

tempc		.byte	0
tempb		.byte	0
ch1count	.word	0
ch2count	.word	0
ltemp1		.word	0
ltemp2		.word	0
target		.byte	0
target2		.byte	0
current		.byte	0
current2	.byte	0


BORDER_COL:               EQU $0
TEMPO:                    .byte 246

MUSICDATA:
                    .word 0   ; Loop start point * 2
                    .word 108   ; Song Length * 2


PATTERNDATA:        .word      PAT7
                    .word      PAT7
                    .word      PAT8
                    .word      PAT9
                    .word      PAT10
                    .word      PAT10
                    .word      PAT11
                    .word      PAT12
                    .word      PAT13
                    .word      PAT13
                    .word      PAT14
                    .word      PAT14
                    .word      PAT15
                    .word      PAT15
                    .word      PAT16
                    .word      PAT17
                    .word      PAT13
                    .word      PAT13
                    .word      PAT14
                    .word      PAT23
                    .word      PAT15
                    .word      PAT15
                    .word      PAT16
                    .word      PAT24
                    .word      PAT3
                    .word      PAT3
                    .word      PAT3
                    .word      PAT3
                    .word      PAT4
                    .word      PAT4
                    .word      PAT4
                    .word      PAT4
                    .word      PAT3
                    .word      PAT3
                    .word      PAT3
                    .word      PAT3
                    .word      PAT4
                    .word      PAT4
                    .word      PAT4
                    .word      PAT4
                    .word      PAT0
                    .word      PAT0
                    .word      PAT0
                    .word      PAT0
                    .word      PAT1
                    .word      PAT1
                    .word      PAT2
                    .word      PAT2
                    .word      PAT0
                    .word      PAT0
                    .word      PAT21
                    .word      PAT21
                    .word      PAT21
                    .word      PAT22

; *** Pattern data consists of pairs of frequency values CH1,CH2 with a single $FE to
; *** Mark the end of the pattern, and $01 for a rest
PAT0:
         .byte 7  ; Pattern tempo
             .byte 161,161
             .byte 1,180
             .byte 54,108
             .byte 1,161
             .byte 68,136
             .byte 1,108
             .byte 81,161
             .byte 1,136
             .byte 102,102
             .byte 1,161
             .byte 136,136
             .byte 1,102
             .byte 144,144
             .byte 1,136
             .byte 180,180
             .byte 1,144
         .byte $FE
PAT1:
         .byte 7  ; Pattern tempo
             .byte 203,203
             .byte 1,180
             .byte 54,108
             .byte 1,203
             .byte 68,136
             .byte 1,108
             .byte 81,161
             .byte 1,136
             .byte 102,102
             .byte 1,161
             .byte 136,136
             .byte 1,102
             .byte 144,144
             .byte 1,136
             .byte 215,215
             .byte 1,144
         .byte $FE
PAT2:
         .byte 7  ; Pattern tempo
             .byte 240,240
             .byte 1,180
             .byte 54,108
             .byte 1,240
             .byte 68,136
             .byte 1,108
             .byte 81,161
             .byte 1,136
             .byte 102,102
             .byte 1,161
             .byte 136,136
             .byte 1,102
             .byte 144,144
             .byte 1,136
             .byte 215,215
             .byte 1,144
         .byte $FE
PAT3:
         .byte 7  ; Pattern tempo
             .byte 121,121
             .byte 136,240
             .byte 81,40
             .byte 121,240
             .byte 102,51
             .byte 81,240
             .byte 121,61
             .byte 102,240
             .byte 76,76
             .byte 121,240
             .byte 102,102
             .byte 76,240
             .byte 108,108
             .byte 102,240
             .byte 136,136
             .byte 108,240
         .byte $FE
PAT4:
         .byte 7  ; Pattern tempo
             .byte 136,136
             .byte 151,180
             .byte 91,45
             .byte 136,180
             .byte 114,57
             .byte 91,180
             .byte 136,68
             .byte 114,180
             .byte 86,86
             .byte 136,180
             .byte 114,114
             .byte 86,180
             .byte 121,121
             .byte 114,180
             .byte 151,151
             .byte 121,180
         .byte $FE
PAT7:
         .byte 7  ; Pattern tempo
             .byte 161,240
             .byte 1,1
             .byte 161,240
             .byte 1,1
             .byte 161,240
             .byte 161,240
             .byte 161,240
             .byte 1,1
             .byte 161,240
             .byte 1,1
             .byte 161,240
             .byte 1,1
             .byte 161,240
             .byte 161,240
             .byte 161,240
             .byte 1,1
         .byte $FE
PAT8:
         .byte 7  ; Pattern tempo
             .byte 1,1
             .byte 1,1
             .byte 171,240
             .byte 171,240
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 171,240
             .byte 171,240
             .byte 171,240
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
         .byte $FE
PAT9:
         .byte 7  ; Pattern tempo
             .byte 171,240
             .byte 171,240
             .byte 171,240
             .byte 171,240
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
             .byte 1,1
             .byte 1,1
             .byte 1,1
             .byte 1,1
             .byte 1,1
             .byte 1,1
         .byte $FE
PAT10:
         .byte 7  ; Pattern tempo
             .byte 203,240
             .byte 1,1
             .byte 203,240
             .byte 1,1
             .byte 203,240
             .byte 203,240
             .byte 203,240
             .byte 1,1
             .byte 203,240
             .byte 1,1
             .byte 203,240
             .byte 1,1
             .byte 203,240
             .byte 203,240
             .byte 203,240
             .byte 1,1
         .byte $FE
PAT11:
         .byte 7  ; Pattern tempo
             .byte 171,240
             .byte 171,240
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 171,240
             .byte 171,240
             .byte 171,240
         .byte $FE
PAT12:
         .byte 7  ; Pattern tempo
             .byte 171,240
             .byte 171,240
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
             .byte 171,240
             .byte 1,1
             .byte 1,1
             .byte 1,1
             .byte 1,1
             .byte 1,1
             .byte 81,1
             .byte 102,1
         .byte $FE
PAT13:
         .byte 7  ; Pattern tempo
             .byte 240,121
             .byte 1,102
             .byte 240,61
             .byte 1,102
             .byte 240,121
             .byte 240,102
             .byte 240,61
             .byte 1,102
             .byte 240,121
             .byte 1,102
             .byte 240,61
             .byte 1,102
             .byte 240,121
             .byte 240,102
             .byte 240,61
             .byte 1,102
         .byte $FE
PAT14:
         .byte 7  ; Pattern tempo
             .byte 240,121
             .byte 1,102
             .byte 240,68
             .byte 1,102
             .byte 240,121
             .byte 240,102
             .byte 240,68
             .byte 1,102
             .byte 240,121
             .byte 1,102
             .byte 240,68
             .byte 1,102
             .byte 240,121
             .byte 240,102
             .byte 240,68
             .byte 1,102
         .byte $FE
PAT15:
         .byte 7  ; Pattern tempo
             .byte 203,121
             .byte 1,102
             .byte 203,81
             .byte 1,76
             .byte 203,121
             .byte 203,102
             .byte 203,81
             .byte 1,76
             .byte 203,121
             .byte 1,102
             .byte 203,81
             .byte 1,76
             .byte 203,121
             .byte 203,102
             .byte 203,81
             .byte 1,76
         .byte $FE
PAT16:
         .byte 7  ; Pattern tempo
             .byte 180,121
             .byte 1,102
             .byte 180,81
             .byte 1,76
             .byte 180,121
             .byte 180,102
             .byte 180,81
             .byte 1,76
             .byte 180,121
             .byte 1,102
             .byte 180,81
             .byte 1,76
             .byte 180,121
             .byte 180,102
             .byte 180,81
             .byte 1,76
         .byte $FE
PAT17:
         .byte 7  ; Pattern tempo
             .byte 180,121
             .byte 1,102
             .byte 180,81
             .byte 1,76
             .byte 180,180
             .byte 180,102
             .byte 180,81
             .byte 1,76
             .byte 180,121
             .byte 1,102
             .byte 180,108
             .byte 1,81
             .byte 180,192
             .byte 192,102
             .byte 203,81
             .byte 215,76
         .byte $FE
PAT21:
         .byte 7  ; Pattern tempo
             .byte 1,161
             .byte 1,180
             .byte 1,108
             .byte 1,161
             .byte 1,136
             .byte 1,108
             .byte 1,161
             .byte 1,136
             .byte 1,102
             .byte 1,161
             .byte 1,136
             .byte 1,102
             .byte 1,144
             .byte 1,136
             .byte 1,180
             .byte 1,144
         .byte $FE
PAT22:
         .byte 7  ; Pattern tempo
             .byte 1,161
             .byte 1,1
             .byte 1,108
             .byte 1,1
             .byte 1,136
             .byte 1,1
             .byte 1,161
             .byte 1,1
             .byte 1,102
             .byte 1,1
             .byte 1,136
             .byte 1,1
             .byte 1,144
             .byte 1,1
             .byte 1,180
             .byte 1,1
         .byte $FE
PAT23:
         .byte 7  ; Pattern tempo
             .byte 240,121
             .byte 1,102
             .byte 240,68
             .byte 1,102
             .byte 240,121
             .byte 240,102
             .byte 240,68
             .byte 1,102
             .byte 215,121
             .byte 1,102
             .byte 215,68
             .byte 1,102
             .byte 215,121
             .byte 215,102
             .byte 215,68
             .byte 1,102
         .byte $FE
PAT24:
         .byte 7  ; Pattern tempo
             .byte 180,121
             .byte 1,102
             .byte 180,81
             .byte 1,76
             .byte 180,180
             .byte 180,102
             .byte 180,81
             .byte 1,76
             .byte 1,180
             .byte 151,180
             .byte 161,180
             .byte 171,180
             .byte 180,192
             .byte 192,203
             .byte 203,215
             .byte 215,227
         .byte $FE
		end		start