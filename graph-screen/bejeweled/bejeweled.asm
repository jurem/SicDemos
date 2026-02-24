bejwl	START 0
		JSUB 	sinit
		LDA 	#27
		JSUB 	hlgem
		LDX 	#0
initbd 	
		JSUB 	gengem
		TIX 	#64
		JLT 	initbd
		JSUB 	drwbrd
mainlp
		JSUB 	handlekb
		JSUB 	chkmatches
		JSUB 	prcsdestroyed
		JSUB 	drwbrd
		J mainlp
		
halt	J		halt
err		J 		err

. Processes any destroyed gems, by shifting the board down and generating new gems in their place
prcsdestroyed
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	LDX 	#0
	. First we draw all of them as empty spaces
emtydraw
	+LDCH 	brdval, X
	COMP 	#gemdst
	JLT 	emtydcnt
	JGT 	emtydcnt
	+LDCH 	#emtyid
	JSUB 	chgem
emtydcnt
	TIX 	#64
	JLT 	emtydraw

	JSUB 	drwbrd

	LDX 	#0
pdlp
	JSUB 	prcdecol
	TIX 	#8
	JLT 	pdlp

	LDX 	#0
pdrelp
	+LDCH 	board, X
	COMP 	#emtyid
	JLT 	pdrcnt
	JGT 	pdrcnt
	JSUB 	gengem
pdrcnt
	TIX 	#64
	JLT 	pdrelp

	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Process any destroyed gems in a column (removing, falling, generating new ones)
. X the column that should be processed
prcdecol
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	. to know when we have to stop
	RMO 	X, B
	LDA 	#8
	SUBR 	A, B
	. Start from the bottom
	LDA 	#56
	ADDR 	A, X
	. To keep track of where the next gem found should be placed
	RMO 	X, T
pdclop
	+LDCH 	board, X
	COMP 	#emtyid
	JEQ 	pdccnt

	. gem found, put it in the next available spot
	. check if it is already in the correct spot
	COMPR 	X, T
	JEQ 	pdcmvc
	
	RMO 	X, S
	RMO 	T, X
	JSUB 	chgem
	RMO 	S, X
pdcmvc
	. Move the next available spot up
	LDS 	#8
	SUBR 	S, T

pdccnt
	LDA 	#8
	SUBR 	A, X
	COMPR 	X, B
	JGT 	pdclop

	. If there is left over space, fill them with empty spaces
	COMPR 	T, B
	JEQ 	pdcend
	RMO 	T, X
pdcelp
	LDCH 	#emtyid
	+STCH 	board, X
	LDA 	#8
	SUBR 	A, X
	COMPR 	X, B
	JGT 	pdcelp

pdcend
	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Checks the board for any matches, and processes them
. A returns how many were matched
chkmatches
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	LDB 	#0
	LDX 	#0
	. Check rows
chrows
	JSUB 	chkrow
	ADDR 	A, B
	TIX 	#8
	JLT 	chrows

	LDX 	#0
	. Check columns
chcols
	JSUB 	chkcol
	ADDR 	A, B
	TIX 	#8
	JLT 	chcols

	RMO 	B, A

	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB
	
. Checks the row of the board for any matches and processes them
. X holds the row to process
chkrow
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	. Stack variable is used, since this seems like the easiest way
	. Keep track of the amount of 3+ matches found
	LDA 	#0
	+STA 	@stkptr
	JSUB 	spush

	. L will be used as general purpose register, for short operations (its value does not survive JSUB instructions)
	. A will be used to load the gem to be compared to value in register S
	. S will hold the gem color to match
	LDS 	#0xFF
	. T will hold the amount of gems matched
	LDT 	#0
	. X will be used to iterate over the board
	. We start on row X*8
	LDB 	#8
	MULR 	B, X
	RMO 	X, B
	LDL 	#7
	. B will hold the final index of the row
	ADDR 	L, B

	. Check row
	+LDCH 	board, X
	RMO 	A, S
