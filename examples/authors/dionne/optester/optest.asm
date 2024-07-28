; MC6801 opcode tester for the TRS-80 MC-10.
; requires original MICROCOLOR BASIC 1.0 ROM

M_SCRN	.equ	$4000
M_STAT	.equ	$4100
M_LASTL	.equ	$41E0
M_IKEY	.equ	$427F
M_CRSR	.equ	$4280

R_START	.equ	$E001
R_PUTS	.equ	$E7B2
R_SPACE	.equ	$E7B9
R_PUTC	.equ	$F9C9
R_KPOLL	.equ	$F879
R_CLS	.equ	$FBD4

ccr	.equ	$41FB
args	.equ	$41FC

	.org	$C9
currop	.block	1
curtab	.block	2
curchk	.block	2
chksum	.block	2
chktmp	.block	2
result	.block	2

	.org	$4400

; main loop
	.module	mdstart
start
	jsr	ssetup
	jsr	scrstat

	ldx	#optable
	stx	curtab

_nxtop
	bsr	evalop
	ldx	result
	cpx	#fail
	brn	_done	; beq to stop
	ldx	curtab
	ldab	#8
	abx
	stx	curtab
	cpx	#opend
	blo	_nxtop
_done
	jmp	scrstat

; evaluate one opcode
	.module	mdevalop
evalop
	jsr	scrstat

	; write opcode byte to screen
	ldab	0,x
	stab	currop
	jsr	spitb
	jsr	R_SPACE

	; write opcode to screen
	inx
	ldab	#4
	jsr	R_PUTS
	jsr	R_SPACE

	; do checksum routine
	ldx	curtab
	ldab	5,x
	ldx	#chktab
	abx
	abx
	ldx	,x
	jsr	,x

	; display checksum
	ldd	chksum
	jsr	spitd
	jsr	R_SPACE

	; give result
	ldx	curtab
	ldd	chksum
	subd	6,x
	bne	_fail
	ldd	6,x
	beq	_skip
	ldx	#pass
	bra	_result
_fail
	ldx	#fail
	bra	_result
_skip
	ldx	#skip
_result
	stx	result
	ldab	#4
	ldaa	,x
	psha
	jsr	R_PUTS
	jsr	R_SPACE

	; update optable
	pula
	ldab	currop
	pshx
	ldx	#M_SCRN
	abx
	stx	M_CRSR
	jsr	R_PUTC
	pulx
	rts

; setup the screen
	.module	mdssetup
ssetup
	jsr	R_CLS
	ldaa	#'.'
	clrb
_nxtdot
	jsr	R_PUTC
	decb
	bne	_nxtdot
	rts

; scroll the status window upward
	.module	mdscrstat
scrstat
	pshx
	ldx	#M_STAT
_scroll
	ldab	$20,x
	stab	 ,x
	inx
	cpx	#M_LASTL-$20
	bne	_scroll
	stx	M_CRSR
	pshx
	ldaa	#'\r'
	jsr	R_PUTC
	pulx
	stx	M_CRSR
	pulx
	rts


; skip instruction
	.module	chkxxxx
chkxxxx
	jsr	chkinit
	rts

; ccr (P) inherent
	.module	mdchkinhp
chkinhp
	jsr	chkinit
	staa	_opcode
_loop
	ldaa	ccr
	tap
_opcode	.block	1
	tpa
	jsr	chka
	jsr	nxtccr
	bne	_loop
	rts

; "take and mutate" from a to b
	.module	mdchkitab
chkitab
	jsr	chkinit
	staa	_opcode
_loop
	ldaa	args
	psha
	ldaa	ccr
	tap
	pula
_opcode	.block	1
	pshb
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; "take and operate" from b to a
	.module	mdchkitba
chkitba
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	ldaa	ccr
	tap

_opcode	.block	1

	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; A register inherent
	.module	mdchkinha
chkinha
	jsr	chkinit
	staa	_opcode
_loop
	ldaa	args
	psha
	ldaa	ccr
	tap
	pula

_opcode	.block	1
	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; B register inherent
	.module	mdchkinhb
chkinhb
	jsr	chkinit
	staa	_opcode
_loop
	ldd	ccr
	tap

_opcode	.block	1
	pshb
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; D register inherent
	.module	mdchkinhd
chkinhd
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	std	args+2
	psha
	ldaa	ccr
	tap
	pula
_opcode	.block	1
	pshb
	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	pula
	jsr	chka
	inc	args
	inc	args
	ldab	args
	cmpb	#$20
	bne	_loop
	clr	args
	jsr	nxtccr
	bne	_loop
	rts

