;********************************************************************************************************
; GHOST RUSH PORT TO MC10 BY SIMON JONASSEN (INVIS)
;
; ORIGINAL 6809 CODE/IDEA/GFX BY PAUL SHOEMAKER
;********************************************************************************************************
;		PROCESSOR	6803
start           ORG	$4d00
		
		
		sei


                ldd     #$0000
                std     Hi_Score
                
                ldx     #Screen+3072
                stx     Pill_Location
		
Restart         nop    
InitRandom      ldd     Random_Word                 ;is the 16 bit random word zero?
                bne     go                          ;No, then exit the inti code
                inc     Random_MSB                  ;Yes, than change state to something else that zero

go              ldd     #$0000
                std     Byte
                jsr     Clear_Screen

;********************************************************************************************************
;Set videomode (128*96)
;********************************************************************************************************
		ldaa	#$24
		staa	$bfff
;********************************************************************************************************
;Display titlescreen
;********************************************************************************************************
                jsr     Title_Screen
;********************************************************************************************************
;Clear screen
;********************************************************************************************************
                ldd     #$0000
                std     Byte
                std     Score
                jsr     Clear_Screen

;********************************************************************************************************
;Display wheel and highscore/player1 labels
;********************************************************************************************************
                jsr     Draw_Wheel
		ldd     #High_Score
		std	tileloc+1
                ldx     #$4120	
                ldd     #$0505
                std     Tile_Y
                jsr     Put_Tile 
                ldx     #$4136		
                ldd     #Player_One
		std	tileloc+1
                ldd     #$0505
                std     Tile_Y
                jsr     Put_Tile 

;********************************************************************************************************
;Display score/hiscore
;********************************************************************************************************
                ldd     #Screen+24
		std	scrpt+1
                ldx     #Score
                jsr     Display_Score
                
                ldd     #Screen
		std	scrpt+1
                ldx     #Hi_Score
                jsr     Display_Score
;********************************************************************************************************
;Clean out vars
;********************************************************************************************************
                clr     Pill_Count
                clr     Direction_Flag
                clr     Button_Depressed
                clr     Ghost_Whl_Pos
                clr     PacMan_Counter
                clr     Slow_PacMan
                clr     PacMan_Flag
                clr     Which_Pac_Flag
                clr     Both_Flag
                clr     Pill_Flag
                com     Pill_Flag
                clr     Ghost_Whl_Pos 

;********************************************************************************************************
;Some setup code for various game aspects
;********************************************************************************************************
                jsr     Calc_Pac_Loc
                jsr     Calc_Ghost_Loc
                jsr     Get_Gh_Buffer
                jsr     Initiate_Spike
                jsr     Get_Sp_Buffer
                com     PacMan_Flag
                jsr     Get_Pac_Buffer
                clr     PacMan_Flag  		;funk for test (rem out)
                jsr     Player_Ready

H1              jsr     Input_Check
;                jsr     Wait_Vsync
		ldx	#$a00			;skanky loop
wlp		dex				;instead of vsync
		bne	wlp
                jsr     Put_Gh_Buffer
                jsr     Put_Sp_Buffer
                jsr     Put_Pac_Buffer
                jsr     Move_Ghost
                jsr     Calc_Ghost_Loc
                jsr     Calc_Pill_Loc
                jsr     Move_Spike
                jsr     Move_Pacman
                jsr     Get_Gh_Buffer
                jsr     Get_Sp_Buffer
                jsr     Get_Pac_Buffer
                jsr     Put_Pill
                jsr     Put_Ghost
                jsr     Put_Spikes
                jsr     Put_PacMan
                jsr     Pill_Coll_Chk
                jsr     Spike_Coll_Chk
                jsr     Pac_Coll_Chk   

                bra     H1

;********************************************************************************************************
; Put the darn pill on the screen already would you.....
;********************************************************************************************************
Put_Pill        tst     Pill_Flag
                beq     PP2
                clr     Pill_Flag
                jsr     Put_Gh_Buffer
                jsr     Put_Pac_Buffer
                jsr     Put_Sp_Buffer
                ldx     Prev_Pill_Loc
                jsr     Put_Pill_Buffer
                ldx     Pill_Location
                jsr     Get_Pill_Buffer              
                ldx     Pill_Pointer
                jsr     ,x              
                jsr     Get_Gh_Buffer
                jsr     Get_Pac_Buffer
                jsr     Get_Sp_Buffer 
PP2             rts   

;********************************************************************************************************
; Move da pacman
;********************************************************************************************************

Move_Pacman     tst     PacMan_Flag
                beq     MP6
                tst     Which_Pac_Flag
                bne     MP8
                com     Slow_PacMan
                tst     Slow_PacMan
                beq     MP6
                ldx     PacMan_Location
                inc     PacMan_Counter
                ldaa    PacMan_Counter
                anda    #%00000011
                staa    PacMan_Counter
                cmpa    #0
                beq     MP5
                cmpa    #2
                beq     MP5
                bra     MP6
MP5             inx
                cpx     PacMan_End
                bhi     MP7
                stx     PacMan_Location
MP6             rts                
MP7             
                tst     Both_Flag
                beq     n7
                com     Which_Pac_Flag
n7              jsr     Calc_Pac_Loc
                rts

MP8             com     Slow_PacMan
                tst     Slow_PacMan
                beq     MP10
                ldx     MsPac_Location
                inc     PacMan_Counter
                ldaa    PacMan_Counter
                anda    #%00000011
                staa    PacMan_Counter
                cmpa    #0
                beq     MP9
                cmpa    #2
                beq     MP9
                bra     MP10
MP9             dex
                cpx     MsPac_End
                beq     MP11
                stx     MsPac_Location
MP10            rts                
MP11            tst     Both_Flag
                beq     m1
                com     Which_Pac_Flag
m1              jsr     Calc_Pac_Loc
                rts

;********************************************************************************************************
; Put da pacman
;********************************************************************************************************
Put_PacMan      tst     PacMan_Flag
                beq     PP1
                tst     Which_Pac_Flag
                bne     PP5
		clra
		ldab	PacMan_Counter
		lsld
		addd	#PacMan_Spr_Tbl
		pshb
		psha
		pulx
		ldx	,x
                jsr     ,x
PP1             rts

PP5		clra
		ldab	PacMan_Counter
		lsld
                addd    #MsPac_Spr_Tbl
		pshb
		psha
		pulx
		ldx	,x
                jsr     ,x
                rts

;********************************************************************************************************
; Spike collision check
;********************************************************************************************************
Spike_Coll_Chk  ldd     Spike_Location
                std     Byte
                ldd     Ghost_Location
                subd    Byte
		pshb
		psha
		pulx
                cpx     #196
                bhs     SC1
s32             subb    #32
                bpl     s32
                addb    #32
                cmpb    #4
                blo     Player_Died
                cmpb    #31
                beq     Player_Died
SC1             rts


;********************************************************************************************************
; did we hit pacman (or the other way around)
;********************************************************************************************************
Pac_Coll_Chk    tst     Which_Pac_Flag
                bne     PCC2

                ldd     PacMan_Location
                std     Byte
                ldd     Ghost_Location
                subd    Byte
		pshb
		psha
		pulx
                cpx     #196
                bhs     PCC1
s32_2           subb    #32
                bpl     s32_2
                addb    #32
                cmpb    #3
                blo     Player_Died   
PCC1            rts

PCC2            ldd     MsPac_Location
                std     Byte
                ldd     Ghost_Location
                subd    Byte
		pshb
		psha
		pulx
                cpx     #196
                bhs     PCC1
s32_3           subb    #32
                bpl     s32_3
                addb    #32
                cmpb    #3
                blo     Player_Died   
                rts


;********************************************************************************************************
; do the dead man
;********************************************************************************************************
Player_Died	ldab    Ghost_Whl_Pos
                ldx     #Whl_Spr_Table
		abx
		clra	
		lslb
		rola
		addd	#Whl_Loc_Table
		pshb
		psha
		pulx
		ldd	,x
		std	Ghost_Location

                ldab    Ghost_Whl_Pos
                ldx     #Whl_Spr_Table
		abx
		ldaa	,x
                ldab    #2
                mul
                addd    #Dead_Spr_Tbl
		pshb
		psha
		pulx
		ldx	,x
		jsr	,x
                jsr     Put_Spikes
                jsr     Put_PacMan



		ldd     #High_Score
		std	tileloc+1
                ldx     #$4120	
                ldd     #$0505
                std     Tile_Y
                jsr     Put_Tile 

                ldd     #Player_One
		std	tileloc+1                
		ldx     #$4136		
                ldd     #$0505
                std     Tile_Y
                jsr     Put_Tile 

                ldd     #Screen+24
		std	scrpt+1
                ldx     #Score
                jsr     Display_Score


                ldd     #Game_Over
		std	tileloc+1
                ldx     #$41e7
                ldd     #$0909
                std     Tile_Y
                jsr     Put_Tile
                
                ldd     Score
                std     Byte
                ldd     Hi_Score
                subd    Byte
                bpl     PD1
                ldd     Score
                std     Hi_Score

                ldd     #Screen
		std	scrpt+1
                ldx     #Hi_Score
                jsr     Display_Score

PD1             ldab    #20
                stab    Counter_X
wait2           jsr     Wait_Vsync
                dec     Counter_X
                bne     wait2


;********************************************************************************************************
; CHECK FOR SPACEBAR
;********************************************************************************************************
nnn		jsr	Input_Check
		tst	Button_Depressed
		beq	nnn
wlpk		jsr	Input_Check
		tst	Button_Depressed
		bne	wlpk
		jmp	Restart	
	


;---------------------------------------------------------
; Compiled Sprite of Pac Man frame 1
Put_PacMan_1    ldx     PacMan_Location

                ldd     1,x
                anda    #%11000000
                oraa    #$2a
                andb    #%00001111
                orab    #$a0
                std     1,x
                
                ldaa    32,x
                anda    #%11111100
                oraa    #$02
                ldab    #$95
                std     32,x
                ldaa    #$5a
                staa    34,x
                
                ldaa    64,x
                anda    #%11110000
                oraa    #$09
                ldab    #$55
                std     64,x
                ldaa    #$55
                ldab    67,x
                andb    #%00111111
                orab    #$80
                std     66,x

                ldaa    96,x
                anda    #%11000000
                oraa    #$25
                ldab    #$55
                std     96,x
                ldaa    #$55
                ldab    99,x
                andb    #%00001111
                orab    #$60
                std     98,x

                ldaa    128,x
                anda    #%11000000
                oraa    #$25
                ldab    #$55
                std     128,x
                ldaa    #$55
                ldab    131,x
                andb    #%00001111
                orab    #$60
                std     130,x                
 
                ldd     #$9555
                std     160,x
                std     192,x            
                ldaa    #$55
                ldab    163,x
                andb    #%00000011
                orab    #$58
                std     162,x

                ldaa    #$55
                ldab    195,x
                andb    #%00000011
                orab    #$58
                std     194,x                

                ldd     #$955a
                std     224,x
                ldaa    #$aa
                ldab    227,x
                andb    #%00000011
                orab    #$a8
                std     226,x 
                
                ldab    #$80
                abx
                abx
                
                ldd     #$9555
                std     256-256,x
                std     288-256,x 
                ldaa    #$55
                ldab    259-256,x
                andb    #%00000011
                orab    #$58
                std     258-256,x
                
                ldaa    #$55
                ldab    291-256,x
                andb    #%00000011
                orab    #$58
                std     290-256,x  
 
                ldaa    320-256,x
                anda    #%11000000
                oraa    #$25
                ldab    #$55
                std     320-256,x
                ldaa    #$55
                ldab    323-256,x
                andb    #%00001111
                orab    #$60
                std     322-256,x

                ldaa    352-256,x
                anda    #%11000000
                oraa    #$25
                ldab    #$55
                std     352-256,x
                ldaa    #$55
                ldab    355-256,x
                andb    #%00001111
                orab    #$60
                std     354-256,x   
 
                ldaa    384-256,x
                anda    #%11110000
                oraa    #$09
                ldab    #$55
                std     384-256,x
                ldaa    #$55
                ldab    387-256,x
                andb    #%00111111
                orab    #$80
                std     386-256,x 

                ldaa    416-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$95
                std     416-256,x
                ldaa    #$5a
                staa    418-256,x 

                ldd     449-256,x
                anda    #%11000000
                oraa    #$2a
                andb    #%00001111
                orab    #$a0
                std     449-256,x
 
                rts

;---------------------------------------------------------
; Compiled Sprite of Pac Man frame 2
Put_PacMan_2    ldx     PacMan_Location
                ldaa    1,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     1,x
                
                ldaa    33,x
                anda    #%11000000
                oraa    #$29
                ldab    #$55
                std     33,x
                ldaa    35,x
                anda    #%00001111
                oraa    #$a0
                staa    35,x

                ldd     #$9555
                std     65,x
                ldaa    67,x
                anda    #%00000011
                oraa    #$58
                staa    67,x
                
                ldaa    96,x
                anda    #%11111100
                oraa    #$02
                ldab    #$55
                std     96,x
                ldd     #$5556
                std     98,x
                std     130,x

                ldaa    128,x
                anda    #%11111100
                oraa    #$02
                ldab    #$55
                std     128,x
                
                ldaa    160,x
                anda    #%11110000
                oraa    #$09
                ldab    #$55
                std     160,x
                ldd     #$556a
                std     162,x

                ldaa    192,x
                anda    #%11110000
                oraa    #$09
                ldab    #$55
                std     192,x
                ldaa    #$5a
                ldab    195,x
                andb    #%00111111
                orab    #$80
                std     194,x

                ldaa    224,x
                anda    #%11110000
                oraa    #$09
                ldab    #$56
                std     224,x
                ldaa    226,x
                anda    #%00001111
                oraa    #$a0
                staa    226,x
                
                ldab    #$80
                abx
                abx

                ldaa    256-256,x
                anda    #%11110000
                oraa    #$09
                ldab    #$55
                std     256-256,x
                ldaa    #$5a
                ldab    259-256,x
                andb    #%00111111
                orab    #$80
                std     258-256,x

                ldaa    288-256,x
                anda    #%11110000
                oraa    #$09
                ldab    #$55
                std     288-256,x
                ldd     #$556a
                std     290-256,x                

                ldaa    320-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$55
                std     320-256,x
                ldd     #$5556
                std     322-256,x
                std     354-256,x

                ldaa    352-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$55
                std     352-256,x

                ldd     #$9555
                std     385-256,x
                ldaa    387-256,x
                anda    #%00000011
                oraa    #$58
                staa    387-256,x

                ldaa    417-256,x
                anda    #%11000000
                oraa    #$29
                ldab    #$55
                std     417-256,x
                ldaa    419-256,x
                anda    #%00001111
                oraa    #$a0
                staa    419-256,x                

                ldaa    449-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     449-256,x                
                rts