chkrlp
	. Load in a gem
	+LDCH 	board, X
	COMP 	#cubeid
	JEQ 	chkrnomatch
	COMPR 	A, S
	JEQ 	chkrismatch
	J 		chkrnomatch

chkrismatch
	LDL 	#1
	ADDR 	L, T
	J 		chkrend

chkrnomatch
	LDL 	#3
	COMPR 	T, L . if 3 are matched we will need to destroy them
	JLT		chkrnodestroy
	. Increment stack variable keeping track of how many valid moves were performed
	JSUB 	spop
	+LDA 	@stkptr
	ADD 	#1
	+STA 	@stkptr
	JSUB 	spush
	. Destroy the gems
	JSUB 	hgemdestroy
chkrnodestroy
	RMO 	A, S
	LDT 	#1
	J 		chkrend

chkrend
	TIXR 	B
	JLT 	chkrlp
	JEQ 	chkrlp
	
	. At the end of the row check if we matched all of them by chance
	LDL 	#3
	COMPR 	T, L . if 3 are matched we will need to destroy them
	. Final load in of the stack variable
	JSUB 	spop
	+LDA 	@stkptr
	JLT		chkreend
	. Increment the stack variable
	ADD 	#1
	JSUB 	hgemdestroy

chkreend
	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Checks the column of the board for any matches and processes them
. X holds the column to process
chkcol
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush
	
	. Stack variable is used, since this seems like the easiest way
	. Keep track of the amount of 3+ matches found
	LDA 	#0
	+STA 	@stkptr
	JSUB 	spush

	. L will be used as general purpose register, for short operations (its value does not survive JSUB instructions)
	. A will be used to load the gem to be compared to value in register S
	. S will hold the gem color to match
	LDS 	#0xFF
	. T will hold the amount of gems matched
	LDT 	#0
	. X will be used to iterate over the board
	. We start on column X
	RMO 	X, B
	LDL 	#56
	. B will hold the final index of the column
	ADDR 	L, B

	. Check column
	+LDCH 	board, X
	RMO 	A, S
chkclp
	. Load in a gem
	+LDCH 	board, X
	COMPR 	A, S
	JEQ 	chkcismatch
	J 		chkcnomatch

chkcismatch
	LDL 	#1
	ADDR 	L, T
	J 		chkcend

chkcnomatch
	LDL 	#3
	COMPR 	T, L . if 3 are matched we will need to destroy them
	JLT		chkcnodestroy
	. Increment stack variable keeping track of how many valid moves were performed
	JSUB 	spop
	+LDA 	@stkptr
	ADD 	#1
	+STA 	@stkptr
	JSUB 	spush
	. Destroy the gems
	JSUB 	vgemdestroy
chkcnodestroy
	RMO 	A, S
	LDT 	#1
	J 		chkcend

chkcend
	LDA 	#8
	ADDR 	A, X
	COMPR 	X, B
	JLT 	chkclp
	JEQ 	chkclp
	
	. At the end of the row check if we matched all of them by chance
	LDL 	#3
	COMPR 	T, L . if 3 are matched we will need to destroy them
	. Final load in of the stack variable
	JSUB 	spop
	+LDA 	@stkptr
	JLT		chkceend
	. Increment the stack variable
	ADD 	#1
	JSUB 	vgemdestroy

chkceend
	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Destroyes the gems in a row
. T amount of gems to destroy
. X last index (exclusive) to destroy
hgemdestroy
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	RMO 	X, B
	SUBR 	T, X

	. Check if a cube should be created (power up)
	RMO 	T, A
	COMP 	#5
	JLT 	hgdlp
	. Change to a cube and skip marking as destroyed
	LDCH 	#cubeid
	JSUB 	chgem
	TIXR 	B

