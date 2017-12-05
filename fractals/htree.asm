. program: Fractal - H tree (factor 2) for graphical screen
. author: Klanjscek Klemen

frach	START	 0

. MAIN PROGRAM
		. stack initialisation
first	JSUB sinit

		.initial values for subroutine rfrac
		LDA		scrrow
		DIV 	#2
		RMO		A,S
		RMO		A,T
		JSUB	rfrac	
halt	J	halt

. main subroutine rfract. Draws H size of A, centered at (S,T)
. @params: A - H size, S - x-axis, T - y-axis
rfrac	STA		dissp
		
		. color randomizer
		ADD		#4
		MUL		#5	
		SUB		#1
		DIV		#3
		AND		#255
		OR		#192
		STA		color
		
		. calculate diplacemet
		LDA		dissp
		DIV		#2
		STA		dissp
		
		. break statent
		COMP	minlen
		JLT		endfrac
		
		. save retaddr
		STL		@sp
		JSUB	spush
		 
	. DRAWING H
	. calculate params/points for drawL, (x1,y1)-->(x2,y2)
	. draw lines with subrutine drawL
	. store points: (x11,y11), (x12,y12), (x21,y21), (x12,y12) for recursive calls
		
		. horizontal line
		RMO		S,A
		SUB		dissp
		STA		x1
		
		RMO		S,A
		ADD		dissp
		STA		x2
		
		STT		y1
		STT		y2
		
		JSUB	drawL
		
		. left vertical line
		RMO		S,A
		SUB		dissp
		STA		x1
		STA		x2
		STA		x11
		STA		x12
		
		RMO		T,A
		SUB		dissp
		STA		y1
		STA		y11
		
		RMO		T,A
		ADD		dissp
		STA		y2
		STA		y12

		JSUB	drawL
		
		. right vertical line
		RMO		S,A
		ADD		dissp
		STA		x1
		STA		x2
		STA		x21
		STA		x22
		
		RMO		T,A
		SUB		dissp
		STA		y1
		STA		y21
		
		RMO		T,A
		ADD		dissp
		STA		y2
		STA		y22
		
		JSUB	drawL
	.end of DRAWING H
		
		. push params for 2. 3. 4. recusive call
		LDA		x12
		STA		@sp
		JSUB	spush
		
		LDA		y12
		STA		@sp
		JSUB	spush
		
		LDA		x21
		STA		@sp
		JSUB	spush
		
		LDA		y21
		STA		@sp
		JSUB	spush
		
		LDA		x22
		STA		@sp
		JSUB	spush
		
		LDA		y22
		STA		@sp
		JSUB	spush

		LDA		dissp
		STA		@sp
		JSUB	spush
		
		. set params for 1. recursive call
		LDA		dissp
		LDS		x11
		LDT		y11
		
		. 1. rec call (draw H top-left)
		JSUB	rfrac
		
		. set params for 2. recursive call
		JSUB	spop
		LDA		@sp
		
		JSUB	spop
		LDT		@sp
		
		JSUB	spop
		LDS		@sp
		
		. store displacemet for 3. rec calls
		STA		@sp
		JSUB	spush
		
		. 2. rec call (draw H bottom-right)
		JSUB	rfrac
		
		. set params for 3. recursive call
		JSUB	spop
		LDA		@sp
		
		JSUB	spop
		LDT		@sp
		
		JSUB	spop
		LDS		@sp
		
		. store displacemet for 4. rec calls
		STA		@sp
		JSUB	spush
		
		. 3. rec call (draw H top-right)
		JSUB	rfrac
		
		. set params for 4. recursive call
		JSUB	spop
		LDA		@sp
		
		JSUB	spop
		LDT		@sp
		
		JSUB	spop
		LDS		@sp
		
		. 4. rec call (draw H bottom-left)
		JSUB	rfrac
		
		. retrieve return addres
		JSUB 	spop
		LDL		@sp
endfrac	RSUB	

. subroutine drawL	
. draw line form (x1,y2) to (x2,y2), precondition x1 <= x2 && y1 <= y2
. @params point (x1,y2), point (x2,y2), scrcol - screen columns, scrrow - screen rows, scrp - screen addres
 
drawL	STA		tmp1
		STX		tmp2
		STS		tmp3
		LDA		x1
		COMP	x2
		JEQ		drawcol
		
		. drowing row
		. (scrp + srccol*y1 + [x1 ... x2])
		LDA		scrcol
		MUL		y1
		STA		eol
		SUB		#2
		ADD		x1
	
		RMO		A,X
		LDA		x2
		ADD		eol
		SUB		#1
		STA		eol
		
loopd1	+LDA	scrp,X
		AND		resetc
		ADD		color
		+STA 	scrp,X
		TIX		eol
		JLT		loopd1
		
		LDA		tmp1
		LDX		tmp2
		LDS		tmp3
		RSUB
		
		. drowing column
		. (scrp + srccol*[y1 ... y2] + x1)
drawcol	LDA		x1
		SUB		#2
		STA		x1
		LDS		scrcol
		LDA		scrcol
		MUL		y1
		ADD		x1
		RMO 	A,X
		LDA		scrcol
		MUL		y2
		ADD		x1
		ADDR	S,A
		STA		eol

loopd2	+LDA	scrp,X
		AND		resetc
		ADD		color
		+STA 	scrp,X
		ADDR	S,X
		RMO		X,A
		COMP	eol
		JLT		loopd2
		
		LDA		tmp1
		LDX		tmp2
		LDS		tmp3
		RSUB

. push and pop implementation	
spush	STA		stack_a
		LDA		sp
		ADD		#3
		STA		sp
		LDA		stack_a
		RSUB

spop	STA		stack_a
		LDA		sp
		SUB		#3
		STA		sp
		LDA		stack_a
		RSUB

. stack initialisation
sinit	LDA		#stack
		STA		sp
		RSUB	

		END		first

. SETTINGS and OTHER VARS
. graphical screen addres
scrp	EQU		40960

. number of rows and columns, precondition (scrrow == scrcol)
scrrow	WORD	333
scrcol	WORD	333

.minimal length of diplacemet, precondition (minlen > 0)
minlen	WORD	3

. color init
color	WORD	194

resetc	WORD	X'FFFF00'
dissp	RESW	1

. vars used for points
x1		RESW 	1
x2		RESW	1
y1		RESW	1
y2		RESW	1
x11		RESW 	1
x12		RESW	1
y11		RESW	1
y12		RESW	1
x21		RESW 	1
x22		RESW	1
y21		RESW	1
y22		RESW	1

. "last" point in a line
eol		RESW	1 

. temporary vars (used for conserving regs)
tmp1	RESW	1
tmp2	RESW	1
tmp3	RESW	1
stack_a	RESW	1

.stack pointer and stack
sp		RESW	1
stack	RESW	4096