;---------------------------------------------------------
; Compiled Sprite of Pac Man frame 3
Put_PacMan_3    ldx     PacMan_Location
                ldd     1,x
                anda    #%11000000
                oraa    #$2a
                andb    #%00001111
                orab    #$a0
                std     1,x
                
                ldaa    32,x
                anda    #%11111100
                oraa    #$02
                ldab    #$95
                std     32,x
                ldaa    34,x
                anda    #%00000011
                oraa    #$58
                staa    34,x
                
                ldaa    64,x
                anda    #%11110000
                oraa    #$09
                ldab    #$55
                std     64,x
                ldaa    66,x
                anda    #%00000011
                oraa    #$58
                staa    66,x

                ldaa    96,x
                anda    #%11000000
                oraa    #$25
                ldab    #$55
                std     96,x
                ldaa    98,x
                anda    #%00001111
                oraa    #$60
                staa    98,x

                ldaa    128,x
                anda    #%11000000
                oraa    #$25
                ldab    #$55
                std     128,x
                ldaa    130,x
                anda    #%00111111
                oraa    #$80
                staa    130,x                
 
                ldd     #$9556
                std     160,x

                ldaa    #$95
                ldab    193,x
                andb    #%00000011
                orab    #$58
                std     192,x                

                ldaa    #$95
                ldab    225,x
                andb    #%00001111
                orab    #$60
                std     224,x 
                
                ldab    #$80
                abx
                abx

                ldaa    #$95
                ldab    257-256,x
                andb    #%00000011
                orab    #$58
                std     256-256,x
                
                ldd     #$9556
                std     288-256,x  
 
                ldaa    320-256,x
                anda    #%11000000
                oraa    #$25
                ldab    #$55
                std     320-256,x
                ldaa    322-256,x
                anda    #%00111111
                oraa    #$80
                staa    322-256,x 

                ldaa    352-256,x
                anda    #%11000000
                oraa    #$25
                ldab    #$55
                std     352-256,x
                ldaa    354-256,x
                anda    #%00001111
                oraa    #$60
                staa    354-256,x  
 
                ldaa    384-256,x
                anda    #%11110000
                oraa    #$09
                ldab    #$55
                std     384-256,x
                ldaa    386-256,x
                anda    #%00000011
                oraa    #$58
                staa    386-256,x

                ldaa    416-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$95
                std     416-256,x
                ldaa    418-256,x
                anda    #%00000011
                oraa    #$58
                staa    418-256,x 

                ldd     449-256,x
                anda    #%11000000
                oraa    #$2a
                andb    #%00001111
                orab    #$a0
                std     449-256,x
 
                rts


;---------------------------------------------------------                
Put_MsPacMan_1  ldx     MsPac_Location
                
                ldaa    3,x
                anda    #%11110000
                oraa    #$0a
                staa    3,x
                
                ldaa    34,x
                anda    #%11000000
                oraa    #$2a
                ldab    #$af
                std     34,x
                ldaa    36,x
                anda    #%00111111
                oraa    #$80
                staa    36,x
                
                ldaa    65,x
                anda    #%11111100
                oraa    #$02
                ldab    #$95
                std     65,x
                ldab    68,x
                ldaa    #$7f
                andb    #%00111111
                orab    #$80
                std     67,x

                ldaa    97,x
                anda    #%11110000
                oraa    #$09
                ldab    #$55
                std     97,x
                ldaa    #$7e
                ldab    100,x
                andb    #%00000011
                orab    #$e8
                std     99,x
                
                ldaa    129,x
                anda    #%11000000
                oraa    #$25
                ldab    #$55
                std     129,x
                ldd     #$57be
                std     131,x
 
                ldaa    161,x
                anda    #%11000000
                oraa    #$25 
                ldab    #$55
                std     161,x  
                ldd     #$55fe
                std     163,x

                ldd     #$9556
                std     193,x
                ldaa    #$a9
                ldab    196,x
                andb    #%00000011
                orab    #$f8
                std     195,x
                
                ldaa    224,x
                anda    #%11111100
                oraa    #$02
                ldab    #$d5
                std     224,x
                ldd     #$5555
                std     226,x
                ldaa    228,x
                anda    #%00000011
                oraa    #$58
                staa    228,x

                ldab    #$80
                abx
                abx
                
                ldd     #$5555
                std     258-256,x
                std     290-256,x
                std     354-256,x
                std     386-256,x
                std     418-256,x

                ldaa    256-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$f5
                std     256-256,x
                ldaa    260-256,x
                anda    #%00000011
                oraa    #$58
                staa    260-256,x

                ldaa    288-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$d5
                std     288-256,x                
                ldaa    292-256,x
                anda    #%00000011
                oraa    #$58
                staa    292-256,x

                ldd     #$9555
                std     321-256,x
                ldaa    #$59
                ldab    324-256,x
                andb    #%00000011
                orab    #$58
                std     323-256,x                
                
                ldaa    353-256,x
                anda    #%11000000
                oraa    #$25
                staa    353-256,x
                ldaa    356-256,x
                anda    #%00001111
                oraa    #$60
                staa    356-256,x                

                ldaa    385-256,x
                anda    #%11000000
                oraa    #$25
                staa    385-256,x
                ldaa    388-256,x
                anda    #%00001111
                oraa    #$60
                staa    388-256,x                 

                ldaa    417-256,x
                anda    #%11110000
                oraa    #$09
                staa    417-256,x
                ldaa    420-256,x
                anda    #%00111111
                oraa    #$80
                staa    420-256,x                
                
                ldaa    449-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$95
                std     449-256,x
                ldaa    #$5a
                staa    451-256,x
                
                ldd     482-256,x
                anda    #%11000000
                oraa    #$2a
                andb    #%00001111
                orab    #$a0
                std     482-256,x
         
                rts
;---------------------------------------------------------                
Put_MsPacMan_2  ldx     MsPac_Location

                ldaa    3,x
                anda    #%00001111
                oraa    #$a0
                staa    3,x
                
                ldaa    33,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     33,x
                ldaa    35,x
                anda    #%00000011
                oraa    #$f8
                staa    35,x
                
                ldaa    65,x
                anda    #%11000000
                oraa    #$29
                ldab    #$57
                std     65,x
                ldaa    67,x
                anda    #%00000011
                oraa    #$f8
                staa    67,x
                
                ldd     #$9557
                std     97,x
                ldaa    #$ee
                ldab    100,x
                andb    #%00111111
                orab    #$80
                std     99,x
                
                ldaa    128,x
                anda    #%11111100
                oraa    #$02
                ldab    #$55
                std     128,x
                ldd     #$557b
                std     130,x
                ldaa    132,x
                anda    #%00001111
                oraa    #$e0
                staa    132,x
 
                ldaa    160,x
                anda    #%11111100
                oraa    #$02
                ldab    #$f5
                std     160,x
                ldd     #$695f
                std     162,x               
                ldaa    164,x
                anda    #%00001111
                oraa    #$e0
                staa    164,x               
                
                ldaa    192,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     192,x                
                ldd     #$5a5f
                std     194,x                
                ldaa    196,x
                anda    #%00111111
                oraa    #$80
                staa    196,x
                
                ldd     #$a555
                std     226,x
                ldaa    228,x
                anda    #%00111111
                oraa    #$80
                staa    228,x                
              
                ldab    #$80
                abx
                abx             
              
                ldaa    258-256,x
                anda    #%11110000
                oraa    #$0a
                ldab    #$55
                std     258-256,x
                ldaa    260-256,x
                anda    #%00111111
                oraa    #$80
                staa    260-256,x                  

                ldd     #$a555
                std     290-256,x
                ldaa    292-256,x
                anda    #%00111111
                oraa    #$80
                staa    292-256,x 

                ldaa    320-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     320-256,x                
                ldd     #$5595
                std     322-256,x                
                ldaa    324-256,x
                anda    #%00111111
                oraa    #$80
                staa    324-256,x

                ldaa    352-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$f5
                std     352-256,x
                ldd     #$5556
                std     354-256,x               

                ldaa    384-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$55
                std     384-256,x
                ldd     #$5556
                std     386-256,x

                ldd     #$9555
                std     417-256,x
                ldaa    419-256,x
                anda    #%00000011
                oraa    #$58
                staa    419-256,x

                ldaa    449-256,x
                anda    #%11000000
                oraa    #$29
                ldab    #$55
                std     449-256,x
                ldaa    451-256,x
                anda    #%00001111
                oraa    #$a0
                staa    451-256,x
                
                ldaa    481-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     481-256,x

                rts                
;---------------------------------------------------------                
Put_MsPacMan_3  ldx     MsPac_Location

                ldaa    3,x
                anda    #%11110000
                oraa    #$0a
                staa    3,x
                
                ldd     #$aaaf
                std     34,x
                ldaa    36,x
                anda    #%00111111
                oraa    #$80
                staa    36,x
                
                ldaa    65,x
                anda    #%11111100
                oraa    #$02
                ldab    #$d5
                std     65,x
                ldaa    #$7f
                ldab    68,x
                andb    #%00111111
                orab    #$80
                std     67,x

                ldd     #$b57e
                std     98,x
                ldaa    100,x
                anda    #%00000011
                oraa    #$e8
                staa    100,x
                
                ldaa    130,x
                anda    #%11000000
                oraa    #$25
                ldab    #$97
                std     130,x
                ldaa    #$be
                staa    132,x
                
                ldaa    162,x
                anda    #%11110000
                oraa    #$09
                ldab    #$a5
                std     162,x
                ldaa    #$fe
                staa    164,x
                
                ldaa    194,x
                anda    #%11111100
                oraa    #$02
                ldab    #$69
                std     194,x
                ldaa    196,x
                anda    #%00000011
                oraa    #$f8
                staa    196,x
                
                ldaa    #$95
                ldab    228,x
                andb    #%00000011
                orab    #$58
                std     227,x
                
                ldab    #$80
                abx
                abx
                
                ldd     259-256,x
                anda    #%11000000
                andb    #%00000011
                oraa    #$25
                orab    #$58
                std     259-256,x

                ldaa    #$95
                ldab    292-256,x
                andb    #%00000011
                orab    #$58
                std     291-256,x                

                ldaa    322-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$59
                std     322-256,x
                ldaa    324-256,x
                anda    #%00000011
                oraa    #$58
                staa    324-256,x                
                
                ldaa    354-256,x
                anda    #%11110000
                oraa    #$09
                ldab    #$55
                std     354-256,x
                ldaa    356-256,x
                anda    #%00001111
                oraa    #$60
                staa    356-256,x

                ldaa    386-256,x
                anda    #%11000000
                oraa    #$25
                ldab    #$55
                std     386-256,x
                ldaa    388-256,x
                anda    #%00001111
                oraa    #$60
                staa    388-256,x              
                
                ldd     #$b555
                std     418-256,x
                ldaa    420-256,x
                anda    #%00111111
                oraa    #$80
                staa    420-256,x

                ldaa    449-256,x
                anda    #%11111100
                oraa    #$02
                ldab    #$d5
                std     449-256,x
                ldaa    #$5a
                staa    451-256,x

                ldaa    #$aa
                ldab    483-256,x
                andb    #%00001111
                orab    #$a0
                std     482-256,x

                rts                    
;********************************************************************************************************
; Compiled sprite of player dead ghost with 0 pixel offset
;********************************************************************************************************

Put_Dead_0      ldx     Ghost_Location

                ldaa   ,x
                anda    #%11110000
                oraa    #$0a
                ldab    1,x
                andb    #%00000011
                orab    #$a8
                std    ,x

                ldaa    32,x
                anda    #%11000000
                oraa    #$2a
                ldab    #$aa
                std     32,x

                ldd     #$aaaa
                std     64,x
                ldaa    66,x
                anda    #%00111111
                oraa    #$80
                staa    66,x
                
                ldd     #$a596
                std     96,x
                ldaa    98,x
                anda    #%00111111
                oraa    #$80
                staa    98,x
                
                ldd     #$aaaa
                std     128,x
                ldaa    130,x
                anda    #%00111111
                oraa    #$80             
                staa    130,x

                ldd     #$a666
                std     160,x
                ldaa    162,x
                anda    #%00111111
                oraa    #$80
                staa    162,x                
                
                ldd     #$9999
                std     192,x
                ldaa    194,x
                anda    #%00111111
                oraa    #$80
                staa    194,x

                ldd     #$aaaa
                std     224,x
                ldaa    226,x
                anda    #%00111111
                oraa    #$80
                staa    226,x

		ldab	#$80
		abx
		abx

                ldaa    ,x
                anda    #%11000011
                oraa    #$28
                ldab    1,x
                andb    #%00001100
                orab    #$a2
                std     ,x
                
                rts
