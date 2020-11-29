;========================================
;S.U & K. S. - Shoot Upward & Kill Stuff
;Written by Ron Davis in 2020 (Thanks for the spare time, China!)
;Released to the public domain.
;tasm6801 suks.asm
;
;Conventions:
;camelCase - global variables, functions and labels
;_camelCase - local variables and labels
;PascalCase - global numeric constants and module names
;_PascalCase - local numeric constants
;
;I realize some of this is non-standard but it is what 
;looks good to me and is easier to type.
;
;This is my first assembly program in 10 years, my first 
;on an 8-bit computer in 35 years, and my first on a 
;68xx ever. Please forgive the inelegant, brute-force coding.
;========================================
;Constants
;========================================
;zero page pointers
TimerControl        .equ    $08 ;bit 3 set = OutCompare int2
CPUTicks            .equ    $09 ;894886.25 khz. 1 tick = 0.00000111746s = 1.11746us
CPUTicksLow         .equ    $0a    
CPUTicksPerMS       .equ    895 ;895 ticks = 1 milliscond
OutCompare          .equ    $0b 
OutCompareLow       .equ    $0c
OutCompareVal       .equ    3428

Adder               .equ    $ee ;Adder should always = 0
AdderLow            .equ    $ef ;for adding 8 bit number to 'd'
B0                  .equ    $f0 ;pseudo-registers
B1                  .equ    $f1
B2                  .equ    $f2
B3                  .equ    $f3
B4                  .equ    $f4
B5                  .equ    $f5
W0                  .equ    $f6
W1                  .equ    $f8
W2                  .equ    $fa
W3                  .equ    $fc
W4                  .equ    $fe
;----------------------------------------
;Constants for 32x16 text mode (64x32 semi-graphics)
;The virtual screen is 0-255 (pixels) in both x and y.
;The playfield is from 64,64 to 127,93 (status bar not included).
;This is so enemies can move in to and out of the top/bottom of 
;screen. Left and right side clipping was too slow and was removed.
;Sprites should not be allowed to move off the left or right edges.
ScreenBytesX        .equ    32
ScreenBytesY        .equ    16
ScreenWidth         .equ    64  ;in "pixels"
ScreenHeight        .equ    32

PlayfieldWidth      .equ    64  ;in pixels
PlayfieldHeight     .equ    30  ;in pixels (visible screen minus status bar)
PlayfieldX1         .equ    64
PlayfieldY1         .equ    64
PlayfieldX2         .equ    PlayfieldX1+PlayfieldWidth-1
PlayfieldY2         .equ    PlayfieldY1+PlayfieldHeight-1

BytesPerRow         .equ    ScreenBytesX
VideoRAM            .equ    $4000
VideoRAMLen         .equ    ScreenBytesX*ScreenBytesY  ;$200/512
VideoRAMEnd         .equ    VideoRAM+VideoRAMLen-1
VDGReg              .equ    $bfff
VDGColorSet0        .equ    $00
VDGColorSet1        .equ    $40
BackgroundByte      .equ    $80     ;black 
BackgroundWord      .equ    $8080   ;black 

GreenPixel          .equ    128
YellowPixel         .equ    144
BluePixel           .equ    160
RedPixel            .equ    176
BuffPixel           .equ    192
CyanPixel           .equ    208
MagentaPixel        .equ    224
OrangePixel         .equ    240

DirUp               .equ    0
DirDown             .equ    1
DirLeft             .equ    2
DirRight            .equ    3
;========================================
;Global Variables
;========================================
    .org $4c00
    .execstart
    nop             ;Reset vector requires nop.
    ldd     #$4c00
    std     $4221
    jmp initialize

vdgColorSet         .byte   $00     ;current color set
deltaTicks          .word   $0000
cpuTicksSave        .word   $0000
deltaMS             .word   $0000
warmStart           .byte   $00     ;set to 1 at initialization. Check after reset.
buff                .fill   16,0    ;general purpose buffer

GameModeOpenScreen  .equ    0       ;opening screen
GameModePlayInit    .equ    1       ;init screen, sprites, etc. for game play
GameModeStageInit   .equ    2       ;initialize the stage
GameModeStageIntro  .equ    3       ;displaying the stage # to user, continue after death
GameModeStagePlay   .equ    4       ;game play
GameModeStageBonus  .equ    5       ;bonus stage
GameModeStageOver   .equ    6
GameModePause       .equ    7
GameModeGameOver    .equ    8       
gameMode            .byte   $00     ;current game mode
gameModeArray       .word   modeOpenScreen, modePlayInit, modeStageInit, modeStageIntro
_gma1               .word   modeStagePlay, modeStageBonus, modeStageOver, modePause, modeGameOver

StageTypeNormal     .equ    1
StageTypeBonus      .equ    2

StageType           .equ    0       ;stage type (1 = normal enemy attack)
StageSpeed          .equ    1       ;speed adjust (difficulty level)
StageSeconds        .equ    2       ;length, in seconds, of the stage
StageEnemyPairs     .equ    3       ;chance/enemy# pairs
StageTitle          .equ    13
;pairs = % chance/enemy # (127,2, 255,3 = 50% chance of enemy 2, 50% of enemy 3. 0,0 = none)
                    ;            typ         spd len  pair1   pair2   pair3   pair4   pair5    title
stageData1:         .byte   StageTypeNormal,  0,  30, 255,0,  0,0,    0,0,    0,0,    0,0, "easy as pie!",0
stageData2:         .byte   StageTypeNormal,  0,  45, 255,0,  0,0,    0,0,    0,0,    0,0, '"',"extra",'"'," easy...",0
stageData3:         .byte   StageTypeNormal,  0,  45, 255,1,  0,0,    0,0,    0,0,    0,0, "look out below!",0
stageData4:         .byte   StageTypeNormal,  0,  60, 128,0,  255,1,  0,0,    0,0,    0,0, "double trouble",0
stageData5:         .byte   StageTypeBonus,   0,  15, 0,0,    0,0,    0,0,    0,0,    0,0, "bonus stage!",0
stageData6:         .byte   StageTypeNormal,  16, 60, 128,0,  255,1,  0,0,    0,0,    0,0, "turning it up a notch",0
stageData7:         .byte   StageTypeNormal,  16, 45, 255,2,  0,0,    0,0,    0,0,    0,0, "a new threat",0
stageData8:         .byte   StageTypeNormal,  16, 60, 128,2,  255,1,  0,0,    0,0,    0,0, "todo: witty title",0
stageData9:         .byte   StageTypeNormal,  16, 60, 85,2,   170,0,  255,1,  0,0,    0,0, "triple play",0
stageData10:        .byte   StageTypeBonus,   16, 30, 0,0,    0,0,    0,0,    0,0,    0,0, "bonus stage!",0
stageData11:        .byte   StageTypeNormal,  24, 60, 85,2,   170,1,  255,0,  0,0,    0,0, "turning it up to 11",0
stageData12:        .byte   StageTypeNormal,  24, 60, 255,3,  0,0,    0,0,    0,0,    0,0, "smarter than the average alien",0
stageData13:        .byte   StageTypeNormal,  24, 60, 64,3,   128,2,  192,1,  255,0,  0,0, "all together now",0
stageData14:        .byte   StageTypeNormal,  24, 60, 255,4,  0,0,    0,0,    0,0,    0,0, "space demons! because...why not?",0
stageData15:        .byte   StageTypeBonus,   24, 45, 0,0,    0,0,    0,0,    0,0,    0,0, "bonus stage!",0
stageData16:        .byte   StageTypeNormal,  24, 60, 51,4,   102,3,  153,2,  204,1,255,0, "to infinity...and beyond",0
stageArray          .word   stageData1,stageData2,stageData3,stageData4,stageData5,stageData6
_sa1:               .word   stageData7,stageData8,stageData9,stageData10,stageData11,stageData12
_sa2:               .word   stageData13,stageData14,stageData15,stageData16
StageMax            .equ    16
StageStart          .equ    1   ;for testing

stageType           .byte   $00
stageSpeed          .byte   $00
stageCurrent        .byte   $00     ;the current stage
stageCurrentBCD     .byte   $00     ;the current stage in BCD
stageData           .word   $0000   ;pointer to current stage data
stageTimer          .word   $0000
stageSecondsLeft    .byte   $00     ;seconds left in stage
StageSecondsDefault .equ    30      ;60 seconds default
 
;Strings
;Reverse video (lower case) is the default.
stringTitle         .text   "S.U&K.S.",0
stringVersion       .text   "v1.01",0
stringScore         .text   "score:000000",0
stringTimer         .text   "t:00",0
stringLives         .text   "l:00",0
stringExtra         .text   '['-64,"extra",']'-64,0
stringTitle1        .text   "hoot",0
stringTitle2        .text   "pward",0
stringTitle3        .text   "ill",0
stringTitle4        .text   "tuff",0
stringAuthor        .text   "written by:ron davis",0
stringLeftRight     .text   "a/s = left/right",0
stringFire          .text   "space = fire",0
stringBreak         .text   "break = pause/quit",0
stringStart         .text   "enter = start",0
stringNewHighScore  .text   "new "  ;no terminator, keep right above stringHighScore
stringHighScore     .text   "high score:000000",0
stringStage         .text   "stage 00",0
stringGameOver      .text   "game over",0
stringPause         .text   "q = quit : enter = resume",0

;These three must be kept together and in order for bcd math routines.
scoreHigh           .word   $0000   ;32-bit BCD score value
score               .word   $0000   ;Only 6 digits displayed.
points              .word   $0100   ;BCD value to add to score

highScoreHigh       .word   $0000   ;32-bit BCD score value
highScore           .word   $0000   ;Only 6 digits displayed.

cheating            .byte   $00
lives               .byte   $02     ;current lives
LivesStart          .equ    $02     ;# of extra lives, not counting starting life
;LivesMax            .equ    $99
extraValue          .byte   $00
ExtraTimeout        .equ    250
extraTimer          .word   $0000
ExtraFlashes        .equ    6
extraFlashCount     .byte   $00
extraSpawnTimer     .word   $0000
ExtraSpawnTimeout   .equ    8000
;----------------------------------------
;Sound variables and data
soundPriority       .word   0   ;priority 0 = none active, 1 - 255 (highest)
soundCount          .word   0   ;Number of transitions left in current sound trio.
soundToggle         .word   0   ;sound bit storage
soundTicksHigh      .word   0   ;Number of ticks to keep square wave high, of current sound trio.
soundTicksLow       .word   0   ;Number of ticks to keep square wave low, of current sound trio.
soundData           .word   0   ;Pointer to currently playing trio
soundNoToggle       .byte   0   ;1 = don't toggle bit, for silent delays    
;soundFormat: priority byte/unused byte, (count, ticks high, ticks low)...0,0,0 terminators
;count = number of cycles to play
;ticks high/low = # of ticks to keep bit high or low (i.e. the duty cycle).
;if ticks low = 0 then ticks high used for ticks low also and bit is not toggled (for silent delays).
;in theory, xx,1714,1714 = middle C ((1/261hz) / 0.00000111746) / 2 = 1714
soundFire           .word   $0100,  15,200,400, 15,250,500, 15,300,600, 15,350,700, 15,400,800, 0,0,0
soundPlayerDeath    .word   $f800,  50,400,800,50,200,600,50,700,200,50,300,500,
_spd2               .word           50,200,900,50,300,410,50,248,342,50,328,609,
_spd3               .word           50,446,200,50,150,762,50,700,200,50,300,500,
_spd4               .word           50,120,350,50,270,877,50,200,300,50,700,340,
_spd5               .word           50,400,600,50,120,350,50,700,200,50,300,500,0,0,0
soundEnemyDeath     .word   $0200,  15,800,800,15,800,0,15,800,800,15,800,0,15,800,800,15,800,0,15,800,800,0,0,0
soundTimerExpiring  .word   $f000,  30,2000,2000,0,0,0
;soundStageIntro     .word   $f000,  20,2000,2000, 20,1800,1800, 20,1600,1600, 20,1400,1400
soundStageIntro     .word   $f100,  20,1000,1000, 20,900,900, 20,800,800, 20,700,700
_ssi2               .word           20,600,600, 20,500,500, 20,400,400, 20,300,300
_ssi3               .word           20,300,300, 20,200,200, 20,100,100, 20,100,100,0,0,0
soundExtraLife      .word   $f100,  200,400,400, 0,0,0;25,1000,0,200,400,400, 25,1000,0,
_sel2               .word           200,400,400, 25,1000,0,200,400,400, 25,1000,0, 0,0,0
soundExtraLifeLong  .word   $f100,  200,400,400, 25,1000,0,200,400,400, 25,1000,0,
_sell2              .word           200,400,400, 25,1000,0,200,400,400, 25,1000,0, 0,0,0
;soundWarn           .word   $f100,  200,1000,1000, 25,1000,0,200,900,900, 25,1000,0,
;_sw1                .word           200,1000,1000, 200,900,900, 0,0,0
soundBonusItem      .word   $01000,  30,800,800,0,0,0

;----------------------------------------
;Sprite definition
SpriteFrameSeq      .equ    0
SpriteFrameCount    .equ    2   ;Number of frame sets in sequence.
SpriteFrameDels     .equ    3
SpriteMovePat       .equ    5
SpriteWidth         .equ    7   ;in pixels
SpriteHeight        .equ    8   ;in pixels
SpriteSpeed         .equ    9   ;# of ms ticks between moves
SpriteX             .equ    11  ;in pixels
SpriteY             .equ    12  ;in pixels
SpriteDir           .equ    13  ;0=up,1=down,2=left,3=right
SpriteActive        .equ    14
SpriteCurFrame      .equ    15
SpriteCurCount      .equ    16  ;frame delay counter
SpriteTimer         .equ    18  ;used with move routine
SpriteStage         .equ    20  ;used with move routine
SpriteLastX         .equ    21
SpriteLastY         .equ    22
SpriteFramePtr      .equ    23
SpriteAltColor      .equ    25
SpriteNeedDraw      .equ    26
SpriteNeedErase     .equ    27
SpriteSpeedCount    .equ    28
SpriteKillNow       .equ    30
SpriteX2            .equ    31  ;in pixels
SpriteY2            .equ    32  ;in pixels
SpriteType          .equ    33
SpriteMoved         .equ    34
SpriteKillFunc      .equ    35
SpritePointValue    .equ    37  ;BCD score value for enemies
SpriteW0            .equ    39  ;private storage for sprite
SpriteW1            .equ    41  ;can also use SpriteB0-B3 aliases
SpriteShotFunc      .equ    43
SpriteShotsLeft     .equ    45
SpriteIndex         .equ    46  ;index in to type (0-2 enemy, etc.)
SizeOfSprite        .equ    47

SpriteB0            .equ    39  ;byte aliases for sprite private storage
SpriteB1            .equ    40  
SpriteB2            .equ    41  
SpriteB3            .equ    42  

;----------------------------------------
;Player sprite
PlayerDefaultSpeed  .equ    25

playerSprite:
playerFrameSeq      .word   playerFrameSeq0
playerFrameCount    .byte   2
playerFrameDels     .word   playerDelays0
playerMovePat       .word   movePatPlayer
playerWidth         .byte   6
playerHeight        .byte   4
playerSpeed         .word   PlayerDefaultSpeed
playerX             .byte   0
playerY             .byte   0
playerDir           .byte   0
playerActive        .byte   1
playerCurFrame      .byte   0
playerCurCount      .word   0
playerTimer         .word   0
playerStage         .byte   0
playerLastX         .byte   0
playerLastY         .byte   0
playerFramePtr      .word   $0000
playerAltColor      .byte   0
playerNeedDraw      .byte   0
playerNeedErase     .byte   0
playerSpeedCount    .word   0
playerKillNow       .byte   0
playerX2            .byte   0
playerY2            .byte   0
playerSpriteType    .byte   SpriteTypePlayer
playerMoved         .byte   0
playerKillFunc      .word   $0000
playerPointValue    .word   0
playerW0            .word   0
playerW1            .word   0
playerShotFunc      .word   $0000       ;only used with enemies
playerShotsLeft     .word   0           ;only used with enemies
playerIndex         .byte   0           ;only used with enemies

;not part of sprite data
playerAllowFire     .byte   1
;----------------------------------------
;Sprite globals

SpriteTypeNone      .equ    0
SpriteTypePlayer    .equ    1
SpriteTypePShot     .equ    2
SpriteTypeEnemy     .equ    3
SpriteTypeEShot     .equ    4

pShotFireDelay      .byte   10  ;Number of player move timeouts between pShots.
pShotFireCount      .byte   0

PShotCount          .equ    4       ;max pShots
pShotSprites        .word   $0000   ;pointer to first pShot sprite