hgdlp
	. Mark gem as destroyed
	JSUB 	markgemdes
	TIXR 	B
	JLT 	hgdlp

	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Destroyes the gems in a column
. T amount of gems to destroy
. X last index (exclusive) to destroy
vgemdestroy
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	RMO 	X, B
	LDA 	#8
	MULR 	A, T
	SUBR 	T, X

	. Check if a cube was created (power up)
	RMO 	T, A
	DIV 	#8
	COMP 	#5
	JLT 	vgdlp
	. Change to a cube and skip marking as destroyed
	LDCH 	#cubeid
	JSUB 	chgem
	LDA 	#8
	ADDR 	A, X

vgdlp
	. Mark gem as destroyed
	JSUB 	markgemdes
	. Move 1 down
	LDA 	#8
	ADDR 	A, X
	. Check if we need to delete more gems
	COMPR 	X, B
	JLT 	vgdlp

	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB
	
. Activates the cubes power and destroys all gems of the specified color
. A color to destroy
. X index of used cube on board
dstcube
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	. Mark the cube as destroyed
	JSUB 	markgemdes
	RMO 	A, B
	+LDS 	#cubeid
	LDX 	#0
dstclp
	COMPR 	B, S
	JEQ 	dstcdst
	+LDCH 	board, X
	COMPR 	A, B
	JLT 	dstclend
	JGT 	dstclend
dstcdst
	. Gem is the correct color and should be destroyed
	JSUB 	markgemdes
dstclend
	TIX 	#64
	JLT 	dstclp

	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Handles the keyboard
handlekb
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	+LDA 	gemsel
	COMP 	#0
	JEQ		pregemsel
	J 		postgemsel

pregemsel
	+LDCH 	kbptr
	COMP 	#65 . A
	LDB 	#2
	JEQ		kbmove
	COMP 	#68 . D
	LDB 	#0
	JEQ 	kbmove
	COMP 	#87 . W
	LDB 	#1
	JEQ 	kbmove
	COMP 	#83	. S
	LDB 	#3
	JEQ 	kbmove
	COMP 	#32	. SPACE
	JEQ 	kbselect
	J 		kbend

kbmove
	+LDA 	hlgemi
	JSUB 	movelbd
	JSUB 	hlgem
	J 		kbend
kbselect
	+LDA 	#1
	+STA 	gemsel
	+LDA 	hlgemi
	+STA 	selgem
	J 		kbend

postgemsel
	+LDCH 	kbptr
	COMP 	#65 . A
	LDB 	#2
	JEQ 	kbmovesel
	COMP 	#68 . D
	LDB 	#0
	JEQ 	kbmovesel
	COMP 	#87 . W
	LDB 	#1
	JEQ 	kbmovesel
	COMP 	#83	. S
	LDB 	#3
	JEQ 	kbmovesel
	COMP 	#32	. SPACE
	JEQ 	kbselectsel
	COMP 	#27 . ESCAPE
	JEQ 	kbescsel
	J 		kbend

kbescsel
	+LDA 	selgem
	JSUB 	hlgem
	+LDA 	#0
	+STA 	gemsel
	J 		kbend

kbmovesel
	+LDA 	selgem
	JSUB 	movelbd
	JSUB 	hlgem
	J 		kbend
kbselectsel
	+LDS 	selgem
	+LDT 	hlgemi
	JSUB 	swpgem
	+LDA 	#0
	+STA 	gemsel
	+LDCH 	#1
	+STCH 	hlgemc
	J 		kbend

kbend
	. cleanup
	+LDCH 	#0
	+STCH 	kbptr

	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB


. Highlight a gem
. A -> board index to highlight
hlgem
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush

	. temporarily store the index
	RMO 	A, B

	. mark previously highlighted as needing a redraw
	+LDX 	hlgemi
	LDCH 	#0
	+STCH 	brdval, X

	. highlight new
	+STB 	hlgemi
	LDCH 	#1
	+STCH 	hlgemc

	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Replaces the gem at index X with a new gem
