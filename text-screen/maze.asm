.
. THIS IS A SIMPLE MAZE GAME
. A SAMPLE MAZE IS PRINTED ONTO THE TEXTUAL SCREEN
. PLAYERS CAN MOVE BY USING WSAD KEYS IN STANDARD INPUT
. PLAYER'S POSITION IS MARKED WITH P
. THERE ARE CHESTS IN THE MAZE, MARKED WITH T
. ONE OF THESE IS THE TREASURE, THE REST ARE TRAPS
. X'S MARK MAZE WALLS AND CANNOT BE CROSSED
.		
maze	START	0
		USE
.
. MAIN MAZE ROUTINES AND DATA
.
. initializes the game
. prints sample maze to screen
. stores coordinates of player and treasure
init	JSUB	stkini
		CLEAR	X
		CLEAR	A
loopi1	CLEAR	S
		ADDR	X,S
		LDT		#0
		LDCH	maze0,X
		JSUB	scrch
		LDT		#1
		LDCH	maze1,X
		JSUB	scrch
		LDT		#2
		LDCH	maze2,X
		JSUB	scrch
		LDT		#3
		LDCH	maze3,X
		JSUB	scrch
		LDT		#4
		LDCH	maze4,X
		JSUB	scrch
		LDT		#5
		LDCH	maze5,X
		JSUB	scrch
		LDT		#6
		LDCH	maze6,X
		JSUB	scrch
		LDT		#7
		LDCH	maze7,X
		JSUB	scrch
		TIX		#10
		JLT		loopi1
		LDA		#1
		STA		PCX
		STA		PCY	
		STA		TRSRY
		LDA		#7
		STA		TRSRX
		LDA		#strt
		JSUB	ehostr
		JSUB	ehonl
. main loop of program
. jumps to appropriate move routine depending on the input
mainlp	CLEAR	A
		JSUB	rdch
		JSUB	direct
		COMP	#0
		JEQ		mainlp
		COMP	#1
		JEQ		mup
		COMP	#2
		JEQ		mdown
		COMP	#3
		JEQ		mleft
		COMP	#4
		JEQ		mright
		J		mainlp
. move routines
. they check if the position where the player wants to move is free
. if there is a wall (X), nothing is done and returns to main loop
. otherwise, the player's location on screen is removed
. if there is a chest (T), it jumps to game over routine
. otherwise, the player's new location is marked on map and returns to main loop
mup		LDS		PCX
		LDT		PCY
		LDA		#1
		SUBR	A,T
		JSUB	scrrd
		COMP	#88
		JEQ		mainlp
		LDA		#1
		ADDR	A,T
		LDA		#32
		JSUB	scrch
		LDA		#1
		SUBR	A,T
		JSUB	scrrd
		STT		PCY
		COMP	#84
		JEQ		gmover
		LDA		#80
		JSUB	scrch
		J		mainlp
mdown	LDS		PCX
		LDT		PCY
		LDA		#1
		ADDR	A,T
		JSUB	scrrd
		COMP	#88
		JEQ		mainlp
		LDA		#1
		SUBR	A,T
		LDA		#32
		JSUB	scrch
		LDA		#1
		ADDR	A,T
		JSUB	scrrd
		STT		PCY
		COMP	#84
		JEQ		gmover
		LDA		#80
		JSUB	scrch
		J		mainlp
mleft	LDS		PCX
		LDT		PCY
		LDA		#1
		SUBR	A,S
		JSUB	scrrd
		COMP	#88
		JEQ		mainlp
		LDA		#1
		ADDR	A,S
		LDA		#32
		JSUB	scrch
		LDA		#1
		SUBR	A,S
		JSUB	scrrd
		STS		PCX
		COMP	#84
		JEQ		gmover
		LDA		#80
		JSUB	scrch
		J		mainlp
mright	LDS		PCX
		LDT		PCY
		LDA		#1
		ADDR	A,S
		JSUB	scrrd
		COMP	#88
		JEQ		mainlp
		LDA		#1
		SUBR	A,S
		LDA		#32
		JSUB	scrch
		LDA		#1
		ADDR	A,S
		JSUB	scrrd
		STS		PCX
		COMP	#84
		JEQ		gmover
		LDA		#80
		JSUB	scrch
		J		mainlp
. game over routine
. checks if the player is located on the treasure
. if so, V is displayed on screen and victory message is printed to standard output
. otherwise, L is displayed on screen and loss message is printed to standard output
. then the program jumps into an infinite loop (halt)
gmover	LDA		PCX
		COMP	TRSRX
		JGT		lose
		JLT		lose
		LDA		PCY
		COMP	TRSRY
		JGT		lose
		JLT		lose
win		LDA		#86
		JSUB	scrch
		JSUB	ehonl
		LDA		#vict
		JSUB	ehostr
		JSUB	ehonl
		JSUB	halt
lose	LDA		#76
		JSUB	scrch
		JSUB	ehonl
		LDA		#loss
		JSUB	ehostr
		JSUB	ehonl
halt	J		halt
. subroutine that converts the ascii char stored in A
. W/w to 1, S/s to 2, A/a to 3 and D/d to 4
. other characters are converted to 0
direct	COMP	#87
		JEQ		ret1
		COMP	#119
		JEQ		ret1
		COMP	#83
		JEQ		ret2
		COMP	#115
		JEQ		ret2
		COMP	#65
		JEQ		ret3
		COMP	#97
		JEQ		ret3
		COMP	#68
		JEQ		ret4
		COMP	#100
		JEQ		ret4
		LDA		#0
		RSUB