;********************************************************************************************************
; Compiled sprite of player dead ghost with 1 pixel offset
;********************************************************************************************************
Put_Dead_1     ldx     Ghost_Location

                ldaa   ,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std    ,x

                ldaa    32,x
                anda    #%11110000
                oraa    #$0a
                ldab    #$aa
                std     32,x
                ldaa    34,x
                anda    #%00111111
                oraa    #$80
                staa    34,x

                ldaa    64,x
                anda    #%11000000
                oraa    #$2a
                ldab    #$aa
                std     64,x
                ldaa    66,x
                anda    #%00001111
                oraa    #$a0
                staa    66,x
                
                ldaa    96,x
                anda    #%11000000
                oraa    #$29
                ldab    #$65
                std     96,x
                ldaa    98,x
                anda    #%00001111
                oraa    #$a0
                staa    98,x

                ldaa    128,x
                anda    #%11000000
                oraa    #$2a
                ldab    #$aa
                std     128,x
                ldaa    130,x
                anda    #%00001111
                oraa    #$a0
                staa    130,x                

                ldaa    160,x
                anda    #%11000000
                oraa    #$29
                ldab    #$99
                std     160,x
                ldaa    162,x
                anda    #%00001111
                oraa    #$a0
                staa    162,x 

                ldaa    192,x
                anda    #%11000000
                oraa    #$26
                ldab    #$66
                std     192,x
                ldaa    194,x
                anda    #%00001111
                oraa    #$60
                staa    194,x 

                ldaa    224,x
                anda    #%11000000
                oraa    #$2a
                ldab    #$aa
                std     224,x
                ldaa    226,x
                anda    #%00001111
                oraa    #$a0
                staa    226,x 

		ldab	#$80
		abx
		abx

                ldaa    ,x
                anda    #%11110000
                oraa    #$0a
                ldab    1,x
                andb    #%11000011
                orab    #$28
                std     ,x
                ldaa    2,x
                anda    #%00111111
                oraa    #$80
                staa    2,x 
                
                rts                
;********************************************************************************************************
; Compiled sprite of player dead ghost with 2 pixel offset
;********************************************************************************************************
Put_Dead_2      ldx     Ghost_Location

                ldaa    #$aa
                ldab    2,x
                andb    #%00111111
                orab    #$80
                std     1,x
                
                ldaa    32,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     32,x
                ldaa    34,x
                anda    #%00001111
                oraa    #$a0
                staa    34,x
                
                ldaa    64,x
                anda    #%11110000
                oraa    #$0a
                ldab    #$aa
                std     64,x
                ldaa    66,x
                anda    #%00000011
                oraa    #$a8
                staa    66,x
                
                ldaa    96,x
                anda    #%11110000
                oraa    #$0a
                ldab    #$59
                std     96,x
                ldaa    98,x
                anda    #%00000011
                oraa    #$68
                staa    98,x

                ldaa    128,x
                anda    #%11110000
                oraa    #$0a
                ldab    #$aa
                std     128,x
                ldaa    130,x
                anda    #%00000011
                oraa    #$a8
                staa    130,x                

                ldaa    160,x
                anda    #%11110000
                oraa    #$0a
                ldab    #$66
                std     160,x
                ldaa    162,x
                anda    #%00000011
                oraa    #$68
                staa    162,x                

                ldaa    192,x
                anda    #%11110000
                oraa    #$09
                ldab    #$99
                std     192,x
                ldaa    194,x
                anda    #%00000011
                oraa    #$98
                staa    194,x

                ldaa    224,x
                anda    #%11110000
                oraa    #$0a
                ldab    #$aa
                std     224,x
                ldaa    226,x
                anda    #%00000011
                oraa    #$a8
                staa    226,x

		ldab	#$80
		abx
		abx
		
                ldaa    ,x
                anda    #%11111100
                oraa    #$02
                ldab    1,x
                andb    #%00110000
                orab    #$8a
                std     ,x
                ldaa    2,x
                anda    #%11001111
                oraa    #$20
                staa    2,x

                rts                
;********************************************************************************************************
; Compiled sprite of player dead ghost with 3 pixel offset
;********************************************************************************************************
Put_Dead_3      ldx     Ghost_Location

                ldaa    1,x
                anda    #%11000000
                oraa    #$2a
                ldab    2,x
                andb    #%00001111
                orab    #$a0
                std     1,x
                
                ldaa    #$aa
                ldab    34,x
                andb    #%00000011
                orab    #$a8
                std     33,x
                
                ldaa    64,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     64,x
                ldaa    #$aa
                staa    66,x

                ldaa    96,x
                anda    #%11111100
                oraa    #$02
                ldab    #$96
                std     96,x
                ldaa    #$5a
                staa    98,x                

                ldaa    128,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     128,x
                ldaa    #$aa
                staa    130,x                 

                ldaa    160,x
                anda    #%11111100
                oraa    #$02
                ldab    #$99
                std     160,x
                ldaa    #$9a
                staa    162,x                 

                ldaa    192,x
                anda    #%11111100
                oraa    #$02
                ldab    #$66
                std     192,x
                ldaa    #$66
                staa    194,x

                ldaa    224,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     224,x
                ldaa    #$aa
                staa    226,x                
		
		ldab	#$80
		abx
		abx
                
                ldaa    1,x
                anda    #%00001100
                oraa    #$a2
                ldab    2,x
                andb    #%00110011
                orab    #$88
                std     1,x

                rts 



;********************************************************************************************************
; Pill collision check
;********************************************************************************************************
Pill_Coll_Chk   ldd     Pill_Location
                std     Byte
                ldd     Ghost_Location
                addd    #65
                subd    Byte
		pshb
		psha
		pulx
		cpx	#194
                bhs     PC1
sub32           subb    #32
                bpl     sub32
                addb    #32
                cmpb    #1
		bhi	PC1
		jmp	Add_Ten
PC1             rts


;********************************************************************************************************
; Add 10 to score
;********************************************************************************************************
 
Add_Ten         inc     Pill_Count
                jsr     Sound
                jsr     Check_Score
                clc
                ldx     #Score
                ldaa    #$10
                adca    1,x
                daa
                staa    1,x
                ldaa    #$00
                adca    0,x
                daa
                staa    0,x
		ldd	#Screen+24
		std	scrpt+1
		ldx	#Score
                jsr     Display_Score
                com     Pill_Flag
                rts

;********************************************************************************************************
; Check score and show fruits at certain scores
;********************************************************************************************************
Check_Score     ldaa    Pill_Count
                cmpa    #15  		;15
                bne     cs35
                jsr     Put_Sp_Buffer
                jsr     Put_Pac_Buffer 
                ldx     #$462e		
                ldd     #$1102
                std     Tile_Y               
                ldd     #Cherry
		std	tileloc+1
                jsr     Put_Tile
                jsr     Get_Sp_Buffer
                jsr     Get_Pac_Buffer                 
                jmp     CS1
                
cs35            cmpa    #35      ;35
                bne     cs75
                com     PacMan_Flag
                jsr     Put_Sp_Buffer
                jsr     Put_Pac_Buffer                
                ldx     #$462e		
                ldd     #$1102
                std     Tile_Y
                ldd     #Strawberry
		std	tileloc+1
                jsr     Put_Tile
                jsr     Get_Sp_Buffer
                jsr     Get_Pac_Buffer                
                jmp     CS1                
                
cs75            cmpa    #75     ;75
                bne     cs150
                com     Both_Flag
                jsr     Put_Sp_Buffer
                jsr     Put_Pac_Buffer                 
                ldx     #$462e		
                ldd     #$1102
                std     Tile_Y
                ldd     #Orange
		std	tileloc+1
                jsr     Put_Tile
                jsr     Get_Sp_Buffer
                jsr     Get_Pac_Buffer                
                bra     CS1                

cs150           cmpa    #150
                bne     cs200
                jsr     Put_Sp_Buffer
                jsr     Put_Pac_Buffer                 
                ldx     #$462e		
                ldd     #$1102
                std     Tile_Y
                ldd     #Apple
		std	tileloc+1
                jsr     Put_Tile
                jsr     Get_Sp_Buffer
                jsr     Get_Pac_Buffer                
                bra     CS1

cs200           cmpa    #200
                bne     cs250
                jsr     Put_Sp_Buffer
                jsr     Put_Pac_Buffer                 
                ldx     #$462e		
                ldd     #$1102
                std     Tile_Y
                ldd     #Fig
		std	tileloc+1
                jsr     Put_Tile
                jsr     Get_Sp_Buffer
                jsr     Get_Pac_Buffer                
                bra     CS1

cs250           cmpa    #250
                bne     CS2
                jsr     Put_Sp_Buffer
                jsr     Put_Pac_Buffer                 
                ldx     #$462e		
                ldd     #$1102
                std     Tile_Y
                ldd     #Key
		std	tileloc+1
                jsr     Put_Tile
                jsr     Get_Sp_Buffer
                jsr     Get_Pac_Buffer                
   
CS1             jsr     Put_PacMan
                jsr     Put_Spikes
;                jsr     Wait_Vsync_1
                ldx     #SONG2
		ldd	#ENDSONG2
                jsr     PLAY		


CS2             rts                

;********************************************************************************************************
; Play Bloop sound
;********************************************************************************************************
Sound           ldaa    #6
                ldab    #15
                stab    Byte
                
Sound0          psha
                ldx     #Sound_Table
Sound1          ldaa    ,x
		inx
                ldab    Byte
Sound2          ldaa	soundbyte
		eora	#$80
		staa	soundbyte
		staa	$bfff
                decb
                bne     Sound2
                cpx     #Sound_Table+18
                blo     Sound1
                dec     Byte
                dec     Byte
                pula
                deca
                bne     Sound0
                rts

;********************************************************************************************************
; whack out the buffer
;********************************************************************************************************
Put_Pill_Buffer ldd     Pill_Buffer
                std     ,x
                ldd     Pill_Buffer+2
                std     32,x
                ldd     Pill_Buffer+4
                std     64,x
                ldd     Pill_Buffer+6
                std     96,x
                rts
;********************************************************************************************************
; get the buffer
;********************************************************************************************************
Get_Pill_Buffer ldd    ,x
                std     Pill_Buffer
                ldd     32,x
                std     Pill_Buffer+2
                ldd     64,x
                std     Pill_Buffer+4
                ldd     96,x
                std     Pill_Buffer+6  
                rts


;********************************************************************************************************
; Calculate pill location
;********************************************************************************************************

Calc_Pill_Loc   tst     Pill_Flag
                beq     CPL1
                ldd     Pill_Location
                std     Prev_Pill_Loc
CPL3            jsr     GetRandom
                ldaa    #32
                mul
		tab
                ldx     #Pill_Spr_Type
		abx
		pshx
		clra
		lsld
		addd	#Pill_Loc_Tble
		pshb
		psha
		pulx
		ldd	,x
                std     Pill_Location
		pulx
		clra
		ldab    ,x
		lsld
		addd	#Pill_Spr_Table
		pshb
		psha
		pulx
		ldd	,x
                std     Pill_Pointer
                ldd     Pill_Location
                subd    Ghost_Location
		pshb
		psha
		pulx
                cpx     #$640
                blo     CPL3
CPL1            rts




;********************************************************************************************************
; Put_pill_0
;********************************************************************************************************
Put_Pill_0      ldx     Pill_Location
                ldaa   ,x
                anda    #%11000011
                oraa    #$28
                staa   ,x
                
                ldaa    #$be
                staa    32,x
                staa    64,x
 
                ldaa    96,x
                anda    #%11000011
                oraa    #$28
                staa    96,x
                                
                rts 
;********************************************************************************************************
; Put_pill_1
;********************************************************************************************************
Put_Pill_1      ldx     Pill_Location
                ldaa   ,x
                anda    #%11110000
                oraa    #$0a
                staa   ,x
                
                ldd     32,x
                anda    #%11000000
                oraa    #$2f
                andb    #%00111111
                orab    #$80
                std     32,x
 
                ldd     64,x
                anda    #%11000000
                oraa    #$2f
                andb    #%00111111
                orab    #$80
                std     64,x 

                ldaa    96,x
                anda    #%11110000
                oraa    #$0a
                staa    96,x
                rts                
;********************************************************************************************************
; Put_pill_2
;********************************************************************************************************
Put_Pill_2      ldx     Pill_Location
                ldd    ,x
                anda    #%11111100
                oraa    #$02
                andb    #%00111111
                orab    #$80
                std    ,x
                
                ldd     32,x
                anda    #%11110000
                oraa    #$0b
                andb    #%00001111
                orab    #$e0
                std     32,x
 
                ldd     64,x
                anda    #%11110000
                oraa    #$0b
                andb    #%00001111
                orab    #$e0
                std     64,x 

                ldd     96,x
                anda    #%11111100
                oraa    #$02
                andb    #%00111111
                orab    #$80
                std     96,x
                rts 

;********************************************************************************************************
; Put_pill_2
;********************************************************************************************************
Put_Pill_3      ldx     Pill_Location
                ldaa    1,x
                anda    #%00001111
                oraa    #$a0
                staa    1,x
                
                ldd     32,x
                anda    #%11111100
                oraa    #$02
                andb    #%00000011
                orab    #$f8
                std     32,x
                
                ldd     64,x
                anda    #%11111100
                oraa    #$02
                andb    #%00000011
                orab    #$f8
                std     64,x

                ldaa    97,x
                anda    #%00001111
                oraa    #$a0
                staa    97,x
                rts 