EnemyCount          .equ    3       ;max enemies
enemySprites        .word   $0000   ;pointer to first enemy sprite

EShotCount          .equ    3       ;max eShots
eShotSprites        .word   $0000   ;pointer to first enemy shot

SpriteCount         .equ    1+PShotCount+EnemyCount+EShotCount
spriteArray         .fill   (SpriteCount*2),0                   ;pointers to sprites
spriteData          .fill   ((SpriteCount-1)*SizeOfSprite),0    ;buffer for pShots, enemies, eShots

;========================================
;Code
;========================================
.module MainLoop

initialize:
    ldab    $ff
    cmpb    #123
    bne     _noCheat
    ldaa    #1
    staa    cheating
_noCheat:
    clr     Adder
    tst     warmStart
    bne     _warmStart
    inc     warmStart
    
    ldaa    VDGColorSet1
    staa    soundToggle
    
    jsr     irqInit
    jsr     rndSeed
    
_warmStart:
    ldd     CPUTicks
    std     cpuTicksSave

    ldaa    #GameModeOpenScreen
    ;ldaa    #GameModePlayInit
    staa    gameMode
    ldaa    #$80
    jsr     wipeScreenAltLines
    
    ldaa    #VDGColorSet1
    staa    VDGReg              ;Set video mode text mode, orange
    staa    vdgColorSet
    ;ldd     #1000
    ;jsr     clockWait
    ;ldaa    #32
    ;jsr     wipeScreenAltLines

_mainLoop:
    ldab    gameMode
    lslb
    ldx     #gameModeArray
    abx
    ldx     ,x
    jsr     ,x
    bra     _mainLoop
    
;========================================
;Testing area for new functions
;========================================

;----------------------------------------
;extraAdd
;Add the letter in SpriteB3 to EXTRA
;W0 = pointer to sprite
;----------------------------------------
.module ExtraAdd

extraAdd:
    ldx     W0
    ldaa    SpriteB3,x
    bita    extraValue
    beq     _cont
    jsr     scoreAddEnemy       ;if already have letter, get points
    rts
_cont:
    oraa    extraValue
    cmpa    #$1f
    bne     _noExtra
    clra    
    inc     lives
    jsr     statusBarUpdateLives
    ldd     #ExtraTimeout
    std     extraTimer
    ldaa    #ExtraFlashes
    staa    extraFlashCount
    ldaa    #$1f
_noExtra:
    staa    extraValue
    jsr     statusBarUpdateExtra
    
    rts
    
;----------------------------------------
;movePatEx
;Move to opposite side of screen then die
;W0 = pointer to sprite
;----------------------------------------
.module MovePatEx

movePatEx:
    ldx     W0
    
    ldaa    SpriteDir,x
    cmpa    #DirLeft
    beq     _goLeft
    jsr     seqRightToX
    bra     _test
_goLeft:
    jsr     seqLeftToX
_test:
    tsta
    beq    _done
    jsr     spriteSuicide
_done:
    rts
;----------------------------------------
;movePatEShot0
;Fall off screen and die.
;W0 = pointer to sprite
;----------------------------------------
.module MovePatEShot0

movePatEShot0:
    ldx     W0
    ldaa    SpriteStage,x
    cmpa    #1
    beq     _stage1
    
_stage0:    
    ldaa    #PlayfieldY2+2      ;y to die
    staa    SpriteB2,x
    inc     SpriteStage,x
    ;fall thru
    
_stage1:
    jsr     seqDownToY
    tsta
    beq    _done
    jsr     spriteSuicide
_done:
    rts
;----------------------------------------
;movePatEShot1
;zigzag pattern, fall off screen and die.
;W0 = pointer to sprite
;----------------------------------------
.module MovePatEShot1

movePatEShot1:
    ldx     W0
    ldaa    SpriteStage,x
    cmpa    #1
    beq     _stage1
    
_stage0:    
    ldaa    #DirRight
    staa    SpriteDir,x
    ldaa    #1              ;# of moves
    staa    SpriteB2,x
    inc     SpriteStage,x
    rts
_stage1:
    ldaa    SpriteDir,x
    cmpa    #DirRight
    beq     _right
_left:
    ldaa    SpriteX,x
    suba    #2
    dec     SpriteB2,x
    bne     _move
    ldab    #DirRight
    stab    SpriteDir,x
    ldab    #2
    stab    SpriteB2,x
    bra     _move
_right:
    ldaa    SpriteX,x
    adda    #2
    dec     SpriteB2,x
    bne     _move
    ldab    #DirLeft
    stab    SpriteDir,x
    ldab    #2
    stab    SpriteB2,x
_move:
    ldab    SpriteY,x
    incb
    ;addb    #2
    jsr     spriteMove
    ldaa    SpriteY,x
    cmpa    #PlayfieldY2+2
    blo     _done
    jsr     spriteSuicide
_done:
    rts
;----------------------------------------
;spawnEShotRnd
;Spawn an enemy shot if space available and rndGet < 'a'
;W0 = pointer to sprite
;'a' = chance to spawn (255/x)
;----------------------------------------
.module SpawnEShotRnd
_chance     .equ    B5

spawnEShotRnd:
    ldx     W0
    tst     SpriteShotsLeft,x
    beq     _done               ;no shots left

    staa    _chance
    jsr     rndGet
    cmpa    _chance
    bhi     _done
    
    ldaa    #EShotCount
    ldx     eShotSprites
    jsr     spriteGetInactive
    cpx     #0
    beq     _done
    
_spawn:
    stx     W1
    ldx     W0
    dec     SpriteShotsLeft,x
    ldx     SpriteShotFunc,x
    jsr     ,x
_done:
    rts
;----------------------------------------
;spawnEShot
;Spawn an enemy shot if space available 
;W0 = pointer to parent sprite
;'a' = chance to spawn (255/x)
;Upon return, W1 = sprite pointer, or 0 if no shot
;----------------------------------------
.module SpawnEShot

spawnEShot:
    ldx     W0
    tst     SpriteShotsLeft,x
    beq     _dontShoot               ;no shots left

    ldaa    #EShotCount
    ldx     eShotSprites
    jsr     spriteGetInactive
    cpx     #0
    beq     _dontShoot
    
_spawn:
    stx     W1
    ldx     W0
    dec     SpriteShotsLeft,x
    ldx     SpriteShotFunc,x
    jsr     ,x
    rts
    
_dontShoot:
    ldd     #0
    std     W1
    rts

;----------------------------------------
;eShot0Create
;Create an eShot0 sprite
;W0 = parent enemy sprite
;W1 = eShotSprite pointer
;----------------------------------------
.module EShot0Create

eShot0Create:
    ldx     W1
    ldaa    #2
    staa    SpriteWidth,x
    ldaa    #1
    staa    SpriteHeight,x
    ldaa    stageSpeed
    lsra
    staa    AdderLow
    ldd     #35
    subd    Adder
    std     SpriteSpeed,x
        
    ldx     W0                  ;parent
    ldaa    SpriteWidth,x
    suba    #2                  ;width of shot
    lsra
    adda    SpriteX,x
    ldab    SpriteY2,x
    incb
    ldx     W1
    jsr     spriteSetup
    
    ldd     #eShot0FrameSeq0
    std     SpriteFrameSeq,x
    std     SpriteFramePtr,x
    ldaa    #eShot0FrameCount
    staa    SpriteFrameCount,x
    ldd     #eShot0Delays0
    std     SpriteFrameDels,x
    ldd     #movePatEShot0
    std     SpriteMovePat,x
    ldaa    #DirDown
    staa    SpriteDir,x
    ldaa    #SpriteTypeEShot
    staa    SpriteType,x
    ldd     #0
    std     SpriteKillFunc,x
    rts
;----------------------------------------
;eShot1Create
;Create an eShot1 sprite
;W0 = parent enemy sprite
;W1 = eShotSprite pointer
;----------------------------------------
.module EShot1Create

eShot1Create:
    ldx     W1
    ldaa    #4
    staa    SpriteWidth,x
    ldaa    #2
    staa    SpriteHeight,x
    ldaa    stageSpeed
    lsra
    staa    AdderLow
    ldd     #35
    subd    Adder
    std     SpriteSpeed,x
        
    ldx     W0                  ;parent
    ldaa    SpriteWidth,x
    suba    #4                  ;width of shot
    lsra
    adda    SpriteX,x
    ldab    SpriteY2,x
    incb
    ldx     W1
    jsr     spriteSetup
    
    ldd     #eShot1FrameSeq0
    std     SpriteFrameSeq,x
    std     SpriteFramePtr,x
    ldaa    #eShot1FrameCount
    staa    SpriteFrameCount,x
    ldd     #eShot1Delays0
    std     SpriteFrameDels,x
    ldd     #movePatEShot1
    std     SpriteMovePat,x
    ldaa    #DirDown
    staa    SpriteDir,x
    ldaa    #SpriteTypeEShot
    staa    SpriteType,x
    ldd     #0
    std     SpriteKillFunc,x
    rts
;----------------------------------------
;movePatE1
;Fall to row, move random distance horizontally and retreat. Random shoot.
;W0 = pointer to sprite
;----------------------------------------
.module MovePatE1
_tmpB   .equ    B0

movePatE1:
    ldx     W0
    ldaa    SpriteStage,x
    cmpa    #1
    beq     _stage1
    cmpa    #2
    beq     _stage2
    cmpa    #3
    beq     _stage3

_stage0:    
    ldaa    #12             ;calc y to stop descending
    jsr     rndGetMax
    adda    #PlayfieldY1+4  ;at least 4 pixels down
    ldx     W0
    staa    SpriteB2,x
    inc     SpriteStage,x
    rts
    
_stage1:    
    jsr     seqDownToY
    tsta
    beq     _done

    ldaa    #15             ;rnd between 12-27
    jsr     rndGetMax
    adda    #12
    staa    _tmpB
    ldx     W0
    
    ldaa    SpriteX,x
    cmpa    #PlayfieldX1 + (PlayfieldWidth/2)
    bhi     _goLeft

    ldaa    SpriteX,x
    adda    _tmpB
    staa    SpriteB2,x
    inc     SpriteStage,x
    rts
_goLeft:    
    ldaa    SpriteX,x
    suba    _tmpB
    staa    SpriteB2,x
    inc     SpriteStage,x
    rts

_stage2:
    ldaa    SpriteX,x
    cmpa    SpriteB2,x
    blo     _right
    jsr     seqLeftToX
    bra     _moveDone
_right:
    jsr     seqRightToX
_moveDone:
    psha
    tsta
    beq     _rnd
    ldaa    #255                ;done with horz move so force shot
    bra     _shoot
_rnd:
    ldaa    #(255/7)            ;1/7 chance
_shoot:
    jsr     spawnEShotRnd
    pula
    tsta
    beq     _done
    ldx     W0
    ldaa    #PlayfieldY1-8
    staa    SpriteB2,x
    inc     SpriteStage,x
    rts
    
_stage3:    
    jsr     seqUpToY
    tsta
    beq     _done
    jsr     spriteSuicide
    
_done:
    rts
;----------------------------------------
;movePatE2
;Move to opposite side of screen, fall down a row, repeat. Shoot when over player.
;W0 = pointer to sprite
;----------------------------------------
.module MovePatE2
    
movePatE2:
    ldx     W0
    ldaa    SpriteStage,x
    cmpa    #1
    beq     _stage1
    
_stage0:    
    ldaa    SpriteDir,x
    cmpa    #DirLeft
    beq     _left0
_right0:
    jsr     seqRightToX
    tsta
    beq     _cont
    ldaa    #DirLeft
    staa    SpriteDir,x
    ldaa    SpriteY,x
    adda    #4
    cmpa    #PlayfieldY2-2
    bls     _r0s
    ldaa    #PlayfieldY2-2
_r0s:
    staa    SpriteB2,x
    inc     SpriteStage,x
    ldaa    #1  
    staa    SpriteShotsLeft,x
    bra     _cont
_left0:    
    jsr     seqLeftToX
    tsta
    beq     _cont
    ldaa    #DirRight
    staa    SpriteDir,x
    ldaa    SpriteY,x
    adda    #4
    cmpa    #PlayfieldY2-2
    bls     _l0s
    ldaa    #PlayfieldY2-2
_l0s:
    staa    SpriteB2,x
    inc     SpriteStage,x
    ldaa    #1  
    staa    SpriteShotsLeft,x
_cont:
    ldaa    SpriteY,x           ;test if off bottom
    cmpa    #PlayfieldY2+4
    blo     _shootTest
    jsr     spriteSuicide
    rts
_shootTest:
    tst     SpriteShotsLeft,x
    bne     _shootTest2
    rts
_shootTest2:
    ldaa    SpriteWidth,x
    lsra
    adda    SpriteX,x
    cmpa    playerX
    bhs     _shootTest3
    rts
_shootTest3:
    cmpa    playerX2
    bls     _shoot
    rts
_shoot:
    jsr     spawnEShot
    ldx     W1
    cpx     #0
    beq     _sdone
    ldaa    #GreenPixel
    staa    SpriteAltColor,x
_sdone:
    rts

_stage1:
    jsr     seqDownToY
    tsta    
    beq     _done
    
    clr     SpriteStage,x
    ldaa    SpriteDir,x
    cmpa    #DirLeft
    beq     _l0
_r0:
    ldaa    #PlayfieldX2
    suba    SpriteWidth,x
    inca
    staa    SpriteB2,x
    rts
_l0:
    ldaa    #PlayfieldX1
    staa    SpriteB2,x
    rts
    
_done:
    rts

;----------------------------------------
;movePatE3
;Drop down to Y, track to player and shoot, pause and track to player, etc.
;W0 = pointer to sprite
;----------------------------------------
.module MovePatE3
    
movePatE3:
    ldx     W0
    ldaa    SpriteStage,x
    cmpa    #1
    beq     _stage1
    cmpa    #2
    beq     _stage2
    cmpa    #3
    beq     _stage3
    
_stage0:    
    jsr     seqDownToY
    tsta
    beq     _cont0
    inc     SpriteStage,x
_cont0:
    rts
    
_stage1:
    ldaa    SpriteWidth,x
    lsra
    adda    SpriteX,x
    adda    #4;inca
    cmpa    playerX
    bls     _right
    suba    #8
    cmpa    playerX2
    bhi     _left
    inc     SpriteStage,x   ;go shoot and pause
    bra     _stage2 ;rts
_left:
    ldaa    SpriteX,x
    suba    #2
    bra     _move
_right:
    ldaa    SpriteX,x
    adda    #2
_move:
    ldab    SpriteY,x
    jsr     spriteMove
    rts
    
_stage2:    
    tst     SpriteShotsLeft,x
    bne     _shoot
    ldaa    #1
    staa    SpriteStage,x
    rts
_shoot:
    inc     SpriteStage,x
    ldaa    #20             ;delay after shooting
    staa    SpriteB3,x  
    jsr     spawnEShot
    ldx     W1
    cpx     #0
    beq     _sdone
_sdone:
    rts
    
_stage3:    
    dec     SpriteB3,x
    bne     _done
    ldaa    #1
    staa    SpriteStage,x
    ldaa    #1
    staa    SpriteShotsLeft,x
    
_done:
    rts

;----------------------------------------
;movePatE4
;Bounce around the screen
;W0 = pointer to sprite
;----------------------------------------
.module MovePatE4
_tmpB   .equ    B5

movePatE4:
    ldx     W0
    
_stage0:    
    ldab    SpriteX,x
    ldaa    SpriteB2,x
    bita    #%10
    beq     _decX
    addb    #2
    ldaa    SpriteWidth,x
    aba
    cmpa    #PlayfieldX2+2
    blo     _doY
    ldab    #PlayfieldX2
    subb    SpriteWidth,x
    ldaa    SpriteB2,x
    anda    #%01
    staa    SpriteB2,x
    ldaa    #1
    staa    SpriteShotsLeft,x
    bra     _doY
_decX:
    subb    #2
    cmpb    #PlayfieldX1
    bhi     _doY
    ldab    #PlayfieldX1
    ldaa    SpriteB2,x
    oraa    #%10
    staa    SpriteB2,x
    ldaa    #1
    staa    SpriteShotsLeft,x
_doY:
    stab    _tmpB
    ldab    SpriteY,x
    ldaa    SpriteB2,x
    bita    #1
    beq     _decY
    addb    #2
    ldaa    SpriteHeight,x
    aba
    cmpa    #PlayfieldY2+2
    blo     _doMove
    ldab    #PlayfieldY2
    subb    SpriteHeight,x
    ldaa    SpriteB2,x
    anda    #%10
    staa    SpriteB2,x
    ldaa    #1
    staa    SpriteShotsLeft,x
    bra     _doMove
