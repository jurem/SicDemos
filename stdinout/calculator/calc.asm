calc    START   0
nextln  LDA	#stack
        STA	sp
        CLEAR	A
        STA	ldigit
readlp  TD      stdin
        JEQ     readlp
        CLEAR	A
        RD      stdin
        COMP    #0
        JEQ     halt
        COMP	white   .whitespace (parse number?)
        JEQ	newexp
        COMP    opn     . (
        JEQ	newexp
        COMP	cls     . )
        JEQ	endexp
        COMP	plus    . +
        JEQ	pplus
        COMP	minus   . -
        JEQ	pminus
        COMP	times   . *
        JEQ	ptimes
        COMP	slash   . /
        JEQ	pslash
        COMP	lnfeed  . \n
        JEQ	prtres
        J	pdigit


newexp  CLEAR	A
        STA	ldigit
        J	readlp
endexp  CLEAR	A
        STA	ldigit
        LDA	sp
        SUB	#3
        STA	sp
        LDS	@sp
        SUB	#3
        STA	sp
        LDT	@sp
        SUB	#3
        STA	sp
        LDA	@sp
        COMP	plus    . +
        JEQ	xplus
        COMP	minus   . -
        JEQ	xminus
        COMP	times   . *
        JEQ	xtimes
        COMP	slash   . /
        JEQ	xslash
pres    STT	@sp
        LDA	sp
        ADD	#3
        STA	sp
        J	readlp

pplus   CLEAR	A
        STA	ldigit
        LDA	plus
        STA	@sp
        LDA	sp
        ADD	#3
        STA	sp
        J	readlp
pminus  CLEAR	A
        STA	ldigit
        LDA	minus
        STA	@sp
        LDA	sp
        ADD	#3
        STA	sp
        J	readlp
ptimes  CLEAR	A
        STA	ldigit
        LDA	times
        STA	@sp
        LDA	sp
        ADD	#3
        STA	sp
        J	readlp
pslash  CLEAR	A
        STA	ldigit
        LDA	slash
        STA	@sp
        LDA	sp
        ADD	#3
        STA	sp
        J	readlp
pdigit  SUB	zero
        RMO	A,B
        LDA	ldigit
        COMP	#1
        JEQ	pndgit
pcdgit  RMO	B,A
        STA	@sp
        LDA	sp
        ADD	#3
        STA	sp
        LDA	#1
        STA	ldigit
        J	readlp
pndgit  LDA	sp
        SUB	#3
        STA	sp
        LDA	@sp
        MUL	#10
        ADDR	A,B
        J	pcdgit

xplus   ADDR	S,T
        J	pres
xminus  SUBR	S,T
        J	pres
xtimes  MULR	S,T
        J	pres
xslash  DIVR	S,T
        J	pres

prtres  LDB	#base
        STB	bp
        LDA	sp
        SUB	#3
        STA	sp
        LDA	@sp
        AND	negsgn
        COMP	negsgn
        JEQ	prtneg
prtnxt  LDA	@bp
        COMP	#0
        JEQ	prtext
        LDA	@sp
        DIV	@bp
        ADD	zero
        WD	stdout
        SUB	zero
        LDB	@bp
        MULR	B,A
        LDB	@sp
        SUBR	A,B
        STB	@sp
        LDA	bp
        ADD	#3
        STA	bp
        J	prtnxt
prtext
        LDA	lnfeed
        WD	stdout
        J	nextln
prtneg
        LDA	minus
        WD	stdout
        LDA	#0
        SUB	#1
        LDS	@sp
        MULR	S,A
        STA	@sp
        J	prtnxt



halt    J       halt

stdin   BYTE    0x00
stdout  BYTE    0x01
zero    WORD    48
lnfeed  WORD    10
white   WORD    32
opn     WORD    40
cls     WORD    41
plus    WORD    43
minus   WORD    45
times   WORD    42
slash   WORD    47

ldigit  WORD    0
negsgn  WORD    0x800000

bp      RESW    1
base    WORD    10000000
        WORD    1000000
        WORD    100000
        WORD    10000
        WORD    1000
        WORD    100
        WORD    10
        WORD    1
        WORD    0

sp      RESW    1
stack   RESW    256
