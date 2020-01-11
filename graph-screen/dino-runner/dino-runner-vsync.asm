dino         START  0

. TEXT

MAIN_ENTRY

            ............ INITIALIZE STACK ............
            JSUB    stackinit
            .............................................


            ............ INIT PLAYER VARIABLES .............
            LDA     #30
            FLOAT
            STF     playerX
            LDA     #CONST_FLOOR_POS_Y
            FLOAT
            STF     playerY
            LDA     #1
            FLOAT   
            DIVF    #20
            STF     constPlayerGravityAy
            ...........................................


            ............ START GAME LOOP .............
            J      gameLoop
            ............ START GAME LOOP .............


gameLoop

            JSUB    handleInput
            JSUB    updateGamestate
            JSUB    render

            ...... Lock rendering to VSYNC. Wait for VSYNC_ADDR (byte) to be 1 (Framebuffer is not being rendered)
gameLoopVsyncWait
            +LDCH    GRAPHICAL_SCREEN_VSYNC_ADDR 
            COMP    #0
            JEQ     gameLoopVsyncWait
            LDA     #0 
            +STCH   GRAPHICAL_SCREEN_VSYNC_ADDR . Clear to 0, so we can check for next VSYNC
            ...........................................................................................................

            JSUB    memcpyFramebuffer

        
            J       gameLoop



................ MEMCPY FRAMEBUFFER ..............
memcpyFramebuffer

            . store L reg
            STL     @stackptr
            JSUB    stackpush

            . store X reg
            STX     @stackptr
            JSUB    stackpush

            . store A reg
            STA     @stackptr
            JSUB    stackpush

            . store B reg
            STB     @stackptr
            JSUB    stackpush

            
            . Optimizations - UNROLL LOOP - 32 pixels per loop (less jumps), 2 * (3byte)word access (LDF) (6 pixels at once). 
            . LDA contains address increment amount
            LDX     #0
            LDL     #30         . 5 * 6 - 1 (last 2 increments are TIX)

            ........... LOOP ............
memcpyFramebufferLoop
           
            +LDF   CONST_6_UNROLL_SFBADDR_0,X
            +STF   CONST_6_UNROLL_GFBADDR_0,X
            +LDF   CONST_6_UNROLL_SFBADDR_1,X
            +STF   CONST_6_UNROLL_GFBADDR_1,X
            +LDF   CONST_6_UNROLL_SFBADDR_2,X
            +STF   CONST_6_UNROLL_GFBADDR_2,X
            +LDF   CONST_6_UNROLL_SFBADDR_3,X
            +STF   CONST_6_UNROLL_GFBADDR_3,X
            +LDF   CONST_6_UNROLL_SFBADDR_4,X
            +STF   CONST_6_UNROLL_GFBADDR_4,X
            ADDR   L,X
            +LDCH  CONST_6_UNROLL_SFBADDR_0,X
            +STCH  CONST_6_UNROLL_GFBADDR_0,X
            +TIX   #GRAPHICAL_SCREEN_SIZE
            +LDCH  CONST_6_UNROLL_SFBADDR_0,X
            +STCH  CONST_6_UNROLL_GFBADDR_0,X
            +TIX   #GRAPHICAL_SCREEN_SIZE
            JLT    memcpyFramebufferLoop
            ............. END LOOP .............

            . restore B reg 
            JSUB    stackpop
            LDB     @stackptr

            . restore A reg 
            JSUB    stackpop
            LDA     @stackptr

            . restore X reg 
            JSUB    stackpop
            LDX     @stackptr

            . pop L reg
            JSUB    stackpop
            LDL     @stackptr


            RSUB
................ END MEMCPY FRAMEBUFFER ..............



................ HANDLE INPUT ..............

keyboardLastPressedKey      WORD    0

