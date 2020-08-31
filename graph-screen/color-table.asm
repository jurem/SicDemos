... -------------------------------
... |    C O L O R   T A B L E    |
... -------------------------------
... Author: Jakob Erzar
... Plugins: Graphical screen
...	- Rows: 109 (4 * 16 + 3 * 15)
...	- Columns: 109
... Frequency: 100 000 Hz = 100 kHz
colors	START	0
	... init the stack
	JSUB	stInit
	... draw the grid
	JSUB	drGrid
	... draw the colors
	JSUB	drCls
	... halt
halt	J	halt



... Draw the table grid
drGrid	STL	@stPtr	. Push L to stack
	JSUB	stPush
	...
	LDA	dispAd
	STA	addr
	CLEAR	T	. T stores the current row
	STT	curRow
	... draw one row of the table grid
drGrRow CLEAR	X	. X stores the current column
	LDB	white	. B stores the color
	LDS	spClRwL	. S stores column / row limit
drGrCol	LDA	addr
	ADD	#4
	JSUB	drPxl
	ADD	#2
	JSUB	drPxl
	ADD	#1
	STA	addr
	TIXR	S
	JLT	drGrCol
	... one row was written, but we have 4 pixels per row
	ADD	#4
	STA	addr
	... loop row
	RMO	T, A
	ADD	#1
	RMO	A, T
	COMP	#4	. Check if still under 4 pixels per row
	JLT	drGrRow
	... one complete row was written
	LDA	curRow
	COMPR	A, S
	.--------------
	JEQ	drGy	. We have drawn enough rows
	.--------------
	ADD	#1
	STA	curRow
	... we now have to draw two horizontal lines
drHrLns	CLEAR	T
	CLEAR	X	. Store the current line to stack (0 of 2)
	STX	@stPtr
	JSUB	stPush
drHrLn	CLEAR	X	. X stores the current columnt
	LDS	#5	. S stores the next black column
	LDA	addr	. A stores the current address
drHrLnC	JSUB	drPxl	. Draw
	ADD	#1
	TIX	cols
	JEQ	drHrLnO	. Go out if crossed limit
	COMPR	X, S	. Check if should skip black line
	JLT	drHrLnC
	ADD	#1
	STA	addr
	TIXR	X	. x++
	RMO	S, A	. Update black column index
	ADD	#7
	RMO	A, S
	LDA	addr
	J	drHrLnC
	... we have now drawn a horizontal line
	... check if we have written both lines
drHrLnO	STA	addr
	JSUB	stPop
	LDA	@stPtr
	ADD	#1
	COMP	#2
	JEQ	drGrRow
	STA	@stPtr
	JSUB	stPush
	... we need to draw another one
	LDA	addr
	ADD	cols	. Add black line in between
	STA	addr
	J	drHrLn

	... draw the gray separator lines
	... start with the vertical lines
drGy	LDA	dispAd
	STA	addr
	CLEAR	T	. T stores the current row
	STT	curRow
	LDB	gray	. B stores the color
	LDS	#3	. S stores column limit
	... draw one row of the table grid
drGyRow CLEAR	X	. X stores the current column
drGyCol	LDA	addr
	ADD	#26
	JSUB	drPxl
	ADD	#2
	STA	addr
	TIXR	S
	JLT	drGyCol
	... we have now drawn all the pixels in this row
	ADD	#25
	STA	addr
	RMO	T, A
	COMP	#spClRwL . Check if rows done
	ADD	#1
	RMO	A, T
	JLT	drGyRow
	... we have now drawn all of the vertical gray lines
drHy	LDA	dispAd
	STA	addr
	CLEAR	T	. T stores the current row
	LDB	gray	. B stores the color
	LDS	cols	. S stores the column limit
drHyLn	CLEAR	X	. X stores the current column
	CLEAR	A
	LDA	cols
	MUL	#26	. 3x7 rows + 1x5 row
	ADD	addr
	STA	addr
drHyCol	LDA	addr
	JSUB	drPxl
	ADD	#1
	STA	addr
	TIXR	S
	JLT	drHyCol
	... we have now drawn a horizal gray line
	ADD	cols
	STA	addr
	RMO	T, A
	ADD	#1
	RMO	A, T
	COMP	#4	. Check if we have drawn all lines
	JLT	drHyLn
	... we have drawn all lines, exit
	J	drGrOut

	... all rows have been written
	... restore stack
drGrOut	JSUB	stPop
	LDL	@stPtr
	RSUB



