... PROGRAM ...

txtwal	START  0

... MAIN ...........................................................................................
. A demo for SicTools text screen. It creates streams of numbers and scrolls them vertically over
.	the screen in a matrix-like style.
.
. Uses text screen, size 80x25 by default, different height supported, but note the change in label:
.	scrrows - should hold the number of screen rows
.
.	Frequency increase necessary for this to work fast! Somewhere from 10^5 to 10^7 should be fine.

main	JSUB	stinit		initiate stack
		JSUB	tsinit		initiate text screen
		
		LDX		#0			X = 0
setloop	LDCH	poslst,X	load next value from poslst
		COMP	#0xFA		check for end value
		JEQ		setend		end 1st phase if found
		
		JSUB	lfsr		call random number generator
		LDA		lfsrreg		A = random 16bit number
		AND		#0x7F		mask it to 7bit (max = 127)
		COMP	#79			compare to last column index
		JGT		set2big		reduce number if it is too big
		J		setok		continue if it is not

		. this one tends to place everything to the right, but is faster
.set2big	SUB		#48			A -= 48 (so at most A can be 79 now)

		. this one places evenly, but is slower for each miss
set2big	JSUB	lfsr		call random number generator
		LDA		lfsrreg		A = random 16bit number
		AND		#0x7F		mask it to 7bit (max = 127)
		COMP	#79			compare to last column index
		JGT		set2big		reduce number if it is too big
		J		setok		continue if it is not
		
setok	STCH	poslst,X	store position number
		
		ADD		screen		add screen coordinate
		STA		scrpos		store position number
		LDA		#0x33		A = ascii 3
		STA		@scrpos		write A to screen
		
		
		JSUB	lfsr		call random number generator
		LDA		lfsrreg		A = random 16bit number
		AND		#0x0F		mask it to 4bit (max = 15)
		STCH	lenlst,X	store length number
		
		LDA		#1			A = 1
		ADDR	A,X			X++
		
		J		setloop		loop the setting phase
		
		
		...2nd phase...
setend	LDX		#0			done setting initial values, X = 0
runloop	JSUB	sscroll		scroll screen
		
		LDCH	lenlst,X	load next value from lenlst
		COMP	#0xFA		check for end value
		JEQ		setend		restart 2nd phase

		COMP	#0x00		check if zero yet
		JEQ		setnew		set a new value if so
		J		decold		decrease old value if not

		... clear old character & set new length, position, character ...
setnew	LDCH	poslst,X	A = position
		ADD		screen		add screen coordinate
		STA		scrpos		store position number
		LDA		#0x20		A = 0x20 (space)
		STA		@scrpos		write A to screen
		
set2bg2	JSUB	lfsr		setting new position, call random number generator
		LDA		lfsrreg		A = random 8bit number
		AND		#0x7F		mask it to 7bit (max = 127)
		COMP	#79			compare to last column index
		JGT		set2bg3		reduce number if it is too big
		J		newposk		continue if it is not
		
set2bg3	SUB		#48			A -= 48 (so at most A can be 79 now)

newposk	STCH	poslst,X	save new position to position list

		JSUB	lfsr		making new length, call random number generator
		LDA		lfsrreg		A = random 8bit number
		AND		#0x0F		mask it to 4bit (max = 15)
		STCH	lenlst,X	store length number
		
		LDCH	poslst,X	A = position
		ADD		screen		add screen coordinate
		STA		scrpos		store position number
		
		.pick random number
		JSUB	lfsr		making new length, call random number generator
		LDA		lfsrreg		A = random 8bit number
		AND		#0x07		mask it to 3bit (max = 7)
		ADD		#0x31		mone it up to hold an ascii number from 1 to 7
		.LDA		#0x38		A = 0x38 (ascii 8)
		
		STA		@scrpos		write A to screen
		
		J		runloop		loop again


		... decrease length and loop...
decold	SUB		#1			A--
		STCH	lenlst,X	store decremented A
		LDA		#1			A = 1
		ADDR	A,X			X++
		J		runloop		loop again
		
		
jscroll	JSUB	sscroll
		.J		jscroll
		
loop	J		loop
		END		main

... FUNCTIONS ......................................................................................

...lfsr - a simple 16bit pseudo-random number generator based on linear-feedback shift register
lfsr	STL		@sp			store L
		JSUB	stpush		sp++
		STA		@sp			store A
		JSUB	stpush		sp++
		STS		@sp			store S
		JSUB	stpush		sp++
		STT		@sp			store T
		JSUB	stpush		sp++
		
		LDS		lfsrreg		S = lsfrreg (starts with b01010101)
		
		RMO		S,A			A = S
		AND		b16			16th bit
		SHIFTR	A,15		move it into 1st spot
		RMO		A,T			move result to T
		
		RMO		S,A			A = S
		AND		b14			14th bit
		SHIFTR	A,13		move it into 1st spot
		ADDR	A,T			add to T
		
		RMO		S,A			A = S
		AND		b13			13th bit
		SHIFTR	A,12		move it into 1st spot
		ADDR	A,T			add to T
		
		RMO		S,A			A = S
		AND		b11			11th bit
		SHIFTR	A,10		move it into 1st spot
		ADDR	A,T			add to T
		
		RMO		T,A			A = T
		AND		#1			A = the 1st bit of A
		
		SHIFTL	S,1			shift value left
		ADDR	A,S			fill the 1st bit of S after shift w/ xor from 16th, 14th, 13th and 11th.
		
		STS		lfsrreg		store result back
		
		.J		lfsr
		