handleInput 
            . store L reg
            STL     @stackptr
            JSUB    stackpush


            JSUB    keyboardRead
            STA     keyboardLastPressedKey
    

            . if space is pressed -> playerDy = -1 (negative direction = up on screen)
            COMP    #32
            JLT     handleInputHopSpaceKey     
            JGT     handleInputHopSpaceKey
            LDF     playerY
            FIX     
            COMP    #CONST_FLOOR_POS_Y
            JLT     handleInputHopSpaceKey

            LDA     #0
            SUB     #17
            FLOAT   
            DIVF    #10
            STF     playerDy

handleInputHopSpaceKey

            . if left key is pressed -> playerX -= 2
            LDA     keyboardLastPressedKey
            COMP    #65
            JLT     handleInputHopLeftKey     
            JGT     handleInputHopLeftKey

            LDF     playerX
            SUBF    #2
            STF     playerX

handleInputHopLeftKey


             . if right key is pressed -> playerX += 2
            LDA     keyboardLastPressedKey
            COMP    #68
            JLT     handleInputHopRightKey     
            JGT     handleInputHopRightKey

            LDA     #2
            FLOAT
            ADDF     playerX
            STF     playerX

handleInputHopRightKey

            . pop L reg
            JSUB    stackpop
            LDL     @stackptr

            RSUB

................ END HANDLE INPUT ..............



.........................................




................ UPDATE GAMESTATE ROUTINE ..............

pointerCactusTableX         WORD        0
pointerCactusTableY         WORD        0
pointerCactusTableZ         WORD        0
boolSpawnNewCactus          WORD        0

updateGamestate
            . store L reg
            STL     @stackptr
            JSUB    stackpush


. increment physics

            LDF     playerDy
            ADDF    constPlayerGravityAy
            STF     playerDy

            ADDF    playerY
            STF     playerY
            
. check floor for player

            LDF     playerY
            FIX
            COMP    #CONST_FLOOR_POS_Y
            JLT     updateGamestateHopCheckFloor
            
            LDA     #CONST_FLOOR_POS_Y
            FLOAT
            STF     playerY
            
            LDA     #0
            FLOAT
            STF     playerDy

updateGamestateHopCheckFloor




......... Cacti FOR loop ..................................
            
                ..... INIT pointers
                LDA         #cactusTable
                STA         pointerCactusTableX
                ADD         #3
                STA         pointerCactusTableY
                ADD         #3
                STA         pointerCactusTableZ

                . check if random generates new cactus
                . threshold < 10'000 (average 5 sec random)
                LDA     prngPrevState
                JSUB    generatePseudoRandomNumber
                STA     prngPrevState
                COMP    constCactusSpawnThreshold
                CLEAR   S
                JGT     updateGamestateCactusHopSpawn
                LDS     #1
updateGamestateCactusHopSpawn
                STS     boolSpawnNewCactus

                .. init ticker
                CLEAR       X

updateGamestateCactusLoop . {

                . check if empty cactus spot
                LDB         @pointerCactusTableZ
                LDA         #1
                SUBR        B,A
                AND         boolSpawnNewCactus
                COMP        #1
                JLT         updateGamestateCactusIfNotEmpty

                . if (empty spot && boolSpawnNewCactus)
                    . add new cactus    
                    LDA     #constCactusStartX
                    STA     @pointerCactusTableX
                    LDA     #constCactusStartY
                    STA     @pointerCactusTableY
                    LDA     #1
                    STA     @pointerCactusTableZ

                    LDA     numCactus
                    ADD     #1
                    STA     numCactus

                    LDA     #0 
                    STA     boolSpawnNewCactus
                    
                    J       updateGamestateCactusLoopContinue

updateGamestateCactusIfNotEmpty
                . if(!empty spot)
                LDA         @pointerCactusTableZ
                COMP        #1
                JEQ         updateGamestateCactusHandleCactus    

                J           updateGamestateCactusLoopContinue

updateGamestateCactusHandleCactus
                
                    . move cactus <- X direction
                    LDA     @pointerCactusTableX
                    ADD     constCactusHorizontalSpeed
                    STA     @pointerCactusTableX

                    . check if cactus out of BB
                    COMP    #0
                    JGT     updateGamestateCactusSkipOutOfBB
                        . ! Cactus out of BB, remove
                        LDA     #0
                        STA     @pointerCactusTableX
                        STA     @pointerCactusTableY
                        STA     @pointerCactusTableZ
                        
                        LDA     numCactus
                        SUB     #1
                        STA     numCactus

updateGamestateCactusSkipOutOfBB
                    
                    . check if collisionWithPlayer
                    LDA      @pointerCactusTableX
                    LDB      @pointerCactusTableY
                    JSUB     checkCollisionBetweenCactusAndPlayer
                    COMP     #0
                    JEQ      updateGamestateCactusSkipEndOfGame
                    
                            . END OF GAME
                            . TODO
                            J   halt


updateGamestateCactusSkipEndOfGame      
                        LDA     #0

                .}....................................



    .......................... } loop            