. X -> board index
gengem
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	
	JSUB 	lfsr24
	AND 	#0xff
	RMO 	A, B
	DIV		#gemcnt
	MUL	 	#gemcnt
	SUBR 	A, B
	RMO 	B, A
	JSUB 	chgem

	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Swap two gems on the board
. S -> board index 1
. T -> board index 2
swpgem
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush

	. load first gem
	RMO 	S, X
	+LDCH 	board, X
	. Checking for cube match
	COMP 	#cubeid
	JEQ 	swpc1
	. store the gem in B
	RMO 	A, B
	. load second gem
	RMO 	T, X
	+LDCH 	board, X
	. Checking for cube match
	COMP 	#cubeid
	JEQ 	swpc2
	. change the first gem index to the second gem
	RMO 	S, X
	JSUB 	chgem
	. change the second gem index to the first gem
	RMO 	B, A
	RMO 	T, X
	JSUB 	chgem
	J 		swpgend

swpc1
	RMO 	T, X
	+LDCH 	board, X
	RMO 	S, X
	JSUB 	dstcube
	J 		swpgend

swpc2
	RMO 	S, X
	+LDCH 	board, X
	RMO 	T, X
	JSUB 	dstcube
	J 		swpgend

swpgend
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Change gem
. A -> new gem id
. X -> board index
chgem
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush

	. DEBUG: Check if in bounds
	RMO 	X, A
	COMP 	#0
	JGT 	chgner
	JEQ 	chgner
	COMP 	#63
	JGT 	chgner
	JEQ 	chgner
	JSUB 	err

chgner
	JSUB spop
	+LDA @stkptr
	JSUB spush

	+STCH 	board, X
	LDCH 	#0
	+STCH 	brdval, X

	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB
	
. Mark gem as destroyed
. X -> board index
markgemdes
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush

	. DEBUG: Check if in bounds
	RMO 	X, A
	COMP 	#0
	JGT 	mgner
	JEQ 	mgner
	COMP 	#63
	JGT 	mgner
	JEQ 	mgner
	JSUB 	err

mgner
	+LDCH 	#gemdst
	+STCH 	brdval, X

	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Draws the board
drwbrd
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	LDX 	#0
	LDA 	#0
drbdlp
	. Check if redraw is necessary
	+LDCH 	brdval, X
	COMP 	#0
	JGT 	drlpct
	LDCH 	#1
	+STCH 	brdval, X

	. Load gem
	+LDCH 	board, X
	. Load board index
	RMO 	X, B
	JSUB 	drwgem

drlpct
	TIX 	#64
	JLT 	drbdlp

	. Highlight the gem if necessary
	+LDCH 	hlgemc
	COMP 	#1
	JLT 	drwhlsel
	JGT 	drwhlsel

	+LDCH 	#0
	+STCH 	hlgemc
	+LDB 	hlgemi
	+LDCH 	#0xfc
	JSUB 	drwHl

drwhlsel
	+LDA 	gemsel
	COMP 	#1
	JLT 	drwbrdend
	JGT 	drwbrdend

	+LDB 	selgem
	+LDCH 	#0xfd
	JSUB 	drwHl

drwbrdend
	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Draws the highlight around a gem on the board
. B -> board index
. A -> color (1 byte)
drwHl
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STA @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	. Temporarily store the color in X
	RMO 	A, X

	. Calculate screen X and Y 
	. Y_idx = b_idx / board_col_count , this must trunacte it
	RMO 	B, A
	DIV 	#8	. board_col_count = 8
	RMO 	A, T
	. X_idx = b_idx - Y_idx * board_col_count
	MUL 	#8 . board_col_count = 8
	SUBR 	A, B
	RMO 	B, S

	. They are both not screen coordinates, so we need to adjust them
	LDA 	#16 . board_to_screen_coords = 16
	MULR 	A, S
	MULR 	A, T

	. Need to move it since X will be set
	RMO 	X, B . color will be in B until we need it, since A and X are both going to be used
	
	. Calculate the screen index
	RMO 	T, A
	MUL 	#gscrw
	ADDR 	S, A
	RMO 	A, X . X now contains the offset from gscptr to the first pixel

	. S and T are no longer required
	. We'll use S for comparison
	ADD 	#16
	RMO 	A, S

	. Load color
	RMO 	B, A

	. Draw top line
