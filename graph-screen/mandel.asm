mandel  START   0

first   LDX     screen
        LDA     width
        FLOAT
        STF     f_wid
        MUL     height
        ADD     screen
        STA     scrend
        LDA     height
        FLOAT
        STF     f_hei
        LDA     #4
        FLOAT
        STF     excon
        CLEAR   A
        CLEAR   S               . i
        CLEAR   T               . j
        
loop    CLEAR   A
        ADDR    S,A
        MUL     #4
        SUB     width
        SUB     width           . A = 4i - 2width
        FLOAT
        DIVF    f_wid           . F in [-2, 2]
        STF     c_x
        
        CLEAR   A
        ADDR    T,A
        MUL     #4
        SUB     height
        SUB     height          . A = 4j - 2height
        FLOAT
        DIVF    f_hei           . F in [-2, 2]
        STF     c_y
        
        JSUB    calc            . A = numIterations
        MUL     #11
        DIV     iters
        JSUB    color           . A = color
        STCH    first,X
        
        RMO     S,A
        ADD     #1
        RMO     A,S
        COMP    width
        JLT     over
        CLEAR   S
        RMO     T,A
        ADD     #1
        RMO     A,T
        
over    TIX     scrend
        JLT     loop

halt    J       halt


. subroutines
calc    STF     tempFc
        STX     tempXc
        STL     tempLc
        
        CLEAR   X
        CLEAR   F
        STF     tempFX
        STF     tempFY
        
loopcl  LDF     tempFY          . F = y
        ADDF    tempFX          . F = (x + y)
        STF     tempF1          . tempF1 = (x + y)
        LDF     tempFX          . F = x
        SUBF    tempFY          . F = x - y
        MULF    tempF1          . F = (x + y)(x - y) = x² - y²
        ADDF    c_x             . F = x² - y² + c_x = new x
        STF     tempF1          . tempF1 = new x
        
        LDA     #2              . A = 2
        FLOAT                   . F = 2
        MULF    tempFX          . F = 2x
        MULF    tempFY          . F = 2xy
        ADDF    c_y             . F = 2xy + c_y = new y
        STF     tempFY          . tempFY = new y
        
        LDF     tempF1          . F = new x
        STF     tempFX          . tempFX = new x
        
        . divergence comparison
        MULF    tempFX          . F = x²
        STF     tempF1
        LDF     tempFY
        MULF    tempFY
        ADDF    tempF1
        COMPF   excon
        JGT     retcalc         . abs(x + yi) > 2 => diverges
        
        TIX     iters
        JLT     loopcl
        
retcalc RMO     X,A
        LDF     tempFc
        LDX     tempXc
        LDL     tempLc
        RSUB
        
        
color   COMP    #3
        JGT     col1
        J       retcol
        
col1    COMP    #6
        JGT     col2
        SUB     #3
        MUL     #16
        ADD     #3
        J       retcol
        
col2    COMP    #9
        JGT     retmax
        SUB     #6
        MUL     #4
        ADD     #51
        
retcol  ADD     #192
        RSUB
        
retmax  LDA     #255
        RSUB 
        

. memory init
screen  WORD    X'00A000'
width   WORD    1000
height  WORD    1000
scrend  RESW    1
f_wid   RESF    1
f_hei   RESF    1
f_offx  RESF    1
f_offy  RESF    1
iters   WORD    100
c_x     RESF    1
c_y     RESF    1
tempFX  RESF    1
tempFY  RESF    1
tempF1  RESF    1
tempFc  RESF    1
tempXc  RESW    1
tempLc  RESW    1
tempFm  RESF    1
negone  WORD    -1
excon   RESW    1
        END     first