updateGamestateCactusLoopContinue

                LDB         constCactusEntrySize
                LDA         pointerCactusTableX
                ADDR        B,A
                STA         pointerCactusTableX
                LDA         pointerCactusTableY
                ADDR        B,A
                STA         pointerCactusTableY
                LDA         pointerCactusTableZ
                ADDR        B,A
                STA         pointerCactusTableZ

                TIX         constCactusTableMax
                JLT         updateGamestateCactusLoop

...............END OF CACTI FOR LOOP.........................



            . pop L reg
            JSUB    stackpop
            LDL     @stackptr

            RSUB

................ END OF UPDATE GAMESTATE ROUTINE ..............







..........START OF RENDER SUBROUTINE...........................
render
            . store L reg
            STL     @stackptr
            JSUB    stackpush

            . clear screen
            LDA     #0x00
            JSUB    clearScreen


......... Cacti FOR loop .......
            
                ..... INIT pointers
                LDA         #cactusTable
                STA         pointerCactusTableX
                ADD         #3
                STA         pointerCactusTableY
                ADD         #3
                STA         pointerCactusTableZ


                LDS         #spriteCactusStructure

                .. init ticker
                CLEAR       X

renderCactusLoop . {

                . check if empty cactus spot
                LDA         @pointerCactusTableZ
                COMP        #0
                JEQ         renderCactusLoopContinue

                . if(!empty spot)
             
                    LDA     @pointerCactusTableX
                    LDB     @pointerCactusTableY
                    
                    JSUB    drawSprite

                .}....................................



    .......................... } loop            
renderCactusLoopContinue

                LDB         constCactusEntrySize
                LDA         pointerCactusTableX
                ADDR        B,A
                STA         pointerCactusTableX
                LDA         pointerCactusTableY
                ADDR        B,A
                STA         pointerCactusTableY
                LDA         pointerCactusTableZ
                ADDR        B,A
                STA         pointerCactusTableZ

                TIX         constCactusTableMax
                JLT         renderCactusLoop

...............END OF CACTI FOR LOOP.........................


..................RENDER PLAYER DINO..................
            LDF     playerY
            FIX
            RMO     A,B
            LDF     playerX
            FIX     
            LDS     #spriteDinoStructure
            JSUB    drawSprite
..................END OF RENDER PLAYER DINO..................



            . pop L reg
            JSUB    stackpop
            LDL     @stackptr

            RSUB
......................END OF RENDER SUBROUTINE................



................ COLLISION CHECK ROUTINE ..............

collisionTmpPx          WORD    0
collisionTmpPxWidth     WORD    0
collisionTmpCx          WORD    0
collisionTmpCxWidth     WORD    0
collisionTmpPy          WORD    0
collisionTmpPyHeight    WORD    0
collisionTmpCy          WORD    0
collisionTmpCyHeight    WORD    0

