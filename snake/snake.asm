... -------------------------------
... |         S N A K E           |
... -------------------------------
... Author: Jakob Erzar
... Plugins: Keyboard & Textual screen
... Frequency: 200000 Hz = 200 kHz
... Controls:
... 	- A -> move left
...	- D -> move right

start 	START	0
	JSUB	skInit	. Init the stack
	... initialize variables
	LDA	row
	STA	rowLmt	. Row limit
	LDA	column
	STA	colLmt	. Column limit
	LDT	#3	. Incrementor
	LDA	nBodies
	MUL	#3
	RMO	A, S	. Table limit
	... display food
	JSUB	showFd

	... initialize snake
	LDA	#40
	STA	bodyX
	LDA	#10
	STA	bodyY
	LDX	#0

	... draw initial state
initlp	JSUB	calcPlc
	CLEAR	A
	LDCH	bodyC
	STCH	@bodyPlc

loop	JSUB	loadTlX
	JSUB	calcPlc
	... save current place as old
	LDA	bodyPlc
	STA	oldPlc
	JSUB	loadHdX

	... move body
	JSUB	chckCrd
	JSUB	readKey
	JSUB	updtCrd
	JSUB	calcPlc

	... check if eaten food
	JSUB	chckFd

	... update screen
	CLEAR	A
	LDCH	emptyC
	STCH	@oldPlc
	LDCH	bodyC
	STCH	@bodyPlc

	JSUB	incrHd
	JSUB	updtTl

	J	loop

... user crashed, stuck here
crash	JSUB	calcPlc
	CLEAR	A
cBlink	LDCH	emptyC
	STCH	@bodyPlc
	LDCH	bodyC
	STCH	@bodyPlc
	J	cBlink

... -------------------------------
... |   S U B R O U T I N E S     |
... -------------------------------
... load body head in X
loadHdX	LDA	bodyHd
	MUL	#3
	RMO	A, X
	RSUB
... load body tail in X
loadTlX	LDA	bodyTl
	MUL	#3
	RMO	A, X
	RSUB

... increment body head
incrHd	LDA	bodyHd
	ADD	#1
	AND	maxBody
	STA	bodyHd
	RSUB
... update body tail
updtTl	LDA	bodyHd
	SUB	nBodies
	. SUB	#1
	AND	maxBody
	STA	bodyTl
	RSUB

... calculate body address
calcPlc	LDA	bodyY, X
	MUL	column
	ADD	disp
	ADD	bodyX, X
	STA	bodyPlc
	RSUB

... update body x and y
updtCrd	STL	@skPtr	. push L
	JSUB	skPush
	STX	@skPtr	. push X
	JSUB	skPush
	... calculate direction X
	... calculate new X
	LDA	bodyX, X
	ADD	bodyVX
	... store it to new
	STA	@skPtr	. push A
	JSUB	skPush
	RMO	X, A
	DIV	#3
	ADD	#1
	AND	maxBody
	MUL	#3
	RMO	A, X
	JSUB	skPop	. pop A
	LDA	@skPtr
	STA	bodyX, X

	JSUB	loadHdX
	... calculate direction Y
	... calculate new Y
	LDA	bodyY, X
	ADD	bodyVY
	... store it to new
	STA	@skPtr	. push A
	JSUB	skPush
	RMO	X, A
	DIV	#3
	ADD	#1
	AND	maxBody
	MUL	#3
	RMO	A, X
	JSUB	skPop	. pop A
	LDA	@skPtr
	STA	bodyY, X

	JSUB	loadHdX
	... pop from stack
	JSUB	skPop	. pop X
	LDX	@skPtr
	... pop L register
	JSUB	skPop	. pop L
	LDL	@skPtr
	RSUB

... check that body is inside bounds
chckCrd	STL	@skPtr
	... push L register
	JSUB	skPush
	... push S register
	STS	@skPtr
	JSUB	skPush
	STS	#0
	... check X coordinate
	LDA	bodyX, X
	COMP	colLmt
	JEQ	crash
	COMP	#0
	JLT	crash
	... check Y coordinate
	LDA	bodyY, X
	COMP	rowLmt
	JEQ	crash
	COMP	#0
	JLT	crash
	... pop S register
chckBck	JSUB	skPop
	LDS	@skPtr
	... pop L register
	JSUB	skPop
	LDL	@skPtr
	RSUB		... Return call from chckCrd

... get food address in foodPlc
calcFd	LDA	disp
	ADD	foodAd
	STA	foodPlc
	RSUB

... check if eaten food
chckFd	LDA	bodyPlc
	COMP	foodPlc
	JEQ	incrSnk
	RSUB

... increase the size of snake
incrSnk	LDA	nBodies
	ADD	#1
	STA	nBodies
	LDA	keytime
	SUB	keysub	. Speed it up a bit!
	STA	keytime
	STL	@skPtr	. Push L
	JSUB	skPush
	JSUB	genFood
	JSUB	showFd

	JSUB	skPop	. Pop L
	LDL	@skPtr
	RSUB

