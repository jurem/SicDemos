life	START	0

. constants
scrorg	EQU		0xA000
scrrows	EQU		64
scrcols EQU		64
scrsize EQU		scrrows * scrcols
scrend	EQU		scrorg + scrsize
scrbuf	EQU		scrend

. main program
first   JSUB	glider

forever CLEAR	X
loop	LDA		#0xFF
		. count number of alive neighbors
		CLEAR	S
		JSUB	alivelo
		JSUB	alivehi
		. decide depending on the number
		LDB		#2
		COMPR	S, B	. if S < 2
		JLT 	clr
		LDB		#3
		COMPR	S, B	. if S < 3
		JLT		cpy
		LDB		#4
		COMPR	S, B	. if S < 4
		JLT		set		. else clear
clr 	CLEAR	A
		J 		go
set		LDCH	#0xFF
		J       go
cpy		+LDCH	scrorg, X
go		+STCH	scrbuf, X
		+TIX	#scrsize
		JLT		loop
		. copy buf to screen
		CLEAR 	X
loop2	+LDCH 	scrbuf, X
		+STCH 	scrorg, X
		+TIX	#scrsize
		JLT		loop2
		J 		forever

. count left up neighbours of cell at offset X
. dirties T, B, A
alivelo	LDT		#1 		. T = 1
		CLEAR	B		. B = 0
		. X = X - scrcols - 1
		LDA		#scrcols
		ADDR	T, A
		SUBR	A, X
		. if X >= 0 then check cell
		COMPR 	X, B
		JLT		c2
		. check cell
		+LDCH	scrorg, X
		COMP	=0
		JEQ		c2
		ADDR	T, S
. cell 2: -scrcols
c2		ADDR	T, X
		COMPR	X, B
		JLT		c3
		+LDCH	scrorg, X
		COMP	=0
		JEQ		c3
		ADDR	T, S
. cell 3: -scrcols+1
c3		ADDR	T, X
		COMPR	X, B
		JLT		c4
		+LDCH	scrorg, X
		COMP	=0
		JEQ		c4
		ADDR	T, S
. cell 4: -1
c4		LDA		#scrcols
		SUBR	T, A
		SUBR	T, A
		ADDR	A, X
		COMPR	X, B
		JLT		endalo
		+LDCH	scrorg, X
		COMP	=0
		JEQ		endalo
		ADDR	T, S
endalo	ADDR	T, X
		RSUB

. count left up neighbours of cell at offset X
. dirties T, B, A
alivehi	LDT		=1 			. T = 1
		+LDB	#scrsize	. B = scrsize
		. X = X + scrcols + 1
		LDA		#scrcols
		ADDR	T, A
		ADDR	A, X
		. if X < scrsize then check cell
		COMPR 	X, B
		JGT		c6
		. check cell
		+LDCH	scrorg, X
		COMP	=0
		JEQ		c6
		ADDR	T, S
. cell 6: +scrcols
c6		SUBR	T, X
		COMPR	X, B
		JGT		c7
		+LDCH	scrorg, X
		COMP	=0
		JEQ		c7
		ADDR	T, S
. cell 7: +scrcols-1
c7		SUBR	T, X
		COMPR	X, B
		JGT		c8
		+LDCH	scrorg, X
		COMP	=0
		JEQ		c8
		ADDR	T, S
. cell 8: +1
c8		LDA		#scrcols
		SUBR	T, A
		SUBR	T, A
		SUBR	A, X
		COMPR	X, B
		JGT		endahi
		+LDCH	scrorg, X
		COMP	=0
		JEQ		endahi
		ADDR	T, S
endahi	SUBR	T, X
		RSUB

glider	CLEAR 	A
		SUB     #1
		LDX		#1
		+STCH	scrorg, X
		LDX		#66
		+STCH	scrorg, X
		LDX		#128
		+STA	scrorg, X
		RSUB

		END 	first