. (A=x, B=y) return (collision A = 1 else A = 0)
checkCollisionBetweenCactusAndPlayer
  
            . store L reg
            STL     @stackptr
            JSUB    stackpush

            . store B reg
            STB     @stackptr
            JSUB    stackpush

             . store X reg
            STX     @stackptr
            JSUB    stackpush
            
             . store S reg
            STS     @stackptr
            JSUB    stackpush

             . store T reg
            STT     @stackptr
            JSUB    stackpush


            STA     collisionTmpCx
            STB     collisionTmpCy
            ADD     spriteCactusStructure . cactus width
            STA     collisionTmpCxWidth
            LDX     #3
            RMO     B,A
            ADD     spriteCactusStructure,X . cactus height
            STA     collisionTmpCyHeight

            LDF     playerX
            FIX     
            STA     collisionTmpPx
            ADD     #12 . dino width (custom BoundingBox)
            STA     collisionTmpPxWidth

            LDF     playerY
            FIX
            STA     collisionTmpPy
            .ADD     spriteDinoStructure,X . dino height
            ADD     #12 . dino height (custom BoundingBox)
            STA     collisionTmpPyHeight


            . comparisons
            . (px < cx + width)
            LDA     collisionTmpPx
            COMP    collisionTmpCxWidth
            JGT     checkCollisionBetweenCactusAndPlayerOut

            . (px + width > cx)
            LDA     collisionTmpPxWidth
            COMP    collisionTmpCx
            JLT     checkCollisionBetweenCactusAndPlayerOut

            . (py < cy + width)
            LDA     collisionTmpPy
            COMP    collisionTmpCyHeight
            JGT     checkCollisionBetweenCactusAndPlayerOut

            . (py + height < cy)
            LDA     collisionTmpPyHeight
            COMP    collisionTmpCy
            JLT     checkCollisionBetweenCactusAndPlayerOut

            . TRUE
            LDA     #1
            J checkCollisionBetweenCactusAndPlayerTrue

    
checkCollisionBetweenCactusAndPlayerOut
            LDA     #0

checkCollisionBetweenCactusAndPlayerTrue

            
            . pop T reg
            JSUB    stackpop
            LDT     @stackptr

            . pop S reg
            JSUB    stackpop
            LDS     @stackptr
            
            .pop X reg
            JSUB    stackpop
            LDX     @stackptr

            . pop B reg
            JSUB    stackpop
            LDB     @stackptr

            . pop L reg
            JSUB    stackpop
            LDL     @stackptr


            RSUB
................ END OF COLLISION CHECK ROUTINE ..............



................ PSEUDO RANDOM NUMBER GENERATOR ROUTINE ..............

prngPrevState      WORD     72859 . seed
.prngPrevState      WORD     10 . seed

prngMulValue       WORD    16807
prngModValue       WORD   991483
prngAndValue       WORD   0xFFFFF

generatePseudoRandomNumber
            
            . store L reg
            STL     @stackptr
            JSUB    stackpush

            . store B reg
            STB     @stackptr
            JSUB    stackpush
            
            . state * 16807 % 991483;
            .MUL     prngMulValue
            .RMO     A,B
            .DIV     prngModValue
            .MUL     prngModValue
            .SUBR    A,B
            .RMO     B,A

            MUL     prngMulValue
            AND     prngAndValue


            . pop B reg
            JSUB    stackpop
            LDB     @stackptr

            . pop L reg
            JSUB    stackpop
            LDL     @stackptr

            RSUB
................ END OF PSEUDO RANDOM NUMBER GENERATOR ROUTINE ..............


................ KEYBOARD READ ROUTINE ..............
keyboardReadTmp    WORD    0
keyboardRead    
            +LDCH   KEYBOARD_ADDR
            STCH    keyboardReadTmp
            CLEAR   A
            +STCH   KEYBOARD_ADDR
            LDCH     keyboardReadTmp
            RSUB
................ END OF KEYBOARD READ ROUTINE ..............


................ DRAW SPRITE ROUTINE ..............
. drawSprite(A=x, B=y, S=spriteStructure)

