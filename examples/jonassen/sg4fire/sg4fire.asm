			.msfirst

;***********************************
; offscreen buffer size
;***********************************
buf_size	.equ $300
;***********************************
; screen address
;***********************************
fbuf_start	.equ $4000
screen		.equ $4000
;***********************************
;end address
;***********************************
fbuf_end	.equ fbuf_start+buf_size
;***********************************
; + 256 to get past irq vectors
; at $42xx
;***********************************
dbuf_start	.equ fbuf_start+buf_size+256
dbuf_end	.equ dbuf_start+buf_size


	.org $5000




;***********************************
; clear screen + buffer
;***********************************
	
	
	ldaa #$40
	staa $bfff


	; clear screen

	ldx #screen
	ldd #$8080
clslp	std ,x
	inx
	inx
	cpx #screen+512
	blo clslp
	

	; clear buffer

	ldx #dbuf_start
	ldd #0
clrlp	std ,x
	inx
	inx
	cpx #dbuf_end
	blo clrlp

;***********************************
; pseudo random routine to seed
; fire buffer
;***********************************
mloop	ldx #dbuf_end-63
	ldab #32
prng

rndx	ldaa #0
	inca
	staa rndx+1
rnda	eora #0
rndc	eora #0
	staa rnda+1
rndb	adda #0
	staa rndb+1
	lsra
	adda rndc+1
	eora rnda+1
	staa rndc+1

;******************************
; and for val between 0..31
; (32 byte palette)
;******************************


	anda  #$20
	staa ,x
	staa 32,x
	inx
	decb
	bne prng

nodraw  


;***********************************
; Update buffer and draw screen
; Each pixel is calculated from 
; pixels below
;
;  X
; ABC
;  D
;
; X = (A + B + C + D)/4
;***********************************


	ldx #dbuf_start+1	; buffer pointer
	stx yloop+1

	ldaa #buf_size/32-2	; number of lines to update
	staa count
	ldd #fbuf_start+1		; screen pointer+1
	std newx


yloop 
	ldx #dbuf_start+1	; buffer pointer


;	firem 1

	ldd  ,x		
;******************************
;never overflows, so use addd
;******************************
	addd 32,x
	addd 33,x
	addd 64,x
	lsra
	lsra
	lsrb
	lsrb
	std 1,x

	staa p1_1+2
	stab p2_1+2

p1_1	ldaa palette
p2_1	ldab palette
	stx oldx1+1

	ldx newx

	std 1,x
oldx1	ldx #0000  

;	firem 2

	ldd 2-1,x			
;******************************
	addd 2+32,x
	addd 2+33,x
	addd 2+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 2,x

	staa p1_2+2
	stab p2_2+2

p1_2	ldaa palette
p2_2	ldab palette
	stx oldx_2+1

	ldx newx

	std 2,x
oldx_2	ldx #0000    




;	firem 4

	ldd 4-1,x			
;******************************
	addd 4+32,x
	addd 4+33,x
	addd 4+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 4,x

	staa p1_4+2
	stab p2_4+2

p1_4	ldaa palette
p2_4	ldab palette
	stx oldx_4+1

	ldx newx

	std 4,x
oldx_4	ldx #0000    

;	firem 6

	ldd 6-1,x			
;******************************

	addd 6+32,x
	addd 6+33,x
	addd 6+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 6,x

	staa p1_6+2
	stab p2_6+2

p1_6	ldaa palette
p2_6	ldab palette
	stx oldx_6+1

	ldx newx

	std 6,x
oldx_6	ldx #0000    

;firem8

	ldd 8-1,x			
;******************************

	addd 8+32,x
	addd 8+33,x
	addd 8+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 8,x

	staa p1_8+2
	stab p2_8+2

p1_8	ldaa palette
p2_8	ldab palette
	stx oldx_8+1

	ldx newx

	std 8,x
oldx_8	ldx #0000    





;	firem 10
	ldd 10-1,x			
;******************************

	addd 10+32,x
	addd 10+33,x
	addd 10+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 10,x

	staa p1_10+2
	stab p2_10+2

p1_10	ldaa palette
p2_10	ldab palette
	stx oldx_10+1

	ldx newx

	std 10,x