;********************************************************************************************************
; Plot spike buffer
;********************************************************************************************************
Put_Spikes      ldx     Spike_Location
                ldaa   ,x
                anda    #%11000000
                oraa    #$2a
                ldab    #$aa
                std    ,x
                ldd     #$aaaa
                std     2,x
                ldaa    4,x
                anda    #%00001111
                oraa    #$a0
                staa    4,x
                
                ldd     #$bfff
                std     32,x
                ldd     #$ffff
                std     34,x
                ldaa    36,x
                anda    #%00000011
                oraa    #$f8
                staa    36,x
                
                ldd     #$baeb
                std     64,x
                ldd     #$abae
                std     66,x
                ldaa    68,x
                anda    #%00000011
                oraa    #$b8
                staa    68,x
                
                ldaa    96,x
                anda    #%11000000
                oraa    #$25
                ldab    #$96
                std     96,x
                ldd     #$5659
                std     98,x
                ldaa    100,x
                anda    #%00001111
                oraa    #$60
                staa    100,x
                
                ldaa    128,x
                anda    #%11000000
                oraa    #$26
                ldab    #$96
                std     128,x
                ldd     #$9a59
                std     130,x
                ldaa    132,x
                anda    #%00001111
                oraa    #$60
                staa    132,x
                
                ldaa    160,x
                anda    #%11110011
                oraa    #$08
                ldab    161,x
                andb    #%00000011
                orab    #$98
                std     160,x
                ldaa    162,x
                anda    #%11001100
                oraa    #$22
                ldab    163,x
                andb    #%00001100
                orab    #$62
                std     162,x
                ldaa    164,x
                anda    #%00001111
                oraa    #$60
                staa    164,x
                
                ldaa    193,x
                anda    #%00000011
                oraa    #$98
                staa    193,x
                ldaa    195,x
                anda    #%00111100
                oraa    #$82
                ldab    196,x
                andb    #%00001111
                orab    #$60
                std     195,x
                
                ldaa    225,x
                anda    #%11001111
                oraa    #$20
                staa    225,x
                ldaa    228,x
                anda    #%00111111
                oraa    #$80
                staa    228,x
                
                rts


;********************************************************************************************************
; CHECK FOR SPACEBAR (DIRECTION OF GHOST)
;********************************************************************************************************
Input_Check	ldaa	#%01111111
		staa	$2
		ldaa	$bfff
		bita	#%00001000
                bne     IC8                 
                tst     Button_Depressed
                bne     IC9
                com     Direction_Flag
                com     Button_Depressed
                rts
IC8             clr     Button_Depressed
IC9             rts


;********************************************************************************************************
; Populate spike buffer
;********************************************************************************************************
Put_Sp_Buffer   ldx     Spike_Location
                
                ldd     Spike_Buffer_1
                std    ,x
                ldd     Spike_Buffer_1+2
                std     2,x
                ldaa    Spike_Buffer_1+4
                staa    4,x

                ldd     Spike_Buffer_1+5
                std     32,x
                ldd     Spike_Buffer_1+7
                std     34,x
                ldaa    Spike_Buffer_1+9
                staa    36,x                
                
                ldd     Spike_Buffer_1+10
                std     64,x
                ldd     Spike_Buffer_1+12
                std     66,x
                ldaa    Spike_Buffer_1+14
                staa    68,x               
                
                ldd     Spike_Buffer_1+15
                std     96,x
                ldd     Spike_Buffer_1+17
                std     98,x
                ldaa    Spike_Buffer_1+19
                staa    100,x                
 
                ldd     Spike_Buffer_1+20
                std     128,x
                ldd     Spike_Buffer_1+22
                std     130,x
                ldaa    Spike_Buffer_1+24
                staa    132,x
 
                ldd     Spike_Buffer_1+25
                std     160,x
                ldd     Spike_Buffer_1+27
                std     162,x
                ldaa    Spike_Buffer_1+29
                staa    164,x                

                ldd     Spike_Buffer_1+30
                std     192,x
                ldd     Spike_Buffer_1+32
                std     194,x
                ldaa    Spike_Buffer_1+34
                staa    196,x                

                ldd     Spike_Buffer_1+35
                std     224,x
                ldd     Spike_Buffer_1+37
                std     226,x
                ldaa    Spike_Buffer_1+39
                staa    228,x
                rts
;********************************************************************************************************
;Plot Ghost buffer
;********************************************************************************************************
Put_Gh_Buffer   ldx     Ghost_Location
                ldd     Ghost_Buffer
                std    ,x
                ldaa    Ghost_Buffer+2
                staa    2,x
                ldd     Ghost_Buffer+3
                std     32,x
                ldaa    Ghost_Buffer+5
                staa    34,x                
                ldd     Ghost_Buffer+6
                std     64,x
                ldaa    Ghost_Buffer+8
                staa    66,x                
                ldd     Ghost_Buffer+9
                std     96,x
                ldaa    Ghost_Buffer+11
                staa    98,x                
                ldd     Ghost_Buffer+12
                std     128,x
                ldaa    Ghost_Buffer+14
                staa    130,x                
                ldd     Ghost_Buffer+15
                std     160,x
                ldaa    Ghost_Buffer+17
                staa    162,x                
                ldd     Ghost_Buffer+18
                std     192,x
                ldaa    Ghost_Buffer+20
                staa    194,x                
                ldd     Ghost_Buffer+21
                std     224,x
                ldaa    Ghost_Buffer+23
                staa    226,x

		ldab	#$80
		abx
		abx
                
                ldd     Ghost_Buffer+24
                std     256-256,x
                ldaa    Ghost_Buffer+26
                staa    258-256,x                
                rts


;********************************************************************************************************
;PACMAN BUFFER PUT
;********************************************************************************************************
Put_Pac_Buffer  tst     PacMan_Flag
		bne	pac1
		rts

pac1            tst     Which_Pac_Flag
		beq	sirpac
                jmp     Put_Pac_Buffer2

sirpac          ldx     PacMan_Location
                
                ldd     PacMan_Buffer
                std     ,x
                ldd     PacMan_Buffer+2
                std     2,x

                ldd     PacMan_Buffer+4
                std     32,x
                ldd     PacMan_Buffer+6
                std     34,x
                
                ldd     PacMan_Buffer+8
                std     64,x
                ldd     PacMan_Buffer+10
                std     66,x
                
                ldd     PacMan_Buffer+12
                std     96,x
                ldd     PacMan_Buffer+14
                std     98,x
 
                ldd     PacMan_Buffer+16
                std     128,x
                ldd     PacMan_Buffer+18
                std     130,x

                ldd     PacMan_Buffer+20
                std     160,x
                ldd     PacMan_Buffer+22
                std     162,x

                ldd     PacMan_Buffer+24
                std     192,x
                ldd     PacMan_Buffer+26
                std     194,x

                ldd     PacMan_Buffer+28
                std     224,x
                ldd     PacMan_Buffer+30
                std     226,x
		
		ldab	#$80
		abx
		abx

                ldd     PacMan_Buffer+32
                std     256-256,x
                ldd     PacMan_Buffer+34
                std     258-256,x

                ldd     PacMan_Buffer+36
                std     288-256,x
                ldd     PacMan_Buffer+38
                std     290-256,x

                ldd     PacMan_Buffer+40
                std     320-256,x
                ldd     PacMan_Buffer+42
                std     322-256,x

                ldd     PacMan_Buffer+44
                std     352-256,x
                ldd     PacMan_Buffer+46
                std     354-256,x

                ldd     PacMan_Buffer+48
                std     384-256,x
                ldd     PacMan_Buffer+50
                std     386-256,x

                ldd     PacMan_Buffer+52
                std     416-256,x
                ldd     PacMan_Buffer+54
                std     418-256,x

                ldd     PacMan_Buffer+56
                std     448-256,x
                ldd     PacMan_Buffer+58
                std     450-256,x

PPB1            rts

Put_Pac_Buffer2 ldx     MsPac_Location
                
                ldd     MsPac_Buffer
                std     ,x
                ldd     MsPac_Buffer+2
                std     2,x
                ldaa    MsPac_Buffer+4
                staa    4,x
                
                ldd     MsPac_Buffer+5
                std     32,x
                ldd     MsPac_Buffer+7
                std     34,x
                ldaa    MsPac_Buffer+9
                staa    36,x                
                
                ldd     MsPac_Buffer+10
                std     64,x
                ldd     MsPac_Buffer+12
                std     66,x
                ldaa    MsPac_Buffer+14
                staa    68,x               
                
                ldd     MsPac_Buffer+15
                std     96,x
                ldd     MsPac_Buffer+17
                std     98,x
                ldaa    MsPac_Buffer+19
                staa    100,x               
                
                ldd     MsPac_Buffer+20
                std     128,x
                ldd     MsPac_Buffer+22
                std     130,x
                ldaa    MsPac_Buffer+24
                staa    132,x                
                
                ldd     MsPac_Buffer+25
                std     160,x
                ldd     MsPac_Buffer+27
                std     162,x
                ldaa    MsPac_Buffer+29
                staa    164,x                
                
                ldd     MsPac_Buffer+30
                std     192,x
                ldd     MsPac_Buffer+32
                std     194,x
                ldaa    MsPac_Buffer+34
                staa    196,x                
                
                ldd     MsPac_Buffer+35
                std     224,x
                ldd     MsPac_Buffer+37
                std     226,x
                ldaa    MsPac_Buffer+39
                staa    228,x                
		ldab	#$80
		abx
		abx
                ldd     MsPac_Buffer+40
                std     256-256,x
                ldd     MsPac_Buffer+42
                std     258-256,x
                ldaa    MsPac_Buffer+44
                staa    260-256,x               

                ldd     MsPac_Buffer+45
                std     288-256,x
                ldd     MsPac_Buffer+47
                std     290-256,x
                ldaa    MsPac_Buffer+49
                staa    292-256,x                
                
                ldd     MsPac_Buffer+50
                std     320-256,x
                ldd     MsPac_Buffer+52
                std     322-256,x
                ldaa    MsPac_Buffer+54
                staa    324-256,x

                ldd     MsPac_Buffer+55
                std     352-256,x
                ldd     MsPac_Buffer+57
                std     354-256,x
                ldaa    MsPac_Buffer+59
                staa    356-256,x

                ldd     MsPac_Buffer+60
                std     384-256,x
                ldd     MsPac_Buffer+62
                std     386-256,x
                ldaa    MsPac_Buffer+64
                staa    388-256,x

                ldd     MsPac_Buffer+65
                std     416-256,x
                ldd     MsPac_Buffer+67
                std     418-256,x
                ldaa    MsPac_Buffer+69
                staa    420-256,x

                ldd     MsPac_Buffer+70
                std     448-256,x
                ldd     MsPac_Buffer+72
                std     450-256,x
                ldaa    MsPac_Buffer+74
                staa    452-256,x                
                
                ldd     MsPac_Buffer+75
                std     480-256,x
                ldd     MsPac_Buffer+77
                std     482-256,x
                ldaa    MsPac_Buffer+79
                staa    484-256,x                
                
                rts

;********************************************************************************************************
;PACMAN BUFFER GET
;********************************************************************************************************
Get_Pac_Buffer  tst     PacMan_Flag
		bne	putpac
		rts

putpac          tst     Which_Pac_Flag
		beq	mrpac
		jmp	Get_Pac_Buffer2

mrpac           ldx     PacMan_Location
                ldd    ,x
                std     PacMan_Buffer
                ldd     2,x
                std     PacMan_Buffer+2

                ldd     32,x
                std     PacMan_Buffer+4
                ldd     34,x
                std     PacMan_Buffer+6
                
                ldd     64,x
                std     PacMan_Buffer+8
                ldd     66,x
                std     PacMan_Buffer+10               

                ldd     96,x
                std     PacMan_Buffer+12
                ldd     98,x
                std     PacMan_Buffer+14

                ldd     128,x
                std     PacMan_Buffer+16
                ldd     130,x
                std     PacMan_Buffer+18
 
                ldd     160,x
                std     PacMan_Buffer+20
                ldd     162,x
                std     PacMan_Buffer+22

                ldd     192,x
                std     PacMan_Buffer+24
                ldd     194,x
                std     PacMan_Buffer+26

                ldd     224,x
                std     PacMan_Buffer+28
                ldd     226,x
                std     PacMan_Buffer+30
;*** abx me
		ldab	#$80
		abx
		abx

                ldd     256-256,x
                std     PacMan_Buffer+32
                ldd     258-256,x
                std     PacMan_Buffer+34

                ldd     288-256,x
                std     PacMan_Buffer+36
                ldd     290-256,x
                std     PacMan_Buffer+38

                ldd     320-256,x
                std     PacMan_Buffer+40
                ldd     322-256,x
                std     PacMan_Buffer+42

                ldd     352-256,x
                std     PacMan_Buffer+44
                ldd     354-256,x
                std     PacMan_Buffer+46

                ldd     384-256,x
                std     PacMan_Buffer+48
                ldd     386-256,x
                std     PacMan_Buffer+50

                ldd     416-256,x
                std     PacMan_Buffer+52
                ldd     418-256,x
                std     PacMan_Buffer+54

                ldd     448-256,x
                std     PacMan_Buffer+56
                ldd     450-256,x
                std     PacMan_Buffer+58
	        rts

;********************************************************************************************************
;MS PACMAN BUFFER GET
;********************************************************************************************************