; X register inherent
	.module	mdchkinhx
chkinhx
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargx
	ldaa	ccr
	tap
_opcode	.block	1
	pshx
	tpa
	jsr	chka
	pula
	jsr	chka
	pula
	jsr	chka
	inc	args
	inc	args
	ldab	args
	cmpb	#$20
	bne	_loop
	clr	args
	jsr	nxtccr
	bne	_loop
	rts

; relative branch
	.module	mdchkrelp
chkrelp
	jsr	chkinit
	staa	_opcode
_loop
	ldaa	ccr
	tap
_opcode brn	_take
	ldaa	#$01
	bra	_go
_take
	ldaa	#$ff
_go
	jsr	chka
	jsr	nxtccr
	bne	_loop
	rts

; pure indexed mode
	.module	mdchkindx
chkindx
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	stab	args+1
	ldx	#args+1
	ldaa	ccr
	tap

_opcode	.block	1
	.byte	0
	tpa
	jsr	chka
	ldaa	args+1
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; pure external mode
	.module	mdchkextn
chkextn
	jsr	chkinit
	staa	_opcode
_loop
	ldd	ccr
	stab	_dst+1
	tap
_opcode	.block	1
_addr	.word	_dst+1
	tpa
	jsr	chka
_dst:	ldaa	#0
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; A register with immediate address mode
	.module	mdchkimma
chkimma
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	std	args+2
	psha
	stab	_opernd
	ldaa	ccr
	tap
	pula
_opcode	.block	1
_opernd	.block	1
	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	inc	args
	ldab	args
	cmpb	#$20
	bne	_loop
	clr	args
	jsr	nxtccr
	bne	_loop
	rts

; B register with immediate address mode
	.module	mdchkimmb
chkimmb
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	std	args+2
	staa	_opernd
	ldaa	ccr
	tap
_opcode	.block	1
_opernd	.block	1
	pshb
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	inc	args
	ldab	args
	cmpb	#$20
	bne	_loop
	clr	args
	jsr	nxtccr
	bne	_loop
	rts

; A register with direct address mode
	.module	mdchkdira
chkdira
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	psha
	stab	chktmp
	ldaa	ccr
	tap
	pula
_opcode	.block	1
_opernd	.byte	chktmp
	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	inc	args
	ldab	args
	cmpb	#$20
	bne	_loop
	clr	args
	jsr	nxtccr
	bne	_loop
	rts

; B register with direct address mode
	.module	mdchkdirb
chkdirb
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	staa	chktmp
	ldaa	ccr
	tap
_opcode	.block	1
_opernd	.byte	chktmp
	pshb
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	inc	args
	ldab	args
	cmpb	#$20
	bne	_loop
	clr	args
	jsr	nxtccr
	bne	_loop
	rts

; A register with indexed address mode
	.module	mdchkidxa
chkidxa
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	psha
	ldx	#_chkdat
	stab	,x
	ldaa	ccr
	tap
	pula

_opcode	.block	1
	.byte	0
	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	inc	args
	ldab	args
	cmpb	#$20
	bne	_loop
	clr	args
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	1

; B register with indexed address mode
	.module	mdchkidxb
chkidxb
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	ldx	#_chkdat
	staa	,x
	ldaa	ccr
	tap
_opcode	.block	1
	.byte	0
	pshb
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	inc	args
	ldab	args
	cmpb	#$20
	bne	_loop
	clr	args
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	1

; A register with external address mode
	.module	mdchkexta
chkexta
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	psha
	stab	_chkdat
	ldaa	ccr
	tap
	pula
_opcode	.block	1
	.word	_chkdat
	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	inc	args
	ldab	args
	cmpb	#$20
	bne	_loop
	clr	args
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	1

; B register with external address mode
	.module	mdchkextb
chkextb
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	staa	_chkdat
	ldaa	ccr
	tap
_opcode	.block	1
	.word	_chkdat
	pshb
	tpa
	jsr	chka
	pula
	jsr	chka
	inc	args
	inc	args
	ldab	args
	cmpb	#$20
	bne	_loop
	clr	args
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	1


; A register with immediate store
	.module	mdchkstai
chkstai
	jsr	chkinit
	staa	_opcode
_loop
	ldaa	args
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
_oper	.block	1
	tpa
	jsr	chka
	ldaa	_oper
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; B register with immediate store
	.module	mdchkstbi
chkstbi
	jsr	chkinit
	staa	_opcode
_loop
	ldd	ccr
	tap
_opcode	.block	1
_oper	.block	1
	tpa
	jsr	chka
	ldaa	_oper
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; A register with direct store
	.module	mdchkstad