_decY:
    subb    #2
    cmpb    #PlayfieldY1
    bhi     _doMove
    ldab    #PlayfieldY1
    ldaa    SpriteB2,x
    oraa    #%01
    staa    SpriteB2,x
    ldaa    #1
    staa    SpriteShotsLeft,x
_doMove:
    ldaa    _tmpB
    jsr     spriteMove
    tst     SpriteShotsLeft,x
    beq     _done
    ldaa    #(255/10)            ;1/10 chance
    jsr     spawnEShotRnd
_done:
    rts

;----------------------------------------
;seqDownToY
;Fall to y in spriteB2.
;'x' =  pointer to sprite
;Returns 1 in 'a' when y reached.
;----------------------------------------
.module SeqDownToY

seqDownToY:
    ldab    SpriteY,x
    incb
    cmpb    SpriteB2,x
    bls     _move
    ldaa    #1
    rts
_move:    
    ldaa    SpriteX,x
    jsr     spriteMove
    clra    
    ldab    SpriteY,x
    cmpb    SpriteB2,x
    blo     _done
    inca
_done:    
    rts

;----------------------------------------
;seqUpToY
;Rise to y in spriteB2.
;'x' =  pointer to sprite
;returns 1 in 'a' when y reached
;----------------------------------------
.module SeqUpToY

seqUpToY:
    ldab    SpriteY,x
    decb
    cmpb    SpriteB2,x
    bhs     _move
    ldaa    #1
    rts
_move:    
    ldaa    SpriteX,x
    jsr     spriteMove
    clra    
    ldab    SpriteY,x
    cmpb    SpriteB2,x
    bhi     _done
    inca
_done:    
    rts
    
;----------------------------------------
;seqRightToX
;Move right to the x in spriteB2.
;'x' =  pointer to sprite
;Returns 1 in 'a' when x reached.
;----------------------------------------
.module SeqRightToX

seqRightToX:
    ldaa    SpriteX,x
    inca
    cmpa    SpriteB2,x
    bls     _move
    ldaa    #1
    rts
_move:    
    ldab    SpriteY,x
    jsr     spriteMove
    clra    
    ldab    SpriteX,x
    cmpb    SpriteB2,x
    blo     _done
    inca
_done:    
    rts
    
;----------------------------------------
;seqLeftToX
;Move left to x in spriteB2.
;'x' =  pointer to sprite
;returns 1 in 'a' when x reached
;----------------------------------------
.module SeqLeftToX

seqLeftToX:
    ldaa    SpriteX,x
    deca
    cmpa    SpriteB2,x
    bhs     _move
    ldaa    #1
    rts
_move:    
    ldab    SpriteY,x
    jsr     spriteMove
    clra    
    ldab    SpriteX,x
    cmpb    SpriteB2,x
    bhi     _done
    inca
_done:    
    rts

;----------------------------------------
;spawnEnemy
;Spawn an enemy if a space available.
;----------------------------------------
.module SpawnEnemy

spawnEnemy:
    ldaa    #EnemyCount
    ldx     enemySprites
    jsr     spriteGetInactive
    cpx     #0
    beq     _done
    stx     W0
    jsr     rndGet

    ldx     extraSpawnTimer
    bne     _noExtra
    cmpa    #178            ;30% chance of extra life enemy
    bls     _noExtra
    ldd     #ExtraSpawnTimeout
    std     extraSpawnTimer
    ldx     #exCreate
    jsr     ,x
    rts

_noExtra:
    ldx     stageData
    ldab    #StageEnemyPairs
    abx
_loop:
    ldab    ,x      ;0% chance = done
    beq     _done
    cmpa    ,x
    bls     _spawn
    inx
    inx
    bra     _loop
    
_spawn:    
    ldaa    ,x
    beq     _done
    inx
    ldab    ,x
    ;decb
    lslb
    ldx     #enemyCreateArray
    abx
    ldx     ,x
    jsr     ,x
_done:
    rts
    
;----------------------------------------
;e0Create
;Create an instance of enemy0
;'W0' = pointer to sprite
;----------------------------------------
.module E0Create

e0Create:
    ;set w/h & speed here, spriteSetup needs them.
    ldx     W0
    ldaa    #6
    staa    SpriteWidth,x
    ldaa    #5
    staa    SpriteHeight,x
    ldaa    stageSpeed
    lsla
    staa    AdderLow
    ldd     #100
    subd    Adder
    std     SpriteSpeed,x

    ;calc x,y
    jsr     rndGet
    anda    #%111110             ;get random X, force even
    cmpa    #58
    bls     _xOk    
    ldaa    #58
    
_xOk:
    adda    #PlayfieldX1
    ldab    #PlayfieldY1-8
    ldx     W0
    jsr     spriteSetup
    
    ldaa    #DirDown
    staa    SpriteDir,x
    ldd     #e0FrameSeq0
    std     SpriteFrameSeq,x
    std     SpriteFramePtr,x
    ldaa    #e0FrameCount
    staa    SpriteFrameCount,x
    ldd     #e0Delays0
    std     SpriteFrameDels,x
    ldd     #movePatE0
    std     SpriteMovePat,x
    
    ldaa    #SpriteTypeEnemy
    staa    SpriteType,x
    ldd     #$0100
    std     SpritePointValue,x
    ldd     #scoreAddEnemy
    std     SpriteKillFunc,x
    rts
;----------------------------------------
;exCreate
;Create an instance of enemyX - extra man letter
;'W0' = pointer to sprite
;----------------------------------------
.module ExCreate

exCreate:
    ;set w/h & speed here, spriteSetup needs them.
    ldx     W0
    ldaa    #6
    staa    SpriteWidth,x
    ldaa    #2
    staa    SpriteHeight,x
    
    ;ldd     #50
    ;std     SpriteSpeed,x
    ldaa    stageSpeed
    ;lsra
    staa    AdderLow
    ldd     #50
    subd    Adder
    std     SpriteSpeed,x
    
    ldd     #0
    std     SpriteShotFunc,x
    ldaa    #0
    staa    SpriteShotsLeft,x

    ;tst     extraFlashCount
    ;beq     _cont0
    ;rts
_cont0:
    ;calc x,y
    jsr     rndGet
    tab    
    bitb    #%001
    beq     _leftSide
    ldaa    #DirLeft
    staa    SpriteDir,x
    ldaa    #PlayfieldX1
    staa    SpriteB2,x
    ldaa    #PlayfieldX2
    suba    #6
    bra     _cont
_leftSide:
    ldaa    #DirRight
    staa    SpriteDir,x
    ldaa    #PlayfieldX2
    suba    #6
    staa    SpriteB2,x
    ldaa    #PlayfieldX1
    
_cont:    
    lsrb
    andb    #%011
    lslb
    addb    #PlayfieldY1
    
    ldx     W0
    jsr     spriteSetup

    clrb
    jsr     rndGet
    cmpa    #192            ;75% chance of missing letter
    blo     _rndLetter
    ldab    extraValue
    
_rndLetter:    
    jsr     rndGet
    cmpa    #51
    bls     _lX
    cmpa    #102
    bls     _lT
    cmpa    #153
    bls     _lR
    cmpa    #204
    bls     _lA
    
_lE:
    bitb    #%10000         ;already have E?
    bne     _lX
    ldab    #%10000
    ldaa    #'E'
    bra     _lCont
_lX:
    bitb    #%01000         
    bne     _lT
    ldab    #%01000
    ldaa    #'X'
    bra     _lCont
_lT:
    bitb    #%00100         
    bne     _lR
    ldab    #%00100
    ldaa    #'T'
    bra     _lCont
_lR:
    bitb    #%00010         
    bne     _lA
    ldab    #%00010
    ldaa    #'R'
    bra     _lCont
_lA:
    bitb    #%00001         
    bne     _lE
    ldab    #%00001
    ldaa    #'A'

_lCont:
    stab    SpriteB3,x
    ldx     #exFrame0_0
    staa    3,x
    ldx     #exFrame1_0
    staa    3,x
    ldx     #exFrame2_0
    staa    3,x
    ldx     #exFrame3_0
    staa    3,x
    ldx     W0
    
    ldd     #exFrameSeq0
    std     SpriteFrameSeq,x
    std     SpriteFramePtr,x
    ldaa    #exFrameCount
    staa    SpriteFrameCount,x
    ldd     #exDelays0
    std     SpriteFrameDels,x
    ldd     #movePatEx
    std     SpriteMovePat,x
    
    ldaa    #SpriteTypeEnemy
    staa    SpriteType,x
    ldd     #$0500
    std     SpritePointValue,x
    ldd     #extraAdd
    std     SpriteKillFunc,x
    rts
    
;----------------------------------------
;e1Create
;Create an instance of enemy1
;'W0' = pointer to sprite
;----------------------------------------
.module E1Create

e1Create:
    ;set w/h & speed here, spriteSetup needs them.
    ldx     W0
    ldaa    #6
    staa    SpriteWidth,x
    ldaa    #2
    staa    SpriteHeight,x
    ldaa    stageSpeed
    staa    AdderLow
    ldd     #50
    subd    Adder
    std     SpriteSpeed,x
    
    
    ldd     #eShot0Create
    std     SpriteShotFunc,x
    ldaa    #1
    staa    SpriteShotsLeft,x
    
    ;calc x,y
    jsr     rndGet
    anda    #%111110             ;get random X, force even
    cmpa    #58
    bls     _xOk
    ldaa    #58
    
_xOk:
    adda    #PlayfieldX1
    ldab    #PlayfieldY1-8
    ldx     W0
    jsr     spriteSetup
    
    ldaa    #DirDown
    staa    SpriteDir,x
    ldd     #e1FrameSeq0
    std     SpriteFrameSeq,x
    std     SpriteFramePtr,x
    ldaa    #e1FrameCount
    staa    SpriteFrameCount,x
    ldd     #e1Delays0
    std     SpriteFrameDels,x
    ldd     #movePatE1
    std     SpriteMovePat,x
    
    ldaa    #SpriteTypeEnemy
    staa    SpriteType,x
    ldd     #$0150
    std     SpritePointValue,x
    ldd     #scoreAddEnemy
    std     SpriteKillFunc,x
    rts
;----------------------------------------
;e2Create
;Create an instance of enemy2
;'W0' = pointer to sprite
;----------------------------------------
.module E2Create

e2Create:
    ;set w/h & speed here, spriteSetup needs them.
    ldx     W0
    ldaa    #8
    staa    SpriteWidth,x
    ldaa    #2                  ;lie so it doesn't collide with player too soon
    staa    SpriteHeight,x
    ldaa    stageSpeed
    staa    AdderLow
    ldd     #50
    subd    Adder
    std     SpriteSpeed,x
    
    ldd     #eShot0Create
    std     SpriteShotFunc,x
    ldaa    #1
    staa    SpriteShotsLeft,x
    
    ;calc x,y
    jsr     rndGet
    bita    #1
    beq     _leftSide
_rightSide:    
    ldaa    #DirLeft
    staa    SpriteDir,x
    ldaa    #PlayfieldX1
    staa    SpriteB2,x
    ldaa    #PlayfieldX2
    suba    SpriteWidth,x
    bra     _xOk
_leftSide:
    ldaa    #DirRight
    staa    SpriteDir,x
    ldaa    #PlayfieldX2
    suba    SpriteWidth,x
    inca
    staa    SpriteB2,x
    ldaa    #PlayfieldX1
    
_xOk:
    ldab    #PlayfieldY1
    ldx     W0
    jsr     spriteSetup
    
    ldd     #e2FrameSeq0
    std     SpriteFrameSeq,x
    std     SpriteFramePtr,x
    ldaa    #e2FrameCount
    staa    SpriteFrameCount,x
    ldd     #e2Delays0
    std     SpriteFrameDels,x
    ldd     #movePatE2
    std     SpriteMovePat,x
    
    ldaa    #SpriteTypeEnemy
    staa    SpriteType,x
    ldd     #$0150
    std     SpritePointValue,x
    ldd     #scoreAddEnemy
    std     SpriteKillFunc,x
    
    rts
    
;----------------------------------------
;e3Create
;Create an instance of enemy3
;'W0' = pointer to sprite
;----------------------------------------
.module E3Create

e3Create:
    ;set w/h & speed here, spriteSetup needs them.
    ldx     W0
    ldaa    #8
    staa    SpriteWidth,x
    ldaa    #4
    staa    SpriteHeight,x
    ldaa    stageSpeed
    staa    AdderLow
    ldd     #65
    subd    Adder
    std     SpriteSpeed,x
    
    ldd     #eShot1Create
    std     SpriteShotFunc,x
    ldaa    #1
    staa    SpriteShotsLeft,x
    
    ;calc x, drop y
    ldaa    SpriteIndex,x
    lsla
    lsla
    adda    #PlayfieldY1
    staa    SpriteB2,x
    ldaa    #28
    jsr     rndGetMax
    lsla
    adda    #PlayfieldX1
    anda    #%11111110
    
_xOk:
    ldab    #PlayfieldY1-4
    ldx     W0
    jsr     spriteSetup
    
    ldd     #e3FrameSeq0
    std     SpriteFrameSeq,x
    std     SpriteFramePtr,x
    ldaa    #e3FrameCount
    staa    SpriteFrameCount,x
    ldd     #e3Delays0
    std     SpriteFrameDels,x
    ldd     #movePatE3
    std     SpriteMovePat,x
    
    ldaa    #SpriteTypeEnemy
    staa    SpriteType,x
    ldd     #$0200
    std     SpritePointValue,x
    ldd     #scoreAddEnemy
    std     SpriteKillFunc,x
    
    rts
;----------------------------------------
;e4Create
;Create an instance of enemy4
;'W0' = pointer to sprite
;----------------------------------------
.module E4Create

e4Create:
    ;set w/h & speed here, spriteSetup needs them.
    ldx     W0
    ldaa    #10
    staa    SpriteWidth,x
    ldaa    #6
    staa    SpriteHeight,x
    ldaa    stageSpeed
    staa    AdderLow
    ldd     #100
    subd    Adder
    std     SpriteSpeed,x
    
    ldd     #eShot0Create
    std     SpriteShotFunc,x
    ldaa    #1
    staa    SpriteShotsLeft,x
    
    ;calc x, drop y
    ldaa    #26
    jsr     rndGetMax
    lsla
    adda    #PlayfieldX1
    anda    #%11111110
    
_xOk:
    ldab    #PlayfieldY1-8
    ldx     W0
    jsr     spriteSetup
    
    ldd     #e4FrameSeq0
    std     SpriteFrameSeq,x
    std     SpriteFramePtr,x
    ldaa    #e4FrameCount
    staa    SpriteFrameCount,x
    ldd     #e4Delays0
    std     SpriteFrameDels,x
    ldd     #movePatE4
    std     SpriteMovePat,x
    
    ldaa    #SpriteTypeEnemy
    staa    SpriteType,x
    ldd     #$0250
    std     SpritePointValue,x
    ldd     #scoreAddEnemy
    std     SpriteKillFunc,x
    jsr     rndGet
    anda    #%11
    oraa    #%01                    ;x = rnd, y = 1
    staa    SpriteB2,x
    rts
    
;========================================
;Game Modes
;========================================
;----------------------------------------
;openScreenShipDraw
;Display ship on opening screen
;'a' = x
;----------------------------------------
.module OpenScreenShipDraw

openScreenShipDraw:
    ldab    #$1d
    ldx     #playerOpenScreenFrame
    jsr     drawBoundFrame
    rts
;----------------------------------------
;openScreenShipErase
;Erase ship on opening screen
;'a' = x
;----------------------------------------
.module OpenScreenShipErase

openScreenShipErase:
    ldab    #$1d
    ldx     #eraseOpenScreenFrame
    jsr     drawBoundFrame
    rts
;----------------------------------------
;openScreenShipMove
;Display ship on opening screen
;'a' = from X
;'b' = to X
;----------------------------------------
.module OpenScreenShipMove
_curX       .equ    B0
_destX      .equ    B1
openScreenShipMove:
    staa    _curX
    stab    _destX
_loop:    
    ldaa    _curX
    ldab    #$1d
    ldx     #playerOpenScreenFrame
    jsr     drawBoundFrame
    ldd     #50
    jsr     clockWait
    ldaa    _curX
    ldab    #$1d
    ldx     #eraseOpenScreenFrame
    jsr     drawBoundFrame
    inc     _curX
    ldaa    _curX
    cmpa    _destX
    bls     _loop
    ldaa    _curX
    ldab    #$1d
    ldx     #playerOpenScreenFrame
    jsr     drawBoundFrame
    rts
