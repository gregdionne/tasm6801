scnwdth	.equ	$20	; screen width

fretop	.equ	$9b	; upperbound of stack
himem	.equ	$a1	; higest RAM address used by BASIC
tmp	.equ	$cc	; temp storage in floating point result
devnum	.equ	$e8	; current i/o device number:  0 = screen; -2 = printer
chrget	.equ	$eb	; get next input character

scnstrt	.equ	$4000	; screen start
scnend	.equ	$4200	; screen end
exec	.equ	$421f	; default EXEC address
wmstart	.equ	$4221	; warm start vector
topram	.equ	$4250	; highest two-byte RAM address ($4FFE with 4K)
cns_in	.equ	$4285	; extension hook for CONSOLE IN
cns_out	.equ	$4288	; extension hook for CONSOLE OUT
cmd_ext	.equ	$42a0	; extension hook for command dispatcher
crsptr	.equ	$4280	; screen cursor position
okprmpt	.equ	$e271	; display OK prompt and go to immediate mode
clrstr	.equ	$e3ee	; reset string variables
breset	.equ	$e3de	; erase variables and reset stack
blink	.equ	$f83f	; blink cursor
pollkey	.equ	$f883	; poll key for key-down transition
lprint	.equ	$f9d0	; write accumulator A to printer
clrscn	.equ	$fbd6	; clear screen with contents of B
clsarg	.equ	$fbc8	; evaluate numeric CLS argument
evalarg	.equ	$ef0d	; evaluate argument into ACCB (0..255)
msft	.equ	$fbe7	; write MICROSOFT to screen

.org	$8e00

.module install
_start	pulx
	stx	fretop
	lds	topram
	ins
	ldx	#ALLDONE
_again	dex
	ldaa	,x
	psha
	cpx	#flipscn
	bne	_again
	sts	himem
	ldd	himem
	subd	#100
	ldx	fretop
	std	fretop
	lds	fretop
	ldaa	#$7E	; opcode for JMP
	staa	cns_in	; for console IN
	staa	cns_out	; for console OUT
	staa	cmd_ext	; for command extension
	ldd	himem
	addd	#1
	std	exec	; default EXEC address
	subd	#flipscn
	std	tmp
	ldd	#EXWRMBT
	addd	tmp
	std	wmstart
	ldd	#EXCURSR
	addd	tmp
	std	cns_in+1
	ldd	#EXTCLS
	addd	tmp
	std	cmd_ext+1
	ldd	#EXTSCN
	addd	tmp
	std	cns_out+1
	pshx
	jsr	flipscn
	jmp	breset

; flips screen
flipscn	.module flipscn 
	ldx	#scnstrt
_flip1	ldaa	,x
	bmi	_flip2
	eora	#$40
	staa	,x
_flip2	inx
	cpx	#scnend
	bne	_flip1
	rts

; console out extension
EXTSCN	.module extscn
	pshx
	pshb
	psha
	ldab	devnum
	beq	_write
	jmp	lprint	; send to printer
_write	ldx     crsptr	; get screen cursor location
	cmpa    #$08	; backspace
	bne     _trycr
	cpx	#scnstrt
	beq     _leave
	ldaa    #$20	; mc6847 SG4 'space' character
	dex    
	staa     ,x
	bra     _done
_trycr	cmpa    #$0D	; carriage return
	bne     _char
	ldx     crsptr
_blank  ldaa     #$20
	staa     ,x
	inx    
	stx     crsptr
	ldab    crsptr+1
	bitb    #$1F
	bne     _blank
	bra     _done
_char	cmpa    #$20
	blo     _leave
	tsta    
	bmi     _nflip
	cmpa    #$40
	blo     _nflip
	cmpa    #$60
	blo     _flip
	anda    #$9F
_flip	eora    #$40
_nflip	staa    ,x
	inx    
_done	stx     crsptr
	cpx	#scnend
	bne     _leave
	ldx     #scnstrt	; scroll up
_again	ldd     $20,x
	std     ,x
	inx
	inx
	cpx    	#scnend-scnwdth
	bne     _again
	ldab    #$20		; 60 FOR NORMAL
	jsr     clrscn+3	; clear to end of screen
_leave	pula    
	pulb    
	pulx    
	ins
	ins
	rts

EXWRMBT	.module warmstart
	nop
	clr	devnum
	jsr	clrstr
	ldab	#$20
	jsr	clrscn	
	jmp	okprmpt

EXCURSR	.module consoleext
	ins
	ins
	pshx
	pshb
_again	jsr	blink
	jsr	pollkey
	beq	_again
	ldab	#$20
	ldx	crsptr
	stab	,x
	pulb
	pulx
	rts


EXTCLS	.module commandext
	cmpa	#$9D
	beq	_gotcls
	rts
_gotcls	pulx
	jsr	chrget
	beq	_cls2
	jsr	evalarg
	cmpb	#8
	bls	_cls1
	bsr	_cls2
	jmp	msft
_cls1	jmp	clsarg
_cls2	ldab	#$20
	jmp	clrscn

ALLDONE	.end