chkstad
	jsr	chkinit
	staa	_opcode
_loop
	ldaa	args
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
_oper	.byte	chktmp
	tpa
	jsr	chka
	ldaa	chktmp
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; B register with direct store
	.module	mdchkstbd
chkstbd
	jsr	chkinit
	staa	_opcode
_loop
	ldd	ccr
	tap
_opcode	.block	1
_oper	.byte	chktmp
	tpa
	jsr	chka
	ldaa	chktmp
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; A register with indexed store
	.module	mdchkstax
chkstax
	jsr	chkinit
	staa	_opcode
_loop
	ldaa	args
	psha	
	ldx	#_chkdat
	ldaa	ccr
	tap
	pula
_opcode	.block	1
_oper	.byte	0
	tpa
	jsr	chka
	ldaa	_chkdat
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	1

; B register with indexed store
	.module	mdchkstbx
chkstbx
	jsr	chkinit
	staa	_opcode
_loop
	ldd	ccr
	ldx	#_chkdat
	tap
_opcode	.block	1
_oper	.byte	0
	tpa
	jsr	chka
	ldaa	_chkdat
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	 1

; A register with extended store
	.module	mdchkstae
chkstae
	jsr	chkinit
	staa	_opcode
_loop
	ldaa	args
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
_oper	.word	_chkdat
	tpa
	jsr	chka
	ldaa	_chkdat
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	1

; B register with extended store
	.module	mdchkstbe
chkstbe
	jsr	chkinit
	staa	_opcode
_loop
	ldd	ccr
	tap
_opcode	.block	1
_oper	.word	_chkdat
	tpa
	jsr	chka
	ldaa	_chkdat
	jsr	chka
	inc	args
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	 1





; D register with immediate
	.module	mdchkimmd
chkimmd
	jsr	chkinit
	staa	_opcode
_loop
	ldd	args
	jsr	wrdargx
	stx	_oper
	tab
	jsr	wrdargd
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
_oper	.block	2
	pshb
	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	pula
	jsr	chka
	jsr	barglsb
	bne	_loop
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; D register with direct
	.module	mdchkdird
chkdird
	jsr	chkinit
	staa	_opcode
_loop
	ldd	args
	jsr	wrdargx
	stx	chktmp
	tab
	jsr	wrdargd
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
	.byte	chktmp
	pshb
	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	pula
	jsr	chka
	jsr	barglsb
	bne	_loop
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts


; D register with indexed
	.module	mdchkidxd
chkidxd
	jsr	chkinit
	staa	_opcode
_loop
	ldd	args
	jsr	wrdargx
	stx	_chkdat
	tab
	jsr	wrdargd
	ldx	#_chkdat
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
	.byte	0
	pshb
	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	pula
	jsr	chka
	jsr	barglsb
	bne	_loop
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	2

; D register with extended
	.module	mdchkextd
chkextd
	jsr	chkinit
	staa	_opcode
_loop
	ldd	args
	jsr	wrdargx
	stx	_chkdat
	tab
	jsr	wrdargd
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
	.word	_chkdat
	pshb
	psha
	tpa
	jsr	chka
	pula
	jsr	chka
	pula
	jsr	chka
	jsr	barglsb
	bne	_loop
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	2


; X register with immediate
	.module	mdchkimmx
chkimmx
	jsr	chkinit
	staa	_opcode
_loop
	ldd	args
	jsr	wrdargx
	stx	_oper
	tab
	jsr	wrdargx
	ldaa	ccr
	tap
_opcode	.block	1
_oper	.block	2
	pshx
	tpa
	jsr	chka
	pula
	jsr	chka
	pula
	jsr	chka
	jsr	barglsb
	bne	_loop
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; X register with direct
	.module	mdchkdirx
chkdirx
	jsr	chkinit
	staa	_opcode
_loop
	ldd	args
	jsr	wrdargx
	stx	chktmp
	tab
	jsr	wrdargx
	ldaa	ccr
	tap
_opcode	.block	1
	.byte	chktmp
	pshx
	tpa
	jsr	chka
	pula
	jsr	chka
	pula
	jsr	chka
	jsr	barglsb
	bne	_loop
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; X register with extended
	.module	mdchkextx
chkextx
	jsr	chkinit
	staa	_opcode
_loop
	ldd	args
	jsr	wrdargx
	stx	_chkdat
	tab
	jsr	wrdargx
	ldaa	ccr
	tap
_opcode	.block	1
	.word	_chkdat
	pshx
	tpa
	jsr	chka
	pula
	jsr	chka
	pula
	jsr	chka
	jsr	barglsb
	bne	_loop
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	2



