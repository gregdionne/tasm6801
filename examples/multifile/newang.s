.MODULE NewAng
;	compute new angle power 
;	angle /= angsqr_r
newang
	ldx	ang_lzb
_ang_lzb	tst	,x
	bne	_numn
	tst	1,x
	bne	_numn
	inx
	stx	ang_lzb
	bra	_ang_lzb
_numn	clra
	ldab	,x
	clr	,x
_byte	inx
	cpx	ang_lsb
	bls	_bit0
	rts
_bit0	lsl	,x	;6
	rolb		;2
	rola		;2
	bcc	_bat0	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit1	;3
_bat0	subd	angsq_r	;5
	bhs	_bit1	;3
	addd	angsq_r	;5
_bit1	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat1	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit2	;3
_bat1	subd	angsq_r	;5
	bhs	_bit2	;3
	addd	angsq_r	;5
_bit2	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat2	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit3	;3
_bat2	subd	angsq_r	;5
	bhs	_bit3	;3
	addd	angsq_r	;5
_bit3	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat3	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit4	;3
_bat3	subd	angsq_r	;5
	bhs	_bit4	;3
	addd	angsq_r	;5
_bit4	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat4	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit5	;3
_bat4	subd	angsq_r	;5
	bhs	_bit5	;3
	addd	angsq_r	;5
_bit5	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat5	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit6	;3
_bat5	subd	angsq_r	;5
	bhs	_bit6	;3
	addd	angsq_r	;5
_bit6	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat6	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit7	;3
_bat6	subd	angsq_r	;5
	bhs	_bit7	;3
	addd	angsq_r	;5
_bit7	rol	,x
	rolb		;2
	rola		;2
	bcc	_bat7	;3
	subd	angsq_r	;5
	clc		;2
	bra	_bit8	;3
_bat7	subd	angsq_r	;5
	bhs	_bit8	;3
	addd	angsq_r	;5
_bit8	rol	,x	;6
	com	,x	;6
	jmp	_byte