tplnhl
	+STCH 	gscrptr, X
	TIXR 	S
	JLT 	tplnhl

	. Next 14 lines are just leftmost pixel and rightmost pixel
	. S will be used to know when we reach line 16
	+LDA 	#gscrw
	MUL 	#14
	ADDR 	A, S

	. Will be used to increase X
	+LDA 	#gscrw
	SUB 	#16 	. we need to move from last pixel to first in next line
	RMO		A, T
	+LDL 	#15

	. Load color back in
	RMO 	B, A

	. Move to next line
	ADDR 	T, X
sidelnhl
	. color first pixel
	+STCH 	gscrptr, X
	. Move to last pixel in line to be colored
	ADDR 	L, X
	. color last pixel
	+STCH 	gscrptr, X
	. Move to next line
	ADDR 	T, X
	. We're one short, so we increment X by 1
	TIXR 	S
	JLT 	sidelnhl

	. Now we have to draw the bottom line
	. S is in line 15, so we move it to line 16
	+LDA 	#gscrw
	ADDR 	A, S

	. Load color
	RMO 	B, A
	
	. Draw bottom line
botlnhl
	+STCH 	gscrptr, X
	TIXR 	S
	JLT 	botlnhl
	
	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDA @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Draws a gem
. Gem id in register A
. Board index in register B
drwgem
	+STL @stkptr
	JSUB spush
	+STX @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	. Store gem id for later
	RMO 	A, X

	. Calculate board X and Y
	. Y_idx = b_idx / board_col_count , this must trunacte it
	RMO 	B, A
	DIV 	#8	. board_col_count = 8
	RMO 	A, T
	. X_idx = b_idx - Y_idx * board_col_count
	MUL 	#8 . board_col_count = 8
	SUBR 	A, B
	RMO 	B, S

	. They are both not screen coordinates, so we need to adjust them
	LDA 	#16 . board_to_screen_coords = 16
	MULR 	A, S
	MULR 	A, T

	. Calculate gem X and Y
	. Y_idx = b_idx / atlas_count , this must trunacte it
	RMO 	X, A
	DIV 	#atlscnt
	RMO 	A, B
	. X_idx = b_idx - Y_idx * atlas_count
	MUL 	#atlscnt
	MUL 	#-1
	ADDR 	X, A
	RMO 	A, X

	. They are both not screen coordinates, so we need to adjust them
	LDA 	#16 . sprite_size = 16
	MULR 	A, X
	MULR 	A, B
	RMO 	B, A
	RMO 	X, B

	JSUB drwsprf
	
	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDX @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Draws a sprite on the screen.
. sprite Y coord on atlas in register A
. sprite X coord on atlas in register B
. X coord in register S
. Y coord in register T
drwspr	+STL	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush
	
	. calculate the start index of the sprite on the atlas
	+MUL 	#atlasw
	ADDR 	B, A
	RMO 	A, B
	
	. calculate the start index of the drawing area on screen
	RMO		T, A
	+MUL	#gscrw
	ADDR	S, A
	RMO 	A, T
	
	. B contains start index of sprite, T contains start index of draw area on screen
	. Adding #atlasw to B will increase sprite y by 1
	. Adding #gscrw to T will increase screen y by 1

	LDX 	#0
	LDS 	#0
drwclp
	
	. draw the first line
	LDX 	#0