; D register with immediate store
	.module	mdchkstdi
chkstdi
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
_oper	.block	2
	tpa
	jsr	chka
	ldaa	_oper
	jsr	chka
	ldaa	_oper+1
	jsr	chka
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; D register with direct store
	.module	mdchkstdd
chkstdd
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
	.byte	chktmp
	tpa
	jsr	chka
	ldaa	chktmp
	jsr	chka
	ldaa	chktmp+1
	jsr	chka
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; D register with indexed store
	.module	mdchkstdx
chkstdx
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	ldx	#_chkdat
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
	.byte	0
	tpa
	jsr	chka
	ldaa	_chkdat
	jsr	chka
	ldaa	_chkdat+1
	jsr	chka
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	2

; D register with extended store
	.module	mdchkstde
chkstde
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargd
	psha	
	ldaa	ccr
	tap
	pula
_opcode	.block	1
	.word	_chkdat
	tpa
	jsr	chka
	ldaa	_chkdat
	jsr	chka
	ldaa	_chkdat+1
	jsr	chka
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	2



; X register with immediate store
	.module	mdchkstxi
chkstxi
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargx
	ldaa	ccr
	tap
_opcode	.block	1
_oper	.block	2
	tpa
	jsr	chka
	ldaa	_oper
	jsr	chka
	ldaa	_oper+1
	jsr	chka
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; X register with direct store
	.module	mdchkstxd
chkstxd
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargx
	ldaa	ccr
	tap
_opcode	.block	1
	.byte	chktmp
	tpa
	jsr	chka
	ldaa	chktmp
	jsr	chka
	ldaa	chktmp+1
	jsr	chka
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts

; X register with extended store 
	.module	mdchkstxe
chkstxe
	jsr	chkinit
	staa	_opcode
_loop
	ldab	args
	jsr	wrdargx
	ldaa	ccr
	tap
_opcode	.block	1
	.word	_chkdat
	tpa
	jsr	chka
	ldaa	_chkdat
	jsr	chka
	ldaa	_chkdat+1
	jsr	chka
	jsr	bargmsb
	bne	_loop
	jsr	nxtccr
	bne	_loop
	rts
_chkdat	.block	2



; MODULE mdchkinit
;   initialize checksum, ccr, and arguments
;   X initialized to ROM start
;
	.module	mdchkinit
chkinit
	ldd	#0
	std	chksum
	std	chktmp
	stab	ccr
	std	args
	std	args+2

	ldx	#R_START
	stx	curchk
	ldaa	currop
	rts


; MODULE mdchka
; take contents of ACCA and adjust checksum
;
	.module	mdchka
chka
	ldx	curchk
	ldab	,x
	orab	#1
	mul
	addd	chksum
	std	chksum
	inx
	bne	_rts
	ldx	#R_START
_rts
	stx	curchk
	rts

; MODULE mdwargs
; handle word table args 
	.module	mdwargs

wrdargx
	ldx	#wordtab
	abx
	ldx	,x
	rts

wrdargd
	ldx	#wordtab
	abx
	ldd	,x
	rts

bargmsb
	ldab	args
	incb
	incb
	cmpb	#$20
	bne	_mrts
	clrb
_mrts
	stab	args
	rts

barglsb
	ldab	args+1
	incb
	incb
	cmpb	#$20
	bne	_lrts
	clrb
_lrts
	stab	args+1
	rts

; MODULE mdnxtccr
; increment the CCR register input mask
; (always skipping the "I" flag)
;
	.module	mdnxtccr
nxtccr
	ldaa	ccr
	inca
	bita	#$0F
	bne	_done
	lsla
	bita	#$40
	beq	_done
	clra
_done
	anda	#$2F
	staa	ccr
	rts


	.module	mdspit
spitd	bsr	spita
spitb	pshb
	psha
	tba
	bsr	spita
	pula
	pulb
	rts
spita
	pshx
	psha
	psha
	lsra
	lsra
	lsra
	lsra
	bsr	_spithex
	pula
	anda	#$0f
	bsr	_spithex
	pula
	pulx
	rts

	; sic hunt dracones!
_spithex
	adda	#0
	daa
	adda	#-10
	adca	#10+'0'
	jmp	R_PUTC

pass	.text	"PASS"
fail	.text	"fail"
skip	.text	"SKIP"

xxxx	.equ	0
inhp	.equ	1
itab	.equ	2
itba	.equ	3
inha	.equ	4
inhb	.equ	5
inhd	.equ	6
inhx	.equ	7

