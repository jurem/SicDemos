rain  START  0
.blue je 195, general 100
first   
		JSUB 	gene
		JSUB	init
		
infJ
		LDX 	#0

.main endless loop, sets previous position of drop to black, loads new one, moves it and checks if it is 
.off-screen and gets new starting position with offset subroutine
iDrop	
		LDA 	#0
		LDS		drops,X
		STS 	pos
		STCH	@pos

		LDT 	sccol
		ADDR 	T,S

		LDT 	posM
		COMPR   S,T
		JLT 	noGt

		.get random offset
		JSUB    offs
		LDT		randP,X
		LDS 	gscrn
		ADDR    T,S
noGt
		STS 	drops,X

		LDA 	#195
		LDS		drops,X
		STS 	pos
		STCH	@pos

		LDS 	#3
		ADDR 	S,X
		LDS 	count
		COMPR 	X,S
		JLT 	iDrop

		J 		infJ

halt   	J    	halt

.init pos,maxPos,drops etc. add screen start to drop position and set seed of each drop for pseudo random
.algorithm (saved in randP)
init
		LDA		gscrn
		STA 	pos
		LDS		scrow
		LDT 	sccol
		MULR	S,T
		ADDR	T,A
		STA 	posM

		LDA     count
		MUL 	#3
		STA 	count
		.set start of drops
		LDX 	#0
		LDS 	pos
		LDT 	count
iJum
		LDA 	drops,X
		ADD 	pos
		STA 	drops,X
		STX 	randP,X
		LDA     #3
		ADDR    A,X
		COMPR   X,T
		JLT 	iJum
		RSUB

.subroutine to calculate new starting position of drop at the top row of screen, uses pseudo random algorithm and
.seed of each drop (and saves it in the table randP)
offs
		STS 	tempS
		STA 	tempA
		STT 	tempT
		STB 	tempB
		.pseudo random *a+b, 29 and 97
		CLEAR 	A
		CLEAR 	T
		CLEAR 	B
		CLEAR 	S

		LDA 	randP,X
		MUL 	#29
		ADD 	#97
		ADDR 	A,T
		LDS 	sccol
		DIVR	S,A
		MULR	S,A
		SUBR 	A,T
		STT 	randP,X

		LDB 	tempB
		LDA 	tempA
		LDS 	tempS
		LDT 	tempT
		RSUB

.subroutine to generate starting position of drops, uses simple pseudo random algorithm with prime numbers
.and saves the position of each drop to the drops table
gene
		LDX 	#0
		.counter
		LDB 	#0
		LDA 	#5
		LDT 	sccol
		LDS 	scrow
		MULR 	S,T
		STT 	pixels
		CLEAR 	T
		CLEAR 	S

geneJ
		MUL 	#29
		ADD 	#97
		ADDR 	A,T
		LDS 	pixels
		DIVR	S,A
		MULR	S,A
		SUBR 	A,T
		STT 	drops,X
		CLEAR 	A
		ADDR 	T,A
		LDS 	#1
		ADDR 	S,B
		LDS 	#3
		ADDR 	S,X
		LDS 	count
		COMPR   B,S
		CLEAR 	T
		JLT		geneJ
		RSUB
. set count,drops and random to the desired number of drops on screen
. set scrow and sccol to the width and height of the graphical display
. podatki
pixels	WORD 	0
count 	WORD	40
drops   RESW 	40
randP 	RESW 	40
pos		WORD	0
posM	WORD	0
gscrn   WORD    X'00A000'
scrow   WORD    64
sccol   WORD    64
tempS	WORD 	0
tempT	WORD 	0
tempA	WORD 	0
tempB 	WORD 	0
        END     first