drawSprite
            . store L reg
            STL     @stackptr
            JSUB    stackpush

             . store A reg
            STA     @stackptr
            JSUB    stackpush
            
            . store B reg
            STB     @stackptr
            JSUB    stackpush
            
             . store X reg
            STX     @stackptr
            JSUB    stackpush
            
             . store S reg
            STS     @stackptr
            JSUB    stackpush

             . store T reg
            STT     @stackptr
            JSUB    stackpush


            LDT     #3
            STS     spriteStructureWidthPointer 
            ADDR    T,S
            STS     spriteStructureHeightPointer
            ADDR    T,S
            STS     spriteStructureSizePointer
            ADDR    T,S
            STS     spriteStructureDataPointer

            RMO     A,X
            RMO     B,A
            MUL     #GRAPHICAL_SCREEN_STRIDE_BYTES
            ADDR    A,X
            
drawSpriteOuterLoop   . {
            CLEAR   S
drawSpriteInnerLoop . {
            CLEAR   A
            +LDCH   @spriteStructureDataPointer
            COMP    colorTransparent
            JEQ     drawSpriteHopColor
            +STCH   GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR,X

drawSpriteHopColor
            LDA     spriteStructureDataPointer
            ADD     #1
            STA     spriteStructureDataPointer
            TIX     #0

            LDA     #1
            ADDR    S,A
            RMO     A,S
            COMP    @spriteStructureWidthPointer
            JLT     drawSpriteInnerLoop
    . }

            SUB     #GRAPHICAL_SCREEN_STRIDE_BYTES
            SUBR    A,X
            

            LDA     spriteStructureSizePointer
            ADD     @spriteStructureSizePointer
            ADD     #3
            COMP    spriteStructureDataPointer
            JEQ     drawSpriteHop
            J       drawSpriteOuterLoop
. }

drawSpriteHop

            . pop T reg
            JSUB    stackpop
            LDT     @stackptr

            . pop S reg
            JSUB    stackpop
            LDS     @stackptr
            
            .pop X reg
            JSUB    stackpop
            LDX     @stackptr

            .pop B reg
            JSUB    stackpop
            LDB     @stackptr

            .pop A reg
            JSUB    stackpop
            LDA     @stackptr

            . pop L reg
            JSUB    stackpop
            LDL     @stackptr

            RSUB
................ END OF DRAW SPRITE ROUTINE ..............


................ CLEAR (FILL) SCREEN ROUTINE ..............

. clearScreen (. A=color)
clearScreen
             . store L reg
            STL     @stackptr
            JSUB    stackpush

             . store A reg
            STA     @stackptr
            JSUB    stackpush

             . store X reg
            STX     @stackptr
            JSUB    stackpush

            . Optimizations : Loop unroll, 6 pixel access
            . Clear first 6 pixel with selected color, then read to F register for following stores
            
            +LDX   #GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR
            STCH   0,X
            STCH   1,X
            STCH   2,X
            STCH   3,X
            STCH   4,X
            STCH   5,X

            . Load 6 pixels of color "A" to F reg
            LDF    0,X

            LDL    #31

clearScreenLoop

            STF    0,X
            STF    6,X
            STF    12,X
            STF    18,X
            STF    24,X
            STCH   30,X
            STCH   31,X
            ADDR   L,X
            +TIX   #GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR_END
            JLT    clearScreenLoop

            .pop X reg
            JSUB    stackpop
            LDX     @stackptr

            .pop A reg
            JSUB    stackpop
            LDA     @stackptr

            . pop L reg
            JSUB    stackpop
            LDL     @stackptr

            RSUB
................ END OF CLEAR (FILL) SCREEN ROUTINE ..............


................ DELAY (ms) ROUTINE ..............
. (A = miliseconds)
delayMilisecondsTmpVar     WORD    0
delayMiliseconds

             . store X reg
            STX     delayMilisecondsTmpVar
        
            MUL     #PROCESSORTICKSMS  
            CLEAR   X
delayMilisecondsLoop
            TIXR    A
            JLT     delayMilisecondsLoop
            
            LDX     delayMilisecondsTmpVar
            RSUB