;----------------------------------------
;openScreenShootString
;Shoot a string from the ship to the top of screen.
;'a' = x (0-63)
;'x' = string
;----------------------------------------
.module OpenScreenShootString
_rowCnt     .equ    B0
_rowsLeft   .equ    B1
_chr        .equ    B2
_stringPtr  .equ    W0
_screenHome .equ    W1
_screenPtr  .equ    W2

openScreenShootString:
    stx     _stringPtr
    lsra
    psha
    ldd     #VideoRAMEnd
    subd    #BytesPerRow*3
    std     _screenPtr
    ldx     _screenPtr      ;point right above ship
    inx
    pulb
    abx
    stx     _screenPtr
    stx     _screenHome

    ldaa    #14
    staa    _rowCnt
    
_chrLoop:        
    dec     _rowCnt
    ldx     _stringPtr
    ldaa    ,x
    beq     _done
    cmpa    #'a'
    blo     _doChar
    cmpa    #'z'
    bhi     _doChar
    suba    #96

_doChar:
    staa    _chr
    inx     
    stx     _stringPtr
    ldx     _screenHome
    stx     _screenPtr
    ldaa    _rowCnt
    staa    _rowsLeft
    ldx     #soundFire
    jsr     soundPlay
    
_moveLoop:    
    ldx     _screenPtr
    ldaa    _chr
    staa    ,x
    ldd     #15
    jsr     clockWait
    dec     _rowsLeft
    beq     _chrLoop
    
    ldx     _screenPtr
    ldaa    #$80
    staa    ,x
    ldd     _screenPtr
    subd    #BytesPerRow
    std     _screenPtr
    bra     _moveLoop
        
_done:
    rts
    
;----------------------------------------
;modeOpenScreen
;Display opening screen, wait for enter key to start.
;----------------------------------------
.module ModeOpenScreen
_row        .byte   0

modeOpenScreen:
    jsr     statusBarClear
    jsr     clearPlayfield
    
    ldaa    #$00
    ldx     #stringTitle
    jsr     stringWriteCentered

    ldaa    #$00
    jsr     openScreenShipDraw
    ldd     #1000
    jsr     clockWait
    ldaa    #$00
    jsr     openScreenShipErase

    ldaa    #1
    ldab    #22
    jsr     openScreenShipMove

    ldaa    #24
    ldx     #stringTitle1
    jsr     openScreenShootString    

    ldaa    #22
    ldab    #26
    jsr     openScreenShipMove

    ldaa    #28
    ldx     #stringTitle2
    jsr     openScreenShootString    

    ldaa    #26
    ldab    #30
    jsr     openScreenShipMove

    ldaa    #32
    ldx     #stringTitle3
    jsr     openScreenShootString    
    
    ldaa    #30
    ldab    #34
    jsr     openScreenShipMove

    ldaa    #36
    ldx     #stringTitle4
    jsr     openScreenShootString    

    ldaa    #34
    jsr     openScreenShipErase
    
    ldaa    #30
    jsr     openScreenShipDraw

    ldaa    #$07
    staa    _row
    
    ldx     #stringHighScore 
    jsr     stringWriteCentered
    ldaa    #23
    ldab    _row
    jsr     scoreDisplayHighScore
    inc     _row
    
    ldaa    _row
    ldx     #stringLeftRight
    jsr     stringWriteCentered
    inc     _row
    
    ldaa    _row
    ldx     #stringFire
    jsr     stringWriteCentered
    inc     _row
    
    ldaa    _row
    ldx     #stringBreak
    jsr     stringWriteCentered
    inc     _row
    
    ldaa    _row
    ldx     #stringStart
    jsr     stringWriteCentered
    inc     _row
    inc     _row
    
    ldaa    _row
    ldx     #stringAuthor
    jsr     stringWriteCentered
    ldaa    _row
    ldx     #stringAuthor
    jsr     stringWriteCentered

    ldd     #$1b00
    ldx     #stringVersion
    jsr     stringWrite
    
    
_waitEnter:    
    jsr     keyboardScanMenu
    tst     keyEnterDown
    beq     _waitEnter
    jmp     _start
    
_start:
    ldaa    #GameModePlayInit
    staa    gameMode
    rts
    
;----------------------------------------
;modePlayInit
;Init screen, sprites, etc. for game play.
;----------------------------------------
.module ModePlayInit

modePlayInit:
    
    jsr     clearPlayfield
    jsr     spritesInit
    ldd     #0
    std     score
    std     scoreHigh
    staa    extraValue
    staa    extraFlashCount

    jsr     statusBarDraw
    ldaa    #LivesStart
    staa    lives
    jsr     statusBarUpdateLives
    
    ldaa    #StageStart
    staa    stageCurrent
    staa    stageCurrentBCD
    staa    playerAllowFire

    ldaa    #GameModeStageInit
    staa    gameMode
    
    rts
;----------------------------------------
;modeStageInit
;Initialize the stage.
;----------------------------------------
.module ModeStageInit

modeStageInit:
    ldab    stageCurrent
    decb
    lslb
    ldx     #stageArray
    abx
    ldx     ,x
    stx     stageData
    ldaa    StageSpeed,x
    staa    stageSpeed
    ldaa    StageType,x
    staa    stageType
    ldaa    StageSeconds,x
    staa    stageSecondsLeft
    jsr     statusBarUpdateTimer
    
    ldd     #1000
    std     stageTimer
    
    ldaa    #GameModeStageIntro
    staa    gameMode

    ldaa    stageCurrent
    cmpa    #1
    bne     _regSpawn       ;no extra on stage 1
    ldd     #$ffff  
    std     extraSpawnTimer
    rts
    
_regSpawn:
    ldd     #ExtraSpawnTimeout/2
    std     extraSpawnTimer
    
    rts
    
;----------------------------------------
;modeStageIntro
;Displaying the stage # to user.
;----------------------------------------
.module ModeStageIntro
_delay      .word   $0000
_cnt        .byte   $00

modeStageIntro:

    clr     playerAllowFire
    ldaa    #7
    ldx     #stringStage
    jsr     stringWriteCentered
    ldaa    #9
    ldx     stageData
    ldab    #StageTitle
    abx
    jsr     stringWriteCentered
    ldaa    #18
    ldab    #7
    ldx     #stageCurrent
    jsr     stringWriteByte
    
    ldaa    #3
    staa    _cnt
_playSound:
    ldx     #soundStageIntro
    jsr     soundPlay
    ldd     #1000
_wait: 
    std     _delay
    jsr     clockUpdate
    jsr     keyboardScan
    jsr     spriteUpdateAll
    
    ldd     _delay
    subd    deltaMS
    bcc     _wait
    dec     _cnt
    bne     _playSound
    
    inc     playerAllowFire
    jsr     stageIntroClear

    ldx     stageData
    ldaa    StageType,x
    cmpa    #2
    beq     _type2
_type1:    
    ldaa    #GameModeStagePlay
    staa    gameMode
    rts
_type2:    
    clr     playerAllowFire
    ldaa    #GameModeStageBonus
    staa    gameMode
    rts
    
;----------------------------------------
;stageTimerUpdate
;Update the seconds left and status bar
;returns 'a'=1 if stage changes
;----------------------------------------
.module StageTimerUpdate

stageTimerUpdate:
    ldaa    stageCurrent    ;last level = infinite
    cmpa    #StageMax
    bne     _cont
    clra
    rts
_cont:
    ldd     stageTimer
    subd    deltaMS
    bcc     _noSec
    dec     stageSecondsLeft
    bne     _secsLeft
    jsr     statusBarUpdateTimer
    ldaa    #GameModeStageOver
    staa    gameMode
    ldaa    #1
    rts
    
_secsLeft
    jsr     statusBarUpdateTimer
    ldaa    stageSecondsLeft
    cmpa    #5
    bhi     _noSound
    ldx     #soundTimerExpiring    
    jsr     soundPlay
_noSound:
    ldd     #1000
_noSec:
    std     stageTimer
    clra    
    rts
    
;----------------------------------------
;modeStagePlay
;The main game play mode. 
;----------------------------------------
.module ModeStagePlay

modeStagePlay:

    ldd     enemyDelay
    std     enemyTimer
    
_mainLoop:
    jsr     clockUpdate
    jsr     stageTimerUpdate
    tsta    
    beq     _cont
    rts
_cont:

    ldd     extraSpawnTimer
    beq     _noDecSpawn
    subd    deltaMS
    std     extraSpawnTimer
    bhi     _noDecSpawn
    ldd     #0
    std     extraSpawnTimer
    
_noDecSpawn:
    tst     extraFlashCount
    beq     _noExtraFlash
    ldd     extraTimer
    subd    deltaMS
    std     extraTimer
    bcc     _noExtraFlash
    ldx     #soundExtraLife
    jsr     soundPlay
    ldaa    extraValue
    eora    #$1f
    dec     extraFlashCount
    bne     _exNotDone
    clra
_exNotDone:
    staa    extraValue
    jsr     statusBarUpdateExtra
    ldd     #ExtraTimeout
    std     extraTimer
    
_noExtraFlash:    
    jsr     keyboardScan
    tst     keyBreakDown
    beq     _noPause
    
    ldaa    #GameModePause
    staa    gameMode
    rts
    
_noPause:    
    ldd     enemyTimer
    subd    deltaMS
    std     enemyTimer
    bcc     _noEnemy
    ldd     enemyDelay
    std     enemyTimer
    jsr     spawnEnemy
    
_noEnemy:
    jsr     spriteUpdateAll
    ldx     #playerSprite
    tst     SpriteActive,x
    beq     _doLives
    jmp     _mainLoop
    
_doLives:    
    ldaa    lives
    beq     _gameOver
    deca    
    staa    lives
    jsr     statusBarUpdateLives
    ldaa    #1
    jsr     spriteSuicideAll
    jsr     playerInit
    ldaa    #GameModeStageIntro
    staa    gameMode
    rts

_gameOver:    
    ldaa    #GameModeGameOver
    staa    gameMode
_done:
    rts
    
;----------------------------------------
;ebCreate
;Create an instance of enemyB (bonus stage item). Also uses eShot sprites.
;'W0' = pointer to sprite
;'a' = x
;'b' = y
;----------------------------------------
.module EBCreate

ebCreate:
    ;set w/h & speed here, spriteSetup needs them.
    ldx     W0
    psha
    pshb
    ldaa    #2
    staa    SpriteWidth,x
    ldaa    #2
    staa    SpriteHeight,x

    ldd     #25
    std     SpriteSpeed,x
    pulb
    pula
    
    ldx     W0
    jsr     spriteSetup
    
    ldaa    #DirDown
    staa    SpriteDir,x
    ldd     #ebFrameSeq0
    std     SpriteFrameSeq,x
    std     SpriteFramePtr,x
    ldaa    #ebFrameCount
    staa    SpriteFrameCount,x
    ldd     #ebDelays0
    std     SpriteFrameDels,x
    ldd     #movePatE0
    std     SpriteMovePat,x
    
    ldaa    #SpriteTypeEShot
    staa    SpriteType,x
    ldd     #$0100
    std     SpritePointValue,x
    ldd     #scoreAddBonus
    std     SpriteKillFunc,x
    rts
;----------------------------------------
;modeStageBonus
;The bonus stage
;----------------------------------------
.module ModeStageBonus
_xPos   .byte   $00
_cnt    .byte   $00
_dir    .byte   $00
_speed  .equ    6

modeStageBonus:

    clr     _cnt
    ldaa    #PlayfieldX1+(PlayfieldWidth/2)
    anda    #%1111110
    staa     _xPos
    ldaa    #DirRight
    staa    _dir
   
_mainLoop:
    jsr     clockUpdate
    jsr     stageTimerUpdate
    tsta    
    beq     _cont
    rts
_cont:
    jsr     keyboardScan
    tst     keyBreakDown
    beq     _noPause
    ldaa    #GameModePause
    staa    gameMode
    rts
    
_noPause:    
    ldd     enemyTimer
    beq     _spawn
    subd    deltaMS
    std     enemyTimer
    bcs     _np1
    jmp     _noEnemy
_np1:
    ldd     #0
    std     enemyTimer
_spawn:
    ldaa    #EnemyCount+EShotCount
    ldx     enemySprites
    jsr     spriteGetInactive
    cpx     #0
    beq     _noEnemy
    stx     W0
    
    tst     _cnt
    bne     _noNewCnt
    jsr     rndGet
    anda    #%111
    staa    _cnt
_noNewCnt:    
    dec     _cnt
    ldaa    _dir
    cmpa    #DirRight 
    beq     _goRight
_goLeft:
    ldaa    _xPos
    suba    #_speed
    cmpa    #PlayfieldX1
    bhs     _left1
    ldaa    #PlayfieldX1
    staa    _xPos
    clr     _cnt
    bra     _reverse
_left1:
    staa    _xPos
    tst     _cnt
    bne     _spawnIt
    bra     _reverse
    
_goRight:    
    ldaa    _xPos
    adda    #_speed
    cmpa    #PlayfieldX1+PlayfieldWidth-2
    bls     _right1
    ldaa    #PlayfieldX1+PlayfieldWidth-2
    staa    _xPos
    clr     _cnt
    bra     _reverse
_right1:
    staa    _xPos
    tst     _cnt
    bne     _spawnIt
    
_reverse:
    ldaa    _dir
    cmpa    #DirRight 
    beq     _revL
    ldaa    #DirRight
    bra     _revDone
_revL:
    ldaa    #DirLeft
_revDone:
    staa    _dir
    bra     _spawnIt

_spawnIt:
    ldaa    _xPos
    ldab    #PlayfieldY1-2
    jsr     ebCreate
    ldaa    stageSpeed
    ldab    #3
    mul
    std     Adder
    ldd     #225
    subd    Adder
    std     enemyTimer
    
_noEnemy:
    jsr     spriteUpdateAll
    jmp     _mainLoop

_done:
    rts
;----------------------------------------
;modeStageOver
;Suicide all sprites then go to next stage.
;----------------------------------------
.module ModeStageOver
_cnt    .byte    0

modeStageOver:

    clra    
    jsr     spriteSuicideAll
    
    ldaa    stageCurrent
    inca
    cmpa    #StageMax
    bls     _nextStage
    ldaa    #GameModeGameOver
    staa    gameMode
    rts
    
_nextStage:    
    staa    stageCurrent
    ldaa    #GameModeStageInit
    staa    gameMode
_done:
    rts
;----------------------------------------
;modePause
;----------------------------------------
.module ModePause

modePause:

    jsr     statusBarClear
    ldd     #$0000
    ldx     #stringPause
    jsr     stringWrite
    
_loop:
    ldd     #100
    jsr     clockWait
    jsr     keyboardScanMenu
    tst     keyBreakDown        ;wait for break not down
    bne     _loop
    tst     keyEnterDown
    bne     _resume
    tst     keyQDown
    bne     _quit
    bra     _loop
    
_quit:
    ldaa    #GameModeGameOver
    staa    gameMode
    bra     _updateStatus
    
_resume:    
    ldaa    #GameModeStagePlay
    staa    gameMode
    
_updateStatus:
    jsr     statusBarDraw
    jsr     statusBarUpdateScore
    jsr     statusBarUpdateLives
    jsr     statusBarUpdateTimer
    jsr     statusBarUpdateExtra
    rts
;----------------------------------------
;modeGameOver
;----------------------------------------
.module ModeGameOver
_timeOut    .byte   20
_cnt        .byte   0
_leftSpin   .word   $0000
_rightSpin  .word   $0000
_screenPtr  .word   $0000
_Delay      .equ    75
_Sc1        .equ    47
_Sc2        .equ    45
_Sc3        .equ    28
_Sc4        .equ    33

modeGameOver:
    ldaa    #1                  ;suicide player also
    jsr     spriteSuicideAll
    
    ldd     scoreHigh       
    subd    highScoreHigh
    beq     _checkLow
    bcc     _newHigh        ;score hi > highScore hi
    bra     _noNewHigh      ;score hi < highScore hi
_checkLow:
    ldd     score
    subd    highScore
    beq     _noNewHigh
    bcc     _newHigh        ;score > highScore
_noNewHigh:
    ldaa    #8
    ldx     #stringGameOver
    jsr     stringWriteCentered
    ldd     #3000
    jsr     clockWait
    jmp     _done

_newHigh:
    ldd     score
    std     highScore
    ldd     scoreHigh
    std     highScoreHigh

    ldaa    #7
    ldx     #stringGameOver
    jsr     stringWriteCentered
    ldaa    #9
    ldx     #stringNewHighScore
    jsr     stringWriteCentered
    ldaa    #25
    ldab    #9
    jsr     scoreDisplayHighScore
    ldaa    #15
    staa    _timeOut

