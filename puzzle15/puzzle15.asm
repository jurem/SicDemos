puzzle	START	0

. 15 PUZZLE
. text screen is 80x25, at 0xB800, 2000 bytes long
. keyboard is at 0xC000
. WASD = move numbered tiles
. R = create new puzzle
. Q = quit
main	J	newgame

. ======== get a new seed from the player ========
newgame	JSUB	scrclr
. print title
	LDS	scrbase
	LDA	#title
	JSUB	text
. print seed things
	LDA	scrbase
	ADD	bseseedmsg
	RMO	A, S
	LDA	#seedmsg
	JSUB	text

	LDA	scrbase
	ADD	bseseedln
	RMO	A, S
	LDA	#seedln
	JSUB	text

	CLEAR	A
	STA	seed
	STA	nkeys

seedloop
	JSUB	rdkeybrd
	STA	keycode
. build a 23-bit seed from the 10 key codes
. hash = (hash * 31 + keycode) mod 2^23
	LDA	seed
	MUL	#31
	ADD	keycode
	AND	mask
	STA	seed
. replace one _ with a *
	LDA	scrbase
	ADD	bseseedln
	ADD	nkeys
	STA	scrptr
	LDA	#42
	STCH	@scrptr
	LDA	nkeys
	ADD	#1
	STA	nkeys
	COMP	#10
	JLT	seedloop

. === start with a solved board, then shuffle ===
	CLEAR	X
. init board
initloop
	CLEAR	A
	LDCH	solvedbrd,X
	STCH	board,X
	TIX	#16
	JLT	initloop
