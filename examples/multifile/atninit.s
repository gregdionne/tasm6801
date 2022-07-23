.MODULE AtnInit
;	initialize new arctanget
atninit
	ldx	ang_msb
	psha
	jsr	clear
	pula
	ldx	ang_msb
	stx	ang_lzb
	staa	,x
	ldx	trm_msb
	stx	trm_lzb
	jsr	newang
	ldd	angsq_r
	tba
	mul
	std	angsq_r
	ldd	#1
	std	coeff_r
	rts