_highlight:    
    ldaa    #BytesPerRow
    ldab    #9                  ;row
    mul
    addd    #VideoRAM
    addd    #5                  ;col
    std     _screenPtr
    subd    #1
    std     _leftSpin
    addd    #22
    std     _rightSpin
_hiLoop:
    ldx     _screenPtr
    ldaa    #21
    staa    _cnt
_loop:    
    ldaa    ,x
    cmpa    #64
    blo     _isLower
    suba    #64
    bra     _doChr
_isLower:
    adda    #64
_doChr:
    staa    ,x
    inx 
    dec     _cnt
    bne     _loop

    pshx    
    ldaa    #_Sc1
    ldx     _leftSpin
    staa    ,x
    ldaa    #_Sc4
    ldx     _rightSpin
    staa    ,x
    ldd     #_Delay
    jsr     clockWait
    ldaa    #_Sc2
    ldx     _leftSpin
    staa    ,x
    ldaa    #_Sc3
    ldx     _rightSpin
    staa    ,x
    ldd     #_Delay
    jsr     clockWait
    ldaa    #_Sc3
    ldx     _leftSpin
    staa    ,x
    ldaa    #_Sc2
    ldx     _rightSpin
    staa    ,x
    ldd     #_Delay
    jsr     clockWait
    ldaa    #_Sc4
    ldx     _leftSpin
    staa    ,x
    ldaa    #_Sc1
    ldx     _rightSpin
    staa    ,x
    ldd     #_Delay
    jsr     clockWait

    pulx
    dec     _timeOut
    beq     _done
    bra     _hiLoop
    
_done:    
    ldaa    #GameModeOpenScreen
    staa    gameMode
    rts
    
    
;========================================
;Actor inits and movement patterns
;========================================
;pShotInit
;Initialize a pShot sprite
;'x' = pointer to sprite
;'a' = x
;'b' = y
;----------------------------------------
.module PShotInit

pShotInit:
    jsr     spriteSetup
    
    ldd     #pShotFrameSeq0
    std     SpriteFrameSeq,x
    std     SpriteFramePtr,x
    ldaa    #pShotFrameCount
    staa    SpriteFrameCount,x
    ldd     #pShotDelays0
    std     SpriteFrameDels,x
    ldd     #movePatPShot
    std     SpriteMovePat,x
    ldaa    #2
    staa    SpriteWidth,x
    ldaa    #1
    staa    SpriteHeight,x
    ldd     #35
    std     SpriteSpeed,x
    std     SpriteSpeedCount,x
    ldaa    #DirUp
    staa    SpriteDir,x
    ldaa    #SpriteTypePShot
    staa    SpriteType,x
    ldd     #0
    std     SpriteKillFunc,x
    rts
    
;----------------------------------------
;movePatPShot
;Default movement pattern for pShots.
;----------------------------------------
.module MovePatPShot

movePatPShot:
    ldx     W0
    ldab    SpriteY,x
    decb    
    cmpb    #PlayfieldY1
    bhs     _move
    jsr     spriteKill
    rts
    
_move:
    ldaa    SpriteX,x
    jsr     spriteMove
    ldaa    SpriteY,x
    cmpa    #PlayfieldY2-3
    blo     _checkCollide
    ldaa    #1
    staa    playerNeedDraw
    
_checkCollide:    
    ldaa    #EnemyCount
    staa    B0
    ldd     enemySprites
    jsr     spriteCollisionTest
    cpx     #0
    beq     _done
    jsr     spriteKill
_done:
    rts
    
;----------------------------------------
;playerInit
;Initialize the player player
;----------------------------------------
.module PlayerInit

playerInit:
    ldx     #playerSprite
    ldaa    #PlayfieldX1+(PlayfieldWidth/2) - 2
    ldab    #PlayfieldY2-3
    jsr     spriteSetup

    ldaa    #DirRight
    staa    playerDir
    ldd     #playerDelays0
    std     playerFrameDels
    ldd     #playerFrameSeq0
    std     playerFramePtr
    ldd     #movePatPlayer
    std     playerMovePat
    ldd     #PlayerDefaultSpeed
    std     playerSpeed
    std     playerSpeedCount
    ldaa    #SpriteTypePlayer
    staa    playerSpriteType
    ldd     #0
    std     playerKillFunc
    rts
    
;----------------------------------------
;movePatPlayer
;Player movement by user
;----------------------------------------
.module MovePatPlayer

movePatPlayer:
    ldx     W0
    
    ldaa    keyLeftDown
    beq     _checkRight
    ldaa    SpriteX,x
    cmpa    #PlayfieldX1
    bhi     _doLeft
    jmp     _checkFire
    
_doLeft:    
    ldaa    SpriteX,x
    deca    
    ldab    SpriteY,x
    jsr     spriteMove
    ldaa    #DirLeft
    staa    SpriteDir,x
    bra     _checkFire
    
_checkRight:
    ldaa    keyRightDown
    beq     _checkFire
    
_doRight:
    ldaa    SpriteX,x
    adda    SpriteWidth,x
    cmpa    #PlayfieldX2
    bhi     _checkFire
    
    ldaa    SpriteX,x
    inca    
    ldab    SpriteY,x
    jsr     spriteMove
    
    ldaa    #DirRight
    staa    SpriteDir,x
    
_checkFire:
    ldaa    pShotFireCount
    beq     _fireOk
    dec     pShotFireCount
    beq     _fireOk
    bra     _done
    
_fireOk:    
    tst     playerAllowFire
    beq     _done
    ldaa    keyFireDown
    beq     _done
    ldaa    pShotFireDelay
    staa    pShotFireCount
    
    ldaa    #PShotCount
    ldx     pShotSprites
    jsr     spriteGetInactive
    cpx     #0
    beq     _done

    ldaa    playerX
    adda    #2
    ldab    playerY
    subb    #1
    jsr     pShotInit
    ldaa    #1
    staa    SpriteActive,x
    staa    SpriteNeedDraw,x
    ldx     #soundFire
    jsr     soundPlay

_done:
    rts
    
;----------------------------------------
;movePatPlayerDeath
;Player death sequence
;----------------------------------------
.module MovePatPlayerDeath

movePatPlayerDeath:
    ldx     W0
    ldaa    SpriteStage,x
    beq     _stage0
    cmpa    #1
    beq     _stage1
    bra     _stage2
    
_stage0:    
    ldd     #deathDelays       ;stop animating (very long delays)
    std     SpriteFrameDels,x
    ldd     #40                 ;flash rate
    std     SpriteSpeed,x       
    std     SpriteSpeedCount,x
    ldaa    #10                  ;flash count
    staa    SpriteB0,x
    inc     SpriteStage,x
    ldx     #soundPlayerDeath
    jsr     soundPlay
    rts

_stage1:    
    ldaa    #OrangePixel
    staa    SpriteAltColor,x
    ldaa    #1
    staa    SpriteNeedDraw,x
    inc     SpriteStage,x
    rts
    
_stage2:
    clr     SpriteAltColor,x
    dec     SpriteB0,x
    beq     _kill
    ldaa    #1
    staa    SpriteNeedDraw,x
    dec     SpriteStage,x
     rts
_kill:
    ldaa    #SpriteTypeNone
    staa    SpriteType,x        ;so it won't reset death sequence
    jsr     spriteKill
    rts

;----------------------------------------
;movePatEnemyDeath
;Enemy death sequence
;----------------------------------------
.module MovePatEnemyDeath

movePatEnemyDeath:
    ldx     W0
    ldaa    SpriteStage,x
    beq     _stage0
    cmpa    #1
    beq     _stage1
    bra     _stage2
    
_stage0:    
    ldd     #deathDelays       ;stop animating (very long delays)
    std     SpriteFrameDels,x
    ldd     #40                 ;flash rate
    std     SpriteSpeed,x       
    std     SpriteSpeedCount,x
    ldaa    #3                  ;flash count
    staa    SpriteB0,x
    inc     SpriteStage,x
    
    ldd     #exFrameSeq0        ;check if extra life enemy
    subd    SpriteFrameSeq,x    
    bne     _notExtra
    ldaa    #255                ;orange full block
    ldx     #exFrame0_0
    staa    3,x
    ldx     #exFrame1_0
    staa    3,x
    ldx     #exFrame2_0
    staa    3,x
    ldx     #exFrame3_0
    staa    3,x
    
_notExtra:    
    ldx     #soundEnemyDeath
    jsr     soundPlay
    rts

_stage1:    
    ldaa    #BuffPixel
    staa    SpriteAltColor,x
    ldaa    #1
    staa    SpriteNeedDraw,x
    inc     SpriteStage,x
    rts
    
_stage2:
    clr     SpriteAltColor,x
    dec     SpriteB0,x
    beq     _kill
    ldaa    #1
    staa    SpriteNeedDraw,x
    dec     SpriteStage,x
     rts
_kill:
    ldaa    #SpriteTypeNone
    staa    SpriteType,x        ;so it won't reset death sequence
    jsr     spriteKill
    rts
    
;----------------------------------------
;movePatE0
;Fall off screen and die.
;W0 = pointer to srpite
;----------------------------------------
.module MovePatE0

movePatE0:
    ldx     W0
    
    ldaa    SpriteStage,x
    cmpa    #1
    beq     _stage1
    
_stage0:    
    ldaa    #PlayfieldY2+2      ;row to die
    staa    SpriteB2,x
    inc     SpriteStage,x
    rts
    
_stage1:
    jsr     seqDownToY
    tsta
    beq    _done
    jsr     spriteSuicide
_done:
    rts
;========================================
;Collision detect and resolve functions
;========================================
;eShotCollisionTest
;Test for a collision between eShots and player
;Kill eShot and player if collided
;----------------------------------------
.module EShotCollisionTest
_idx    .byte   0

eShotCollisionTest:
    ldaa    #EShotCount
    staa    _idx
    ldx     eShotSprites
_eShotLoop:
    ldaa    SpriteActive,x
    beq     _nextEShot
    ldaa    SpriteMoved,x
    beq     _nextEShot
    
    clr     SpriteMoved,x
    ldaa    #1
    staa    B0
    ldd     #playerSprite
    pshx
    jsr     spriteCollisionTest
    cpx     #0
    beq     _eShotCont
    jsr     spriteKill          ;kill player
    pulx
    jsr     spriteKill          ;kill self
    rts     ;bra     _nextEShot
_eShotCont:
    pulx
_nextEShot:
    dec     _idx
    beq     _done
    ldab    #SizeOfSprite
    abx
    bra     _eShotLoop
_done:
    rts

;----------------------------------------
;enemyCollisionTest
;Test for a collision between enemy and player/eShots
;Kill enemys and pShot/player if collided
;----------------------------------------
.module EnemyCollisionTest
_idx    .byte   0

enemyCollisionTest:
    ldaa    #EnemyCount
    staa    _idx
    ldx     enemySprites
_enemyLoop:
    ldaa    SpriteActive,x
    beq     _nextEnemy
    ldaa    SpriteMoved,x
    beq     _nextEnemy
    
    clr     SpriteMoved,x
    ldaa    #PShotCount
    staa    B0
    ldd     pShotSprites
    pshx
    jsr     spriteCollisionTest
    cpx     #0
    beq     _checkShip
    jsr     spriteKill          ;kill shot
    pulx
    jsr     spriteKill          ;kill self
    bra     _nextEnemy
    
_checkShip:
    pulx
    ldaa    #1
    staa    B0
    ldd     #playerSprite
    pshx
    jsr     spriteCollisionTest
    cpx     #0
    beq     _enemyCont
    jsr     spriteKill          ;kill player
    ldx     stageData
    ldaa    StageType,x
    pulx
    
    cmpa    #StageTypeBonus
    beq     _addScore
    ldd     #0
    std     SpritePointValue,x
_addScore:
    jsr     spriteKill          ;kill enemy
    bra     _nextEnemy
_enemyCont:
    pulx
_nextEnemy:
    dec     _idx
    beq     _done
    ldab    #SizeOfSprite
    abx
    bra     _enemyLoop
_done:
    rts

;----------------------------------------
;pShotCollisionTest
;Test for a collision between pShots and enemies
;Kill enemies and pShots if collided
;----------------------------------------
.module PShotCollisionTest
_idx    .byte   0

pShotCollisionTest:

    ldaa    #PShotCount
    staa    _idx
    ldx     pShotSprites
_pShotLoop:
    ldaa    SpriteActive,x
    beq     _nextPShot
    ldaa    SpriteMoved,x
    beq     _nextPShot
    
    clr     SpriteMoved,x
    ldaa    #EnemyCount
    staa    B0
    ldd     enemySprites
    pshx
    jsr     spriteCollisionTest
    cpx     #0
    beq     _pShotCont
    ;ldaa    #1
    jsr     spriteKill          ;set enemy 
    pulx
    jsr     spriteKill          ;kill self
    bra     _nextPShot
_pShotCont:
    pulx
_nextPShot:
    dec     _idx
    beq     _done
    ldab    #SizeOfSprite
    abx
    bra     _pShotLoop
_done:
    rts

;----------------------------------------
;playerCollisionTest
;Test for a collision between player and enemies/eShots
;----------------------------------------
.module PlayerCollisionTest

playerCollisionTest:
    ldaa    playerMoved
    bne     _test1
    rts
_test1:    
    clr     playerMoved
    ldx     #playerSprite
    ldaa    #EnemyCount+EShotCount
    staa    B0
    ldd     enemySprites
    jsr     spriteCollisionTest
    clra
    cpx     #0
    beq     _done
    ldx     #playerSprite
    jsr     spriteKill
_done:
    rts

;----------------------------------------
;spriteCollisionTest
;Test for a collision between sprites
;'x' = source sprite
;'d' =  pointer to sprites to check 
;'B0' = number of sprites to check
;returns x = pointer to first sprite collided with, or 0 if none
;----------------------------------------
.module SpriteCollisionTest
_cnt    .equ    B0
_x1     .equ    B1
_x2     .equ    B2
_y1     .equ    B3
_y2     .equ    B4

spriteCollisionTest:
    std     W0
    ldaa    SpriteX,x
    staa    _x1
    ldaa    SpriteX2,x
    staa    _x2
    ldaa    SpriteY,x
    staa    _y1
    ldaa    SpriteY2,x
    staa    _y2
    ldx     W0
    
_loop:
    tst     SpriteActive,x
    beq     _nextSprite
    
    ldaa    _x1
    cmpa    SpriteX2,x
    bls     _test2
    bra     _nextSprite
_test2:
    ldaa    _x2
    cmpa    SpriteX,x
    bhs     _test3
    bra     _nextSprite
_test3:
    ldaa    _y1
    cmpa    SpriteY2,x
    bls     _test4
    bra     _nextSprite
_test4:
    ldaa    _y2
    cmpa    SpriteY,x
    blo     _nextSprite
    
    ;collided with sprite in X so just return
    rts                     
    
_nextSprite:
    dec     _cnt
    beq     _done
    ldab    #SizeOfSprite
    abx
    bra     _loop
    
_done:
    ldx     #0              ;no collision
    rts
;========================================
;Sprite Functions
;========================================
;spriteGetInactive
;Get a point to the first inactive sprite of a type.
;'a' = sprite count (e.g. PShotCount)
;'x' = pointer to first sprite of the type (e.g. pShotSprites)
;returns pointer in x, or 0 if none available
;----------------------------------------
.module SpriteGetInactive
_cnt        .equ    B0

spriteGetInactive:
    staa    _cnt
    
_next:    
    ldab    SpriteActive,x
    beq     _done
    ldab    #SizeOfSprite
    abx     
    dec     _cnt
    bne     _next
    ldx     #$0000
    
_done:    
    rts

;----------------------------------------
;spriteMove
;Updates x,y, lastX/Y, x2/y2, needDraw, etc.
;'x' = pointer to sprite
;'a' = new x
;'b' = new y
;----------------------------------------
.module SpriteMove

spriteMove:
    psha
    ldaa    SpriteX,x
    staa    SpriteLastX,x
    pula
    staa    SpriteX,x
    adda    SpriteWidth,x
    deca    
    staa    SpriteX2,x
    
    ldaa    SpriteY,x
    staa    SpriteLastY,x
    stab    SpriteY,x
    addb    SpriteHeight,x
    decb    
    stab    SpriteY2,x
    
    ldaa    #1
    staa    SpriteMoved,x
    staa    SpriteNeedDraw,x
    staa    SpriteNeedErase,x
    rts
    
;----------------------------------------
;spriteChangeMovePat
;Change the movement patter of the a sprite.
;'x' =  pointer to sprite
;'d' = address of mseq
;----------------------------------------
;.module SpriteChangeMovePat
;
;spriteChangeMovePat:
;    std     SpriteMovePat,x
;    clr     SpriteStage,x
;    ldd     SpriteSpeed,x
;    std     SpriteSpeedCount,x
;    rts
;----------------------------------------
;spriteSuicideAll
;Kill all sprites, player sprite optional
;'a' = suicide player also (0/1)
;----------------------------------------
.module SpriteSuicideAll
_cnt        .equ    B0