drwllp
	. get sprite offset
	ADDR 	B, X
	. load 3 bytes
	+LDA 	sprtmap, X 	. If the first byte being read is ff this will read the wrong value
	SUBR 	B, X
	
	. get screen offset
	ADDR 	T, X
	. print 3 bytes
	+STA 	gscrptr, X
	
	. add 3 to loop index X
	RMO 	T, A
	SUB 	#3
	SUBR 	A, X
	
	. Check if 15 bytes have been printed
	LDA 	#15
	COMPR 	A, X
	JGT 	drwllp . drawing bytes 0 to 12
	. Check if 16 bytes have been printed
	LDA 	#16
	COMPR 	A, X
	JEQ 	lndrwn . all 16 bytes drawn 
	
	. 15 bytes drawn already, but not 16
	. draw remaining 16%3=1 bytes, by going back 2 and redarwing 3 of them
	LDA 	#2
	SUBR 	A, X
	J 		drwllp
	
lndrwn
	. draw next column
	LDA 	#gscrw
	ADDR 	A, T
	LDA 	#atlasw
	ADDR 	A, B
	LDA 	#1
	ADDR 	A, S
	LDA 	#16
	
	
	COMPR 	A, S
	JGT 	drwclp
	
	

	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB
	
. Draws a sprite on the screen.
. sprite Y coord on atlas in register A
. sprite X coord on atlas in register B
. X coord in register S
. Y coord in register T
drwsprf	+STL	@stkptr
	JSUB	spush
	+STX	@stkptr
	JSUB	spush
	
	. calculate the start index of the sprite on the atlas
	+MUL 	#atlasw
	ADDR 	B, A
	RMO 	A, B
	
	. calculate the start index of the drawing area on screen
	RMO		T, A
	+MUL	#gscrw
	ADDR	S, A
	RMO 	A, T
	
	. B contains start index of sprite, T contains start index of draw area on screen
	. Adding #atlasw to B will increase sprite y by 1
	. Adding #gscrw to T will increase screen y by 1

	LDX 	#0
	LDS 	#0
drwclpf
	
	. draw the first line
	LDX 	#0
drwllpf
	. get sprite offset
	ADDR 	B, X
	. load 6 bytes
	+LDF 	sprtmap, X 	. If the first byte being read is ff this will read the wrong value
	SUBR 	B, X
	
	. get screen offset
	ADDR 	T, X
	. print 6 bytes
	+STF 	gscrptr, X
	
	. add 6 to loop index X
	RMO 	T, A
	SUB 	#6
	SUBR 	A, X
	
	. Check if 12 bytes have been printed
	LDA 	#12
	COMPR 	A, X
	JGT 	drwllpf . drawing bytes 0 to 12
	. Check if 16 bytes have been printed
	LDA 	#16
	COMPR 	A, X
	JEQ 	lndrwnf . all 16 bytes drawn 
	
	. 12 bytes drawn already, but not 16
	. draw remaining 16%6=4 bytes
	LDA 	#2
	SUBR 	A, X
	J 		drwllpf
	
lndrwnf
	. draw next column
	LDA 	#gscrw
	ADDR 	A, T
	LDA 	#atlasw
	ADDR 	A, B
	LDA 	#1
	ADDR 	A, S
	LDA 	#16
	
	
	COMPR 	A, S
	JGT 	drwclpf
	
	

	JSUB	spop
	+LDX	@stkptr
	JSUB	spop
	+LDL	@stkptr
	RSUB

. Moves the provided index logically on the board in the cardinal directions
. A is the index
. B is the direction in which to move
.   0 -> right, 1 -> up, 2 -> left, 3 -> down
movelbd
	+STL @stkptr
	JSUB spush
	+STB @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush
	+STT @stkptr
	JSUB spush

	. jump to correct spot
	LDS 	#1
	COMPR 	B, S
	JLT 	mvright
	JEQ 	mvup
	LDS 	#3
	COMPR 	B, S
	JLT 	mvleft
	JEQ 	mvdown
	J 		err 	. invalid value provided