Get_Pac_Buffer2 ldx     MsPac_Location
                ldd    ,x
                std     MsPac_Buffer
                ldd     2,x
                std     MsPac_Buffer+2
                ldaa    4,x
                staa    MsPac_Buffer+4

                ldd     32,x
                std     MsPac_Buffer+5
                ldd     34,x
                std     MsPac_Buffer+7
                ldaa    36,x
                staa    MsPac_Buffer+9

                ldd     64,x
                std     MsPac_Buffer+10
                ldd     66,x
                std     MsPac_Buffer+12
                ldaa    68,x
                staa    MsPac_Buffer+14

                ldd     96,x
                std     MsPac_Buffer+15
                ldd     98,x
                std     MsPac_Buffer+17
                ldaa    100,x
                staa    MsPac_Buffer+19

                ldd     128,x
                std     MsPac_Buffer+20
                ldd     130,x
                std     MsPac_Buffer+22
                ldaa    132,x
                staa    MsPac_Buffer+24

                ldd     160,x
                std     MsPac_Buffer+25
                ldd     162,x
                std     MsPac_Buffer+27
                ldaa    164,x
                staa    MsPac_Buffer+29

                ldd     192,x
                std     MsPac_Buffer+30
                ldd     194,x
                std     MsPac_Buffer+32
                ldaa    196,x
                staa    MsPac_Buffer+34

                ldd     224,x
                std     MsPac_Buffer+35
                ldd     226,x
                std     MsPac_Buffer+37
                ldaa    228,x
                staa    MsPac_Buffer+39

		ldab	#$80
		abx	
		abx

                ldd     256-256,x
                std     MsPac_Buffer+40
                ldd     258-256,x
                std     MsPac_Buffer+42
                ldaa    260-256,x
                staa    MsPac_Buffer+44

                ldd     288-256,x
                std     MsPac_Buffer+45
                ldd     290-256,x
                std     MsPac_Buffer+47
                ldaa    292-256,x
                staa    MsPac_Buffer+49

                ldd     320-256,x
                std     MsPac_Buffer+50
                ldd     322-256,x
                std     MsPac_Buffer+52
                ldaa    324-256,x
                staa    MsPac_Buffer+54

                ldd     352-256,x
                std     MsPac_Buffer+55
                ldd     354-256,x
                std     MsPac_Buffer+57
                ldaa    356-256,x
                staa    MsPac_Buffer+59

                ldd     384-256,x
                std     MsPac_Buffer+60
                ldd     386-256,x
                std     MsPac_Buffer+62
                ldaa    388-256,x
                staa    MsPac_Buffer+64

                ldd     416-256,x
                std     MsPac_Buffer+65
                ldd     418-256,x
                std     MsPac_Buffer+67
                ldaa    420-256,x
                staa    MsPac_Buffer+69

                ldd     448-256,x
                std     MsPac_Buffer+70
                ldd     450-256,x
                std     MsPac_Buffer+72
                ldaa    452-256,x
                staa    MsPac_Buffer+74

                ldd     480-256,x
                std     MsPac_Buffer+75
                ldd     482-256,x
                std     MsPac_Buffer+77
                ldaa    484-256,x
                staa    MsPac_Buffer+79
                
                rts

;********************************************************************************************************
;SPIKE BUFFER GET
;********************************************************************************************************

Get_Sp_Buffer   ldx     Spike_Location
                ldd    ,x
                std     Spike_Buffer_1
                ldd     2,x
                std     Spike_Buffer_1+2
                ldaa    4,x
                staa    Spike_Buffer_1+4

                ldd     32,x
                std     Spike_Buffer_1+5
                ldd     34,x
                std     Spike_Buffer_1+7
                ldaa    36,x
                staa    Spike_Buffer_1+9

                ldd     64,x
                std     Spike_Buffer_1+10
                ldd     66,x
                std     Spike_Buffer_1+12
                ldaa    68,x
                staa    Spike_Buffer_1+14

                ldd     96,x
                std     Spike_Buffer_1+15
                ldd     98,x
                std     Spike_Buffer_1+17
                ldaa    100,x
                staa    Spike_Buffer_1+19

                ldd     128,x
                std     Spike_Buffer_1+20
                ldd     130,x
                std     Spike_Buffer_1+22
                ldaa    132,x
                staa    Spike_Buffer_1+24
 
                ldd     160,x
                std     Spike_Buffer_1+25
                ldd     162,x
                std     Spike_Buffer_1+27
                ldaa    164,x
                staa    Spike_Buffer_1+29

                ldd     192,x
                std     Spike_Buffer_1+30
                ldd     194,x
                std     Spike_Buffer_1+32
                ldaa    196,x
                staa    Spike_Buffer_1+34

                ldd     224,x
                std     Spike_Buffer_1+35
                ldd     226,x
                std     Spike_Buffer_1+37
                ldaa    228,x
                staa    Spike_Buffer_1+39
                rts

;********************************************************************************************************
;
;********************************************************************************************************
Initiate_Spike  ldx     #Screen+5
                jsr     GetRandom
                ldaa    #18
                mul
		tab
		abx
                stx     Spike_Location
                rts
;********************************************************************************************************
;
;********************************************************************************************************
Move_Spike      ldx     Spike_Location
		ldab	#32
		abx
                cpx     #Screen+3072
                blo     keepmove
                jsr     Initiate_Spike
keepmove        stx     Spike_Location
                rts


;********************************************************************************************************
;Move our ghostie
;********************************************************************************************************
Move_Ghost      tst     Direction_Flag
                bne     MG1
                ldaa    Ghost_Whl_Pos
                cmpa    #150
                bne     MG2
                clr     Ghost_Whl_Pos
                bra     MG4
MG2             inc     Ghost_Whl_Pos
                bra     MG4
                
MG1             tst     Ghost_Whl_Pos
                bne     MG3
                ldaa    #150
                staa    Ghost_Whl_Pos
                bra     MG4
MG3             dec     Ghost_Whl_Pos
MG4             rts 

;********************************************************************************************************
;calc location of Ghost
;********************************************************************************************************
Calc_Ghost_Loc	ldab    Ghost_Whl_Pos
                ldx     #Whl_Spr_Table
		abx
		clra	
		lslb
		rola
		addd	#Whl_Loc_Table
		pshb
		psha
		pulx
		ldd	,x
		std	Ghost_Location

                ldab    Ghost_Whl_Pos
                ldx     #Whl_Spr_Table
		abx
		ldaa	,x
                ldab    #2
                mul
                addd    #Ghost_Spr_Tbl
		pshb
		psha
		pulx
		ldd	,x
		std	Ghost_Pointer
		rts

;********************************************************************************************************
;Place Ghost on wheel 
;********************************************************************************************************
Put_Ghost       ldx     Ghost_Pointer
                jsr     ,x
                rts

;********************************************************************************************************
;Ghost sprite 0px offset
;********************************************************************************************************
Put_Ghost_0     ldx     Ghost_Location

                ldaa    0,x
                anda    #%11110000
                oraa    #$0a
                ldab    1,x
                andb    #%00000011
                orab    #$a8
                std     0,x

                ldaa    32,x
                anda    #%11000000
                oraa    #$2f
                ldab    #$fe
                std     32,x

                ldd     #$bfff
                std     64,x
                ldaa    66,x
                anda    #%00111111
                oraa    #$80
                staa    66,x
                
                ldd     #$b6db
                std     96,x
                ldaa    98,x
                anda    #%00111111
                oraa    #$80
                staa    98,x
                
                ldd     #$b5d7
                std     128,x
                ldaa    130,x
                anda    #%00111111
                oraa    #$80             
                staa    130,x

                ldd     #$bfff
                std     160,x
                std     192,x
                ldaa    162,x
                anda    #%00111111
                oraa    #$80
                staa    162,x
                ldaa    194,x
                anda    #%00111111
                oraa    #$80
                staa    194,x

                ldd     #$befb
                std     224,x
                ldaa    226,x
                anda    #%00111111
                oraa    #$80
                staa    226,x


		ldab	#$80
		abx
		abx

                ldaa    ,x
                anda    #%11000011
                oraa    #$28
                ldab    1,x
                andb    #%00001100
                orab    #$a2
                std     ,x
                
                rts

;********************************************************************************************************
;Ghost sprite 1px offset
;********************************************************************************************************
Put_Ghost_1     ldx     Ghost_Location

                ldaa    0,x
                anda    #%11111100
                oraa    #$02
                ldab    #$aa
                std     0,x

                ldaa    32,x
                anda    #%11110000
                oraa    #$0b
                ldab    #$ff
                std     32,x
                ldaa    34,x
                anda    #%00111111
                oraa    #$80
                staa    34,x

                ldaa    64,x
                anda    #%11000000
                oraa    #$2f
                ldab    #$ff
                std     64,x
                ldaa    66,x
                anda    #%00001111
                oraa    #$e0
                staa    66,x
                
                ldaa    96,x
                anda    #%11000000
                oraa    #$2d
                ldab    #$b6
                std     96,x
                ldaa    98,x
                anda    #%00001111
                oraa    #$e0
                staa    98,x

                ldaa    128,x
                anda    #%11000000
                oraa    #$2d
                ldab    #$75
                std     128,x
                ldaa    130,x
                anda    #%00001111
                oraa    #$e0
                staa    130,x                

                ldaa    160,x
                anda    #%11000000
                oraa    #$2f
                ldab    #$ff
                std     160,x
                ldaa    162,x
                anda    #%00001111
                oraa    #$e0
                staa    162,x 

                ldaa    192,x
                anda    #%11000000
                oraa    #$2f
                ldab    #$ff
                std     192,x
                ldaa    194,x
                anda    #%00001111
                oraa    #$e0
                staa    194,x 

                ldaa    224,x
                anda    #%11000000
                oraa    #$2e
                ldab    #$fb
                std     224,x
                ldaa    226,x
                anda    #%00001111
                oraa    #$e0
                staa    226,x 

		ldab	#$80
		abx
		abx

                ldaa    ,x
                anda    #%11110011
                oraa    #$08
                ldab    1,x
                andb    #%00001100
                orab    #$a2
                std     ,x
                ldaa    2,x
                anda    #%00111111
                oraa    #$80
                staa    2,x 
                
                rts                

;********************************************************************************************************
;Ghost sprite 2px offset
;********************************************************************************************************
Put_Ghost_2     ldx     Ghost_Location

                ldaa    #$aa
                ldab    2,x
                andb    #%00111111
                orab    #$80
                std     1,x
                
                ldaa    32,x
                anda    #%11111100
                oraa    #$02
                ldab    #$ff
                std     32,x
                ldaa    34,x
                anda    #%00001111
                oraa    #$e0
                staa    34,x
                
                ldaa    64,x
                anda    #%11110000
                oraa    #$0b
                ldab    #$ff
                std     64,x
                ldaa    66,x
                anda    #%00000011
                oraa    #$f8
                staa    66,x
                
                ldaa    96,x
                anda    #%11110000
                oraa    #$0b
                ldab    #$6d
                std     96,x
                ldaa    98,x
                anda    #%00000011
                oraa    #$b8
                staa    98,x

                ldaa    128,x
                anda    #%11110000
                oraa    #$0b
                ldab    #$5d
                std     128,x
                ldaa    130,x
                anda    #%00000011
                oraa    #$78
                staa    130,x                

                ldaa    160,x
                anda    #%11110000
                oraa    #$0b
                ldab    #$ff
                std     160,x
                ldaa    162,x
                anda    #%00000011
                oraa    #$f8
                staa    162,x                

                ldaa    192,x
                anda    #%11110000
                oraa    #$0b
                ldab    #$ff
                std     192,x
                ldaa    194,x
                anda    #%00000011
                oraa    #$f8
                staa    194,x

                ldaa    224,x
                anda    #%11110000
                oraa    #$0b
                ldab    #$ef
                std     224,x
                ldaa    226,x
                anda    #%00000011
                oraa    #$b8
                staa    226,x

		ldab	#$80
		abx
		abx

                ldaa    ,x
                anda    #%11111100
                oraa    #$02
                ldab    1,x
                andb    #%00110000
                orab    #$8a
                std     ,x
                ldaa    2,x
                anda    #%11001111
                oraa    #$20
                staa    2,x

                rts                

;********************************************************************************************************
;Ghost sprite 3px offset
;********************************************************************************************************
Put_Ghost_3     ldx     Ghost_Location

                ldaa    1,x
                anda    #%11000000
                oraa    #$2a
                ldab    2,x
                andb    #%00001111
                orab    #$a0
                std     1,x
                
                ldaa    #$bf
                ldab    34,x
                andb    #%00000011
                orab    #$f8
                std     33,x
                
                ldaa    64,x
                anda    #%11111100
                oraa    #$02
                ldab    #$ff
                std     64,x
                ldaa    #$fe
                staa    66,x

                ldaa    96,x
                anda    #%11111100
                oraa    #$02
                ldab    #$db
                std     96,x
                ldaa    #$6e
                staa    98,x                

                ldaa    128,x
                anda    #%11111100
                oraa    #$02
                ldab    #$d7
                std     128,x
                ldaa    #$5e
                staa    130,x                 

                ldaa    160,x
                anda    #%11111100
                oraa    #$02
                ldab    #$ff
                std     160,x
                ldaa    #$fe
                staa    162,x                 

                ldaa    192,x
                anda    #%11111100
                oraa    #$02
                ldab    #$ff
                std     192,x
                ldaa    #$fe
                staa    194,x

                ldaa    224,x
                anda    #%11111100
                oraa    #$02
                ldab    #$ef
                std     224,x
                ldaa    #$be
                staa    226,x                
          
		ldab	#$80
		abx
		abx
	      
                ldaa    1,x
                anda    #%00110000
                oraa    #$8a
                ldab    2,x
                andb    #%11000011
                orab    #$28
                std     1,x

                rts                


;********************************************************************************************************
;Ghost sprite 3px offset
;********************************************************************************************************
Get_Gh_Buffer   ldx     Ghost_Location
                ldd     0,x
                std     Ghost_Buffer
                ldaa    2,x
                staa    Ghost_Buffer+2
                ldd     32,x
                std     Ghost_Buffer+3
                ldaa    34,x
                staa    Ghost_Buffer+5
                ldd     64,x
                std     Ghost_Buffer+6
                ldaa    66,x
                staa    Ghost_Buffer+8              
                ldd     96,x
                std     Ghost_Buffer+9
                ldaa    98,x
                staa    Ghost_Buffer+11
                ldd     128,x
                std     Ghost_Buffer+12
                ldaa    130,x
                staa    Ghost_Buffer+14
                ldd     160,x
                std     Ghost_Buffer+15
                ldaa    162,x
                staa    Ghost_Buffer+17
                ldd     192,x
                std     Ghost_Buffer+18
                ldaa    194,x
                staa    Ghost_Buffer+20
                ldd     224,x
                std     Ghost_Buffer+21
                ldaa    226,x
                staa    Ghost_Buffer+23
		ldab	#$80
		abx
		abx
                ldd     ,x
                std     Ghost_Buffer+24
                ldaa    2,x
                staa    Ghost_Buffer+26
                rts