spriteSuicideAll:
_mainLoop:
    ldx     #spriteArray
    ldab    #SpriteCount
    stab    _cnt
    tsta    
    bne     _loop
    decb                ;skip player
    inx 
    inx
    stab    _cnt
_loop:
    pshx
    ldx     ,x
    jsr     spriteSuicide
    pulx
    inx 
    inx
    dec     _cnt
    bne     _loop
    jsr     spriteUpdateAll
    rts
;----------------------------------------
;spriteSuicide
;Same as spriteKill except killFunc not called and death move pat not assigned.
;Used when enemies kill themselves.
;'x' = pointer to sprite
;----------------------------------------
.module SpriteSuicide

spriteSuicide:
    ldaa    #1
    staa    SpriteKillNow,x
    staa    SpriteNeedErase,x
    clr     SpriteNeedDraw,x
    
    ;so it will erase at current x,y
    ldaa    SpriteX,x           
    staa    SpriteLastX,x
    ldaa    SpriteY,x
    staa    SpriteLastY,x
    rts
;----------------------------------------
;spriteKill
;Sets variables so spriteUpdateAll will erase and inactivate sprite
;'x' = pointer to sprite
;'x' is preserved
;----------------------------------------
.module SpriteKill

spriteKill:
    ldaa    SpriteKillNow,x
    bne     _done

    ;tst     SpriteKillFunc,x    ;was it enemy that suicided?
    ;beq     _normalKill
    
    ldaa    SpriteType,x
    cmpa    #SpriteTypeEnemy
    bne     _checkPlayer
    
    ldd     SpriteMovePat,x
    subd    #movePatEnemyDeath
    beq     _doNothing          ;already dying
    ldd     #movePatEnemyDeath
    std     SpriteMovePat,x
    clr     SpriteStage,x
_doNothing:
    rts
    
_checkPlayer:
    ldaa    SpriteType,x
    cmpa    #SpriteTypePlayer
    bne     _normalKill

    ldaa    stageType           ;don't die on bonus stage
    cmpa    #StageTypeBonus
    beq     _doNothing
    
    ldd     SpriteMovePat,x
    subd    #movePatPlayerDeath
    beq     _doNothing           ;already dying
    ldd     #movePatPlayerDeath
    std     SpriteMovePat,x
    clr     SpriteStage,x
    rts
    
_normalKill: 
    ldaa    #1
    staa    SpriteKillNow,x
    staa    SpriteNeedErase,x
    clr     SpriteNeedDraw,x
    
    ;so it will erase at current x,y
    ldaa    SpriteX,x           
    staa    SpriteLastX,x
    ldaa    SpriteY,x
    staa    SpriteLastY,x
    
    tst     SpriteKillFunc,x
    beq     _done
    stx     W0
    pshx
    ldx     SpriteKillFunc,x
    jsr     ,x
    pulx
_done:
    rts
    
;----------------------------------------
;spriteSetup
;Set the common sprite variables
;'x' = pointer to sprite
;'a' = x
;'b' = y
;----------------------------------------
.module SpriteSetup

spriteSetup:
    staa    SpriteX,x
    staa    SpriteLastX,x
    adda    SpriteWidth,x
    deca    
    staa    SpriteX2,x
    
    stab    SpriteY,x
    stab    SpriteLastY,x
    addb    SpriteHeight,x
    decb    
    stab    SpriteY2,x

    ldd     #0
    std     SpriteTimer,x
    staa    SpriteKillNow,x
    staa    SpriteCurFrame,x
    staa    SpriteStage,x
    staa    SpriteAltColor,x
    staa    SpriteNeedErase,x
    
    inca
    staa    SpriteActive,x
    staa    SpriteNeedDraw,x
    
    ldd     #100
    std     SpriteCurCount,x
    
    ldd     SpriteSpeed,x
    std     SpriteSpeedCount,x
    rts
    
;----------------------------------------
;spritesInit - Initialize the sprite variables and default sprites
;----------------------------------------
.module SpritesInit
_cnt        .equ    B0
_arrayPtr   .equ    W0
_dataPtr    .equ    W1

spritesInit:
    ldx     #spriteArray
    stx     _arrayPtr
    
    jsr     playerInit
    ldd     #playerSprite
    ldx     _arrayPtr
    std     ,x
    inx
    inx
    stx     _arrayPtr
    
    ;pShots
    ldaa    pShotFireDelay
    staa    pShotFireCount
    
    ldd     #spriteData
    std     _dataPtr
    std     pShotSprites
    
    ldaa    #PShotCount
    staa    _cnt
    
_pShotLoop:    
    ldd     _dataPtr
    std     ,x
    inx
    inx
    stx     _arrayPtr
    ldx     _dataPtr
    
    ldd     #0
    jsr     pShotInit
    clr     SpriteActive,x
    clr     SpriteNeedDraw,x
    
    dec     _cnt
    beq     _doEnemies

    ldd     _dataPtr
    addd    #SizeOfSprite
    std     _dataPtr
    ldx     _arrayPtr
    bra     _pShotLoop
    
_doEnemies:    
    ldaa    #EnemyCount
    staa    _cnt
    ldd     _dataPtr
    addd    #SizeOfSprite
    std     _dataPtr
    std     enemySprites
    ldx     _arrayPtr
    
_enemyLoop:    
    pshx
    std     ,x
    ldx     ,x
    clr     SpriteActive,x
    psha    
    ldaa    #3
    suba    _cnt
    staa    SpriteIndex,x
    pula
    pulx
    
    inx
    inx
    dec     _cnt
    beq     _doEShots
    addd    #SizeOfSprite
    std     _dataPtr
    bra     _enemyLoop
    
_doEShots:
    ldaa    #EShotCount
    staa    _cnt
    ldd     _dataPtr
    addd    #SizeOfSprite
    std     eShotSprites
    std     _dataPtr
    
_eShotLoop:    
    pshx
    ldx     ,x
    clr     SpriteActive,x
    pulx
    
    std     ,x
    inx
    inx
    dec     _cnt
    beq     _done
    addd    #SizeOfSprite
    std     _dataPtr
    clr     SpriteActive,x
    bra     _eShotLoop

_done:
    rts
    
;----------------------------------------
;spriteUpdateAll
;Move, update and draw all sprites
;----------------------------------------
.module SpriteUpdateAll
_tmpw       .word   $0000
_idx        .byte   $00

spriteUpdateAll:
    ldab    #SpriteCount     ;update sprites in reverse order
    stab    _idx

_spriteLoop:
    ldx     #spriteArray    ;point to sprite[_idx]
    ldab    _idx
    decb
    lslb
    abx
    ldx     ,x
    
    ldaa    SpriteActive,x
    beq     _nextSprite

    ldaa    SpriteKillNow,x
    beq     _noKillI
    clr     SpriteActive,x  ;inactivate here so it can still erase
    bra     _goErase
    
_noKillI:
    ldaa    SpriteFrameCount,x
    cmpa    #1              
    bls     _noFrameUpdate
    pshx
    jsr     spriteUpdateFrame
    pulx
    
_noFrameUpdate:
    pshx
    ldaa    SpriteActive,x
    beq     _moveDone            ;not acive
    ldd     SpriteSpeedCount,x
    beq     _doMove              ;active but timer not used
    
    subd    deltaMS
    beq     _resetCnt
    blo     _adjustCnt 
    std     SpriteSpeedCount,x
    bra     _moveDone
    
_adjustCnt:                     
    ldd     deltaMS
    subd    SpriteSpeedCount,x
    std     W0
    ldd     SpriteSpeed,x
    subd    W0
    bls     _resetCnt
    std     SpriteSpeedCount,x
    bra     _doMove

_resetCnt:
    ldd     SpriteSpeed,x
    std     SpriteSpeedCount,x
    
_doMove:
    stx     W0
    ldx     SpriteMovePat,x
    jsr     ,x
    
_moveDone:
    pulx
_goErase:    
    ldaa    SpriteNeedErase,x
    beq     _checkDraw
    pshx
    jsr     spriteErase
    pulx
    
_checkDraw:
    ldaa    SpriteNeedDraw,x
    beq     _nextSprite
    jsr     spriteDraw
    
_nextSprite:
    dec     _idx
    bne     _spriteLoop

    jsr     playerCollisionTest
    jsr     pShotCollisionTest
    jsr     enemyCollisionTest
    jsr     eShotCollisionTest
    
    rts
    
;----------------------------------------
;spriteUpdateFrame
;Update frame of sprite at 'x'
;'x' should point to sprite data
;SpriteActive is assumed true
;----------------------------------------
.module SpriteUpdateFrame
_tmpw   .equ    W0

spriteUpdateFrame:

    ldd     SpriteCurCount,x
    subd    #1
    std     SpriteCurCount,x
    bne     _done
    
    ldab    SpriteCurFrame,x
    incb
    cmpb    SpriteFrameCount,x
    blt     _updatePtr
    clrb
    
_updatePtr:

    ldaa    #1
    staa    SpriteNeedDraw,x
    
    stab    SpriteCurFrame,x
    pshx    
    ldx     SpriteFrameDels,x
    lslb
    abx
    ldd     ,x
    pulx    
    std     SpriteCurCount,x

    ldab    SpriteCurFrame,x
    pshx    
    ldx     SpriteFrameSeq,x
    lslb
    abx
    stx     _tmpw
    pulx
    ldd     _tmpw
    std     SpriteFramePtr,x
    
_done:
    rts
    
;----------------------------------------
;spriteDraw
;'x' should point to sprite
;----------------------------------------
.module SpriteDraw
_widthHi        .byte   $00     ;Keep these two in order.
_width          .byte   $00     ;Used in 16-bit math.

_height         .byte   $00
_byteCnt        .byte   $00
_altColor       .byte   $00     ;used to flash sprite
_framePtr       .word   $0000
_screenPtr      .word   $0000

spriteDraw:
        clr     SpriteNeedDraw,x
        ldaa    SpriteAltColor,x
        staa    _altColor
        ldaa    SpriteX,x
        ldab    SpriteY,x
        jsr     calcXYAddress
        std     _screenPtr

        ldab    #0
        ldaa    SpriteX,x       ;if x is odd, add 1 to frame pointer
        bita    #1
        beq     _checkY
        incb
_checkY:
        ldaa    SpriteY,x       ;if y is odd, add 2 to frame pointer
        bita    #1
        beq     _frameDone
        incb
        incb
        
_frameDone:
        lslb 
        ldx     SpriteFramePtr,x
        ldx     ,x
        abx                     ;adjust the frame pointer
        ldx     ,x
        
        ldaa    ,x
        staa    _width
        inx     
        ldaa    ,x
        staa    _height
        inx 
        stx     _framePtr
        
_rowLoop:
        ldab    _width
        stab    _byteCnt

        ldd     _screenPtr
        subd    #VideoRAM+BytesPerRow   ;at least row 1 of screen?
        bhs     _rowChk2
        ldd     _framePtr
        addd    _widthHi
        std     _framePtr
        ldd     _screenPtr
        addd    #BytesPerRow
        bra     _nextRoW2
_rowChk2:
        ldd     _screenPtr
        subd    #VideoRAMEnd            ;done if off bottom of screen
        blo     _colLoop
        rts
        
_colLoop:
        ldab    _byteCnt
        cmpb    #1
        beq     _doByte

        ldx     _framePtr       ;draw a word
        ldd     ,x
        tst     _altColor
        beq     _noAltW
        anda    #$0f
        oraa    _altColor
        andb    #$0f
        orab    _altColor
_noAltW:        
        inx
        inx
        stx     _framePtr

        ldx     _screenPtr
        std     ,x
        inx
        inx
        stx     _screenPtr
        
        dec     _byteCnt
        dec     _byteCnt
        bne     _colLoop
        bra     _nextRow
        
_doByte:
        
        ldx     _framePtr       ;draw last byte
        ldaa    ,x
        tst     _altColor
        beq     _noAltB
        anda    #$0f
        oraa    _altColor
        andb    #$0f
        orab    _altColor
_noAltB:        
        inx
        stx     _framePtr
        
        ldx     _screenPtr
        staa    ,x
        inx
        stx     _screenPtr
        
        ;dec     _byteCnt
        ;bne     _colLoop

_nextRow:
        ldd     _screenPtr
        addd    #BytesPerRow
        subd    _widthHi        ;16-bit subtract of _width
_nextRoW2:
        std     _screenPtr
        dec     _height
        beq     _done
        jmp     _rowLoop
_done:
        rts
        
;----------------------------------------
;spriteErase
;'x' should point to sprite
;----------------------------------------
.module SpriteErase
_zero           .byte   $00 ;Keep these two in order.
_width          .byte   $00 ;Used in 16-bit math.
_height         .byte   $00
_byteCnt        .byte   $00
_screenPtr      .word   $0000

spriteErase:
        clr     SpriteNeedErase,x
        ldaa    SpriteLastX,x
        ldab    SpriteLastY,x
        jsr     calcXYAddress
        std     _screenPtr

        ldab    #0
        ldaa    SpriteLastX,x   ;if x is odd, add 1 to frame pointer
        bita    #1
        beq     _checkY
        incb
_checkY:
        ldaa    SpriteLastY,x   ;if y is odd, add 2 to frame pointer
        bita    #1
        beq     _frameDone
        incb
        incb
        
_frameDone:
        lslb
        ldx     SpriteFramePtr,x
        ldx     ,x
        abx                     ;adjust the frame pointer
        ldx     ,x
        
        ldaa    ,x
        staa    _width
        inx     
        ldaa    ,x
        staa    _height
        inx 
        
        ldx     _screenPtr
_rowLoop:
        ldab    _width
        stab    _byteCnt
        ldd     #BackgroundWord

        cpx     #VideoRAM+BytesPerRow   ;at least row 1 of screen?
        bhs     _rowChk2
        ldab    #BytesPerRow
        abx
        bra     _skipRow
_rowChk2:
        cpx     #VideoRAMEnd            ;done if off bottom of screen
        blo    _colLoop
        rts
        
_colLoop:
        ldab    _byteCnt    
        cmpb    #1
        beq     _lastByte

        ldab    #BackgroundByte
        std     ,x          ;erase word at last x,y
        inx
        inx
        dec     _byteCnt
        dec     _byteCnt
        bne     _colLoop
        bra     _nextRow
        
_lastByte:
        staa    ,x          ;erase last byte at last x,y
        inx

_nextRow:
        ldab    #BytesPerRow
        subb    _width
        abx
_skipRow:        
        dec     _height
        bne     _rowLoop
        rts

;----------------------------------------
;Draw bound frame
;'x' should point to frame data.
;'a' should hold x coord
;'b' should hold y coord
;Bound frames are only drawn on even byte x boundaries.
;Playfield is not considered. Whole screen used.
;----------------------------------------
.module DrawBoundFrame
_widthHi    .equ    B3
_width      .equ    B4
_height     .equ    B5
_dest:      .equ    W4

drawBoundFrame:
        clr     _widthHi
        lsra                    ;divide x by 2
        staa    _width
        lsrb                    ;divide y by 2
        ldaa    #BytesPerRow
        mul                     ;multiply y*BytesPerRow
        addd    #VideoRAM
        addd    _widthHi
        std     _dest
        
        ldaa    ,x
        staa    _width
        inx     
        ldaa    ,x
        staa    _height
        inx 
_rowLoop:
        ldab    _width
_colLoop:        
        ldaa    ,x
        inx
        pshx
        ldx     _dest
        staa    ,x
        inx 
        stx     _dest
        pulx
        decb
        bne     _colLoop
        ldd     _dest
        addd    #BytesPerRow
        subd    _widthHi
        std     _dest
        dec     _height
        bne     _rowLoop
        rts
;========================================
;Sound Functions
;========================================
;soundPlay
;Play a sound, if priority is higher than current sound.
;'x' = pointer to sound data
;----------------------------------------
.module SoundPlay

soundPlay:
    ldaa    soundPriority
    beq     _playIt     ;no sound active
    
    cmpa    ,x
    bls     _playIt     ;current priority < new priority? 
    rts
    
_playIt:
    sei
    ldaa    ,x
    staa    soundPriority
    inx
    inx
    stx     soundData
    ldd     #0
    std     soundTicksHigh
    std     soundTicksLow
    std     soundCount
    staa    soundNoToggle
    
    ldd     CPUTicks  ;enable interrupt
    addd    #100
    std     OutCompare
    ldaa    #8              
    staa    TimerControl
    cli
    rts
    