mvright
	. Make a copy of A since math will be happening in A
	RMO 	A, B
	. calculate maximal index (truncate to same row)
	DIV 	#8 . board width
	MUL 	#8 . truncate it
	ADD 	#7 . board width - 1

	. make sure it does not go over 63
	LDS 	#0 . dummy value, that needs to be smaller than A, we use min board index
	LDT 	#63
	JSUB 	clamp

	. Result is new MAX
	RMO 	A, T

	RMO 	B, A
	ADD 	#1
	LDS 	#0
	. MAX is already loaded
	JSUB 	clamp
	J 		mvend

mvleft
	. Make a copy of A since math will be happening in A
	RMO 	A, B
	. calculate minimal index (truncate to same row)
	DIV 	#8 . board width
	MUL 	#8 . truncate it

	. make sure it does not go under 0
	LDS 	#0
	LDT 	#63 . dummy value, that needs to be larger than A, we use max board index
	JSUB 	clamp

	. Result is new MIN
	RMO 	A, S

	RMO 	B, A
	SUB 	#1
	. MIN is already loaded
	LDT 	#63
	JSUB 	clamp
	J 		mvend

mvdown
	. Make a copy of A since math will be happening in A
	RMO 	A, B
	. We need to calculate the index in row
	. Get the minimal row index
	DIV 	#8 . board width
	MUL 	#8 . truncate it

	. Calculate index - minimal row index = index in row
	RMO 	A, S
	RMO 	B, A
	SUBR 	S, A

	. Guaranteed to be in range [0, 7]

	. Move it to last row (+7*8=+56)
	ADD 	#56

	. Result is new MAX
	RMO 	A, T

	RMO 	B, A
	ADD 	#8 . board width
	LDS 	#0
	. MAX is already loaded
	JSUB 	clamp
	J 		mvend

mvup
	. Make a copy of A since math will be happening in A
	RMO 	A, B
	. We need to calculate the index in row
	. Get the minimal row index
	DIV 	#8 . board width
	MUL 	#8 . truncate it

	. Calculate index - minimal row index = index in row
	RMO 	A, S
	RMO 	B, A
	SUBR 	S, A

	. Guaranteed to be in range [0, 7]

	. Result is new MIN
	RMO 	A, S

	RMO 	B, A
	SUB 	#8 . board width
	. MIN is already loaded
	LDT 	#63
	JSUB 	clamp
	J 		mvend