ret1	LDA		#1
		RSUB
ret2	LDA		#2
		RSUB
ret3	LDA		#3
		RSUB
ret4	LDA		#4
		RSUB
. data
. PCX and PCY store player's coordinates
. TRSRX and TRSRY store treasure's coordinates
. maze0-n store n+1 rows of equal length that contain the maze in ascii format
. X's are walls, P is the player, spaces are empty and T's are traps and treasure
. it is possible to use more than one trap
. strt, loss and vict contain the display messages for game beginning and end
		USE		data
PCX		RESW	1
PCY		RESW	1
TRSRX	RESW	1
TRSRY	RESW	1
maze0	BYTE	C'XXXXXXXXXX'
		BYTE	X'00'
maze1	BYTE	C'XPX   XT X'
		BYTE	X'00'
maze2	BYTE	C'X X X XX X'
		BYTE	X'00'
maze3	BYTE	C'X   X    X'
		BYTE	X'00'
maze4	BYTE	C'XXXXXXXX X'
		BYTE	X'00'
maze5	BYTE	C'XTX   X  X'
		BYTE	X'00'
maze6	BYTE	C'X   X   XX'
		BYTE	X'00'
maze7	BYTE	C'XXXXXXXXXX'
		BYTE	X'00'
strt	BYTE	C'BEGIN!'
		BYTE	X'00'
loss	BYTE	C'TRAP! YOU LOSE!'
		BYTE	X'00'
vict	BYTE	C'TREASURE! YOU WIN!'
		BYTE	X'00'
.
. STANDARD INPUT/OUTPUT SUBROUTINES
.
		USE
. subroutine reads character from input and returns it in A
rdch	TD		input
		JEQ		rdch
		CLEAR	A
		RD		input
		RSUB
. subroutine prints newline character (CR + LF)
ehonl	STA		tmp_a
		CLEAR	A
		LDCH	cr
loopa1	TD		output
		JEQ		loopa1
		WD		output
		LDCH	lf
loopa2	TD		output
		JEQ		loopa2
		WD		output
		LDA		tmp_a
		RSUB
. subroutine prints string at the address stored in register A
ehostr	STA		stradd
loopb1	TD		output
		JEQ		loopb1
		CLEAR	A
		LDCH	@stradd
		COMP	#0
		JEQ		exlpb1
		WD		output
		LDA		stradd
		ADD		#1
		STA		stradd
		J		loopb1
exlpb1	LDA		stradd
		RSUB
. data
		USE		data
stradd	RESW	1
cr		BYTE	X'0D'
lf		BYTE	X'0A'
input	BYTE	X'00'
output	BYTE	X'01'
.
. SCREEN SUBROUTINES
.
		USE
. subroutine to print ascii character in register A to screen
. at coordinates X [0-79] (given in S) and Y [0-24] (given in T)
scrch	STL		@stkptr
		JSUB	stkpsh
		STA		@stkptr
		JSUB	stkpsh
		CLEAR	A
		ADDR	T,A
		MUL		scrcol
		ADDR	S,A
		ADD		screen
		STA		scradd
		JSUB	stkpop
		LDA		@stkptr
		STCH	@scradd
		JSUB	stkpop
		LDL		@stkptr
		RSUB
. subroutine to read character on screen into register A
. at coordinates X [0-79] (given in S) and Y [0-24] (given in T)
scrrd	STL		@stkptr
		JSUB	stkpsh
		CLEAR	A
		ADDR	T,A
		MUL		scrcol
		ADDR	S,A
		ADD		screen
		STA		scradd
		CLEAR	A
		LDCH	@scradd
		JSUB	stkpop
		LDL		@stkptr
		RSUB	
. data
		USE		data
scradd	RESW	1
scrcol	WORD	80
scrrow	WORD	25
scrlen	WORD	2000
screen	WORD	X'00B800'
scrmax	WORD	X'00BFD0'
. 
. IMPLEMENTATION OF STACK
. REGISTERS ARE PUSHED TO STACK WITH
. STA	@stkptr
. JSUB	stkpsh
. REGISTERS ARE POPPED FROM STACK WITH
. JSUB	stkpop
. LDA	@stkptr
. STACK MUST BE INITIALIZED WITH
. JSUB stkini
.
		USE
. subroutine to init stack
stkini	STA		tmp_a
		LDA		#stack
		STA		stkptr
		STA		stkmin
		ADD		#3072
		STA		stkmax
		LDA		tmp_a
		RSUB
. immediately returns from subroutine
. used when pushing to full stack or poping from empty stack
stkret	LDA		tmp_a
		RSUB
. subroutine that increments stack pointer
stkpsh	STA		tmp_a
		LDA		stkptr
		ADD		#3
		COMP	stkmax
		JGT		stkret
		STA		stkptr
		LDA		tmp_a
		RSUB
. subroutine that decrements stack pointer
stkpop	STA		tmp_a
		LDA		stkptr
		SUB		#3
		COMP	stkmin
		JLT		stkret
		STA		stkptr
		LDA		tmp_a
		RSUB
. data
		USE		data
tmp_a	RESW	1
stkptr	RESW	1
stkmin	RESW	1
stkmax	RESW	1
stack	RESW	1024
		END		init