;----------------------------------------
;IRQOutCompare
;Output compare int handler
;----------------------------------------
.module IRQOutCompare

IRQOutCompare:
    ldaa    soundPriority
    bne     _playing
    jmp     _disable
    
_playing:    
    ldd     soundCount
    beq     _waveDone
    subd    #1
    std     soundCount
    bra     _flipBit
    
_waveDone:
    clr     soundNoToggle
    ldx     soundData
    ldd     ,x
    std     soundCount
    beq     _done
    inx     
    inx     
    ldd     ,x
    std     soundTicksHigh
    inx     
    inx     
    ldd     ,x
    bne     _noDelay
    ldaa    #1
    staa    soundNoToggle
    ldd     soundTicksHigh
_noDelay:
    std     soundTicksLow
    inx     
    inx     
    stx     soundData
    ldaa    vdgColorSet
    staa    soundToggle 
    bra     _flipBit
    
_done:
    clr     soundPriority
    ldd     #0
    std     soundTicksHigh
    std     soundTicksLow
    std     soundCount
    std     soundData
    ldaa    vdgColorSet
    staa    soundToggle 
    bra     _disable
    
_flipBit:
    tst     soundNoToggle
    beq     _doToggle
    bra     _goLow          ;delay active, don't toggle
_doToggle:
    ldaa    soundToggle
    eora    #$80
    staa    soundToggle
    staa    VDGReg
    bita    #$80
    bne     _goLow
    ldd     CPUTicks
    addd    soundTicksHigh
    bra     _storeTicks
    
_goLow:
    ldd     CPUTicks
    addd    soundTicksLow
    
_storeTicks:
    std     OutCompare
    ldaa    TimerControl
    ldaa    #8
    staa    TimerControl
    rti

_disable:
    tsx                 ;cli in stacked CC reg
    ldaa    ,x
    oraa    #$10
    staa    ,x
    rti
    
;----------------------------------------
;irqInit
;Initialize the output compare int
;----------------------------------------
.module IRQInit

irqInit:
    ldx     #$4206      ;output compare int vector, standard ROM
    ldaa    $fff4
    cmpa    #$01        ;is it mcx rom?
    bne     _srom
    ldx     #$0106
_srom:
    ldaa    #$7e        ;jmp opcode
    staa    ,x
    inx
    ldd     #IRQOutCompare
    std     ,x
    ;ldd     #OutCompareVal
    ;std     OutCompare
    ;cli
    ;ldaa    #8              ;bit 3 set = OutCompare int2
    ;staa    TimerControl
    rts
    
;========================================
;Score Functions
;========================================
;scoreAddEnemy
;Add an enemies SpritePointValue to the players score.
;----------------------------------------
.module ScoreAddEnemy

scoreAddEnemy:
    ldx     W0
    ldd     SpritePointValue,x
    cmpa    #0
    bne     _add
    cmpb    #0  
    bne     _add
    rts
_add:    
    std     points
    jsr     scoreAddPoints
    rts
;----------------------------------------
;scoreAddBonus
;Add a bonus stage item SpritePointValue to the players score.
;----------------------------------------
.module ScoreAddBonus

scoreAddBonus:
    ldx     W0
    ldd     SpritePointValue,x
    cmpa    #0
    bne     _add
    cmpb    #0  
    bne     _add
    rts
_add:    
    std     points
    jsr     scoreAddPoints
    ldx     #soundBonusItem
    jsr     soundPlay
    rts
    
;----------------------------------------
;scoreDisplayHighScore
;Update the displayed high score on game over.
;'a' = col
;'b' = row
;----------------------------------------
.module ScoreDisplayHighScore
_cnt        .equ    B0
_tmpb       .equ    B1
_screenPtr  .equ    W0

scoreDisplayHighScore:
    staa    AdderLow        ;tmp save col/row
    stab    _tmpb
    ldx     #highScore
    inx                     ;point to byte 0 
    ldaa    _tmpb           ;row
    ldab    #BytesPerRow
    mul
    addd    #VideoRAM
    addd    Adder           ;col
    std     _screenPtr
    ldaa    #3              ;3 bytes of score
    staa    _cnt
_loop:    
    ldaa    ,x
    staa    _tmpb
    anda    #$0f
    adda    #48
    pshx
    ldx     _screenPtr
    staa    ,x
    ldaa    _tmpb
    lsra    
    lsra    
    lsra    
    lsra    
    adda    #48
    dex
    staa    ,x
    dex
    stx     _screenPtr
    pulx
    dex
    dec     _cnt
    bne     _loop
    rts
    
;----------------------------------------
;scoreAddPoints
;Add the BCD value in 'points' to the players score and
;update the displayed score.
;----------------------------------------
.module ScoreAddPoints
_tmpB   .byte    0

scoreAddPoints:
;scoreHigh           .word   $0000  
;score               .word   $0000
;points              .word   $0100

    ldx     #scoreHigh
    ldaa    1,x
    staa    _tmpB
    clc
    ldaa    5,x     ;get byte 0 of points
    adda    3,x     ;add to byte 0 of score
    daa             ;adjust for BCD
    staa    3,x     ;save 
    ldaa    4,x     ;get byte 1 of points
    adca    2,x     ;add w/carry to byte 1 of score
    daa             ;etc...
    staa    2,x     
    ldaa    #0      
    adca    1,x     ;push the carry bit to the last byte
    daa             
    staa    1,x     
    ldaa    #0
    adca    ,x
    daa
    staa    0,x
    jsr     statusBarUpdateScore
    ldaa    _tmpB
    cmpa    1,x
    beq     _done
    inc     lives
    jsr     statusBarUpdateLives
    ldx     #soundExtraLifeLong
    jsr     soundPlay
_done:
    rts
    
;========================================
;Status Bar Functions
;========================================
;----------------------------------------
;statusBarClear
;Clear status bar
;----------------------------------------
.module StatusBarClear
statusBarClear:

    ldx     #VideoRAM
    ldaa    #32
_loop:
    staa    ,x
    inx
    cpx     #VideoRAM+BytesPerRow
    bne     _loop
    rts
    
;----------------------------------------
;statusBarDraw
;Draw status bar
;----------------------------------------
.module StatusBarDraw
statusBarDraw:

    jsr     statusBarClear
    
    ldd     #$0000
    ldx     #stringScore
    jsr     stringWrite
    
    ldd     #$0e00
    ldx     #stringExtra
    jsr     stringWrite

    ldd     #$1700
    ldx     #stringTimer
    jsr     stringWrite
    
    ldd     #$1c00
    ldx     #stringLives
    jsr     stringWrite
    
    rts
;----------------------------------------
;statusBarUpdateScore
;Update the displayed score.
;----------------------------------------
.module StatusBarUpdateScore
_cnt    .equ    B0
_tmpb   .equ    B1

statusBarUpdateScore:
    ldaa    #3      ;3 bytes of score
    staa    _cnt
    ldab    #11     ;11th character of status bar
    ldx     #score
    inx             ;point to byte 0 of score
_loop:    
    ldaa    ,x
    staa    _tmpb
    anda    #$0f
    adda    #48
    pshx
    ldx     #VideoRAM
    abx
    staa    ,x
    ldaa    _tmpb
    lsra    
    lsra    
    lsra    
    lsra    
    adda    #48
    dex
    staa    ,x
    pulx
    dex
    decb
    decb
    dec     _cnt
    bne     _loop
    rts
;----------------------------------------
;statusBarUpdateTimer
;Display seconds left on status bar
;----------------------------------------
.module StatusBarUpdateTimer
_dashdash   .text   "--",0

statusBarUpdateTimer:
    ldaa    stageCurrent    ;last level = infinite
    cmpa    #StageMax
    bne     _cont
    ldd     #$1900
    ldx     #_dashdash
    jsr     stringWrite
    rts
_cont:
    ldd     #$1900
    ldx     #stageSecondsLeft
    jsr     stringWriteByte
    rts
;----------------------------------------
;statusBarUpdateLives
;Display lives left on status bar
;----------------------------------------
.module StatusBarUpdateLives

statusBarUpdateLives:
    ldd     #$1e00
    ldx     #lives
    jsr     stringWriteByte
    rts
;----------------------------------------
;statusBarUpdateExtra
;Display 'extra' letters on status bar
;----------------------------------------
.module StatusBarUpdateExtra
statusBarUpdateExtra:
    ldx     #VideoRAM+15
    ldab    extraValue
    
    ldaa    #'E'
    bitb    #%10000
    bne     _e
    suba    #64
_e:
    staa    ,x
    inx
    
    ldaa    #'X'
    bitb    #%01000
    bne     _x
    suba    #64
_x:
    staa    ,x
    inx

    ldaa    #'T'
    bitb    #%00100
    bne     _t
    suba    #64
_t:
    staa    ,x
    inx
    
    ldaa    #'R'
    bitb    #%00010
    bne     _r
    suba    #64
_r:
    staa    ,x
    inx
    
    ldaa    #'A'
    bitb    #%00001
    bne     _a
    suba    #64
_a:
    staa    ,x
    inx
    
    ;ldd     #$0e00
    ;ldx     #stringExtra
    ;jsr     stringWrite
    rts
;========================================
;Utility Functions
;========================================
;calcXYAddress
;Caonvert x,y to byte address in video RAM
;'a' should hold x coord
;'b' should hold y coord
;Result returned in 'd'
;----------------------------------------
.module CalcXYAddress
_xhi        .byte   $00
_x          .byte   $00

calcXYAddress:
        suba    #PlayfieldX1    ;subtract start of playfield
        lsra                    ;divide x by 2
        staa    _x
        lsrb                    ;divide y by 2
        incb                    ;skip over status bar
        ldaa    #BytesPerRow
        mul                     ;multiply y*BytesPerRow
        addd    #VideoRAM-(BytesPerRow*(PlayfieldY1/2))
        addd    _xhi
        rts
        
;----------------------------------------
;keyboardScan
;Checks for keyLeft,keyRight, keyFire and Break
;----------------------------------------
keyLeft         .byte   %11111101,%00000001
keyRight        .byte   %11110111,%00000100
keyFire         .byte   %01111111,%00001000
keyLeftDown     .byte   0
keyRightDown    .byte   0
keyFireDown     .byte   0
keyBreakDown    .byte   0
KeyReg          .equ    $bfff

.module KeyboardScan

keyboardScan:

_scanLeft:
    clr     keyLeftDown
    ldx     #keyLeft
    ldaa    ,x
    staa    2
    ldaa    KeyReg
    inx
    bita    ,x
    bne     _scanRight
    inc     keyLeftDown
    
_scanRight:
    clr     keyRightDown
    ldx     #keyRight
    ldaa    ,x
    staa    2
    ldaa    KeyReg
    inx
    bita    ,x
    bne     _scanFire
    inc     keyRightDown

_scanFire:
    clr     keyFireDown
    ldx     #keyFire
    ldaa    ,x
    staa    2
    ldaa    KeyReg
    inx
    bita    ,x
    bne     _scanBreak
    inc     keyFireDown

_scanBreak:
    clr     keyBreakDown
    ldaa    #%11111011 
    staa    2
    ldaa    3
    bita    #%00000010 
    bne     _done
    inc     keyBreakDown
    
_done:
    rts
    
;----------------------------------------
;keyboardScanMenu
;Checks for enter, break and y/n
;----------------------------------------
keyEnter        .byte   %10111111,%00001000
keyQ            .byte   %11111101,%00000100
key5            .byte   %11011111,%00010000
keyEnterDown    .byte   0
keyQDown        .byte   0

.module KeyboardScanMenu

keyboardScanMenu:

_scanEnter:
    clr     keyEnterDown
    ldx     #keyEnter
    ldaa    ,x
    staa    2
    ldaa    KeyReg
    inx
    bita    ,x
    bne     _scanQ
    inc     keyEnterDown
    
_scanQ:
    clr     keyQDown
    ldx     #keyQ
    ldaa    ,x
    staa    2
    ldaa    KeyReg
    inx
    bita    ,x
    bne     _scan5
    inc     keyQDown
    
_scan5:
    tst     cheating
    beq     _scanBreak
    ldx     #key5
    ldaa    ,x
    staa    2
    ldaa    KeyReg
    inx
    bita    ,x
    bne     _scanBreak
    ldaa    #5
    staa    lives

_scanBreak:
    clr     keyBreakDown
    ldaa    #%11111011 
    staa    2
    ldaa    3
    bita    #%00000010 
    bne     _done
    inc     keyBreakDown
    
_done:
    rts
    
;----------------------------------------
;fillScreen
;Fill the screen
;'a' should contain fill byte
;----------------------------------------
.module FillScreen
fillScreen:
    ldx     #VideoRAM
_fillLoop:
    staa    ,x
    inx 
    cpx     #VideoRAM+VideoRAMLen
    bne     _fillLoop
    rts

;----------------------------------------
;clearPlayfield
;Clear the playfield (not the status bar in row 0)
;----------------------------------------
.module ClearPlayfield
clearPlayfield:
    ldx     #VideoRAM+BytesPerRow   ;skip first row
    ldaa    #BackgroundByte
_fillLoop:
    staa    ,x
    inx 
    cpx     #VideoRAM+VideoRAMLen
    bne     _fillLoop
    rts
;----------------------------------------
;stageIntroClear
;Clear the stage intro text
;----------------------------------------
.module StageIntroClear
stageIntroClear:
    ldx     #VideoRAM+(BytesPerRow*7)   ;skip first row
    ldaa    #BackgroundByte
_fillLoop:
    staa    ,x
    inx 
    cpx     #VideoRAM+(BytesPerRow*10)
    bne     _fillLoop
    rts
    
;----------------------------------------
;stringLength
;Returns length of a string.
;'x' = string pointer
;'x' is preserved.
;----------------------------------------
.module StringLength

stringLength:
    ldaa    #0
    pshx
_loop:
    ldab    ,x
    beq     _done
    inx
    inca
    bra     _loop
_done:
    pulx
    rts
    
;----------------------------------------
;stringWriteCentered
;Write string centered horizontally
;'a' = row  (0-31)
;'x' = string pointer
;----------------------------------------
.module StringWriteCentered
_row    .equ    B0
_len    .equ    B1

stringWriteCentered:
    staa    _row
    jsr     stringLength
    staa    _len
    ldaa    #BytesPerRow
    suba    _len
    lsra
    ldab    _row
    jsr     stringWrite
    rts
    
;----------------------------------------
;stringWrite
;Write string to screen
;'a' = x    (0-31)
;'b' = y    (0-15)
;'x' = string pointer
;----------------------------------------
.module StringWrite
_xhi        .equ    B0
_x          .equ    B1
_screenPtr  .equ    W0
_stringPtr  .equ    W1

stringWrite:
    stx     _stringPtr
    staa    _x
    clr     _xhi
    ldaa    #BytesPerRow
    mul     ;multiply y*BytesPerRow
    addd    _xhi
    addd    #VideoRAM
    std     _screenPtr
    
_loop:
    ldx     _stringPtr
    ldaa    ,x
    beq     _done   ;null terminator
    cmpa    #'a'
    blo     _doChar
    cmpa    #'z'
    bhi     _doChar
    suba    #96

_doChar:
    inx 
    stx     _stringPtr
    ldx     _screenPtr
    staa    ,x
    inx     
    stx     _screenPtr
    bra     _loop
_done:
    rts
    