lfsrend	JSUB	stpop		sp--
		LDT		@sp			restore T
		JSUB	stpop		sp--
		LDS		@sp			restore S
		JSUB	stpop		sp--
		LDA		@sp			restore A
		JSUB	stpop		sp--
		LDL		@sp			restore L
		RSUB


... SCREEN FUNCTIONS ...............................................................................


...sscroll - scroll all the text DOWN by one line to free a new line
sscroll	STL		@sp			store L
		JSUB	stpush		sp++
		STA		@sp			store A
		JSUB	stpush		sp++
		STS		@sp			store S
		JSUB	stpush		sp++
		STT		@sp			store T
		JSUB	stpush		sp++
		LDT		tmpcur		load temp cursor address
		STT		@sp			push it to save it for later
		JSUB	stpush		sp++
		
		LDA		screen		A = screen
		RMO		A,S			S = screen
		STS		curaddr		curaddr = screen
		ADD		scrcols		A = screen + width
		RMO		A,T			T = screen + width
		STT		tmpcur		tmpcur = screen + width
		
scrloop	LDCH	@curaddr
		STCH	@tmpcur
		
		LDA		#1			A = 1
		ADDR	A,S			S++
		STS		curaddr		curaddr++
		ADDR	A,T			T++
		STT		tmpcur		tmpcur++
		
		LDA		scrend		A = scrend
		ADD		#1
		COMPR	A,T			check if T is at the last char yet
		JEQ		scrlend		jump to end
		J		scrloop		loop

scrlend	LDA		scrend		A = screen end
		SUB		scrcols		A = screen end - screen width
		ADD		#1			A = screen end - screen width + 1
		STA		curaddr		curaddr = 1st column, last row

		JSUB	stpop		sp--
		LDT		@sp			load temp cursor address into T
		STT		tmpcur		restore temp cursor address
		JSUB	stpop		sp--
		LDT		@sp			restore T
		JSUB	stpop		sp--
		LDS		@sp			restore S
		JSUB	stpop		sp--
		LDA		@sp			restore A
		JSUB	stpop		sp--
		LDL		@sp			restore L
		RSUB


...tsinit - text screen variables init
tsinit	STL		@sp			store L
		JSUB	stpush		sp++
		STA		@sp			store A
		JSUB	stpush		sp++
		
		LDA		scrcols		A = scrcols
		MUL		scrrows		A = scrcols * scrrows
		STA		scrlen		scrlen = scrcols * scrrows
		ADD		screen		A = screen + scrlen
		SUB		#1			A = screen + scrlen - 1
		STA		scrend		scrend = screen + scrlen - 1
		
		JSUB	stpop		sp--
		LDA		@sp			restore A
		JSUB	stpop		sp--
		LDL		@sp			restore L
		RSUB

... STACK FUNCTIONS ................................................................................

...stinit
stinit	LDA		#stack
		STA		sp		get stack pointer in place
		RSUB			return

...stpush
stpush	STA		tempa	store A value because we need it
		LDA		sp		\
		ADD		#3		 > sp += 3
		STA		sp		/
		LDA		tempa	restore A value
		RSUB			return

...stpop
stpop	STA		tempa	store A value because we need it
		LDA		sp		\
		SUB		#3		 > sp -= 3
		STA		sp		/
		LDA		tempa	restore A value
		RSUB			return



... DATA ...........................................................................................

number	BYTE	X'02050800'	numbers for faculty calculation
				
poslst	BYTE	X'000000000000000000000000000000000000000000000000000000000000FA'
lenlst	BYTE	X'000000000000000000000000000000000000000000000000000000000000FA'

scrpos	RESW	1
andspc	RESW	1

.lfsrreg	WORD	85
lfsrreg	WORD	41
b16		WORD	32768		16th bit
b14		WORD	8192		14th bit
b13		WORD	4096		13th bit
b11		WORD	1024		11th bit

screen	WORD	X'00B800'	the location of screen memory mapping
scrcols	WORD	80			screen width (column count)
scrrows	WORD	25			screen height (row count)
scrlen	RESW	1			screen length in bytes
curaddr	WORD	X'00B800'	address where cursor points in memory
tmpcur	WORD	X'00B800'	temporary cursor address
scrend	RESW	1			last screen position

sp		RESW	1		Stack pointer (that needs to be initiated!)
stack	RESW	256		Stack space.
tempa	RESW	1		Spot for temporarily storing A.