relp	.equ	8
indx	.equ	9
extn	.equ	10

imma	.equ	11
immb	.equ	12
dira	.equ	13
dirb	.equ	14
idxa	.equ	15
idxb	.equ	16
exta	.equ	17
extb	.equ	18

stai	.equ	19
stbi	.equ	20
stad	.equ	21
stbd	.equ	22
stax	.equ	23
stbx	.equ	24
stae	.equ	25
stbe	.equ	26

immd	.equ	27
dird	.equ	28
idxd	.equ	29
extd	.equ	30
immx	.equ	31
dirx	.equ	32
extx	.equ	33

stdi	.equ	34
stdd	.equ	35
stdx	.equ	36
stde	.equ	37
stxi	.equ	38
stxd	.equ	39
stxe	.equ	40

chktab
	.word	chkxxxx
	.word	chkinhp
	.word	chkitab
	.word	chkitba
	.word	chkinha
	.word	chkinhb
	.word	chkinhd
	.word	chkinhx

	.word	chkrelp
	.word	chkindx
	.word	chkextn

	.word	chkimma
	.word	chkimmb
	.word	chkdira
	.word	chkdirb
	.word	chkidxa
	.word	chkidxb
	.word	chkexta
	.word	chkextb

	.word	chkstai
	.word	chkstbi
	.word	chkstad
	.word	chkstbd
	.word	chkstax
	.word	chkstbx
	.word	chkstae
	.word	chkstbe

	.word	chkimmd
	.word	chkdird
	.word	chkidxd
	.word	chkextd
	.word	chkimmx
	.word	chkdirx
	.word	chkextx

	.word	chkstdi
	.word	chkstdd
	.word	chkstdx
	.word	chkstde
	.word	chkstxi
	.word	chkstxd
	.word	chkstxe

wordtab
	.word	$0000
	.word	$0001
	.word	$3ffe
	.word	$3fff
	.word	$4000
	.word	$4001
	.word	$7ffe
	.word	$7fff
	.word	$8000
	.word	$8001
	.word	$Bffe
	.word	$Bfff
	.word	$C000
	.word	$C001
	.word	$fffe
	.word	$ffff