;********************************************************************************************************
;calc location of pacman / mrs pacman
;********************************************************************************************************
Calc_Pac_Loc    tst     Which_Pac_Flag
                bne     CPL2
                jsr     GetRandom
                ldaa    #58
                mul
                ldab    #32
                mul
                addd    #Screen+(23*32)
                std     PacMan_Location
                addd    #28
                std     PacMan_End
                rts

CPL2            jsr     GetRandom
                ldaa    #58
                mul
                ldab    #32
                mul
                addd    #Screen+(23*32)+27
                std     MsPac_Location
                subd    #28
                std     MsPac_End
                rts    

;********************************************************************************************************
;2voice BZZZ player sequencer
;********************************************************************************************************
PLAY		stx	ploop+1
		std	eploop+1
ploop		ldx	#SONG1
eploop		cpx	#ENDSONG1
		bne	playmore
		rts

playmore	ldd	,x
		inx
		inx
		stx	ploop+1
		lslb
		ldx	#NOTES
		abx
		ldx	,x
		stx	freq+1
		tab
		lslb
		ldx	#NOTES
		abx
		ldx	,x
		stx	freq2+1

		ldx	#780
playit		jsr	sum
		dex
		bne	playit
		bra	ploop

sum		ldd 	#$0000 
freq		addd	#$0000
		std 	sum+1
;********************************************************************************************************
;2voice player oscillator loop
;********************************************************************************************************
sum2		ldd	#$0000	
		bcs	freq2		;tripped on overflow from above summation
		addd	freq2+1		;add the new freq (ch2)
		std	sum2+1		;store it
		bcs	bit_on		;carry (overflow on above add)

bit_off		ldaa	#$24		;turn off 1bit (with videomode on)
		staa	$bfff		;set the hardware
		rts

freq2		addd	#$0000		;our 1st SUM tripped an overflow
		std	sum2+1		;and we store back to sum #2
bit_on		ldaa	#$a4		;turn on 1bit (with videomode on)
		staa	$bfff		;set the hardware
		rts

dun		inc	$4000
		jmp	dun
;********************************************************************************************************
;Display ready text and play zix
;********************************************************************************************************
Player_Ready    ldd     #Ready
		std	tileloc+1    
		ldx     #$41eb
                ldd     #$0706
                std     Tile_Y
                jsr     Put_Tile

                ldx     #SONG1
		ldd	#ENDSONG1
                jsr     PLAY		;wemove moi !!

                ldaa    #7
                staa    Counter_Y
                ldx     #$41eb
clrready        ldd     #$0000
	        std     0,x
                std     2,x
                std     4,x
                std     6,x
                std     8,x
                std     10,x
		ldab	#32
		abx
                dec     Counter_Y
                bne     clrready
                rts

;********************************************************************************************************
; Displays the score
;********************************************************************************************************
Display_Score	ldaa    ,x
                lsra
                lsra
                lsra
                lsra
                ldab    #16
                mul
		addd	#Score_Font
                jsr     Put_Digit
		ldaa    ,x
		anda	#%00001111                
                ldab    #16
                mul
		addd	#Score_Font
                jsr     Put_Digit
		inx
		ldaa    ,x
                lsra
                lsra
                lsra
                lsra
                ldab    #16
                mul
		addd	#Score_Font
                jsr     Put_Digit
		ldaa    ,x
		anda	#%00001111                
                ldab    #16
                mul
		addd	#Score_Font
                jsr     Put_Digit

                rts
;********************************************************************************************************
; Put it on da screen
;********************************************************************************************************
Put_Digit	pshx
		sts	digit_s+1
		std	our_s+1
our_s		lds	#$0000
		des
scrpt		ldx	#$0000
		pula
		pulb
                std     0,x
		pula
		pulb
                std     32,x
		pula
		pulb
                std     64,x
		pula
		pulb
                std     96,x
		pula
		pulb
                std     128,x
		pula
		pulb
                std     160,x
		pula
		pulb
                std     192,x
		pula
		pulb
                std     224,x
		ldab	#2
		abx
		stx	scrpt+1
digit_s		lds	#$0000
		pulx
                rts

;********************************************************************************************************
;Draws wheel track within which the player ghost can travel
;********************************************************************************************************
Draw_Wheel      sts	wheel_s+1
		ldx     #Screen+7+(24*32)
                lds     #Wheel
		des
                ldaa    #$45
                staa    Counter_Y
DW1             ldaa    #$09
                staa    Counter_X
DW2             pula
		pulb
                std     ,x
		inx
		inx
                dec     Counter_X
                bne     DW2
		ldab	#32-18
		abx
                dec     Counter_Y
                bne     DW1
wheel_s		lds	#$0000
                rts

;********************************************************************************************************
;Display title screen & continuously modify random seed while waiting
;********************************************************************************************************
Title_Screen
		ldd     #Logo
		std	tileloc+1
                ldx     #$40C8	
                ldd     #$1c09
                std     Tile_Y
                jsr     Put_Tile

                ldd     #Text_1
		std	tileloc+1
                ldx     #$4504	
                ldd     #$050c
                std     Tile_Y
                jsr     Put_Tile                

                ldd     #space
		std	tileloc+1
                ldx     #$4AA5		
                ldd     #$050b
                std     Tile_Y
                jsr     Put_Tile                

                ldd     #invis
		std	tileloc+1
                ldx     #$45e5		
                ldd     #$050b
                std     Tile_Y
                jsr     Put_Tile                

                ldd     #Big_Ghost
		std	tileloc+1
                ldx     #$478E	
                ldd     #$1102
                std     Tile_Y
                jsr     Put_Tile  

                ldd     #Cherry
		std	tileloc+1
                ldx     #$4766
                ldd     #$1102
                std     Tile_Y
                jsr     Put_Tile 
 
                ldd     #Strawberry
		std	tileloc+1
                ldx     #$4776		
                ldd     #$1102
                std     Tile_Y
                jsr     Put_Tile  

;********************************************************************************************************
;Animate ghost and fruits while we wait for spacebar press
;********************************************************************************************************
                ldab    #10
                stab    Counter_X
wfr1            jsr     Wait_Vsync
                dec     Counter_X
                bne     wfr1                

TS1             jsr     Wait_Vsync
                jsr     GetRandom
                ldaa    #100
                mul
                inca
                cmpa    #1
                bne     TS2
                jsr     Wiggle_Fruit1
                bra     TS4

TS2             cmpa    #2
                bne     TS3
                jsr     Wiggle_Fruit2
                bra     TS4

TS3             cmpa    #3
                bne     TS4
                ldx     #$478e+(5*32)
                ldd     #$2f69
                std     ,x
                std     32,x
                ldd     #$da60
                std     2,x
                std     34,x                
    
TS4
;********************************************************************************************************
; CHECK FOR SPACEBAR
;********************************************************************************************************
		ldaa	#%01111111
		staa	$2
wkey1		ldaa	$bfff
		bita	#%00001000
		bne	TS1
                rts



               
;********************************************************************************************************
;does what the label says
;********************************************************************************************************
Wiggle_Fruit1   ldd     #Cherry		;object
		std	tileloc+1	;store it
                ldd     #$1102		;height/width
                std     Tile_Y		

		ldx	#$4766-32	;up one line
                jsr     Put_Tile
                jsr     Wait_Vsync
                jsr     Wait_Vsync

		ldx	#$4766
                jsr     Put_Tile
                jsr     Wait_Vsync
                jsr     Wait_Vsync

                ldx	#$4766+32	;down one line
                jsr     Put_Tile
                jsr     Wait_Vsync
                jsr     Wait_Vsync

		ldx	#$4766
                jsr     Put_Tile
                jsr     Wait_Vsync
                jsr     Wait_Vsync
;********************************************************************************************************
;Moves ghosts eyes
;********************************************************************************************************
                ldx     #$478E+(5*32)
                ldd     #$2fa5
                std     0,x
                std     32,x
                ldd     #$e960
                std     2,x
                std     34,x
                jsr     Wait_Vsync
                
                rts

;********************************************************************************************************
;does what the label says
;********************************************************************************************************
Wiggle_Fruit2   ldd     #Strawberry	;object
		std	tileloc+1	;store it
                ldd     #$1102		;height/width
                std     Tile_Y		

		ldx	#$4776-32	;up one line
                jsr     Put_Tile
                jsr     Wait_Vsync
                jsr     Wait_Vsync

		ldx	#$4776
                jsr     Put_Tile
                jsr     Wait_Vsync
                jsr     Wait_Vsync

                ldx	#$4776+32	;down one line
                jsr     Put_Tile
                jsr     Wait_Vsync
                jsr     Wait_Vsync

		ldx	#$4776
                jsr     Put_Tile
                jsr     Wait_Vsync
                jsr     Wait_Vsync

;********************************************************************************************************
;Moves ghosts eyes
;********************************************************************************************************
                ldx     #$478e+(5*32)
                ldd     #$2f5a
                std     0,x
                std     32,x
                ldd     #$d6a0
                std     2,x
                std     34,x
                jsr     Wait_Vsync
		rts
;********************************************************************************************************
;wait about a FRAME (just use the free running timer here)
;********************************************************************************************************
Wait_Vsync	ldx	#$800
wvs		dex
		bne	wvs
		rts
;		stx	$9
;wait		ldx	$9
;		cpx	#$c5a2		;$fff8 - 57*262
;		bls	wait
;		rts
;********************************************************************************************************
;Clear graphic screen (3k)
;********************************************************************************************************
Clear_Screen	ldd	#$0000
		ldx	#$4000
loop1		std	,x
		inx
		inx
		cpx	#$4000+3072
		blo	loop1
		rts
;********************************************************************************************************
;Plot tiles
;********************************************************************************************************
Put_Tile        sts	olds+1
tileloc		lds	#0000
		des
		ldaa     Tile_Y
                staa     Counter_Y
PT1             ldaa     Tile_X
                staa     Counter_X
PT2             pula
		pulb
                std     ,x
		inx
		inx
                dec     Counter_X
                bne     PT2
                ldab    #32
                subb    Tile_X
                subb    Tile_X
                abx
                dec     Counter_Y
                bne     PT1
olds		lds	#0000
                rts


;********************************************************************************************************
; RNG BASED ON BJORKS CODE
;********************************************************************************************************
GetRandom	clr	mys               ;Clear holder of LFSB
		ldaa	Random_MSB        ;get high byte of 16-bit Random word
		anda	#%10110100        ;Get the bits check in shifting
		ldab	#6                ;Use the top 6 bits for xoring
GetRandom1	lsla  			  ;move top bit into the carry flag
		bcc	GetRandom2        ;skip incing the LFSB if no carry
		inc	mys               ;add one to the LFSB test holder
GetRandom2	decb                      ;remove one from loop counter
		bne	GetRandom1        ;loop if all bits are not done
		ldaa	mys               ;get LFSB off of stack
		inca                      ;invert lower bit by adding one
		rora                      ;move bit 0 into carry
		rol	Random_LSB        ;shift carry in to the bit 0 of Random_LSB
		rol	Random_MSB        ;one for shift to complete the 16 shifting
		ldd	Random_Word       ;Load up a and b with the new Random word
		rts

soundbyte	.byte	$24
mys		.byte	0
Random_MSB 	.byte	1
Random_LSB 	.byte	1
Random_Word 	equ    	Random_MSB
Screen          equ     $4000
Wait_Delay      equ     10

Ghost_Buffer    .fill     27
Spike_Buffer_1  .fill     40
Spike_Buffer_2  .fill     40
PacMan_Buffer   .fill     60
MsPac_Buffer    .fill     80
Pill_Buffer     .fill     8

Button_Depressed  .fill     1
Direction_Flag  .fill     1

Ghost_Location  .fill     2
Ghost_Whl_Pos   .fill     1
Ghost_Pointer   .fill     2

PacMan_Location .fill     2
PacMan_End      .fill     2
PacMan_Counter  .fill     1
PacMan_Pointer  .fill     2
PacMan_Flag     .fill     1
Slow_PacMan     .fill     1

MsPac_Location  .fill     2
MsPac_End       .fill     2
MsPac_Counter   .fill     1
MsPac_Pointer   .fill     2
MsPac_Flag      .fill     1
Slow_MsPac      .fill     1

Which_Pac_Flag  .fill     1               ; 0 = Pac Man, 1 = Ms Pac Pan
Both_Flag       .fill     1               ; 0 = Just Pac Man, 1 = Mr & Ms alternate

Spike_Loc_1     .fill     2
Spike_Loc_2     .fill     2
Spike_Location  .fill     2
Spike_Pointer   .fill     2

Pill_Location   .fill     2
Prev_Pill_Loc   .fill     2
Pill_Pointer    .fill     2
Pill_Flag       .fill     1
Pill_Count      .fill     1

Fruit1          .fill     2
Fruit2          .fill     2

Palette_Num     .fill     1

CoCo_Type       .fill     1
Byte            .fill     2
Counter_Y       .fill     1
Counter_X       .fill     1
Score           .fill     2
Hi_Score        .fill     2
Tile_Y          .fill     1
Tile_X          .fill     1

;		align	$100
                .org  (($+0ffh) & 0ff00h)

NOTES
c0		.word	$0000,$004f,$0054,$0059,$005e,$0064,$0069,$0070,$0076,$007d,$0085,$008d
c1		.word	$0095,$009E,$00A8,$00B2,$00BC,$00C8,$00D3,$00E0,$00ED,$00FB,$010A,$011A
c2		.word	$012b,$013D,$0150,$0164,$0179,$018F,$01A7,$01C0,$01DB,$01F7,$0215,$0234
c3		.word	$0256,$027A,$029F,$02C7,$02F1,$031E,$034E,$0380,$03B5,$03EE,$042A,$0469
c4		.word	$04AC,$04F3,$053E,$058E,$05E3,$063C,$069B,$0700,$076B,$07DB,$0853,$08D2
c5		.word	$0958,$09E6,$0A7D,$0B1D,$0BC6,$0C79,$0D37,$0E00,$0ED5,$0FB7,$10A6,$11A4
c6		.word	$12B0,$13CC,$14FA,$1639,$178B,$18F2,$1A6E,$1C00,$1DAA,$1F6E,$214C,$2347
c7		.word	$2560,$2799,$29F4,$2C72,$2F17,$31E4,$34DB,$3800,$3B54,$3EDB,$4298,$468E
c8		.word	$4AC0,$4F32,$53E7,$58E5,$5E2E,$63C8,$69B6,$7000,$76A9,$7DB7,$8531,$8D1C