... Draw the actual colors
drCls	... save registers
	STL	@stPtr
	JSUB	stPush
	JSUB	stAllPu
	... init registers
	LDA	dispAd	. Use A / addr for current address
	STA	addr
	CLEAR	B	. Use B for current color
	LDS	colRowL	. Use S for column / row limit
	CLEAR	X	. Use X for columns
	CLEAR	T	. Use T for rows
	... start drawing
drClsRw	CLEAR	X
drClsCl	STA	@stPtr
	JSUB	stPush	. Push current address to stack
	... draw the square
	JSUB	drSq
	... update color
	RMO	B, A
	ADD	#1
	RMO	A, B
	... update address
	JSUB	stPop
	LDA	@stPtr
	ADD	#7
	... check column boundary
	TIXR	S
	JLT	drClsCl
	... the row is finished
	... update address - skip horizontal line
	SUB	#3
	ADD	cols
	ADD	cols
	ADD	cols
	ADD	cols
	ADD	cols
	ADD	cols
	... check row boundary
	RMO	T, X
	TIXR	S
	RMO	X, T
	JLT	drClsRw
	... finished drawing
	... pop registers
	JSUB	stAllPo
	JSUB	stPop
	LDL	@stPtr
	RSUB



... -------------------------------
... |       H E L P E R S         |
... -------------------------------
... Draw a pixel of color (reg B) to address (reg A)
drPxl	STA	addr
	RMO	B, A
	STCH	@addr
	LDA	addr
	RSUB

... Draw a 4x4 square of color (reg B) to address starting at (reg A)
drSq	... push all regs
	STL	@stPtr
	JSUB	stPush
	JSUB	stAllPu
	... init regs
	CLEAR	X	. X stores the current column
	CLEAR	T	. T stores the current row
	LDS	#4	. S stores the limit
drSqRw	CLEAR	X
	... draw the 4 pixels in the row
drSqCl	JSUB	drPxl
	ADD	#1
	TIXR	S
	JLT	drSqCl
	... check if done
	STA	addr
	RMO	T, X
	TIXR	S
	JEQ	drSqOut	. Jump out if done
	RMO	X, T
	LDA	addr
	ADD	cols
	SUB	#4
	J	drSqRw
drSqOut	... pop all regs
	JSUB	stAllPo
	JSUB	stPop
	LDL	@stPtr
	RSUB


... -------------------------------
... |          D A T A            |
... -------------------------------
... Temp vars
tmp	RESW	1
addr	RESW	1

... Display configuration
dispAd	WORD	X'00A000'
cols	WORD	109	. Amount of columns on display

... Colors
black	WORD	0x00
gray	WORD	0xEA
white	WORD	0xFF

... Grid
spClRwL	WORD	15	. Separator column / row limit
colRowL	WORD	16	. Column / row limit
curRow	WORD	0


... -------------------------------
... |         S T A C K           |
... -------------------------------

... Subroutine Stack Initialize
stInit	LDA	#stStart
	STA	stPtr
	RSUB
... Subroutine Stack Push
stPush	STA	stStA
	LDA	stPtr
	ADD	#3
	STA	stPtr
	LDA	stStA
	RSUB
... Subroutine Stack Pop
stPop	LDA	stPtr
	SUB	#3
	STA	stPtr
	RSUB
... Subroutine Push All (except L)
stAllPu	STL	stStL	. Store L in memory
	STA	@stPtr
	JSUB	stPush	. Push A
	STB	@stPtr
	JSUB	stPush	. Push B
	STS	@stPtr
	JSUB	stPush	. Push S
	STT	@stPtr
	JSUB	stPush	. Push T
	STX	@stPtr
	JSUB	stPush	. Push X
	LDL	stStL	. Load L from memory
	RSUB
... Subroutine Pop All (except L)
stAllPo	STL	stStL	. Store L in memory
	JSUB	stPop
	LDX	@stPtr	. Pop X
	JSUB	stPop
	LDT	@stPtr	. Pop T
	JSUB	stPop
	LDS	@stPtr	. Pop S
	JSUB	stPop
	LDB	@stPtr	. Pop B
	JSUB	stPop
	LDA	@stPtr	. Pop A
	LDL	stStL	. Load L from memory
	RSUB

... Stack variables
stPtr	RESW	1
stStart	RESW	200
stStL	RESW	1
stStA	RESW	1



	... All good things come to an end :)
	END	colors