optable

	.byte	$00, "clb ", inhb, $72, $7E ; inhb
	.byte	$01, "NOP ", inhp, $41, $00
	.byte	$02, "sexa", inha, $6F, $B4
	.byte	$03, "seta", inha, $71, $34
	.byte	$04, "LSRD", inhd, $90, $58
	.byte	$05, "LSLD", inhd, $3F, $DE
	.byte	$06, "TAP ", inha, $74, $EC
	.byte	$07, "TPA ", inha, $C4, $D4
	.byte	$08, "INX ", inhx, $EC, $E2
	.byte	$09, "DEX ", inhx, $60, $6A

	.byte	$0A, "CLV ", inhp, $2A, $28
	.byte	$0B, "SEV ", inhp, $57, $AC
	.byte	$0C, "CLC ", inhp, $32, $88
	.byte	$0D, "SEC ", inhp, $49, $4A
	.byte	$0E, "CLI ", xxxx, $00, $00
	.byte	$0F, "SEI ", xxxx, $00, $00

	.byte	$10, "SBA ", inhd, $05, $84
	.byte	$11, "CBA ", inhd, $65, $54
	.byte	$12, "scba", inhd, $76, $F4
	.byte	$13, "sdba", inhd, $03, $B8
	.byte	$14, "tdab", itab, $11, $C0 ; inhd = $E4B8
	.byte	$15, "tdba", itba, $11, $C0 ; inhd = $613E
	.byte	$16, "TAB ", itab, $EA, $82
	.byte	$17, "TBA ", itba, $EA, $82
	.byte	$18, "aba ", inhd, $67, $AE
	.byte	$19, "DAA ", inha, $C9, $1A
	.byte	$1A, "aba ", inhd, $67, $AE
	.byte	$1B, "ABA ", inhd, $01, $C8
	.byte	$1C, "tdab", itab, $11, $C0 ; inhd = $E4B8
	.byte	$1D, "tdbc", itba, $81, $D8 ; inhd = $8126
	.byte	$1E, "tab ", itab, $EA, $82 ; inhd = $BA94
	.byte	$1F, "tbac", itba, $69, $0A ; inhd = $C220

	.byte	$20, "BRA ", relp, $AB, $3E
	.byte	$21, "BRN ", relp, $16, $C2
	.byte	$22, "BHI ", relp, $FA, $EA
	.byte	$23, "BLS ", relp, $C7, $16
	.byte	$24, "BCC ", relp, $50, $2E
	.byte	$25, "BCS ", relp, $71, $D2
	.byte	$26, "BNE ", relp, $81, $BE
	.byte	$27, "BEQ ", relp, $40, $42
	.byte	$28, "BVC ", relp, $56, $16
	.byte	$29, "BVS ", relp, $6B, $EA
	.byte	$2A, "BPL ", relp, $0C, $AA
	.byte	$2B, "BMI ", relp, $B5, $56
	.byte	$2C, "BGE ", relp, $75, $D2
	.byte	$2D, "BLT ", relp, $4C, $2E
	.byte	$2E, "BGT ", relp, $56, $2A
	.byte	$2F, "BLE ", relp, $6B, $D6

	.byte	$30, "TSX ", xxxx, $00, $00
	.byte	$31, "INS ", xxxx, $00, $00
	.byte	$32, "PULA", xxxx, $00, $00
	.byte	$33, "PULB", xxxx, $00, $00
	.byte	$34, "DES ", xxxx, $00, $00
	.byte	$35, "TXS ", xxxx, $00, $00
	.byte	$36, "PSHA", xxxx, $00, $00
	.byte	$37, "PSHB", xxxx, $00, $00
	.byte	$38, "PULX", xxxx, $00, $00
	.byte	$39, "RTS ", xxxx, $00, $00
	.byte	$3A, "ABX ", xxxx, $00, $00
	.byte	$3B, "RTI ", xxxx, $00, $00
	.byte	$3C, "PSHX", xxxx, $00, $00
	.byte	$3D, "MUL ", inhd, $40, $70
	.byte	$3E, "WAI ", xxxx, $00, $00
	.byte	$3F, "SWI ", xxxx, $00, $00

	.byte	$40, "NEGA", inha, $51, $7A
	.byte	$50, "NEGB", inhb, $51, $7A
	.byte	$60, "NEG ", indx, $51, $7A
	.byte	$70, "NEG ", extn, $51, $7A

	.byte	$41, "nga ", inha, $69, $0A
	.byte	$51, "ngb ", inhb, $69, $0A
	.byte	$61, "ng  ", indx, $5C, $F8
	.byte	$71, "ng  ", extn, $5C, $F8

	.byte	$42, "ngca", inha, $02, $64
	.byte	$52, "ngcb", inhb, $02, $64
	.byte	$62, "ngc ", indx, $02, $64
	.byte	$72, "ngc ", extn, $02, $64

	.byte	$43, "COMA", inha, $56, $88
	.byte	$53, "COMB", inhb, $56, $88
	.byte	$63, "COM ", indx, $56, $88
	.byte	$73, "COM ", extn, $56, $88

	.byte	$44, "LSRA", inha, $CC, $7C
	.byte	$54, "LSRB", inhb, $CC, $7C
	.byte	$64, "LSR ", indx, $CC, $7C
	.byte	$74, "LSR ", extn, $CC, $7C

	.byte	$45, "lra ", inha, $CC, $7C
	.byte	$55, "lrb ", inhb, $CC, $7C
	.byte	$65, "lr  ", indx, $26, $EC
	.byte	$75, "lr  ", extn, $26, $EC

	.byte	$46, "RORA", inha, $6D, $58
	.byte	$56, "RORB", inhb, $6D, $58
	.byte	$66, "ROR ", indx, $6D, $58
	.byte	$76, "ROR ", extn, $6D, $58

	.byte	$47, "ASRA", inha, $8D, $50
	.byte	$57, "ASRB", inhb, $8D, $50
	.byte	$67, "ASR ", indx, $8D, $50
	.byte	$77, "ASR ", extn, $8D, $50

	.byte	$48, "LSLA", inha, $CF, $76
	.byte	$58, "LSLB", inhb, $CF, $76
	.byte	$68, "LSL ", indx, $CF, $76
	.byte	$78, "LSL ", extn, $CF, $76

	.byte	$49, "ROLA", inha, $71, $58
	.byte	$59, "ROLB", inhb, $71, $58
	.byte	$69, "ROL ", indx, $71, $58
	.byte	$79, "ROL ", extn, $71, $58

	.byte	$4A, "DECA", inha, $11, $C0
	.byte	$5A, "DECB", inhb, $11, $C0
	.byte	$6A, "DEC ", indx, $11, $C0
	.byte	$7A, "DEC ", extn, $11, $C0

	.byte	$4B, "dca ", inha, $81, $D8
	.byte	$5B, "dcb ", inhb, $81, $D8
	.byte	$6B, "dc  ", indx, $81, $D8
	.byte	$7B, "dc  ", extn, $81, $D8

	.byte	$4C, "INCA", inha, $57, $A4
	.byte	$5C, "INCB", inhb, $57, $A4
	.byte	$6C, "INC ", indx, $57, $A4
	.byte	$7C, "INC ", extn, $57, $A4

	.byte	$4D, "TSTA", inha, $1D, $F8
	.byte	$5D, "TSTB", inhb, $1D, $F8
	.byte	$6D, "TST ", indx, $1D, $F8
	.byte	$7D, "TST ", extn, $1D, $F8

	.byte	$4E, "hcfa", xxxx, $00, $00
	.byte	$5E, "hcfb", xxxx, $00, $00
	.byte	$6E, "JMP ", xxxx, $00, $00
	.byte	$7E, "JMP ", xxxx, $00, $00

	.byte	$4F, "CLRA", inha, $D7, $88
	.byte	$5F, "CLRB", inhb, $D7, $88
	.byte	$6F, "CLR ", indx, $D7, $88
	.byte	$7F, "CLR ", extn, $D7, $88

	.byte	$80, "SUBA", imma, $58, $44
	.byte	$90, "SUBA", dira, $58, $44
	.byte	$A0, "SUBA", idxa, $58, $44
	.byte	$B0, "SUBA", exta, $58, $44
	.byte	$C0, "SUBB", immb, $E7, $DA
	.byte	$D0, "SUBB", dirb, $E7, $DA
	.byte	$E0, "SUBB", idxb, $E7, $DA
	.byte	$F0, "SUBB", extb, $E7, $DA

	.byte	$81, "CMPA", imma, $4C, $66
	.byte	$91, "CMPA", dira, $4C, $66
	.byte	$A1, "CMPA", idxa, $4C, $66
	.byte	$B1, "CMPA", exta, $4C, $66
	.byte	$C1, "CMPB", immb, $27, $B4
	.byte	$D1, "CMPB", dirb, $27, $B4
	.byte	$E1, "CMPB", idxb, $27, $B4
	.byte	$F1, "CMPB", extb, $27, $B4

	.byte	$82, "SBCA", imma, $33, $66
	.byte	$92, "SBCA", dira, $33, $66
	.byte	$A2, "SBCA", idxa, $33, $66
	.byte	$B2, "SBCA", exta, $33, $66
	.byte	$C2, "SBCB", immb, $CB, $E4
	.byte	$D2, "SBCB", dirb, $CB, $E4
	.byte	$E2, "SBCB", idxb, $CB, $E4
	.byte	$F2, "SBCB", extb, $CB, $E4

	.byte	$83, "SUBD", immd, $11, $6A
	.byte	$93, "SUBD", dird, $11, $6A
	.byte	$A3, "SUBD", idxd, $11, $6A
	.byte	$B3, "SUBD", extd, $11, $6A
	.byte	$C3, "ADDD", immd, $18, $5A
	.byte	$D3, "ADDD", dird, $18, $5A
	.byte	$E3, "ADDD", idxd, $18, $5A
	.byte	$F3, "ADDD", extd, $18, $5A

	.byte	$84, "ANDA", imma, $F6, $E2
	.byte	$94, "ANDA", dira, $F6, $E2
	.byte	$A4, "ANDA", idxa, $F6, $E2
	.byte	$B4, "ANDA", exta, $F6, $E2
	.byte	$C4, "ANDB", immb, $F6, $E2
	.byte	$D4, "ANDB", dirb, $F6, $E2
	.byte	$E4, "ANDB", idxb, $F6, $E2
	.byte	$F4, "ANDB", extb, $F6, $E2

	.byte	$85, "BITA", imma, $98, $2E
	.byte	$95, "BITA", dira, $98, $2E
	.byte	$A5, "BITA", idxa, $98, $2E
	.byte	$B5, "BITA", exta, $98, $2E
	.byte	$C5, "BITB", immb, $8A, $76
	.byte	$D5, "BITB", dirb, $8A, $76
	.byte	$E5, "BITB", idxb, $8A, $76
	.byte	$F5, "BITB", extb, $8A, $76

	.byte	$86, "LDAA", imma, $52, $66
	.byte	$96, "LDAA", dira, $52, $66
	.byte	$A6, "LDAA", idxa, $52, $66
	.byte	$B6, "LDAA", exta, $52, $66
	.byte	$C6, "LDAB", immb, $27, $2E
	.byte	$D6, "LDAB", dirb, $27, $2E
	.byte	$E6, "LDAB", idxb, $27, $2E
	.byte	$F6, "LDAB", extb, $27, $2E

	.byte	$87, "I87 ", stai, $D0, $5A
	.byte	$97, "STAA", stad, $EA, $82
	.byte	$A7, "STAA", stax, $EA, $82
	.byte	$B7, "STAA", stae, $EA, $82
	.byte	$C7, "IC7 ", stbi, $D0, $5A
	.byte	$D7, "STAB", stbd, $EA, $82
	.byte	$E7, "STAB", stbx, $EA, $82
	.byte	$F7, "STAB", stbe, $EA, $82

	.byte	$88, "EORA", imma, $21, $3C
	.byte	$98, "EORA", dira, $21, $3C
	.byte	$A8, "EORA", idxa, $21, $3C
	.byte	$B8, "EORA", exta, $21, $3C
	.byte	$C8, "EORB", immb, $21, $3C
	.byte	$D8, "EORB", dirb, $21, $3C
	.byte	$E8, "EORB", idxb, $21, $3C
	.byte	$F8, "EORB", extb, $21, $3C

	.byte	$89, "ADCA", imma, $30, $7A
	.byte	$99, "ADCA", dira, $30, $7A
	.byte	$A9, "ADCA", idxa, $30, $7A
	.byte	$B9, "ADCA", exta, $30, $7A
	.byte	$C9, "ADCB", immb, $30, $7A
	.byte	$D9, "ADCB", dirb, $30, $7A
	.byte	$E9, "ADCB", idxb, $30, $7A
	.byte	$F9, "ADCB", extb, $30, $7A

	.byte	$8A, "ORAA", imma, $2E, $EA
	.byte	$9A, "ORAA", dira, $2E, $EA
	.byte	$AA, "ORAA", idxa, $2E, $EA
	.byte	$BA, "ORAA", exta, $2E, $EA
	.byte	$CA, "ORAB", immb, $2E, $EA
	.byte	$DA, "ORAB", dirb, $2E, $EA
	.byte	$EA, "ORAB", idxb, $2E, $EA
	.byte	$FA, "ORAB", extb, $2E, $EA

	.byte	$8B, "ADDA", imma, $C5, $FC
	.byte	$9B, "ADDA", dira, $C5, $FC
	.byte	$AB, "ADDA", idxa, $C5, $FC
	.byte	$BB, "ADDA", exta, $C5, $FC
	.byte	$CB, "ADDB", immb, $C5, $FC
	.byte	$DB, "ADDB", dirb, $C5, $FC
	.byte	$EB, "ADDB", idxb, $C5, $FC
	.byte	$FB, "ADDB", extb, $C5, $FC

	.byte	$8C, "CPX ", immx, $E5, $0C
	.byte	$9C, "CPX ", dirx, $E5, $0C
	.byte	$AC, "CPX ", xxxx, $00, $00
	.byte	$BC, "CPX ", extx, $E5, $0C
	.byte	$CC, "LDD ", immd, $F1, $A8
	.byte	$DC, "LDD ", dird, $F1, $A8
	.byte	$EC, "LDD ", idxd, $F1, $A8
	.byte	$FC, "LDD ", extd, $F1, $A8

	.byte	$8D, "BSR ", xxxx, $00, $00
	.byte	$9D, "JSR ", xxxx, $00, $00
	.byte	$AD, "BSR ", xxxx, $00, $00
	.byte	$BD, "BSR ", xxxx, $00, $00
	.byte	$CD, "STD ", stdi, $31, $CA
	.byte	$DD, "STD ", stdd, $ED, $DE
	.byte	$ED, "STD ", stdx, $ED, $DE
	.byte	$FD, "STD ", stde, $ED, $DE

	.byte	$8E, "LDS ", xxxx, $00, $00
	.byte	$9E, "LDS ", xxxx, $00, $00
	.byte	$AE, "LDS ", xxxx, $00, $00
	.byte	$BE, "LDS ", xxxx, $00, $00
	.byte	$CE, "LDX ", immx, $F1, $A8
	.byte	$DE, "LDX ", dirx, $F1, $A8
	.byte	$EE, "LDX ", xxxx, $00, $00
	.byte	$FE, "LDX ", extx, $F1, $A8

	.byte	$8F, "I8F ", xxxx, $00, $00
	.byte	$9F, "STS ", xxxx, $00, $00
	.byte	$AF, "STS ", xxxx, $00, $00
	.byte	$BF, "STS ", xxxx, $00, $00
	.byte	$CF, "ICF ", stxi, $31, $CA
	.byte	$DF, "STX ", stxd, $ED, $DE
	.byte	$EF, "STX ", xxxx, $00, $00
	.byte	$FF, "STX ", stxe, $ED, $DE
opend
	.end


