. 
.			PONG
.
. Objective: Don't let the ball touch the southern wall!
.
. Recommended Frequency: 200kHz (higher frequency => higher difficulty)
. Screen size: 64 x 64
.
. This programs requires an adapted version of SicTools Simulator
. to run correctly, as it requires a non-blocking input method.
.
. Adapted SicTools: https://github.com/MatevzFa/SicTools.git (this has since been merged into jurem/SicTools)
. After running sictools.jar, navigate to View > Keyboard
. and open the Keyboard.
. Use 'A' and 'D' to move the pad left and right, respectively.
.

PONG		START	0

		JSUB	stackinit

LOOP		JSUB	moveball
		JSUB	drawball
		JSUB	readinput
		JSUB	drawpad1
		. Delay for smoother experience
		CLEAR	X
delay		+TIX	=5000
		JLT	delay

		J	LOOP

HALT		J	HALT

.== Data ==.........................................
display		EQU	40960
dwidth		WORD	64
dheight		WORD	64

maxX		EQU	62
maxY		EQU	62

ballx		WORD	1
bally		WORD	1

balldx		WORD	-1
balldy		WORD	-1

pad1		WORD	55
pad1pos		WORD	32

WHITE		BYTE	X'FF'
RED		BYTE	X'F0'
BLACK		BYTE	X'00'

keyboard	EQU	49152
....................................................


.== readinput
readinput	STL	@stackptr
		JSUB	stackpush
		STA	@stackptr
		JSUB	stackpush

		. move pad left if necessary
		+LDCH	keyboard
		COMP	=65
		JLT	skipleft
		JGT	skipleft
		LDA	=-2
		JSUB	movepad

		. move pad right if necessary
skipleft	+LDCH	keyboard
		COMP	=68
		JLT	skipright
		JGT	skipright
		LDA	=2
		JSUB	movepad


skipright	CLEAR	A
		+STCH	keyboard

		JSUB	stackpop
		LDA	@stackptr
		JSUB	stackpop
		LDL	@stackptr
		RSUB
.	.	.	.	.readinput	.

.== moveball
moveball	STL	@stackptr
		JSUB	stackpush
		STA	@stackptr
		JSUB	stackpush

		LDA	bally
		MUL	dheight
		ADD	ballx
		RMO	A, X

		LDCH	BLACK
		+STCH	display, X

		LDA	ballx
		ADD	balldx
		STA	ballx

		JSUB	chkwalls
		JSUB	chkpads

		LDA	bally
		ADD	balldy
		STA	bally

		JSUB	stackpop
		LDA	@stackptr
		JSUB	stackpop
		LDL	@stackptr
		RSUB
.	.	.	.	.moveball	.

.== movepad
. Stores new 'x' coordinate for pad
.	A - move for this much
movepad		STL	@stackptr
		JSUB	stackpush
		STA	@stackptr
		JSUB	stackpush
		STS	@stackptr
		JSUB	stackpush


		LDS	pad1pos
		ADDR	S, A

		. check left
		COMP	=0
		JLT	movepadend

		. cjeck right
		COMP	=60
		JGT	movepadend

		STA	pad1pos


movepadend	JSUB	stackpop
		LDS	@stackptr
		JSUB	stackpop
		LDA	@stackptr
		JSUB	stackpop
		LDL	@stackptr
		RSUB
.	.	.	.	.movepad	.

.== chkpads
chkpads		STL	@stackptr
		JSUB	stackpush
		STA	@stackptr
		JSUB	stackpush

		.check X
		LDA	ballx
		COMP	pad1pos
		JLT	chkpadsend
		SUB	=4
		COMP	pad1pos
		JEQ	chkpadsend
		JGT	chkpadsend
		.check Y
		LDA	bally
		ADD	=1
		COMP	pad1
		JEQ	swapy2

chkpadsend	JSUB	stackpop
		LDA	@stackptr
		JSUB	stackpop
		LDL	@stackptr
		RSUB

swapy2		LDA	balldy
		MUL	=-1
		STA	balldy
		J	chkpadsend
.	.	.	.	.chkpads	.



.== Bounce off the wall
chkwalls	STL	@stackptr
		JSUB	stackpush
		STA	@stackptr
		JSUB	stackpush

		. bounce off left and rihgt walls
		LDA	ballx
		COMP	#maxX
		JGT	swapx
		LDA	ballx
		COMP	=1
		JLT	swapx

		. bounce off top and bottom walls
		LDA	bally
		COMP	#maxY
		JGT	HALT
		LDA	bally
		COMP	=1
		JLT	swapy

chkxyend	JSUB	stackpop
		LDA	@stackptr
		JSUB	stackpop
		LDL	@stackptr
		RSUB

		. inverts x
swapx		LDA	balldx
		MUL	=-1
		STA	balldx
		J	chkxyend

		. inverts y
swapy		LDA	balldy
		MUL	=-1
		STA	balldy
		J	chkxyend
.	.	.	.	.chkwals	.


.== drawball
drawball	STL	@stackptr
		JSUB	stackpush
		STA	@stackptr
		JSUB	stackpush
		STX	@stackptr
		JSUB	stackpush

		LDA	bally
		MUL	dheight
		ADD	ballx
		RMO	A, X

		LDCH	RED
		+STCH	display, X

		JSUB	stackpop
		LDX	@stackptr
		JSUB	stackpop
		LDA	@stackptr
		JSUB	stackpop
		LDL	@stackptr
		RSUB
.	.	.	.	.drawball	.


.== drawpad1
drawpad1	STL	@stackptr
		JSUB	stackpush
		STA	@stackptr
		JSUB	stackpush
		STX	@stackptr
		JSUB	stackpush

		LDA	pad1
		MUL	dheight
		ADD	pad1pos

		SUB	=2
		RMO	A, X

		. erase 2 pixels before
		LDCH	BLACK
		+STCH	display, X
		TIX	=0
		LDCH	BLACK
		+STCH	display, X
		TIX	=0

		. draw the pad
		LDCH	WHITE
		+STCH	display, X
		TIX	=0
		+STCH	display, X
		TIX	=0
		+STCH	display, X
		TIX	=0
		+STCH	display, X
		TIX	=0

		. erase 2 pixels after
		LDCH	BLACK
		+STCH	display, X
		TIX	=0
		LDCH	BLACK
		+STCH	display, X


		JSUB	stackpop
		LDX	@stackptr
		JSUB	stackpop
		LDA	@stackptr
		JSUB	stackpop
		LDL	@stackptr
		RSUB
.	.	.	.	.drawpad1	.


.== Sklad	.	.	.	.
stack		RESW	100		.
stackptr	RESW	1		.
tmpA		RESW	1		.
.	.	.	.	.	.
.	OPERACIJE NAD SKLADOM		.
.					.
.== stackpush				.
.	Inkrementira stackptr za 3	.
stackpush	STA	tmpA		.
		LDA	stackptr	.
		ADD	=3		.
		STA	stackptr	.
		LDA	tmpA		.
		RSUB			.
.					.
.== stackpop				.
.	Dekrementira stackptr za 3.	.
stackpop	STA	tmpA		.
		LDA	stackptr	.
		SUB	=3		.
		STA	stackptr	.
		LDA	tmpA		.
		RSUB			.
.					.
.== stackinit				.
.	stackptr na naslov sklada	.
stackinit	STA	tmpA		.
		LDA	#stack		.
		STA	stackptr	.
		LDA	tmpA		.
		RSUB			.
.	.	.	.	.	.