................ END OF DELAY (ms) ROUTINE ..............



................ STACK ROUTINEs ..............

regA                    WORD    0
CONST_WORD_INCREMENT    EQU     3

stackinit
            LDA     #stack
            STA     stackptr
            RSUB

stackpush   
            STA     regA
            LDA     stackptr
            ADD     #CONST_WORD_INCREMENT
            STA     stackptr
            LDA     regA
            RSUB

stackpop
            STA     regA
            LDA     stackptr
            SUB     #CONST_WORD_INCREMENT
            STA     stackptr
            LDA     regA
            RSUB
................ STACK ROUTINEs ..............


. HALT
halt    J      halt


............ Variables and constants -> .........................................
.................................................................................


................ PROCESSOR FREQUENCY (important for delays) ....................
PROCESSORFREQUENCY  EQU     15000000
PROCESSORTICKSMS    EQU     PROCESSORFREQUENCY / 2000
...............................................................................


........... SCREEN DIMS: W=128, H=64, PixelSize=6 ..................

GRAPHICAL_SCREEN_STRIDE_BYTES                           EQU     128
GRAPHICAL_SCREEN_ADDR                                   EQU     0xA000
GRAPHICAL_SCREEN_WIDTH                                  EQU     128
GRAPHICAL_SCREEN_HEIGHT                                 EQU     64
GRAPHICAL_SCREEN_SIZE                                   EQU     GRAPHICAL_SCREEN_WIDTH * GRAPHICAL_SCREEN_HEIGHT 
GRAPHICAL_SCREEN_VSYNC_ADDR                             EQU     GRAPHICAL_SCREEN_ADDR + GRAPHICAL_SCREEN_SIZE
GRAPHICAL_SCREEN_SCRATCH_FRAMEBUFFER_ADDR               EQU     0x8000
GRAPHICAL_SCREEN_SCRATCH_FRAMEBUFFER_ADDR_END           EQU     GRAPHICAL_SCREEN_SCRATCH_FRAMEBUFFER_ADDR + GRAPHICAL_SCREEN_SIZE

GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR                    EQU   GRAPHICAL_SCREEN_SCRATCH_FRAMEBUFFER_ADDR
GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR_END                EQU   GRAPHICAL_SCREEN_SCRATCH_FRAMEBUFFER_ADDR + GRAPHICAL_SCREEN_SIZE

.................................................................................



.................................................................................
.. UNROLL CONSTANTS
.................................................................................
CONST_6_UNROLL_SFBADDR_0   EQU     GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR + 0
CONST_6_UNROLL_SFBADDR_1   EQU     GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR + 6
CONST_6_UNROLL_SFBADDR_2   EQU     GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR + 12
CONST_6_UNROLL_SFBADDR_3   EQU     GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR + 18
CONST_6_UNROLL_SFBADDR_4   EQU     GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR + 24
CONST_6_UNROLL_SFBADDR_5   EQU     GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR + 30
CONST_6_UNROLL_SFBADDR_6   EQU     GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR + 36
CONST_6_UNROLL_SFBADDR_7   EQU     GRAPHICAL_SCREEN_DRAWING_BUFFER_ADDR + 42

CONST_6_UNROLL_GFBADDR_0    EQU     GRAPHICAL_SCREEN_ADDR + 0
CONST_6_UNROLL_GFBADDR_1    EQU     GRAPHICAL_SCREEN_ADDR + 6
CONST_6_UNROLL_GFBADDR_2    EQU     GRAPHICAL_SCREEN_ADDR + 12
CONST_6_UNROLL_GFBADDR_3    EQU     GRAPHICAL_SCREEN_ADDR + 18
CONST_6_UNROLL_GFBADDR_4    EQU     GRAPHICAL_SCREEN_ADDR + 24
CONST_6_UNROLL_GFBADDR_5    EQU     GRAPHICAL_SCREEN_ADDR + 30
CONST_6_UNROLL_GFBADDR_6    EQU     GRAPHICAL_SCREEN_ADDR + 36
CONST_6_UNROLL_GFBADDR_7    EQU     GRAPHICAL_SCREEN_ADDR + 42
.................................................................................


