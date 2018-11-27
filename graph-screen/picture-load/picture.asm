pic		START  0

. -------------------------- MAIN ----------------------------
main	JSUB 	sinit

		. size check
		RD		dev
		STA 	maxY
		COMP 	scrwdth
		JGT 	error
		RD 		dev
		STA 	maxX
		COMP 	scrwdth
		JGT 	error
		
		. calculate stop address
		LDA 	maxY
		SUB 	one
		MUL 	scrwdth
		ADD 	maxX
		SUB 	one
		ADD 	screen
		STA 	stpAddr

		. draw
mloop	LDA 	currY
		MUL 	scrwdth
		ADD 	currX
		ADD 	screen
		STA 	currA

		COMP 	stpAddr	
		JGT 	halt	

		RD 		dev	
		STCH 	@currA

		LDA 	currX
		ADD 	one
		COMP 	maxX
		JEQ 	incY
		J 		goodX
incY	CLEAR	A
		STA 	currX
		LDA 	currY	
		ADD 	one
		STA 	currY
		J 		mloop
goodX	STA 	currX
		J 		mloop

error 	LDA 	#niz1
		JSUB 	echostr
		JSUB 	echonl

halt    J		halt
. --------------------------- END MAIN -----------------------


. -------------------- ECHO A C STRING ----------------------
echostr	STL		@sptr 		
		JSUB 	spush
		STA		@sptr 		
		JSUB 	spush

		STA 	currStr
loop	LDA		@currStr
		SHIFTR	A,16
		COMP	zero
		JEQ		echose
		WD 		stdout		. write it out
		LDA		currStr		. increment current pointer
		ADD		one
		STA 	currStr
		J		loop

echose	JSUB	spop
		LDA 	@sptr
		JSUB	spop
		LDL 	@sptr
		RSUB
. ---------------------------------------------------

. ------------------------ ECHO NEW LINE -------------------
echonl	STL		@sptr 		
		JSUB 	spush
		STA		@sptr 		
		JSUB 	spush

		LDA 	#10
		WD		stdout
		
		JSUB	spop
		LDA 	@sptr
		JSUB	spop
		LDL 	@sptr
		RSUB
. -----------------END ECHO NEW LINE -----------------------


.	--------------- STACK FUNCTIONS -------------------
sinit	STA 	stackr
		LDA		#spos
		STA 	sptr
		LDA     stackr
		RSUB

spush	STA 	stackr
		LDA		sptr
		ADD 	wlen
		STA     sptr	
		LDA     stackr
		RSUB

spop	STA 	stackr
		LDA		sptr
		SUB 	wlen
		STA     sptr	
		LDA     stackr
		RSUB
.   ---------------------------------------------------


.   ------------- DATA -------------------------
zero	WORD	0
one		WORD 	1
two 	WORD 	2
stdout 	BYTE 	1
dev		BYTE 	X'A0'
screen 	WORD 	X'00A000'
scrwdth	WORD 	64
currStr RESW 	1

niz1	BYTE	C'Input picture to large.'
		BYTE	0

currY 	WORD 	0	
currX	WORD 	0
maxY 	RESW 	1
maxX 	RESW 	1
stpAddr	RESW 	1
currA 	RESW 	1
. 	-------------------------------------------

. 	--------------- STACK DATA ----------------
wlen    WORD    3
stackr	RESW	1
sptr	RESW	1
spos	EQU		*
stack 	RESW 	4096
.   -------------------------------------------

        END    main

        