;********************************************
; 2 voice squarewave pattern player 
; for 1 bit output at $bfff on MC10
; (C) 2021 Simon Jonassen (invisible man)
;
; FREE FOR ALL - USE AS YOU SEE FIT, JUST
; REMEMBER WHERE IT ORGINATED AND GIVE CREDIT
;********************************************
;		PROCESSOR 	6803
;********************************************
; MC-10 clock is .89488625Mhz or 894.88625 KHz
; We need 7.0Khz interrupts so 894.88625 / 7.0  
; = 128 (127.9xxxx rounded up) 
;********************************************
TVAL		EQU		$80		; Timer period 128
;*************************************
;some equates for the 6803 hardware
;*************************************
TCSR		EQU		$0008		; Timer Control Status Register
TIMER		EQU		$0009		; Counter ($9/$a)
OCR		EQU		$000B		; Output Compare Register ($b/$c)
OCV		EQU		$4206		; Output Compare interrupt Vector
TCSRVAL		EQU		$08		; bit settings for the TCSR
;********************************************
;* Main
;********************************************
		org		$5000
start		sei				;disable irq's
;********************************************
; double note values to save shifts
; on the sequencer
; it's a freq table lookup (them be words)
;********************************************
		ldx		#zix
convert		ldd		,x
		asld	
		std		,x
		inx
		inx
		cpx		#endzix
		blo		convert
;********************************************
; SETUP IRQ ROUTINE
;********************************************
		ldaa		#$7e		;load 'jmp' instruction opcode
		ldx		#note		;irq handler address after JMP instruction
		staa		OCV		;store into OCV vector
		stx		OCV+1
		ldd		#TVAL		;set the timer duration
		std		OCR
		staa		TIMER		;reset the counter to $FFF8
		ldaa		#TCSRVAL	;Enable the timer interrupt
		staa		TCSR

;********************************************
; ENABLE IRQ
;********************************************
		cli				;enable irq's
poop		inc		$4000		;program here spudz (is we runnin irq's)
		jmp		poop		
		rts

;********************************************
; PLAYER ROUTINE
;********************************************
note		staa		TIMER		;Reset the timer
		ldaa		TCSR		;Reset the OCF flag
		ldd		#TVAL		;set the timer duration
		std		OCR
		dec		frames		;
		bne		sum		;(2 ticks per row (ish))
		ldaa		#$c8		;$c0
		staa		frames	
		com		frames+1
		beq		sum
;********************************************
; SEQUENCER
;********************************************

oldx		ldx		#zix		;save pattern position
curnote		ldd		,x
		inx
		inx
		cpx		#endzix
		bne		plnote
		ldx		#zix
plnote		stx		oldx+1		;restore pattern position to start
		staa		frq1+2
		stab		frq2+2
frq1		ldx		#freqtab	;get the right freq
		ldx		,x
		stx		freq+1		;store
frq2		ldx		#freqtab
		ldx		,x
		stx		freq2+1
		rti

;********************************************
; NOTE ROUTINE
;********************************************

sum		ldd 		#$0000 
freq		addd 		#$0000
		std 		sum+1


sum2		ldd		#$0000	
		bcs 		freq2		;tripped on overflow from above summation
		addd		freq2+1		;add the new freq (ch2)
		std		sum2+1		;store it
		bcs		bit_on		;carry (overflow on above add)

bit_off		ldaa		#0		;turn off 1bit
		staa		$bfff		;set the hardware
		rti

freq2		addd		#$0000		;our 1st SUM tripped an overflow
		std		sum2+1		;and we store back to sum #2
bit_on		ldaa		#128		;turn on 1bit
		staa		$bfff		;set the hardware
		rti
;******************************************************
; variables 
;******************************************************
frames		.word	$c800

		.org (($+0FFH) & (0FF00H))
;******************************************************
;equal tempered 12 note per octave frequency table
;
;7Khz vals here
;
;val= freq / 7.000 / 8		'7.0Khz 
;counter=val*256
;
;actual musical freq's - like say 32,70Hz for c1 etc...
;
;entry 0 is SILENCE (would be c1)
;******************************************************


freqtab
c1		.word	$0000,$009E,$00A8,$00B2,$00BC,$00C8,$00D3,$00E0,$00ED,$00FB,$010A,$011A
c2		.word	$012B,$013D,$0150,$0164,$0179,$018F,$01A7,$01C0,$01DB,$01F7,$0215,$0234
c3		.word	$0256,$027A,$029F,$02C7,$02F1,$031E,$034E,$0380,$03B5,$03EE,$042A,$0469
c4		.word	$04AC,$04F3,$053E,$058E,$05E3,$063C,$069B,$0700,$076B,$07DB,$0853,$08D2
c5		.word	$0958,$09E6,$0A7D,$0B1D,$0BC6,$0C79,$0D37,$0E00,$0ED5,$0FB7,$10A6,$11A4
c6		.word	$12B0,$13CC,$14FA,$1639,$178B,$18F2,$1A6E,$1C00,$1DAA,$1F6E,$214C,$2347
c7		.word	$2560,$2799,$29F4,$2C72,$2F17,$31E4,$34DB,$3800,$3B54,$3EDB,$4298,$468E
c8		.word	$4AC0,$4F32,$53E7,$58E5,$5E2E,$63C8,$69B6,$7000,$76A9,$7DB7,$8531,$8D1C