Sound_Table     .byte     $8b,$a7,$c2,$de,$fa,$de
                .byte     $c2,$a7,$8b,$6f,$53,$38
                .byte     $1c,$02,$1c,$38,$53,$6f

SONG1           .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
	        .byte     64,00
;	        .byte     64,00
;	        .byte     64,00


	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
	        .byte     62,00
;	        .byte     62,00
;	        .byte     62,00

                .byte     00,00
                .byte     61,45
                .byte     61,45
                .byte     61,45
                .byte     61,45
                .byte     64,45
                .byte     64,00
                .byte     64,00
                .byte     00,00
                .byte     62,40
                .byte     62,40
                .byte     62,40
                .byte     62,40
                .byte     61,40
                .byte     61,00
                .byte     59,00
                .byte     00,00
                .byte     57,45
                .byte     57,45
                .byte     57,45
                .byte     57,45
                .byte     57,45
                .byte     57,00
                .byte     57,00
                .byte     00,00
                .byte     52,45
                .byte     52,45
                .byte     52,45
                .byte     52,45
                .byte     52,45
                .byte     52,00
                .byte     52,00
                .byte     00,00
ENDSONG1	equ	*

SONG2           .byte     54,38
 	        .byte     54,38
 	        .byte     54,38
 	        .byte     54,38
 	        .byte     54,38

                .byte     54,00
                .byte     54,00

                .byte     00,00

                .byte     54,38
                .byte     54,38
                .byte     54,38

                .byte     00,38
                .byte     56,38

                .byte     56,00
                .byte     56,00

                .byte     00,00

                .byte     59,35
                .byte     59,35
                .byte     59,35
                .byte     59,35

                .byte     57,35

                .byte     57,00
                .byte     57,00

                .byte     00,00
                .byte     56,35
                .byte     56,35
                .byte     56,35
                .byte     56,35

                .byte     54,35
                .byte     54,00
                .byte     54,00

                .byte     00,00
                .byte     52,40
                .byte     52,40
                .byte     52,40
                .byte     52,40
                .byte     52,40

                .byte     52,00
                .byte     52,00
                .byte     00,00
ENDSONG2	equ	*


Ghost_Spr_Tbl   .word     Put_Ghost_0,Put_Ghost_1,Put_Ghost_2,Put_Ghost_3
Dead_Spr_Tbl    .word     Put_Dead_0,Put_Dead_1,Put_Dead_2,Put_Dead_3
PacMan_Spr_Tbl  .word     Put_PacMan_1,Put_PacMan_2,Put_PacMan_3,Put_PacMan_2
MsPac_Spr_Tbl   .word     Put_MsPacMan_1,Put_MsPacMan_2,Put_MsPacMan_3,Put_MsPacMan_2
Pill_Spr_Table  .word     Put_Pill_0,Put_Pill_1,Put_Pill_2,Put_Pill_3

Pill_Spr_Type   .byte     1,1,1,1
                .byte     0,2,0,1               
                .byte     1,0,2,0
                .byte     1,1,1,1
                .byte     2,2,2,2
                .byte     0,1,0,0
                .byte     0,0,1,1
                .byte     1,1,1,2


Pill_Loc_Tble
	        .word     $4390,$43D1,$4412,$4433
	        .word     $4515,$4595,$4616,$4696
	        .word     $4776,$47F6,$4875,$48F5
	        .word     $49B3,$4A12,$4A51,$4A70
	        .word     $4A2E,$4A4D,$4A0C,$49AB
	        .word     $490A,$4889,$4809,$4789
	        .word     $4689,$45E9,$4569,$450A
	        .word     $444B,$440C,$43AD,$438E

Whl_Loc_Table 
		.word     $436E,$436F,$436F,$436F,$438F,$4390,$4390,$4390,$4390,$43B1,$43B1,$43D1
		.word     $43D1,$43F2,$43F2,$4412,$4412,$4433,$4453,$4473,$4493,$44B4,$44D4,$44F4
		.word     $4514,$4534,$4554,$4575,$4595,$45B5,$45D5,$45F5,$4615,$4635,$4655,$4675
		.word     $4695,$46B5,$46D5,$46F5,$4715,$4735,$4755,$4775,$4795,$47B5,$47D5,$47F5
		.word     $4815,$4835,$4854,$4874,$4894,$48B4,$48D4,$48F3,$4913,$4933,$4953,$4972
		.word     $4992,$4992,$49B2,$49B1,$49D1,$49F1,$49F1,$49F0,$4A10,$4A10,$4A10,$4A0F
		.word     $4A0F,$4A2F,$4A2F,$4A2E,$4A2E,$4A2E,$4A2E,$4A0D,$4A0D,$4A0D,$4A0D,$4A0C
		.word     $49EC,$49EC,$49CC,$49CB,$49AB,$498B,$498B,$496A,$494A,$492A,$490A,$4909
		.word     $48E9,$48C9,$48A9,$4889,$4869,$4848,$4828,$4808,$47E8,$47C8,$47A8,$4788
		.word     $4768,$4748,$4728,$4708,$46E8,$46C8,$46A8,$4688,$4668,$4648,$4628,$4608
		.word     $45E8,$45C8,$45A8,$4588,$4568,$4548,$4529,$4509,$44E9,$44C9,$44A9,$4489
		.word     $4469,$446A,$444A,$442A,$442A,$440B,$43EB,$43EB,$43CB,$43AC,$43AC,$43AC
		.word     $438C,$438D,$438D,$436D,$436D,$436E,$436E	

Whl_Spr_Table   .byte     3,0,1,2,3,0,1,2,3,0,1,2
                .byte     3,0,1,2,3,0,1,2,3,0,1,1
                .byte     2,3,3,0,0,0,1,1,1,2,2,2
                .byte     2,2,2,2,2,2
                .byte     1,1,1,1,1,0,0,0,3,2,1,1
                .byte     0,3,2,1,0,3,2,1,0,3,2,1
                .byte     0,3,2,1,0,3,2,1,0,3,2,1
                .byte     0,3,2,1,0,3,2,1,0,3,2,1
                .byte     0,3,2,1,0,3,3,2,2,1,0,3
                .byte     3,3,2,2,1,1,1,0,0,0,0,0
                .byte     0,0,0,1,1,1,1,2,2,2,3,3
                .byte     0,0,1,1,2,3,3,0,1,2,3,0
                .byte     1,2,3,0,1,2,3,0,1,2,3,0
                .byte     1


Wheel           .word     $0000,$0000,$0000,$000A,$A8AA,$8000,$0000,$0000,$0000
                .word     $0000,$0000,$0000,$0AAA,$A8AA,$AA80,$0000,$0000,$0000
                .word     $0000,$0000,$0002,$AAA9,$5895,$AAAA,$0000,$0000,$0000
                .word     $0000,$0000,$00AA,$A555,$5A95,$556A,$A800,$0000,$0000
                .word     $0000,$0000,$02A9,$5555,$5555,$5555,$AA00,$0000,$0000
                .word     $0000,$0000,$2A95,$5555,$5555,$5555,$5AA0,$0000,$0000
                .word     $0000,$0000,$A955,$5555,$5555,$5555,$55A8,$0000,$0000
                .word     $0000,$000A,$A555,$5555,$5555,$5555,$556A,$0000,$0000
                .word     $0000,$002A,$5555,$5555,$5555,$5555,$5556,$A000,$0000
                .word     $0000,$00A9,$5555,$5555,$5555,$5555,$5555,$A800,$0000
                .word     $0000,$00A5,$5555,$5555,$5555,$5555,$5555,$6800,$0000
                .word     $0000,$0025,$5555,$5555,$5A95,$5555,$5555,$6000,$0000
                .word     $0000,$2A09,$5555,$5555,$5895,$5555,$5555,$82A0,$0000
                .word     $0000,$A989,$5555,$5555,$A8A9,$5555,$5555,$89A8,$0000
                .word     $0000,$A565,$5555,$55AA,$A8AA,$A955,$5555,$6568,$0000
                .word     $0002,$9555,$5555,$56AA,$0002,$AA55,$5555,$555A,$0000
                .word     $0002,$9555,$5555,$6A00,$0000,$02A5,$5555,$555A,$8000
                .word     $000A,$5555,$5655,$A800,$0000,$00A9,$5655,$5556,$8000
                .word     $0029,$5555,$589A,$8000,$0000,$000A,$9895,$5555,$A000
                .word     $0029,$5555,$582A,$0000,$0000,$0002,$A095,$5555,$A000
                .word     $00A5,$5555,$5600,$0000,$0000,$0000,$0255,$5555,$6800
                .word     $00A5,$5555,$5680,$0000,$0000,$0000,$0A55,$5555,$6800
                .word     $0295,$5555,$5680,$0000,$0000,$0000,$0A55,$5555,$5A00
                .word     $0295,$5555,$5A00,$0000,$0000,$0000,$0295,$5555,$5A00
                .word     $0295,$5555,$6800,$0000,$0000,$0000,$00A5,$5555,$5A00
                .word     $0A55,$5555,$6800,$0000,$0000,$0000,$00A5,$5555,$5680
                .word     $0A55,$5555,$A000,$0000,$0000,$0000,$0029,$5555,$5680
                .word     $0A55,$5555,$A000,$0000,$0000,$0000,$0029,$5555,$5680
                .word     $2A55,$5556,$8000,$0000,$0000,$0000,$000A,$5555,$56A0
                .word     $2955,$5556,$8000,$0000,$0000,$0000,$000A,$5555,$55A0
                .word     $2955,$5556,$8000,$0000,$0200,$0000,$000A,$5555,$55A0
                .word     $2955,$555A,$0000,$0000,$0A80,$0000,$0002,$9555,$55A0
                .word     $2955,$555A,$0000,$0000,$29A0,$0000,$0002,$9555,$55A0
                .word     $2A95,$55AA,$0000,$0000,$A568,$0000,$0002,$A955,$5AA0
                .word     $0095,$5580,$0000,$0002,$955A,$0000,$0000,$0955,$5800
                .word     $2A95,$55AA,$0000,$0000,$A568,$0000,$0002,$A955,$5AA0
                .word     $2955,$555A,$0000,$0000,$29A0,$0000,$0002,$9555,$55A0
                .word     $2955,$555A,$0000,$0000,$0A80,$0000,$0002,$9555,$55A0
                .word     $2955,$5556,$8000,$0000,$0200,$0000,$000A,$5555,$55A0
                .word     $2955,$5556,$8000,$0000,$0000,$0000,$000A,$5555,$55A0
                .word     $2A55,$5556,$8000,$0000,$0000,$0000,$000A,$5555,$56A0
                .word     $0A55,$5555,$A000,$0000,$0000,$0000,$0029,$5555,$5680
                .word     $0A55,$5555,$A000,$0000,$0000,$0000,$0029,$5555,$5680
                .word     $0A55,$5555,$6800,$0000,$0000,$0000,$00A5,$5555,$5680
                .word     $0295,$5555,$6800,$0000,$0000,$0000,$00A5,$5555,$5A00
                .word     $0295,$5555,$5A00,$0000,$0000,$0000,$0295,$5555,$5A00
                .word     $0295,$5555,$5680,$0000,$0000,$0000,$0A55,$5555,$5A00
                .word     $00A5,$5555,$5680,$0000,$0000,$0000,$0955,$5555,$6800
                .word     $00A5,$5555,$5600,$0000,$0000,$0000,$0955,$5555,$6800
                .word     $0029,$5555,$582A,$0000,$0000,$0002,$8255,$5555,$A000
                .word     $0029,$5555,$58A6,$8000,$0000,$000A,$6255,$5555,$A000
                .word     $000A,$5555,$5655,$A800,$0000,$00A9,$5955,$5556,$8000
                .word     $000A,$9555,$5555,$6A00,$0000,$02A5,$5555,$555A,$0000
                .word     $0002,$9555,$5555,$56AA,$0002,$AA55,$5555,$555A,$0000
                .word     $0000,$A555,$5555,$55AA,$A8AA,$A955,$5555,$5568,$0000
                .word     $0000,$A969,$5555,$5555,$A8A9,$5555,$5555,$A5A8,$0000
                .word     $0000,$2A82,$5555,$5555,$5895,$5555,$5556,$0AA0,$0000
                .word     $0000,$0A09,$5555,$5555,$5A95,$5555,$5555,$8280,$0000
                .word     $0000,$0025,$5555,$5555,$5555,$5555,$5555,$6000,$0000
                .word     $0000,$0029,$5555,$5555,$5555,$5555,$5555,$A000,$0000
                .word     $0000,$002A,$5555,$5555,$5555,$5555,$5556,$A000,$0000
                .word     $0000,$0002,$A555,$5555,$5555,$5555,$556A,$8000,$0000
                .word     $0000,$0000,$A955,$5555,$5555,$5555,$55A8,$0000,$0000
                .word     $0000,$0000,$2A95,$5555,$5555,$5555,$5AA0,$0000,$0000
                .word     $0000,$0000,$02A9,$5555,$5555,$5555,$AA00,$0000,$0000
                .word     $0000,$0000,$00AA,$A555,$5A95,$556A,$A800,$0000,$0000
                .word     $0000,$0000,$0002,$AAA9,$5895,$AAAA,$0000,$0000,$0000
                .word     $0000,$0000,$0000,$0AAA,$A8AA,$AA80,$0000,$0000,$0000
                .word     $0000,$0000,$0000,$000A,$A8AA,$8000,$0000,$0000,$0000

