. DRAW
. enter a command (or more commands) to stdin and press enter to draw
. commands:
. - h : displays help on stdout
. - w, a, s, d : up, left, down, right
. - f : changes drawing symbol to next typed character
. - c : clears the screen and returns to center
. - p : fills the screen with drawing symbol
. - q : halt
.
. examples:    'aaaa wwww dddd ssss' -> draws a 4x4 square
.              'f.' -> changes drawing symbol to '.'
.              'f-dddf df-dddf df-ddd' -> draws a dashed line '--- --- ---'
.
draw START 0 
reset LDA scrcols            . calculate center:  X = (scrcols/2) * scrrows  
	DIV #2
	MUL scrrows
	RMO A, X                   . set X to center coordinate
	J help                     . display help (comment this line to skip it)
	J printcur                         
	
input RD #0
	COMP #10                   
	JEQ input                  . newline, ignore
	COMP #113
	JEQ halt                   . q, halt 
	COMP #102
	JEQ switch                 . f, change drawing symbol
	COMP #99
	JEQ clear                  . c, clear screen
	COMP #112
	JEQ fill                   . p, fill screen
	COMP #104
	JEQ help                   . h, help
	COMP #119
	JEQ up                     . w a s d za premikanje kurzorja
	COMP #97
	JEQ left
	COMP #115
	JEQ down
	COMP #100
	JEQ right
	J input
	
	                          . switch the drawing symbol 
switch RD #0                
	COMP #10                    
	JEQ switch                . newline is ignored, read another character
	STA symbol
	J input                  
	
	                          . clear screen - call scrclear
clear JSUB scrclear    
	J reset
	
	                          . fill screen - load symbol and call scrfill
fill LDA symbol
	JSUB scrfill
	J reset
	
printcur LDA cursor         . print cursor to coordinate in X
	+STCH screen, X
	J input
	
	                          . move up
up LDA symbol
	+STCH screen, X           . print symbol on current X (location of cursor) 
	LDA scrcols               . move X up (X = X - scrcols)
	SUBR A, X
	LDA #0                    
	COMPR X, A                . if X is too far up, move it to bottom of the screen 
	JLT pluslen               
	J printcur                
pluslen LDA scrlen          . moves X from above the screen to bottom (adds scrlen)
	ADDR A, X
	J printcur                . add scrlen (move X from top to bottom)
	
	                          . move down - almost the same as up
down LDA symbol             
	+STCH screen, X           . draw symbol to X, move X down one row
	LDA scrcols
	ADDR A, X                 
	LDA scrlen
	COMPR X, A
	JGT minuslen              . if X is too far down, move it to top of screen
	J printcur                
minuslen LDA scrlen         . subtract scrlen (move X from bottom to top)
	SUBR A, X
	J printcur                
	
	                          . move left
left LDA symbol             
	+STCH screen, X           . draw symbol to X
	RMO X, A
	DIV scrcols               . calculate current row ( X / scrcols)
	STA currow
	LDA #1
	SUBR A, X                 . move X one to left
	RMO X, A                  . if X moved too far left, it will be one row higher on the right side
	DIV scrcols               
	COMP currow               . X / scrcols gives us the row X is on
	JLT pluscol               . if calculated row is lower than currow, move one down 
	J printcur
pluscol LDA scrcols         . add scrcols (move X one down)
	ADDR A, X
	J printcur
	
	                          . move right - almost the same as up
right LDA symbol
	+STCH screen, X           . draw symbol, move X to right, check if we went too far
	RMO X, A
	DIV scrcols
	STA currow
	LDA #1
	ADDR A, X
	RMO X, A
	DIV scrcols
	JGT minuscol              . if calculated row is too high, move X one row up
	J printcur
minuscol LDA scrcols        . subtract scrcols (move X one up)
	SUBR A, X
	J printcur

help STX tmpX               . print help to stdout
	LDX #0
	LDA #helplen              .calculate length of help text
	SUB #helptxt
	SUB #2
	STA helplen
help1 LDA helptxt, X        . read from helptxt, write to stdout
	WD #1
	TIX helplen               . increment X and compare it to help length
	JEQ rethelp               
	J help1    
rethelp LDX tmpX . restore X, set A to 0 and go to input
	LDA #0
	J printcur                . draw cursor on the screen and wait for new input 
	
scrclear STA tmpA           . save A to tmpA, set it to space and call writeA
	LDA #32 
	J writeA
	
scrfill STA tmpA            . save A to tmpA and call writeA
	J writeA
	
writeA  STX tmpX            . write last bit of A to whole screen
	LDX #0 
loop +STCH screen, X
	TIX scrlen
	JEQ return
	J loop
return LDX tmpX             . reload A and X from tmpA and tmpX
	LDA tmpA
	RSUB               
	
halt J halt
	
symbol WORD 42        . drawing symbol
cursor WORD 43        . cursor symbol
currow WORD 12        . current row
tmpX RESW 1     
tmpA RESW 1
scrcols WORD 80       . screen columns - should be the same as settings in simulator
scrrows WORD 25       . screen rows    
scrlen WORD 2000
	                    . help text
helptxt BYTE C'  ---DRAW---'    
	BYTE 10
	BYTE C'type a command (or more commands) to stdin and press enter to draw'
	BYTE 10
	BYTE C'commands:'
	BYTE 10
	BYTE C'- h: help'
	BYTE 10
	BYTE C'- w,a,s,d: up, left, down, right'
	BYTE 10
	BYTE C'- f: change drawing symbol to next entered character'
	BYTE 10
	BYTE C'- c: clear screen and move to center'
	BYTE 10
	BYTE C'- p: fill screen with drawing symbol'
	BYTE 10
	BYTE C'- q: stop the program'   
	BYTE 10
helplen RESW 1         
	
	ORG 47104           . screen address in memory
screen RESB 1