mvend
	JSUB spop
	+LDT @stkptr
	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDB @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Pseudorandom 24-bit fibonacci LFSR (https://en.wikipedia.org/wiki/Linear-feedback_shift_register)
. The polinomial x^24 + x^23 + x^22 + x^17 + 1 is used, which coresponds to taps 0xE10000
. XORS were used originally, but it is really slow since its simulated, so instead we cleverly use ADD
. we just have to be careful to not overflow, and we get the same functionality as XOR
. Returns the new number in A, but also places it in seed
lfsr24
	+STL @stkptr
	JSUB spush
	+STS @stkptr
	JSUB spush

	. init registers
	LDS 	#0

	. done this way to avoid overflow when adding
	. lfsr, x^24
	+LDA 	seed
	AND 	#1
	ADDR 	A, S

	. lfsr >> 1, x^23
	+LDA 	seed
	SHIFTR 	A, 1
	AND 	#1
	ADDR 	A, S

	. lfsr >> 2, x^22
	+LDA 	seed
	SHIFTR 	A, 2
	AND 	#1
	ADDR 	A, S

	. lfsr >> 7, x^17
	+LDA 	seed
	SHIFTR 	A, 7
	AND 	#1
	ADDR 	A, S

	. new bit is calculated and moved into S
	RMO 	S, A
	AND 	#1
	RMO 	A, S
	
	. bit << 23
	SHIFTL	S, 16
	SHIFTL 	S, 7

	. lfsr >> 1
	+LDA 	seed
	SHIFTR 	A, 1 	. shift right adds a 1 at the left side, we dont want that
	AND 	shrmsk

	. OR lfsr >> 1 | bit << 23
	+STS 	seed
	OR 		seed

	+STA 	seed

	JSUB spop
	+LDS @stkptr
	JSUB spop
	+LDL @stkptr
	RSUB

. Utility clamp functions, clamps the value in A between a max and min
. A is the thing to clamp
. S is min
. T is max
clamp
	+STL @stkptr
	JSUB spush

	COMPR 	A, S
	JLT 	clunderflow
	COMPR 	A, T
	JGT 	cloverflow
	J 		clend

clunderflow
	RMO 	S, A
	J 		clend
cloverflow
	RMO 	T, A
	J 		clend

clend
	JSUB spop
	+LDL @stkptr
	RSUB

. SIC/XE does not have a not operation because why have it
. We abuse 2's complement to implement it
not
	+STA 	tmpnot
	LDA 	#0
	SUB 	#1
	SUB 	tmpnot
	RSUB

. XOR implementation
. A contains the first word
. B contains the second word
. Result is in A
xor
	+STL 	@stkptr
	JSUB 	spush
	+STB 	@stkptr
	JSUB 	spush

	. A | B
	+STA 	xora
	+STB 	xorb
	+OR 	xorb
	RMO 	A, B

	. !A & B
	+LDA 	xora
	+AND 	xorb
	JSUB 	not

	. (A | B) & (!(A & B))
	+STB 	xorb
	+AND 	xorb

	JSUB 	spop
	+LDB 	@stkptr
	JSUB 	spop
	+LDL 	@stkptr
	RSUB

. Basic stack functionality routines
.
. Initialize the stack, usage:
. JSUB sinit
sinit
	LDA	#stack
	ADD	#stklen
	SUB	#3
	+STA	stkptr
	RSUB

. Push a register on the stack, usage:
. +STA @stkptr
. JSUB spush
spush
	STA	spptmp
	+LDA	stkptr
	SUB	#3
	+STA	stkptr
	LDA	spptmp
	RSUB

. Pop from the stack, usage:
. JSUB spop
. +LDA @stkptr
spop
	STA	spptmp
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

. 16x16 per sprite, 8 sprites => 16x8 = 128
gscrptr	EQU		0xA000
gscrw 	EQU		128
gscrh 	EQU		128

. keyboard is just a byte with the value of the key being pressed
kbptr 	EQU 	0xF000

. 8x8 game board
board 	RESB 	64
. Wether the currently displayed board index is valid
brdval 	RESB 	64
gemsel	WORD 	0 	. wether a gem is selected
selgem	WORD 	0	. the selected gem board index
hlgemi	WORD 	0 	. the currently highlighted gem board index
hlgemc 	BYTE 	0 	. if the highlighted gem board index was changed this cycle

. temporary variable to perform not operation
tmpnot 	WORD 	0
. The seed used to generate numbers (pseudo randum, 2 bytes, must be non 0)
seed	WORD	0xabcdef
shrmsk 	WORD 	0x7FFFFF . shift right introduces a 1, for this algorithm we can't have that happend
xora	RESW 	1
xorb	RESW 	2

cubeid	EQU 	0x7
emtyid 	EQU 	0xa

gemdst  EQU 	8
maxgem 	EQU 	7
atlasw 	EQU 	176
gemcnt 	EQU 	7
atlscnt	EQU		11
sprtmap EQU 	*
sprites	
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf4
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xf4
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf4
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xf4
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf4
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xf4
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xe3
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xfc
		BYTE	0xfc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc7
		BYTE	0xcc
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xc7
		BYTE	0xc7
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf4
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xea
		BYTE	0xea
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xf0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
		BYTE	0xc0