oldx_10	ldx #0000    


;	firem 12


	ldd 12-1,x			
;******************************

	addd 12+32,x
	addd 12+33,x
	addd 12+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 12,x

	staa p1_12+2
	stab p2_12+2

p1_12	ldaa palette
p2_12	ldab palette
	stx oldx_12+1

	ldx newx

	std 12,x
oldx_12	ldx #0000    


;	firem 14
	ldd 14-1,x			
;******************************

	addd 14+32,x
	addd 14+33,x
	addd 14+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 14,x

	staa p1_14+2
	stab p2_14+2

p1_14	ldaa palette
p2_14	ldab palette
	stx oldx_14+1

	ldx newx

	std 14,x
oldx_14	ldx #0000    

;	firem 16

	ldd 16-1,x			
;******************************

	addd 16+32,x
	addd 16+33,x
	addd 16+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 16,x

	staa p1_16+2
	stab p2_16+2

p1_16	ldaa palette
p2_16	ldab palette
	stx oldx_16+1

	ldx newx

	std 16,x
oldx_16	ldx #0000    

;	firem 18
	ldd 18-1,x			
;******************************

	addd 18+32,x
	addd 18+33,x
	addd 18+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 18,x

	staa p1_18+2
	stab p2_18+2

p1_18	ldaa palette
p2_18	ldab palette
	stx oldx_18+1

	ldx newx

	std 18,x
oldx_18	ldx #0000    



;	firem 20
	ldd 20-1,x			
;******************************

	addd 20+32,x
	addd 20+33,x
	addd 20+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 20,x

	staa p1_20+2
	stab p2_20+2

p1_20	ldaa palette
p2_20	ldab palette
	stx oldx_20+1

	ldx newx

	std 20,x
oldx_20	ldx #0000    


;	firem 22
	ldd 22-1,x			
;******************************

	addd 22+32,x
	addd 22+33,x
	addd 22+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 22,x

	staa p1_22+2
	stab p2_22+2

p1_22	ldaa palette
p2_22	ldab palette
	stx oldx_22+1

	ldx newx

	std 22,x
oldx_22	ldx #0000    


;	firem 24
	ldd 24-1,x			
;******************************

	addd 24+32,x
	addd 24+33,x
	addd 24+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 24,x

	staa p1_24+2
	stab p2_24+2

p1_24	ldaa palette
p2_24	ldab palette
	stx oldx_24+1

	ldx newx

	std 24,x
oldx_24	ldx #0000    



;	firem 26
	ldd 26-1,x			
;******************************

	addd 26+32,x
	addd 26+33,x
	addd 26+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 26,x

	staa p1_26+2
	stab p2_26+2

p1_26	ldaa palette
p2_26	ldab palette
	stx oldx_26+1

	ldx newx

	std 26,x
oldx_26	ldx #0000    



;	firem 28

	ldd 28-1,x			
;******************************

	addd 28+32,x
	addd 28+33,x
	addd 28+64,x
	lsra
	lsra
	lsrb
	lsrb
	std 28,x

	staa p1_28+2
	stab p2_28+2

p1_28	ldaa palette
p2_28	ldab palette
	stx oldx_28+1

	ldx newx

	std 28,x
oldx_28	ldx #0000    


;***********************************
	ldab #32
	abx		; next line in buffer
	stx yloop+1
	ldx newx	; next line on screen
	abx
	stx newx
	dec count
	bne nxt
	jmp mloop
;***********************************

nxt	jmp yloop

	
;***********************************
;PALLETE SETUP
;***********************************

black		.equ $80
dk_orange	.equ $20
br_orange	.equ $60
yellow		.equ $9f
red		.equ $bf
white		.equ $cf
orange		.equ $ff

;***********************************
; PAGE ALIGNED 32 byte palette
;***********************************
	.ORG  (($+0FFH) & 0FF00H)


palette
	.fill 10,black
	.fill 1,dk_orange
	.fill 1,red
	.fill 1,orange
	.fill 1,br_orange
	.fill 1,yellow
	.fill 16,white

count	.byte	0
newx	.word	$0000

	.end