Score_Font      .byte     $2A,$A8
                .byte     $A5,$5A
                .byte     $96,$96
                .byte     $96,$96
                .byte     $96,$96
                .byte     $96,$96
                .byte     $A5,$5A
                .byte     $2A,$A8

                .byte     $0A,$A0
                .byte     $29,$60
                .byte     $25,$60
                .byte     $29,$60
                .byte     $09,$60
                .byte     $A9,$6A
                .byte     $95,$56
                .byte     $AA,$AA

                .byte     $2A,$A8
                .byte     $A5,$5A
                .byte     $96,$96
                .byte     $AA,$96
                .byte     $29,$5A
                .byte     $A5,$AA
                .byte     $95,$56
                .byte     $AA,$AA

                .byte     $2A,$A8
                .byte     $A5,$5A
                .byte     $9A,$96
                .byte     $A9,$5A
                .byte     $AA,$96
                .byte     $96,$96
                .byte     $A5,$5A
                .byte     $2A,$A8

                .byte     $AA,$AA
                .byte     $96,$96
                .byte     $96,$96
                .byte     $96,$96
                .byte     $A5,$56
                .byte     $2A,$96
                .byte     $00,$96
                .byte     $00,$AA

                .byte     $AA,$AA
                .byte     $95,$56
                .byte     $96,$AA
                .byte     $95,$5A
                .byte     $AA,$96
                .byte     $96,$96
                .byte     $A5,$5A
                .byte     $2A,$A8

                .byte     $2A,$A8
                .byte     $A5,$58
                .byte     $96,$A8
                .byte     $95,$5A
                .byte     $96,$96
                .byte     $96,$96
                .byte     $A5,$5A
                .byte     $2A,$A8

                .byte     $AA,$AA
                .byte     $95,$56
                .byte     $AA,$96
                .byte     $0A,$5A
                .byte     $09,$68
                .byte     $09,$60
                .byte     $09,$60
                .byte     $0A,$A0

                .byte     $2A,$A8
                .byte     $A5,$5A
                .byte     $96,$96
                .byte     $A5,$5A
                .byte     $96,$96
                .byte     $96,$96
                .byte     $A5,$5A
                .byte     $2A,$A8

                .byte     $2A,$A8
                .byte     $A5,$5A
                .byte     $96,$96
                .byte     $96,$96
                .byte     $A5,$56
                .byte     $2A,$96
                .byte     $25,$5A
                .byte     $2A,$A8

Logo            .word     $0AAA,$AA02,$A80A,$A00A,$AAA8,$00AA,$AAA0,$2AAA,$A800
                .word     $2FFF,$FD8B,$F62F,$D82F,$FFF6,$02FF,$FFD8,$BFFF,$F600
                .word     $BFFF,$FD8B,$F62F,$D8BF,$FFFD,$8BFF,$FFD8,$BFFF,$F600
                .word     $BF6A,$AA0B,$F62F,$D8BF,$6AFD,$8BF6,$AAA8,$AAFD,$AA00
                .word     $BF6A,$A80B,$F6AF,$D8BF,$6AFD,$8BF6,$AAA8,$2AFD,$A800
                .word     $BF6F,$F60B,$FFFF,$D8BF,$62FD,$8BFF,$FF60,$02FD,$8000
                .word     $BF6F,$FD8B,$FFFF,$D8BF,$62FD,$8AFF,$FFD8,$02FD,$8000
                .word     $BF6A,$FD8B,$F6AF,$D8BF,$62FD,$82AA,$AFD8,$02FD,$8000
                .word     $BF6A,$FD8B,$F62F,$D8BF,$6AFD,$82AA,$AFD8,$02FD,$8000
                .word     $BFFF,$FD8B,$F62F,$D8BF,$FFFD,$8BFF,$FFD8,$02FD,$8000
                .word     $AFFF,$F68B,$F62F,$D8AF,$FFF6,$8BFF,$FF68,$02FD,$8000
                .word     $2AAA,$AA0A,$AA2A,$A82A,$AAAA,$0AAA,$AAA0,$02AA,$8000
                .word     $0AAA,$A802,$A80A,$A00A,$AAA8,$02AA,$AA80,$00AA,$0000
                .word     $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                .word     $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                .word     $0002,$AAAA,$802A,$80AA,$00AA,$AAA0,$2A80,$AA00,$0000
                .word     $000B,$FFFF,$60BF,$62FD,$82FF,$FFD8,$BF62,$FD80,$0000
                .word     $000B,$FFFF,$D8BF,$62FD,$8BFF,$FFD8,$BF62,$FD80,$0000
                .word     $000B,$F6AF,$D8BF,$62FD,$8BF6,$AAA8,$BF62,$FD80,$0000
                .word     $000B,$F6AF,$D8BF,$62FD,$8BF6,$AAA8,$BF6A,$FD80,$0000
                .word     $000B,$FFFF,$68BF,$62FD,$8BFF,$FF60,$BFFF,$FD80,$0000
                .word     $000B,$FFFF,$60BF,$62FD,$8AFF,$FFD8,$BFFF,$FD80,$0000
                .word     $000B,$F6AF,$D8BF,$62FD,$82AA,$AFD8,$BF6A,$FD80,$0000
                .word     $000B,$F6AF,$D8BF,$6AFD,$82AA,$AFD8,$BF62,$FD80,$0000
                .word     $000B,$F62F,$D8BF,$FFFD,$8BFF,$FFD8,$BF62,$FD80,$0000
                .word     $000B,$F62F,$D8AF,$FFF6,$8BFF,$FF68,$BF62,$FD80,$0000
                .word     $000A,$AA2A,$A82A,$AAAA,$0AAA,$AAA0,$AAA2,$AA80,$0000
                .word     $0002,$A80A,$A00A,$AAA8,$02AA,$AA80,$2A80,$AA00,$0000

Text_1          .word     $8800,$0000,$0000,$0000,$0000,$0A00,$0000,$000A,$0000,$0000,$0000,$0000
                .word     $88A0,$A8A8,$A8A8,$A002,$8220,$088A,$8888,$0020,$220A,$2A2A,$2A22,$2A28
                .word     $A888,$2020,$20A0,$8802,$A2A0,$0A08,$8888,$002A,$2A22,$282A,$2228,$2822
                .word     $A8A0,$2020,$2080,$8802,$2020,$080A,$8888,$0002,$2222,$2022,$2A22,$2028
                .word     $8888,$A820,$20A8,$8802,$A2A0,$0808,$8A8A,$8028,$2228,$2A22,$2222,$2A22

space		.word     $0A00,$0000,$0000,$0A00,$0000,$0000,$0000,$00A8,$0002,$8000,$0000
		.word     $088A,$8A82,$8280,$202A,$2A2A,$2A28,$2A2A,$0020,$2802,$2202,$A220
		.word     $0A08,$8A08,$0800,$2A22,$2220,$282A,$2222,$0020,$8802,$8202,$22A0
		.word     $080A,$0800,$8080,$022A,$2A20,$2022,$2A28,$0020,$8802,$0202,$A020
		.word     $0808,$8A8A,$0A00,$2820,$222A,$2A2A,$2222,$0020,$A002,$02A2,$22A0

invis		.word     $0882,$800A,$0A80,$2200,$0000,$0000,$0000,$0000,$02A0,$0000,$0000
		.word     $0A88,$0002,$0880,$222A,$2A0A,$2A0A,$2800,$A088,$0082,$8222,$A0A0
		.word     $0A88,$0A82,$0880,$2228,$2220,$0822,$2200,$A8A8,$0082,$2220,$8200
		.word     $0888,$0002,$0880,$2220,$2802,$0822,$2200,$8808,$0082,$2220,$8020
		.word     $0882,$800A,$8A80,$082A,$2228,$2A28,$2200,$A8A8,$02A2,$2082,$A280


Big_Ghost       .word     $000A,$8000
                .word     $00AF,$E800
                .word     $02FF,$FE00
                .word     $0BFF,$FF80
                .word     $2FD7,$F5E0
                .word     $2F69,$DA60
                .word     $2F69,$DA60
                .word     $BF55,$D578
                .word     $BFD7,$F5F8
                .word     $BFFF,$FFF8
                .word     $BFFF,$FFF8
                .word     $BFFF,$FFF8
                .word     $BFFF,$FFF8
                .word     $BEFA,$FEF8
                .word     $B8BA,$F8B8
                .word     $2020,$A020
                .word     $0000,$0000

Cherry          .word     $0000,$0000
                .word     $0000,$00A0
                .word     $0000,$0A08
                .word     $0000,$A008
                .word     $0002,$08A0
                .word     $02A8,$A880
                .word     $0BF2,$A200
                .word     $2FCF,$8A00
                .word     $2FFE,$CF80
                .word     $2DFB,$CFE0
                .word     $2F7B,$FFE0
                .word     $0BFB,$7FE0
                .word     $02AB,$DFE0
                .word     $0002,$FF80
                .word     $0000,$AA00
                .word     $0000,$0000
                .word     $0000,$0000

Strawberry      .word     $0000,$0000
                .word     $0002,$0000
                .word     $0009,$8000
                .word     $00A9,$A800
                .word     $0201,$0200
                .word     $0BC0,$0F80
                .word     $2FFC,$FDE0
                .word     $2F7F,$FFE0
                .word     $2FF7,$DFE0
                .word     $2FFF,$FFE0
                .word     $0B7D,$F780
                .word     $0BFF,$FF80
                .word     $02DF,$7E00
                .word     $00BF,$F800
                .word     $002B,$A000
                .word     $0002,$0000
                .word     $0000,$0000

Orange          .word     $0000,$0000
                .word     $0000,$0020
                .word     $0002,$0288
                .word     $000B,$8808
                .word     $002B,$A820
                .word     $009F,$D580
                .word     $0257,$5560
                .word     $0955,$5558
                .word     $0955,$5558
                .word     $0955,$5558
                .word     $0955,$5558
                .word     $0255,$5560
                .word     $0255,$5560
                .word     $0095,$5680
                .word     $002A,$A800
                .word     $0000,$0000
                .word     $0000,$0000

Apple           .word     $0000,$0000
                .word     $0000,$8000
                .word     $02A2,$6A00
                .word     $0BF9,$BF80
                .word     $2FFD,$FFE0
                .word     $2FFF,$FFF8
                .word     $2FFF,$FFF8
                .word     $2FFF,$FFF8
                .word     $2FFF,$FDF8
                .word     $2FFF,$FDF8
                .word     $0BFF,$F7E0
                .word     $0BFF,$FFE0
                .word     $02FF,$FF80
                .word     $00BE,$FE00
                .word     $0028,$A800
                .word     $0000,$0000
                .word     $0000,$0000

Fig             .word     $0000,$0000
                .word     $000A,$A800
                .word     $002F,$FE00
                .word     $00BA,$E800
                .word     $0028,$4A00
                .word     $0080,$8080
                .word     $0226,$0220
                .word     $0208,$1820
                .word     $0860,$2208
                .word     $0881,$8188
                .word     $0860,$2008
                .word     $0209,$9820
                .word     $0202,$0220
                .word     $0088,$0880
                .word     $0028,$2A00
                .word     $0002,$A000
                .word     $0000,$0000

Key             .word     $0000,$0000
                .word     $000A,$8000
                .word     $00AF,$E800
                .word     $02FA,$BE00
                .word     $02FF,$FE00
                .word     $02FF,$FE00
                .word     $02FF,$FE00
                .word     $00A6,$6800
                .word     $0026,$6000
                .word     $0026,$5800
                .word     $0026,$6000
                .word     $0026,$6000
                .word     $0026,$5800
                .word     $0026,$6000
                .word     $0009,$8000
                .word     $0002,$0000
                .word     $0000,$0000

Ready           .word     $3FFC,$3FFC,$0FC0,$FFC0,$F0F0,$3F00
                .word     $3C0F,$3C00,$3CF0,$F0F0,$F0F0,$3F00
                .word     $3C0F,$3C00,$F03C,$F03C,$F0F0,$FC00
                .word     $3C3F,$3FF0,$F03C,$F03C,$3FC0,$F000
                .word     $3FF0,$3C00,$FFFC,$F03C,$0F00,$C000
                .word     $3CFC,$3C00,$F03C,$F0F0,$0F00,$0000
                .word     $3C3F,$3FFC,$F03C,$FFC0,$0F03,$0000

Game_Over       .word     $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                .word     $03FF,$03F0,$3C0F,$3FFC,$0000,$3FF0,$F03C,$FFF3,$FFC0
                .word     $0F00,$0F3C,$3F3F,$3C00,$0000,$F03C,$F03C,$F003,$C0F0
                .word     $3C00,$3C0F,$3FFF,$3C00,$0000,$F03C,$F03C,$F003,$C0F0
                .word     $3C3F,$3C0F,$3FFF,$3FF0,$0000,$F03C,$FCFC,$FFC3,$C3F0
                .word     $3C0F,$3FFF,$3CCF,$3C00,$0000,$F03C,$3FF0,$F003,$FF00
                .word     $0F0F,$3C0F,$3C0F,$3C00,$0000,$F03C,$0FC0,$F003,$CFC0
                .word     $03FF,$3C0F,$3C0F,$3FFC,$0000,$3FF0,$0300,$FFF3,$C3F0
                .word     $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

Player_One      .word     $2800,$0000,$0000,$000A,$0000
                .word     $2220,$2A22,$2A28,$0022,$0A2A
                .word     $2820,$222A,$2822,$0022,$2228
                .word     $2020,$2A02,$2028,$0022,$2220
                .word     $202A,$222A,$2A22,$0028,$222A

High_Score      .word     $8800,$0000,$0028,$0000,$0000
                .word     $88A8,$A888,$0080,$A828,$A0A8
                .word     $A820,$8088,$00A8,$8088,$88A0
                .word     $8820,$88A8,$0008,$8088,$A080
                .word     $88A8,$A888,$00A0,$A8A0,$88A8

		end		start