. empty holds index of empty square
. prevpos holds index of previous empty square
.	(used so that we don't move back and forth)
.	(set to 16 so first move is always valid)
. shufcnt holds number of moves made during shuffling
. moves holds number of moves made by player
	LDA	#15
	STA	empty
	LDA	#16
	STA	prevpos
	CLEAR	A
	STA	shufcnt
	STA	moves
. generate pseudorandom legal moves 
shufloop
	LDA	seed
	MUL	#109
	ADD	#1021
	AND	mask
	STA	seed
. use higher bits of seed (/ 2^16)
. lower bits are less random
	+DIV	#65536
	AND	#3
	COMP	#0
	JEQ	shup
	COMP	#1
	JEQ	shdown
	COMP	#2
	JEQ	shleft
	J	shright

. if the move is illegal, try again, don't count it as a move
shup	LDA	empty
	COMP	#4
	JLT	shufloop
	SUB	#4
	J	shapply
shdown	LDA	empty
	COMP	#11
	JGT	shufloop
	ADD	#4
	J	shapply
shleft	LDA	empty
	AND	#3
	COMP	#0
	JEQ	shufloop
	LDA	empty
	SUB	#1
	J	shapply
shright	LDA	empty
	AND	#3
	COMP	#3
	JEQ	shufloop
	LDA	empty
	ADD	#1
	
shapply	
. if we did a back and forth, try again, don't count it as a move
	COMP	prevpos
	JEQ	shufloop
. apply the move
. target holds the index of the tile we want to swap with
	STA	target
	LDA	empty
	STA	prevpos
	LDA	target
	JSUB	doswap
	LDA	shufcnt
	ADD	#1
	STA	shufcnt
	COMP	shuffles
	JLT	shufloop
. if after all shuffling, the board is solved, redo
	JSUB	checkwin
	COMP	#1
	JEQ	shufloop
. ===============================================


. ======== draw board and enter game loop ========
startgame
	JSUB	scrclr
	LDS	scrbase
	LDA	#title
	JSUB	text

	LDA	scrbase
	ADD	bsehelp
	RMO	A, S
	LDA	#help
	JSUB	text

	LDA	scrbase
	ADD	bsemovlbl
	RMO	A, S
	LDA	#movlbl
	JSUB	text
	JSUB	drawboard
	JSUB	drawmoves
	J	game

. ================================================

. ========= keyboard and  tile movement =========
game	JSUB	rdkeybrd
	AND	#223	. convert lowercase to uppercase
	COMP	#81
	JEQ	halt
	COMP	#82
	JEQ	newgame

	COMP	#87
	JEQ	down	. W moves numbered tile UP
	COMP	#83
	JEQ	up	. S moves numbered tile DOWN
	COMP	#65
	JEQ	right	. A moves numbered tile LEFT
	COMP	#68
	JEQ	left	. D moves numbered tile RIGHT
	J	game

up	LDA	empty
	COMP	#4
	JLT	game
	SUB	#4
	J	swap
down	LDA	empty
	COMP	#11
	JGT	game
	ADD	#4
	J	swap
left	LDA	empty
	AND	#3
	COMP	#0
	JEQ	game
	LDA	empty
	SUB	#1
	J	swap
right	LDA	empty
	AND	#3
	COMP	#3
	JEQ	game
	LDA	empty
	ADD	#1

swap	JSUB	doswap
	LDA	moves
	ADD	#1
	STA	moves
	JSUB	drawboard
	JSUB	drawmoves
	JSUB	checkwin
	COMP	#1
	JEQ	victory
	J	game
. ===============================================


. ========== perform the swap in memory ==========
. A holds the destination index of the empty space
doswap	STA	target
	RMO	A, X
	CLEAR	A
	LDCH	board, X
	LDX	empty
	STCH	board, X
	CLEAR	A
	LDX	target
	STCH	board, X
	LDA	target
	STA	empty
	RSUB
. ================================================


. ====== victory text and wait for new game ======
victory	LDA	scrbase
	ADD	bsewintxt
	RMO	A, S
	LDA	#wintxt
	JSUB	text
vwait	JSUB	rdkeybrd
	AND	#223
	COMP	#82
	JEQ	newgame
	COMP	#81
	JEQ	halt
	J	vwait
halt	J	halt
. ================================================


. ============= read keyboard input =============
. key is returned in A
rdkeybrd
	STT	tsave
	CLEAR	A
	STCH	@keybrd
keyloop	CLEAR	A
	LDCH	@keybrd
	COMP	#0
	JEQ	keyloop
	RMO	A, T
	CLEAR	A
	STCH	@keybrd
	RMO	T, A
	LDT	tsave
	RSUB
. ===============================================


. ============== clear text screen ==============
scrclr	STT	tsave

	LDA	scrbase
	STA	scrptr

	. txt screen is 2000 bytes
	ADD	scrlen
	RMO	A, T

. T holds end of screen
cloop	LDA	#0
	STCH	@scrptr
	
	LDA	scrptr
	ADD	#1
	STA	scrptr
	COMPR	A, T
	JLT	cloop

	LDT	tsave
	RSUB
. ===============================================

. ==== print zero-terminated string to screen ====
. A holds address of string
. S holds address on screen
text	STA	txtsrc
	RMO	S, A
	STA	txtdst

tloop	
. print out the character
	CLEAR	A
	LDCH	@txtsrc
	COMP	#0
	JEQ	tend
	STCH	@txtdst

. increment
	LDA	txtsrc
	ADD	#1
	STA	txtsrc
	LDA	txtdst
	ADD	#1
	STA	txtdst
	J	tloop
tend	RSUB
. ===============================================


. ======= draw board from memory to screen =======
drawboard
	STT	tsave
	LDA	scrbase
	ADD	bseboard
	STA	scrptr
	CLEAR	X

. X holds current index in the board
. T holds the value stored at that index
bloop	CLEAR	A
	LDCH	board, X
	RMO	A, T
	COMP	#10
	JLT	cleartens
	LDA	ascii0
	ADD	#1
	J	puttens

cleartens
	CLEAR	A

puttens	STCH	@scrptr
	LDA	scrptr
	ADD	#1
	STA	scrptr

. empty tile
	RMO	T, A
	COMP	#0
	JEQ	clearones

	COMP	#10
	JLT	digit
	SUB	#10

digit	ADD	ascii0
	J	putones

clearones
	CLEAR	A

putones	STCH	@scrptr
	LDA	scrptr
	ADD	#4
	STA	scrptr

	TIX	#16
	JEQ	bdone

	RMO	X, A
	AND	#3
	COMP	#0
	JEQ	nextrow
	J	bloop

nextrow	LDA	scrptr
	ADD	#140
	STA	scrptr
	J	bloop

bdone	LDT	tsave
	RSUB
. ================================================


. ============== show move counter ==============
drawmoves
	STT	tsave
	STS	ssave

	LDA	scrbase
	ADD	bsemovcnt
	STA	scrptr

	LDA	moves
	RMO	A, S

. hundreds
	DIV	#100
	RMO	A, T
	ADD	ascii0
	STCH	@scrptr

	LDA	scrptr
	ADD	#1
	STA	scrptr

. remove hundreds from S
	RMO	T, A
	MUL	#100
	SUBR	A, S

. tens
	RMO	S, A
	DIV	#10
	RMO	A, T
	ADD	ascii0
	STCH	@scrptr

	LDA	scrptr
	ADD	#1
	STA	scrptr

. remove tens from S
	RMO	T, A
	MUL	#10
	SUBR	A, S

. ones
	RMO	S, A
	ADD	ascii0
	STCH	@scrptr

	LDT	tsave
	LDS	ssave
	RSUB
. ===============================================


. ====== check if board in memory is solved ======
. returns result in A: 1 if solved, 0 otherwise
checkwin
	STT	tsave
	CLEAR	X
. A holds what is on the board
. T holds what should be on the board
cwloop	RMO	X, A
	ADD	#1
	RMO	A, T
	CLEAR	A
	LDCH	board, X
	COMPR	A, T
	JEQ	woncheck
	J	notsolved
woncheck
	TIX	#15
	JLT	cwloop
	CLEAR	A
	LDCH	board, X
	COMP	#0
	JEQ	solved
	J	notsolved
solved	LDA	#1
	LDT	tsave
	RSUB
notsolved
	LDA	#0
	LDT	tsave
	RSUB
. ================================================

. data
scrbase	WORD	X'00B800'
keybrd	WORD	X'00C000'
title	BYTE	C'15 PUZZLE'
	BYTE	X'00'
seedmsg	BYTE	C'PRESS ANY 10 KEYS TO CREATE A NEW PUZZLE'
	BYTE	X'00'
bseseedmsg
	WORD	342
seedln	BYTE	C'__________'
	BYTE	X'00'
bseseedln
	WORD	593
help	BYTE	C'WASD: MOVE TILES   R: NEW GAME   Q: QUIT'
	BYTE	X'00'
bsehelp	WORD	185
movlbl	BYTE	C'MOVES: '
	BYTE	X'00'
bsemovlbl
	WORD	1470
bsemovcnt
	WORD	1477
wintxt	BYTE	C'YOU WIN!   R: NEW GAME   Q: QUIT'
	BYTE	X'00'
bsewintxt
	WORD	1710
board	RESB	16
solvedbrd
	BYTE	X'01020304'
	BYTE	X'05060708'
	BYTE	X'090A0B0C'
	BYTE	X'0D0E0F00'
bseboard
	WORD	592
empty	RESW	1
target	RESW	1
moves	RESW	1
scrptr	RESW	1
scrlen	WORD	2000
ssave	RESW	1
tsave	RESW	1
txtsrc	RESW	1
txtdst	RESW	1
nkeys	RESW	1
keycode	RESW	1
seed	RESW	1
mask	WORD	X'7FFFFF'
shufcnt	RESW	1
prevpos	RESW	1
shuffles
	WORD	100
ascii0	WORD	48

	END	main