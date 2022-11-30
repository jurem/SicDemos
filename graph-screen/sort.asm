sort	START	0
	JSUB	sinit
	JSUB	initbl
	JSUB	srttbl
	JSUB	clrhl
halt	J	halt
err	J	err	. if program halts on this line something went wrong

. Sortes the table
srttbl	+STL	@stkptr
	JSUB	spush
	+STT	@stkptr
	JSUB	spush
	+STS	@stkptr
	JSUB	spush
	+STA	@stkptr
	JSUB	spush
	+STB	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush

	. selection sort
	. set everything to 0
	LDX	#0
strlp1
	+STX	@stkptr
	JSUB	spush
	+STA	@stkptr
	JSUB	spush

	. smallest element index always in S
	RMO	X, S

	. highlight it as smallest
	LDA	#0x0B		. blue
	JSUB	hlelem		. X is already set

	. X should go to next element
	LDA	#1
	ADDR	A, X

strlp2	. loop 2
	. highlight it
	LDA	#0xF0		. red
	JSUB	hlelem		. X is already set

	. element being checked, goes into T
	RMO	X, T

	. compare them
	JSUB	compr
	JLT	strlb1
	JEQ	strlb1

	. T is smaller than S
	+STX	@stkptr
	JSUB	spush

	. clear highlight since it is no longer smallest
	RMO	S, X
	JSUB	clrhl

	. set new smallest
	RMO	T, S

	. higlight new smallest element
	LDA	#0x0B		. blue
	RMO	S, X
	JSUB	hlelem		. X is already set

	JSUB	spop
	+LDX	@stkptr

	. continue (without clearing j)
	J	slp2ex
strlb1	. skip if not smaller

	. clear higlight so next element can be highlighted
	JSUB	clrhl

slp2ex
	TIX	#tblcnt
	JLT	strlp2

	JSUB	spop
	+LDA	@stkptr
	JSUB	spop
	+LDX	@stkptr

	. S contains the smallest one
	RMO	X, T
	JSUB	swap

	. Highlight the new sorted spot in green
	LDA	#0x0C		. green
	JSUB	hlelem

	TIX	#tblcnt
	JLT	strlp1


srtend
	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDB	@stkptr
	JSUB	spop
	+LDA	@stkptr
	JSUB	spop
	+LDS	@stkptr
	JSUB	spop
	+LDT	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. initializes the table contents
initbl	+STL	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush
	+STA	@stkptr
	JSUB	spush
	+STB	@stkptr
	JSUB	spush
	+STS	@stkptr
	JSUB	spush

	LDX	#0
	LDB	#3		. used for multiplying and dividing X register
inilop
	RMO	X, A
	ADD	#1		. 0 would be invisible
	MUL	#23
	LDS	#64		. used for modulo
	JSUB	mod
	ADD	#1		. 0 would be invisible
	MULR	B, X
	STA	table, X
	DIVR	B, X

	LDCH	#0x3F		. all white at start
	STCH	tblcol, X

	. draw element
	RMO	X, A
	JSUB	drawel

	RMO	X, A
	MUL	#3
	ADD	#3
	TIX	#0		. just used so we can easily do +1 on X
	COMP	#tbllen
	JLT	inilop

	JSUB	spop
	+LDS	@stkptr
	JSUB	spop
	+LDB	@stkptr
	JSUB	spop
	+LDA	@stkptr
	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. Calculates modulo of two numbers
. First number in A
. Second number in S
. Returns A % S in A
mod	+STL	@stkptr
	JSUB	spush
	+STS	@stkptr
	JSUB	spush
	+STT	@stkptr
	JSUB	spush
	+STB	@stkptr
	JSUB	spush

	RMO	A, T
	. x%y <=> x-(x/y*y)
	DIVR	S, A
	MULR	S, A
	RMO	A, B
	RMO	T, A
	SUBR	B, A

	JSUB	spop
	+LDB	@stkptr
	JSUB	spop
	+LDT	@stkptr
	JSUB	spop
	+LDS	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. Gets element from table
. Index in X
. Returns value in A
getele	+STL	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush

	. need to multiply for size of word
	LDA	#3
	MULR	A, X
	LDA	table, X

	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. Highlights element
. Color in rightmost byte of register A
. Index in register X
hlelem	+STL	@stkptr
	JSUB	spush
	+STA	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush

	. Update color in color table
	STCH	tblcol, X
	RMO	X, A
	JSUB	drawel

	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDA	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. Cleares the highlight of an element
. Index in register X
clrhl	+STL	@stkptr
	JSUB	spush
	+STA	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush

	. Will just redraw but in white
	. set color
	LDCH	#0xFF
	. update color
	JSUB	hlelem

	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDA	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. Compares two numbers in the table
. Table index one in register S
. Table index two in register T
. Result S : T in SW
compr	+STL	@stkptr
	JSUB	spush
	+STA	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush
	+STS	@stkptr
	JSUB	spush
	+STT	@stkptr
	JSUB	spush

	. multiply so indexes point to right location
	LDA	#3
	MULR	A, S
	MULR	A, T

	. load in data
	RMO	S, X
	LDS	table, X
	RMO	T, X
	LDT	table, X

	. compare
	COMPR	S, T

	JSUB	spop
	+LDT	@stkptr
	JSUB	spop
	+LDS	@stkptr
	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDA	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. Swaps the numbers of two elements in the table. The colors are also moved with the elements.