. KEYBOARD 
KEYBOARD_ADDR               EQU     0xD000

. GAME CONSTANTs
CONST_FLOOR_POS_Y         EQU     32


. CACTUS TABLE (3 max, word x, word y, word z)
constCactusStartX           EQU     112
constCactusStartY           EQU     35
constCactusSpawnThreshold   WORD    10000

constCactusHorizontalSpeed  WORD    -1

constCactusTableMax         WORD    3
constCactusEntrySize        WORD    9

numCactus                   WORD    0
cactusTable                 RESW    27

. Player
constPlayerGravityAy        RESW    2

playerX                     RESW    2
playerY                     RESW    2
playerDy                    RESW    2


. Sprite table (10 sprites, word x, word y, word z, word spriteStructure)
. 5-Z depths
constSpriteMaxZDepth        WORD    5
constSpriteEntrySize        WORD    12   

spriteTableLength           WORD    0
spriteTable                 RESW    40


spriteStructureWidthPointer        WORD     0
spriteStructureHeightPointer        WORD    0
spriteStructureSizePointer          WORD    0
spriteStructureDataPointer          WORD    0

spriteDinoStructure
                WORD    18 . width
                WORD    19 . height
                WORD    342 . size
                BYTE    C'0000000000~~~~~~~0'
                BYTE    C'000000000~~0~~~~~~'
                BYTE    C'000000000~~~~~~~~~'
                BYTE    C'000000000~~~~~~~~~'
                BYTE    C'000000000~~~~~~~~~'
                BYTE    C'000000000~~~~00000'
                BYTE    C'000000000~~~~~~~~0'
                BYTE    C'~0000000~~~~~00000'
                BYTE    C'~~000~~~~~~~~00000'
                BYTE    C'~~~00~~~~~~~~~0000'
                BYTE    C'~~~~~~~~~~~~~00000'
                BYTE    C'~~~~~~~~~~~~~00000'
                BYTE    C'0~~~~~~~~~~~000000'
                BYTE    C'0000~~~~~~~0000000'
                BYTE    C'0000~~~~~~00000000'
                BYTE    C'0000~~~0~~00000000'
                BYTE    C'0000~~000~00000000'
                BYTE    C'0000~0000~00000000'
                BYTE    C'0000~~000~~0000000'


spriteCactusStructure
                WORD    16 . width
                WORD    16 . height
                WORD    256 . size
                BYTE X'30303030303030303030303030303030'
                BYTE X'30303030303030303030303030303030'
                BYTE X'30303030303030303030303030303030'
                BYTE X'30303030303030CCCC30303030303030'
                BYTE X'3030303030CCCCCCCCCC3030CC303030'
                BYTE X'3030CC30CCCCCCCCCCCC30CCCC303030'
                BYTE X'3030CCCCCCCCCCCCCCCCCCCC30303030'
                BYTE X'303030CCCCCCCCCCCCCCCC3030303030'
                BYTE X'3030303030CCCCCCCCCCCC3030303030'
                BYTE X'30303030CCCCCCCCCCCCCC3030303030'
                BYTE X'303030CCCCCCCCCCCCCCCC30CC303030'
                BYTE X'303030CCCCCCCCCCCCCCCCCCCC303030'
                BYTE X'30303030CCCCCCCCCCCCCCCC30303030'
                BYTE X'30303030CCCCCCCCCCCCCC3030303030'
                BYTE X'3030303030CCCCCCCCCCCC3030303030'
                BYTE X'3030303030CCCCCCCCCCCC3030303030'


colorWhite          WORD    0xFF
colorBlack          WORD    0x00
colorGreen          WORD    0xCC
colorGrey           WORD    0x7E

. Color 0x30 == transparent
colorTransparent    WORD    0x30



stackptr    WORD    0
stack       RESW    100


            END    MAIN_ENTRY