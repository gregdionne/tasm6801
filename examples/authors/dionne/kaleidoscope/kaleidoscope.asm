rseed   .equ    $fe     ; random number seed
color	.equ	$ff     ; direct page address to store color value
vidram  .equ    $4000   ; start of video RAM
vidend  .equ    $4c00   ; end of video RAM
kvsprt	.equ	$bfff   ; keyboard video sound port
vidmod  .equ    100     ; code for CG3 (96 x 128) 4 colors (buff, cyan, magenta, orange)
mcbrom  .equ    $e000   ; start of MICROCOLOR BASIC ROM

	.org	vidend

	.module mdmain

        ; set to CG3 and clear screen
	ldaa	#vidmod
	staa	kvsprt
        ldx     #vidram
_nxtclr
        clr     ,x
        inx
        cpx     #vidend
        bne     _nxtclr

        ; main loop
_begin
        ldx     #mcbrom ; point to start of BASIC ROM
_loop
	ldaa	,x	; get rom byte
	anda	#3	; use first byte as color.  keep within 0-3.
	staa	color
	ldab	1,x	; get next rom byte
        tba             ; and do multiplication
        orab    #1      ; ... with an odd value
        eora    rseed   ; ... of the complement with seed
        mul             ; ... to mimic a random
        stab    rseed   ; ... number
	anda	#127	; keep col within 0-127
	andb	#63	; keep row within 0-63

	; registers A and B now hold row and column, respectively.
	; plot 
	bsr	plot

	; plot 95-row,col
	negb
	addb	#95
	bsr	plot

	; plot 95-row,127-col
	nega
	adda	#127
	bsr	plot

	; plot row,127-col
	negb
	addb	#95
	bsr	plot

	; bump data pointer
	inx
	bne	_loop   ; loop if still in ROM
        bra     _begin  ; restart at beginning of ROM


	.module mdplot
; entry:  ACCA  holds row (0-95)
;         ACCB  holds column (0-127)
;         color holds color (0-3)
plot
	pshx		; save registers
	pshb
	psha
	psha		; save column
	ldaa	#32	; multiply row by 32 (bytes/row)
	mul		;
	adda	#$40	; and add $4000 to result (screen start)
	pshb		; transfer ACCD to register X.
	psha		
	pulx
	pulb		; restore column
	tba		; divide column by 4 (pixels/byte)
	lsrb
	lsrb
	abx		; and add to register X
	ldab	#$40	; initialize lsb of mask with leftmost pixel
	anda	#3	; take column modulo 4.
	beq	_pixel	; go if already leftmost pixel
_shift
	lsrb		; shift multiplier down by two bits
	lsrb
	deca		; decrement column count
	bne	_shift	; keep shifting until count is zero
_pixel
	pshb		; save lsb of mask
	tba		; multiply by 3
	lslb		;
	aba		;
	coma		; invert mask and
	anda	,x	; remove the previous pixel
	staa	,x
	pulb		; restore lsb of mask
	ldaa	color	; and multiply by color
	mul		; to get new color mask
	orab	,x	; put new color into pixel
	stab	,x
	pula		; restore registers
	pulb		; and return
	pulx
	rts
