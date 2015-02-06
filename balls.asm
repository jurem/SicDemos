BALLS    START  0
FIRST    CLEAR  X
. check lower wall
LOOP     LDA    DATA,X
         COMP   HEIGHT
         JLT    J1
         LDA    #3
         ADDR   A,X
         LDB    MINUS
         STB    DATA,X
         SUBR   A,X
. check upper wall
J1       LDA    DATA,X
         COMP   #0
         JGT    J2
         LDA    #3
         ADDR   A,X
         LDB    #1
         STB    DATA,X
         SUBR   A,X
. check right wall
J2       LDA    #6
         ADDR   A,X
         LDA    DATA,X
         COMP   WIDTH
         JLT    J3
         LDA    #3
         ADDR   A,X
         LDB    MINUS
         STB    DATA,X
         SUBR   A,X
. check left wall
J3       LDA    DATA,X
         COMP   #0
         JGT    J4
         LDA    #3
         ADDR   A,X
         LDB    #1
         STB    DATA,X
         SUBR   A,X
. pobrisem prejsnjo in izpisem novo zvezdico
J4       LDT    DATA,X
         LDA    #6
         SUBR   A,X
         LDS    DATA,X
         LDA    SPACE
         JSUB   PRINT
         LDA    #3
         ADDR   A,X
         LDB    DATA,X
         ADDR   B,S
         SUBR   A,X
         STS    DATA,X
         LDA    #6
         ADDR   A,X
         LDT    DATA,X
         LDA    #3
         ADDR   A,X
         LDB    DATA,X
         ADDR   B,T
         SUBR   A,X
         STT    DATA,X
         LDA    #6
         ADDR   A,X
         LDA    STAR
         JSUB   PRINT
         RMO    X,A
         COMP   #35
         JLT    LOOP
         CLEAR  X
         J      LOOP
STAR     WORD   C'***'
SPACE    WORD   C'   '
MINUS    WORD   X'FFFFFF'
.
. 4 fields for each star: x, dx, y, dy
DATA     WORD   X'000005'
         WORD   X'000001'
         WORD   X'000007'
         WORD   X'000001'
         WORD   X'000010'
         WORD   X'000000'
         WORD   X'000008'
         WORD   X'000001'
         WORD   X'000005'
         WORD   X'000001'
         WORD   X'000007'
         WORD   X'000000'

. Print char in A to location (S,T)
PRINT    STA    OLDA
         STX    OLDX
         RMO    S,X
         LDA    WIDTH
         MULR   A,X
         RMO    T,A
         ADDR   A,X
         LDA    SCREEN
         ADDR   A,X
         STX    PADDR
         LDA    OLDA
         STCH   @PADDR
         LDX    OLDX
         RSUB
OLDA     RESW   1
OLDX     RESW   1
PADDR    RESW   1

. Default data for screen
SCREEN   WORD   X'00B800'
WIDTH    BYTE   X'000050'
HEIGHT   BYTE   X'000019'
.
         END     FIRST