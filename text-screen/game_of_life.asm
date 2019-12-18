. Source (rules): https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
poly	START	0
begin	JSUB	stackinit
	LDX	#0
	LDA	screen
	STA	counter
	. initialization of one of the predefined patterns
	JSUB	pattern1
.==========================================================================
. Main loop: one iterations represents one generation
.	     all changes within the generation are pushed to the stack
.	     and processed at the end of the generation 
.==========================================================================
loop	LDA	screen
	ADDR	X,A
	STA	counter
	JSUB	cells	. in cells procedure we calculate number of neighbors for this cell
	LDA	#0
	LDCH	@counter
	COMP	char
	JEQ	alive
. If the cell is dead and has three neighbors it becomes alive
dead	LDA	nCells 
	COMP	#3
	JEQ	born
	J	contd
. Birth of cell is pushed to the stack
born	LDA	#0	. we ma
	LDA	char
	STA	@stackptr
	JSUB	stackpush
	LDA	counter
	STA	@stackptr
	JSUB	stackpush
	LDA	numElements
	ADD	#1
	STA	numElements
	J	contd
. If the cell is alive it can die because of the under/over-population
alive	LDA	nCells	
	COMP	#2
	JLT	dies
	COMP	#3
	JGT	dies
	J	contd
dies	LDA	#0	. 
	STA	@stackptr
	JSUB	stackpush
	LDA	counter
	STA	@stackptr
	JSUB	stackpush
	LDA	numElements
	ADD	#1
	STA	numElements
. Preperation for the next iteration of this generation
contd	LDA	#1	
	ADDR	X,A
	LDX	#0
	ADDR	A,X
	COMP	scrlen
	JLT	loop
. At the end of geneeration we empty the stack in process the changes
	LDX	#0
empty	LDA	numElements
	COMP	#0
	JEQ	loop
	JSUB	stackpop
	LDA	@stackptr
	STA	saveLoc
	JSUB	stackpop
	LDA	@stackptr
	STCH	@saveLoc
	LDA	numElements
	SUB	#1
	STA	numElements
	J	empty
halt	J	halt
.=====================================================================
. PROCEDURE: calculating number of neighboring cells of the i-th cell
.=====================================================================
cells	STA	regA
	LDA	counter
	STA	tempCo
	LDA	#0
	STA	nCells
	. neighbor x-1,y-1
	LDA	tempCo
	SUB	scrcols
	SUB	#1
	STA	tempNu

	COMP	screen
	JLT	s1
	LDA	#0
	LDCH	@tempNu

	COMP	char
	JLT	s1
	LDA	nCells
	ADD	#1
	STA	nCells	
s1	. neighbor x,y-1
	LDA	tempCo
	SUB	scrcols
	STA	tempNu

	COMP	screen
	JLT	s2
	LDA	#0
	LDCH	@tempNu

	COMP	char
	JLT	s2
	LDA	nCells
	ADD	#1
	STA	nCells

s2	. neighbor	x+1,y-1
	LDA	tempCo
	SUB	scrcols
	ADD	#1
	STA	tempNu

	COMP	screen
	JLT	s3
	COMP	endScr
	JGT	s3
	LDA	#0
	LDCH	@tempNu

	COMP	char
	JLT	s3
	LDA	nCells
	ADD	#1
	STA	nCells

s3	. neighbor x-1,y
	LDA	tempCo
	SUB	#1
	STA	tempNu

	COMP	screen
	JLT	s4
	LDA	#0
	LDCH	@tempNu

	COMP	char
	JLT	s4
	LDA	nCells
	ADD	#1
	STA	nCells

s4	. neighbor x+1,y
	LDA	tempCo
	ADD	#1
	STA	tempNu

	COMP	endScr
	JGT	s5
	LDA	#0
	LDCH	@tempNu

	COMP	char
	JLT	s5
	LDA	nCells
	ADD	#1
	STA	nCells

s5	. neighbor x-1,y+1
	LDA	tempCo
	ADD	scrcols
	SUB	#1
	STA	tempNu

	COMP	endScr
	JGT	s6
	LDA	#0
	LDCH	@tempNu

	COMP	char
	JLT	s6
	LDA	nCells
	ADD	#1
	STA	nCells

s6	. neighbor x,y+1
	LDA	tempCo
	ADD	scrcols
	STA	tempNu


	COMP	endScr
	JGT	s7
	LDA	#0
	LDCH	@tempNu

	COMP	char
	JLT	s7
	LDA	nCells
	ADD	#1
	STA	nCells

s7	. neighbor x+1,y+1
	LDA	tempCo
	ADD	scrcols
	ADD	#1
	STA	tempNu

	COMP	endScr
	JGT	end
	LDA	#0
	LDCH	@tempNu

	COMP	char
	JLT	end
	LDA	nCells
	ADD	#1
	STA	nCells

end	LDA	regA
	RSUB	
. Three hardcoded patterns: oscilator, spaceship in still life form
pattern1
	LDA	start
	STA	counter
	LDA	char
	STCH	@counter
	
	LDA	counter
	ADD	#1
	ADD	scrcols
	STA	counter
	LDA	char
	STCH	@counter

	LDA	counter
	SUB	#1
	STA	counter
	LDA	char
	STCH	@counter

	LDA	counter
	SUB	#1
	STA	counter
	LDA	char
	STCH	@counter	
	RSUB

pattern2
	LDA	start
	STA	counter
	LDA	char
	STCH	@counter
	
	LDA	counter
	ADD	#1
	ADD	scrcols
	STA	counter
	LDA	char
	STCH	@counter

	LDA	counter
	ADD	scrcols
	STA	counter
	LDA	char
	STCH	@counter

	LDA	counter
	SUB	#1
	STA	counter
	LDA	char
	STCH	@counter	

	LDA	counter
	SUB	#1
	STA	counter
	LDA	char
	STCH	@counter	
	RSUB

pattern3
	LDA	start
	STA	counter
	LDA	char
	STCH	@counter
	
	LDA	counter
	ADD	scrcols
	STA	counter
	LDA	char
	STCH	@counter

	LDA	counter
	ADD	scrcols
	STA	counter
	LDA	char
	STCH	@counter

	LDA	counter
	ADD	scrcols
	STA	counter
	LDA	char
	STCH	@counter
	RSUB

.===============================================
. PROCEDURE: Procedures for stack manipulations
.===============================================
stackinit	STA	regA
		LDA	#stack
		STA	stackptr
		LDA	regA
		RSUB
stackpush	STA	regA
		LDA	#3
		ADD	stackptr
		STA	stackptr
		LDA	regA
		RSUB
stackpop	STA	regA
		LDA	stackptr
		SUB	#3
		STA	stackptr
		LDA	regA
		RSUB

stackptr	WORD	0
numElements	WORD	0
saveLoc		WORD	0

regA	WORD	0
. podatki o rutini cells
tempCo	WORD	0
tempNu	WORD	0
nCells	WORD	0
. podatki o zaslonu
screen	WORD	X'00B800'
counter	WORD	0
scrcols	WORD	80
scrrows	WORD	25
scrlen	WORD	2000
endScr	WORD	X'00BFD0'
char	BYTE	0
	BYTE	0
	BYTE	C'X'
start	WORD	47443
stack		RESW	1000

	END 	begin
