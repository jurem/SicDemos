start START 0
	JSUB stackinit
	.stack initialized
	
	LDA #100
rp	COMP #0
	SUB #1
	STA @stackptr
	JSUB stackpush
	
	JEQ hlt
	
	LDA #20
	JSUB sie
	
	LDA c
	LDS #400
	MULR S, A
	LDS #1000
	ADDR S, A
	CLEAR S
	ADDR A, S
	DIV #4095
	MUL #4095
	SUBR A, S
	CLEAR A
	ADDR S, A
	CLEAR S
	
	STA c
	
	CLEAR A
	CLEAR S
	CLEAR X
	CLEAR T
	
	LDA @stackptr
	JSUB stackpop
	J rp

hlt J hlt

sie	STL @stackptr
	JSUB stackpush
	
	STA @stackptr
	JSUB stackpush
	
	CLEAR A
	CLEAR S
	CLEAR T
	CLEAR X
	
	.----SIERPINSKI GASKET
		
beg	JSUB stackpop
	LDA @stackptr
	
	COMP #0
	
	SUB #1
	STA @stackptr
	JSUB stackpush
	
	JEQ fin
	
	.Now lets randomly select one of the
	.three triangle vertices
	CLEAR A
	CLEAR S
	
	LDA seed
	LDS a
	MULR S, A
	LDS c
	ADDR S, A
	CLEAR S
	ADDR A, S
	DIV #4095
	MUL #4095
	SUBR A, S
	CLEAR A
	ADDR S, A
	CLEAR S
	
	STA seed
	
	.Now that we have the random number
	.we check which vertex was selected
	COMP #1365
	JGT two	
	
	LDX #100
	LDT #0
	
	JSUB cal

	J rep
two	COMP #2730
	JGT thr
	
	LDX #0
	LDT #200
	
	JSUB cal
	
	J rep
thr LDX #200
	LDT #200
	
	JSUB cal

rep CLEAR T
	CLEAR X
	
	.finally we draw the pixel
	LDA sty
	LDS stx
	SUB #1
	MUL #200
	ADDR A, S
	
	LDA screen
	STA @stackptr
	JSUB stackpush
	
	ADDR S, A
	STA screen
	
	LDA #255
	STCH @screen
	
	JSUB stackpop
	LDA @stackptr
	STA screen
	
	CLEAR A
	CLEAR S
	J beg
	.----SIERPINSKI GASKET
fin JSUB stackpop

	JSUB stackpop
	LDL @stackptr

	RSUB
	
cal	STL @stackptr
	JSUB stackpush
	
	.Calculating x coordinate
	LDA stx
	LDS stx
	SUBR X, A
	DIV #2
	SUBR A, S
	STS stx
	
	LDA sty
	LDS sty
	SUBR T, A
	DIV #2
	SUBR A, S
	STS sty
	
	JSUB stackpop
	LDL @stackptr
	
	RSUB

stackinit LDA #stck
	STA stackptr
	RSUB

stackpush STA help
	LDA stackptr
	ADD #3
	STA stackptr
	LDA help
	RSUB

stackpop STA help
	LDA stackptr
	SUB #3
	STA stackptr
	LDA help
	RSUB
	
.triangle data

stx WORD 100
sty WORD 100	

seed WORD 1
a WORD 400
c WORD 1000
m WORD 4095

.STACK DATA
.data
stackptr RESW 1
stck RESW 60

.a small helpful buffer
help WORD 0

.SCREEN ADDRESS
screen WORD X'00A000'