. Table index one in register S
. Table index two in register T
swap	+STL	@stkptr
	JSUB	spush
	+STA	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush
	+STB	@stkptr
	JSUB	spush
	+STS	@stkptr
	JSUB	spush
	+STT	@stkptr
	JSUB	spush

	. swap colors
	RMO	S, X
	LDCH	tblcol, X
	RMO	A, B
	RMO	T, X
	LDCH	tblcol, X
	RMO	S, X
	STCH	tblcol, X
	RMO	B, A
	RMO	T, X
	STCH	tblcol, X

	. indexes needs to be multiplied by 3 to properly index table
	LDA	#3
	MULR	A, S
	MULR	A, T

	. swap values
	RMO	S, X
	LDA	table, X
	RMO	A, B
	RMO	T, X
	LDA	table, X
	RMO	S, X
	STA	table, X
	RMO	B, A
	RMO	T, X
	STA	table, X

	. redraw the elements
	LDA	#3
	DIVR	A, S
	DIVR	A, T
	RMO	S, A
	JSUB	drawel
	RMO	T, A
	JSUB	drawel

	JSUB	spop
	+LDT	@stkptr
	JSUB	spop
	+LDS	@stkptr
	JSUB	spop
	+LDB	@stkptr
	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDA	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. Draws the table element
. Index in register A
drawel	+STL	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush
	+STT	@stkptr
	JSUB	spush
	+STS	@stkptr
	JSUB	spush
	+STA	@stkptr
	JSUB	spush

	. set column
	RMO	A, S
	. read in height
	MUL	#3
	RMO	A, X
	LDT	table, X
	. get color
	DIV	#3
	RMO	A, X
	LDCH	tblcol, X
	OR	#0xC0		. always do maximum brightness
	. draw
	JSUB	drwcol

	JSUB	spop
	+LDA	@stkptr
	JSUB	spop
	+LDS	@stkptr
	JSUB	spop
	+LDT	@stkptr
	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. Draws a column on the graphical screen
. Pixel data for color in register A
. Column in register S
. Height in register T
drwcol	+STL	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush
	+STT	@stkptr
	JSUB	spush
	+STB	@stkptr
	JSUB	spush
	+STA	@stkptr
	JSUB	spush

	. will start drawing in black (most likely)
	LDCH	#0	. change color to black

	. store how far we gotta draw
	+LDB	#gscrrow
	SUBR	T, B	. at what y coordinate we gotta change color
	. loop over height
	LDX	#0
collop

	. update reg T (height)
	RMO	X, T

	. check if we should switch to right color (should be first thing on stack)
	COMPR	T, B
	JLT	clrskp
	. little hacky, but we pop it, read it, and push it back, so the function trailer will load the correct A register
	JSUB	spop
	+LDA	@stkptr
	JSUB	spush
clrskp

	. draw pixel
	JSUB	drawpx

	. repeat unless tall enough
	+TIX	#gscrrow
	JLT	collop

	JSUB	spop
	+LDA	@stkptr
	JSUB	spop
	+LDB	@stkptr
	JSUB	spop
	+LDT	@stkptr
	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. Draws a pixel on the screen, note that this function performs bound checks based on the gscrrow and gscrcol variables. If the coordinates are out of bounds this function will halt the program on the err label.
. Pixel data in register A
. X coord in register S
. Y coord in register T
drawpx	+STL	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush
	+STB	@stkptr
	JSUB	spush

	RMO	A, B	. temporarily store pixel information so calculation can be done in A
	. calculate screen position
	RMO	T, A
	MUL	#gscrcol
	ADDR	S, A
	RMO	A, X

	. check if out of bounds (can be removed after development is done for faster times)
	+COMP	#gscrsz
	JGT	err
	COMP	#0
	JLT	err

	. load back in pixel information
	RMO	B, A

	. draw pixel
	+STCH	gscrptr, X

	JSUB	spop
	+LDB	@stkptr
	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB


. Basic stack functionality routines
sinit	LDA	#stack
	ADD	#stklen
	SUB	#3
	+STA	stkptr
	RSUB

spush	STA	spptmp
	+LDA	stkptr
	SUB	#3
	+STA	stkptr
	LDA	spptmp
	RSUB

spop	STA	spptmp
	+LDA	stkptr
	ADD	#3
	+STA	stkptr
	LDA	spptmp
	RSUB

. stack push and stack pop temporary variables, shared since no multi threading
spptmp	RESW	1

stack	RESW	1000
stkend	EQU	*
stkptr	RESW	1
stklen	EQU	stkend - stack

gscrptr	EQU	0xA000
gscrrow EQU	64
gscrcol EQU	64
gscrsz	EQU	gscrrow * gscrcol
gscrmxr EQU	gscrrow - 1		. maximum row

table	RESW	64
tblend	EQU	*
tbllen	EQU	tblend - table
tblcnt	EQU	tbllen / 3

tblcol	RESB	64
tbcend	EQU	*
tbclen	EQU	tbcend - tblcol


	END	sort