... show food on screen
showFd	STL	@skPtr
	JSUB	skPush	. Push L
	JSUB	calcFd
	CLEAR	A
	LDCH	foodC
	STCH	@foodPlc
	JSUB	skPop	. Pop L
	LDL	@skPtr
	RSUB

... generate the next coordinates of food
genFood	LDA	foodPlc
	MUL	foodGnM
	ADD	foodGnA
genFdMd	COMP	displen
	JLT	gendFd
	SUB	displen
	J	genFdMd
gendFd	STA	foodAd
	RSUB

... reads the key from the keyboard
... it waits some time first, doing nothing...
... it spends less time here as the snake increases...
... it uses the time of press for better random generation...
readKey	CLEAR	A
	... init time and keyrng
	LDA	#0
	STA	keyrng
	LDA	keytime
	STA	keywait
	... kill some time here
keyWtLp	CLEAR	A
	LDA	keyrng
	COMP	#0
	JGT	keyWtSb
	LDCH	@keybord
	COMP	#0
	JEQ	keyWtSb
	... key just pressed, use the time of press
	... for a random generation of next food
	LDA	keywait
	STA	foodGnA
	LDA	#1
	STA	keyrng
	LDA	keywait
	SUB	#2	. make up for time wasted
	STA 	keywait
	... continue here if user already pressed the key
keyWtSb	LDA 	keywait
	SUB	#1
	STA	keywait
	COMP	#0
	JGT	keyWtLp
	... done waiting, read the key and process
	LDCH	@keybord
	STA	rdk
	COMP	leftC
	JEQ	updtL
	COMP	rightC
	JEQ	updtR
	RSUB

... updateLeft branch
updtL	LDA	snakeD
	SUB	#1
	J	updtLR
... updateRight branch
updtR	LDA	snakeD
	ADD	#1
	J	updtLR
... combined update branch
updtLR	AND	#3
	STA	snakeD
	MUL	#3
	STA	snakeDX
	... update vec
	STL	@skPtr	... push current L
	JSUB	skPush
	STX	@skPtr	... push current x
	JSUB	skPush
	LDX	snakeDX
	LDA	bodyVXA, X
	STA	bodyVX
	LDA	bodyVYA, X
	STA	bodyVY
	LDA	#0
	STCH	@keybord
	JSUB	skPop	... pop current X
	LDX	@skPtr
	JSUB	skPop	... pop current L
	LDL	@skPtr
	RSUB

... -------------------------------
... |         S T A C K           |
... -------------------------------
... Note: Register A is mutated.

... Subroutine Stack Initialize
skInit	LDA	#skStart
	STA	skPtr
	RSUB
... Subroutine Stack Push
skPush	LDA	skPtr
	ADD	#3
	STA	skPtr
	RSUB
... Subroutine Stack Pop
skPop	LDA	skPtr
	SUB	#3
	STA	skPtr
	RSUB


... -------------------------------
... |        M E M O R Y          |
... -------------------------------
... Body properties
nBodies	WORD	1	. Current length of body
maxBody	WORD	127	. Maximum length of body
bodyHd	WORD	0	. Index of body head
bodyTl	WORD	0	. Index of body tail
... Coordinates
bodyX	RESW	128	. Body X coords
bodyY	RESW	128	. Body Y coords
... Direction of the snake - 0 = go right, clockwise
snakeD	WORD	0
snakeDX	WORD	0
... Body speeds
bodyVX	WORD	1
bodyVY	WORD	0
... Body speed array (X axis)
bodyVXA	WORD	1
	WORD	0
	WORD	-1
	WORD	0
... Body speed array (Y axis)
bodyVYA	WORD	0
	WORD	1
	WORD	0
	WORD	-1

... Food
foodAd	WORD	200	. Food starting place
foodGnM	WORD	3	. Food generator multiplier
foodGnA	WORD	181	. Food generator add

... Place for storing body position on screen
oldPlc	RESW	1
bodyPlc	RESW	1
foodPlc	RESW	1

... Characters for body and cleaning
bodyC	BYTE	X'4F'	. 4F => O
emptyC	BYTE	X'20'	. 2E => . (for a cool trailing effect)
foodC	BYTE	X'58'	. 58 => X
leftC	WORD	X'000041'	. 65 => A
rightC	WORD	X'000044'	. 68 => D

... Display configuration
disp	WORD	X'00B800'
row	WORD	25
column	WORD	80
displen	WORD	2000

... Keyboard configuration
keybord	WORD	X'00C000'
keytime WORD	3000	. Amount of time to wait for registration of a key
keysub	WORD	40	. Amount of time to subtract when increasing body

... Keyboard variables
keywait	RESW	1	. Amount of time to wait left
keyrng	RESW	1	. Whether the key press has already been used for rng
rdk 	RESW	1	. The key that was just read

... Automatically initialized
rowLmt	RESW	1	. Limit for the rows (Y)
colLmt	RESW	1	. Limit for the columns (X)

... Stack variables
skPtr	RESW	1
skStart	RESW	200

	END	start