;----------------------------------------
;stringWriteByte
;Write a byte as a decimal value, limited to 2 digits (lives, timer, stage #).
;'a' = x    (0-31)
;'b' = y    (0-15)
;'x' points to byte to write
;----------------------------------------
.module StringWriteByte
_val        .byte   0
_x          .byte   0
_y          .byte   0

stringWriteByte:
    staa    _x
    stab    _y
    ldaa    ,x
    staa    _val
    ldx     #buff
    ldaa    #'0'
    staa    0,x
    staa    1,x
    clr     2,x
    ldaa    _val
_loop:
    cmpa    #10
    bcs     _done
    suba    #10
    ldab    0,x
    incb
    stab    0,x
    bra     _loop
    
_done:    
    adda    1,x
    staa    1,x
    ldaa    _x
    ldab    _y
    jsr     stringWrite
    
    rts
;----------------------------------------
;'random' number generator
;rndSeed initializes with CPUTicks
;rndGet returns 0-255 in 'a'
;rndGetMax returns 0-'a' in 'a'. Limited to 31 max for speed.
;
;'borrowed' from https://codebase64.org/doku.php?id=base:small_fast_8-bit_prng
;TODO: Replace this. The repeating pattern is too obvious and it will never
;give the same number twice until all 256 numbers returned. It's probably good 
;enough for simple games.
;----------------------------------------
.module RandomNumber
_seed:      .byte 55  
_xorVal:    .byte $1d
_xorValues: 
    .byte $1d,$2b,$2d,$4d,$5f,$63,$65,$69
    .byte $71,$87,$8d,$a9,$c3,$cf,$e7,$f5

rndSeed:                
    ldaa    CPUTicksLow
    staa    _seed
    ldab    CPUTicks
    andb    #$0F
    ldx     #_xorValues
    abx
    ldaa    ,x
    staa    _xorVal
    rts
    
rndGet:
    ldaa     _seed
    beq     _doXor
    asla
    beq     _noXor      ;if the input was $80, skip the EOR
    bcc     _noXor
_doXor:    
    eora    _xorVal
_noXor:  
    staa    _seed
    rts
    
rndGetMax:
    staa    B5
    jsr     rndGet
    anda    #%00011111   ;limit to 0-31 to minimize loops
_loop:
    cmpa    B5
    bls     _done
    suba    B5
    bra     _loop
_done:
    rts
    
    
    
;----------------------------------------
;clockUpdate
;Calcs deltaMS.
;----------------------------------------
.module ClockUpdate
_ticks              .word   $0000
_msCounter          .word   895

clockUpdate:
    ldd     CPUTicks
    std     _ticks
    subd    cpuTicksSave
    std     deltaTicks
    ldd     _ticks
    std     cpuTicksSave

    ldd     #0
    std     deltaMS
    ldd     _msCounter  ;TODO: This seems convoluted. 
    subd    deltaTicks
    bcc     _deltaLower
    ldd     deltaTicks
_deltaHigher:           ;deltaTicks > msCounter
    subd    _msCounter
    bcs     _dh1
    std     _ticks
    ldd     deltaMS
    addd    #1
    std     deltaMS
    ldd     #CPUTicksPerMS
    std     _msCounter
    ldd     _ticks
    bra     _deltaHigher
_dh1:
    ldd    _msCounter
    subd    _ticks
_deltaLower:            ;deltaTicks < msCounter
    std     _msCounter  
    rts
    
;----------------------------------------
;clockWait
;Waits for 'd' ms.
;----------------------------------------
.module ClockWait
_tmpW   .word   $0000

clockWait:
    std     _tmpW
    jsr     clockUpdate     ;discard any previous delta
_loop:    
    jsr     clockUpdate
    ldd     _tmpW
    subd    deltaMS
    std     _tmpW
    bcc     _loop
    rts
    
;----------------------------------------
;wipeScreenAltLines
;Fill screen with char in 'a' by sliding them in from 
;left/right side on alternating rows.
;----------------------------------------
.module WipeScreenAltLines
_col    .equ    B0
_row    .equ    B1
_chr    .equ    B2

wipeScreenAltLines:
    staa    _chr
    
    ldaa    #32
    staa    _col
    
_colLoop:
    ldx     #VideoRAM
    ldaa    #16
    staa    _row
_rowLoop:    
    ldaa    _row
    bita    #1
    beq     _evenRow
    ldab    #0
    addb    _col
    decb
    bra     _cont
    
_evenRow 
    ldab    #BytesPerRow
    subb    _col
    
_cont:
    pshx
    abx
    ldaa    _chr
    staa    ,x
    pulx
    ldab    #BytesPerRow
    abx
    dec     _row
    bne     _rowLoop
    pshx
    ldd     #10
    jsr     clockWait
    pulx
    dec     _col
    bne     _colLoop
    rts
;========================================
;Sprite Frame Data
;========================================

PlayerClr0    .equ    RedPixel
PlayerClr1    .equ    BluePixel
PlayerClr2    .equ    RedPixel      ;change color for flashing gun
PlayerClr3    .equ    BluePixel

;Frames: 0=even x/even y, 1=odd x/even y, 2=even x/odd y, 3=odd x/odd y
;Player never changes from even y so only 0 and 1 needed.
playerFrame0_0: .byte   4,2
                .byte   $80, PlayerClr0+%0011, $80,$80
                .byte   PlayerClr1+%0110, PlayerClr1+%1100,PlayerClr1+%1001,$80
                
playerFrame0_1: .byte   4,2
                .byte   $80, PlayerClr0+%0001, PlayerClr0+%0010, $80  
                .byte   PlayerClr1+%0001, PlayerClr1+%1100, PlayerClr1+%1100,PlayerClr1+%0010 
                
;frame set 1 is not used with the player unless PlayerClr2 is changed.
playerFrame1_0: .byte   4,2
                .byte   $80, PlayerClr2+%0011, $80,$80
                .byte   PlayerClr3+%0110, PlayerClr3+%1100,PlayerClr3+%1001,$80
                
playerFrame1_1: .byte   4,2
                .byte   $80, PlayerClr2+%0001, PlayerClr2+%0010, $80  
                .byte   PlayerClr3+%0001, PlayerClr3+%1100, PlayerClr3+%1100,PlayerClr3+%0010 
                
;Frame set: An array of 4 frames for each possible even/odd position. Must be 4 frames.
playerFrameSet0:  .word   playerFrame0_0,playerFrame0_1,playerFrame0_0,playerFrame0_1
playerFrameSet1:  .word   playerFrame1_0,playerFrame1_1,playerFrame1_0,playerFrame1_1

;Frame Seq: An array of frame sets. Each frame set is one logical frame of animation.
playerFrameSeq0:  .word   playerFrameSet0,playerFrameSet1
;Delay between frames of animation.
playerDelays0:    .word   50,50
;----------------------------------------

playerOpenScreenFrame:
                .byte   4,2
                .byte   $80, PlayerClr0+%0011, $80,$80
                .byte   PlayerClr1+%0110, PlayerClr1+%1100,PlayerClr1+%1001,$80
eraseOpenScreenFrame:
                .byte   4,2
                .byte   $80,$80,$80,$80
                .byte   $80,$80,$80,$80
;----------------------------------------
PShotClr0       .equ    BuffPixel

pShotFrame0_0:  .byte   2,1
                .byte   PShotClr0+%1100,$80
pShotFrame0_1:  .byte   2,1
                .byte   PShotClr0+%0100,PShotClr0+%1000
pShotFrame0_2:  .byte   2,1
                .byte   PShotClr0+%0011, $80
pShotFrame0_3:  .byte   2,1
                .byte   PShotClr0+%0001, PShotClr0+%0010
                
pShotFrameSet0: .word   pShotFrame0_0,pShotFrame0_1,pShotFrame0_2,pShotFrame0_3
pShotFrameSeq0: .word   pShotFrameSet0
pShotDelays0:   .word   25
pShotFrameCount .equ    1
;----------------------------------------

E0Color0        .equ    RedPixel
E0Color1        .equ    YellowPixel

e0Frame0_0:     .byte   3,3
                .byte   $80,E0Color0+%0011,$80
                .byte   E0Color0+%1111,E0Color1+%1000,E0Color0+%1111
                .byte   $80,E0Color0+%1100,$80
e0Frame1_0:     .byte   3,3
                .byte   $80,E0Color0+%0011,$80
                .byte   E0Color0+%1111,E0Color1+%0100,E0Color0+%1111
                .byte   $80,E0Color0+%1100,$80
e0Frame2_0:     .byte   3,3
                .byte   $80,E0Color0+%0011,$80
                .byte   E0Color0+%1111,E0Color1+%0001,E0Color0+%1111
                .byte   $80,E0Color0+%1100,$80
e0Frame3_0:     .byte   3,3
                .byte   $80,E0Color0+%0011,$80
                .byte   E0Color0+%1111,E0Color1+%0010,E0Color0+%1111
                .byte   $80,E0Color0+%1100,$80
                
;enemy 0 only allowed on even X and y
e0FrameSet0:    .word   e0Frame0_0,e0Frame0_0,e0Frame0_0,e0Frame0_0
e0FrameSet1:    .word   e0Frame1_0,e0Frame1_0,e0Frame1_0,e0Frame1_0
e0FrameSet2:    .word   e0Frame2_0,e0Frame2_0,e0Frame2_0,e0Frame2_0
e0FrameSet3:    .word   e0Frame3_0,e0Frame3_0,e0Frame3_0,e0Frame3_0
e0FrameSeq0:    .word   e0FrameSet0,e0FrameSet1,e0FrameSet2,e0FrameSet3
e0Delays0:      .word   100,100,100,100
e0FrameCount    .equ    4

;----------------------------------------
;Enemy1  
E1Color0        .equ    RedPixel
E1Color1        .equ    GreenPixel
E1Color2        .equ    CyanPixel

e1Frame0_0:     .byte   3,1
                .byte   E1Color0+%1001,E1Color1+%0011,E1Color0+%0110
                ;.byte   $80,$80,$80
;enemy1Frame0_2: .byte   4,2 ;unused
;                .byte   E1Color0+%0010,$80,E1Color0+%0001
;                .byte   E1Color0+%0100,E1Color1+%1100,E1Color0+%1000
e1Frame1_0:     .byte   3,1
                .byte   E1Color0+%1001,E1Color2+%0011,E1Color0+%0110
          
                
;enemy 0 only allowed on even X and y
e1FrameSet0:    .word   e1Frame0_0,e1Frame0_0,e1Frame0_0,e1Frame0_0
e1FrameSet1:    .word   e1Frame1_0,e1Frame1_0,e1Frame1_0,e1Frame1_0
e1FrameSeq0:    .word   e1FrameSet0,e1FrameSet1
e1Delays0:      .word   100,100
e1FrameCount    .equ    2
;----------------------------------------
;EShot 0
EShot0Clr0       .equ    RedPixel

eShot0Frame0_0: .byte   2,1
                .byte   EShot0Clr0+%1100,$80
eShot0Frame0_1: .byte   2,1
                .byte   EShot0Clr0+%0100,EShot0Clr0+%1000
eShot0Frame0_2: .byte   2,1
                .byte   EShot0Clr0+%0011, $80
eShot0Frame0_3: .byte   2,1
                .byte   EShot0Clr0+%0001, EShot0Clr0+%0010
                
eShot0FrameSet0: .word   eShot0Frame0_0,eShot0Frame0_1,eShot0Frame0_2,eShot0Frame0_3
eShot0FrameSeq0: .word   eShot0FrameSet0
eShot0Delays0:   .word   25
eShot0FrameCount .equ    1
;----------------------------------------
;EShot 1    - magenta/cyan zigzag laser
EShot1Clr0       .equ    MagentaPixel
EShot1Clr1       .equ    CyanPixel

eShot1Frame0_0: .byte   2,1
                .byte   EShot1Clr0+%1100,EShot1Clr1+%0011
                ;.byte   EShot1Clr0+%1100,EShot1Clr1+%0011
eShot1Frame1_0: .byte   2,1
                .byte   EShot1Clr1+%0011,EShot1Clr0+%1100
                ;.byte   EShot1Clr1+%0011,EShot1Clr0+%1100
                
eShot1FrameSet0: .word   eShot1Frame0_0,eShot1Frame0_0,eShot1Frame0_0,eShot1Frame0_0
eShot1FrameSet1: .word   eShot1Frame1_0,eShot1Frame1_0,eShot1Frame1_0,eShot1Frame1_0
eShot1FrameSeq0: .word   eShot1FrameSet0,eShot1FrameSet1
eShot1Delays0:   .word   50,50
eShot1FrameCount .equ    2
;----------------------------------------
;EnemyX - extra man letter
ExColor0        .equ    OrangePixel

exFrame0_0:     .byte   3,1
                .byte   ExColor0+%0011,'E',ExColor0+%1100
exFrame1_0:     .byte   3,1
                .byte   ExColor0+%1001,'E',ExColor0+%1001
exFrame2_0:     .byte   3,1
                .byte   ExColor0+%1100,'E',ExColor0+%0011
exFrame3_0:     .byte   3,1
                .byte   ExColor0+%0110,'E',ExColor0+%0110
          
;enemy X only allowed on even X and y
exFrameSet0:    .word   exFrame0_0,exFrame0_0,exFrame0_0,exFrame0_0
exFrameSet1:    .word   exFrame1_0,exFrame1_0,exFrame1_0,exFrame1_0
exFrameSet2:    .word   exFrame2_0,exFrame2_0,exFrame2_0,exFrame2_0
exFrameSet3:    .word   exFrame3_0,exFrame3_0,exFrame3_0,exFrame3_0
exFrameSeq0:    .word   exFrameSet0,exFrameSet1,exFrameSet2,exFrameSet3
exDelays0:      .word   100,100,100,100
exFrameCount    .equ    4
;----------------------------------------
;enemyB - bonus stage item
ebFrame0_0:     .byte   1,1
                .byte   '$'+64
ebFrameSet0:    .word   ebFrame0_0,ebFrame0_0,ebFrame0_0,ebFrame0_0
ebFrameSeq0:    .word   ebFrameSet0
ebDelays0:      .word   25
ebFrameCount    .equ    1
;----------------------------------------
;Enemy2
E2Color0        .equ    CyanPixel
E2Color1        .equ    YellowPixel
E2Color2        .equ    BluePixel

e2Frame0_0:     .byte   4,2
                .byte   E2Color0+%0001,E2Color1+%0011,E2Color1+%0011,E2Color0+%0010
                .byte   E2Color0+%1000,E2Color0+%1100,E2Color0+%1100,E2Color0+%0100
e2Frame1_0:     .byte   4,2
                .byte   E2Color0+%0010,E2Color1+%0011,E2Color1+%0011,E2Color0+%0001
                .byte   E2Color0+%0100,E2Color0+%1100,E2Color0+%1100,E2Color0+%1000
;enemy 2 only allowed on even X and y
e2FrameSet0:    .word   e2Frame0_0,e2Frame0_0,e2Frame0_0,e2Frame0_0
e2FrameSet1:    .word   e2Frame1_0,e2Frame1_0,e2Frame1_0,e2Frame1_0
e2FrameSeq0:    .word   e2FrameSet0,e2FrameSet1
e2Delays0:      .word   100,100
e2FrameCount    .equ    2
;----------------------------------------
;Enemy3
E3Color0        .equ    GreenPixel
E3Color1        .equ    MagentaPixel
E3Color2        .equ    CyanPixel

e3Frame0_0:     .byte   4,2
                .byte   $80,E3Color0+%0011,E3Color0+%0011,$80
                .byte   E3Color0+%1110,E3Color1+%0101,E3Color2+%1010,E3Color0+%1101
e3Frame1_0:     .byte   4,2
                .byte   $80,E3Color0+%0011,E3Color0+%0011,$80
                .byte   E3Color0+%1110,E3Color2+%0101,E3Color1+%1010,E3Color0+%1101
;enemy 3 only allowed on even X and y
e3FrameSet0:    .word   e3Frame0_0,e3Frame0_0,e3Frame0_0,e3Frame0_0
e3FrameSet1:    .word   e3Frame1_0,e3Frame1_0,e3Frame1_0,e3Frame1_0
e3FrameSeq0:    .word   e3FrameSet0,e3FrameSet1
e3Delays0:      .word   100,100
e3FrameCount    .equ    2
;----------------------------------------
;Enemy4
E4Color0        .equ    RedPixel
E4Color1        .equ    YellowPixel

e4Frame0_0:     .byte   5,3
                .byte   $80,E4Color1+%0111,E4Color0+%0011,E4Color1+%1011,$80
                .byte   E4Color0+%0001,E4Color0+%1011,E4Color0+%1111,E4Color0+%0111,E4Color0+%0010
                .byte   $80,E4Color0+%1101,E4Color1+%0011,E4Color0+%1110,$80
e4Frame1_0:     .byte   5,3
                .byte   $80,E4Color1+%0111,E4Color0+%0011,E4Color1+%1011,$80
                .byte   E4Color0+%0001,E4Color0+%1011,E4Color0+%1111,E4Color0+%0111,E4Color0+%0010
                .byte   $80,E4Color0+%1101,E4Color1+%0011,E4Color0+%1110,$80
;enemy 3 only allowed on even X and y
e4FrameSet0:    .word   e4Frame0_0,e4Frame0_0,e4Frame0_0,e4Frame0_0
e4FrameSet1:    .word   e4Frame1_0,e4Frame1_0,e4Frame1_0,e4Frame1_0
e4FrameSeq0:    .word   e4FrameSet0,e4FrameSet1
e4Delays0:      .word   100,100
e4FrameCount    .equ    2
;----------------------------------------
;Enemy variables and data
;----------------------------------------
enemyCreateArray .word  e0Create,e1Create,e2Create,e3Create,e4Create
enemyMax        .byte   1

deathDelays:    .word   2000,2000,2000,2000 ;for player/enemy death sequence
enemyDelay      .word   1000                ;MS between enemy spawns
enemyTimer      .word   0                   ;MS until next spawn

   .end         
