; This program is a translation of the sample
; program contained in the instruction guide
; for the built-in assembler/editor of the
; Matra Alice.
;
; The program also works on a stock TRS-80 MC-10
;
;          Directives
;     Alice   TASM equivalent
;
;     =        .equ
;     '        .text
;     BLC      .block
;     DFO      .byte
;     DFD      .word
;     EXC      .end
;
; Note: ".end" should be placed at the end of
; the assembly program

	; Programme d'essai pour l'Assembleur.
	;
	; Ce programme permet d'emettre
	; des sons, impossibles a obtenir
	; en BASIC, pour animer des jeux video.
	;
	; Attention: ce programm boucle

	.org	$4800

init	ldx	#$0001
	stx	compt

debut	clra
	ldab	#$30

bruit	ldx	compt
	eora	#$80
	staa	$bfff	; adress qui fait du bruit

boucl	dex
	bne	boucl
	decb
	bne	bruit

chang			; changement de frequence
	ldx	compt
	ldab	#$5
	abx
	stx	compt
	cpx	#$200
	bgt	init
	bra	debut

	; donnees du programme

compt	.word	$0

	.end	init	; fin

