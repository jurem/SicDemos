
.
. How to use:
. - graphical screen, 109x109 
. - frequency, 10000 (1000 works as well)
. - input: 
.	- colour is element of {r - red, w - white, y - yellow, g - green}
.	- x, y and n are elements of [-5, 5]
.   - draw a point: 
.		- pxyK{colour}
.		- where K is optional and if used will draw the point as a cross
.		- p22r -> draws point at x = 2, y = 2 in red colour
.		- p-23Ky -> draws point as a cross at x = -2, y = 3 in yellow colour
.   - draw a function:
.		- functions have two ways of input:
.			- y = x and y = -x : fx{colour} and f-x{colour}
.			- y = n: fn{colour}
.			- f-4w -> draws y = -4 function in white colour
.			- fxr -> draws y = x function in red colour
.	- clear screen: c
.	- exit program: 0
.

primer  START  0

first
	LDA rows		...calculate max screen address
	MUL cols
	ADD screenOrg
	STA screenMax
	LDA =0
	JSUB initGraph   ...function that draws initial graph
	
startLoop
	RD stdin			
	COMP =0x30			...if '0' on input, end program (inf. loop)
	JEQ koncaj
	COMP =0x66			...if 'f' on input, draw function
	JEQ fun
	COMP =0x63			...if 'c' on input, clear screen
	JEQ clr
	COMP =0x70
	JEQ point			...if 'p' on input, draw point
	J halt				...if invalid input, end program (inf. loop)
	
clr
	JSUB clearScreen	....function for clearing screen
	J fun1
fun
	JSUB funkcija		....function for drawing functions
	J fun1
point
	JSUB tocka			....function for drawing points
fun1
	RD stdin			...NL
	RD stdin			...CR

	LDA =0
	STA col				...reset row and column that were used
	STA row
	J startLoop
	
koncaj
	RD stdin
	RD stdin
halt    J      halt

.................
clearScreen
	STL skokPoint	...save L register
	LDA =0
	STA row
	STA col
	
	...Nested loop that iterates over the whole screen, setting every address to 0
clearLoop
			JSUB calculateAddr	...Calculates the address
			LDA =0
			STA @address
			LDA col
			ADD =3
			STA col
			COMP cols
		JLT clearLoop
		LDA =0	
		STA col
		LDA row
		ADD =1	
		STA row
		COMP rows	
	JLT clearLoop
		
	JSUB initGraph	...after screen cleared, redraw graph
	LDL skokPoint	...reload L register
	RSUB
	
.................

...Function for drawing functions(jump here if 'f' on input)
funkcija
	STL skok	...save L register
	
	JSUB getFun		...Read other parameters of input
	LDA funkcijaSpr	...variable that tells us what kind of function we have
	COMP =0			...if funkcijaSpr == 0 then we have a function of type y = 2 (not dependant on x)
	JGT funkcijaDone	...skip if funkcijaSpr > 0, because it was already drawn
	JSUB getColour	
	LDA =0
	
functionLoop		...Draw the function if funkcijaSpr = 0
		STA col
		JSUB calculateAddr
		LDA colour
		STCH @address
		LDA col 
		ADD =1
		COMP cols
	JLT functionLoop

funkcijaDone	.... When done reset col and row
	LDA =0
	STA col
	STA row
	LDL skok	...reload L register
	RSUB
.................	
...Function for drawing points
tocka
	STL skok
	
	JSUB getCol	..gets column where we want to draw
	JSUB getRow	 ..gets row where we want to draw
	JSUB drawPoint ..draws the point
	
	LDL skok
	RSUB
.................
getFun
	STL skokPoint	...save L register
	
	JSUB getRow     ...get the function that was on input
	LDA funkcijaSpr 
	COMP =0
	JEQ gotFun      ...if function of type y = n (not dependant of x), then draw it in the other subroutine
	JSUB getColour  ...otherwise get color
	COMP =2
	JEQ pozFunkcija	...y = x
	COMP =1
	JEQ negFunkcija ...y = -x
	

pozFunkcija
		LDA screenMax	...start at first column of last row
		SUB =110
		STA address
		LDA screenOrg
		ADD =109
		STA screenTemp	...end at last column of first row

pozFunLoop				...draw function
		LDA colour
		STCH @address
		LDA address
		SUB =108		...equivalent to: row - 1, col - 1
		STA address
		COMP screenTemp
	JGT pozFunLoop
	J gotFun
	
negFunkcija
		LDA screenMax	...start at last column of last row
		STA address
		
negFunLoop
		LDA colour
		STCH @address
		LDA address
		SUB =110		...equivalent to: row + 1, col + 1
		STA address
		COMP screenOrg	...end at first element of screen
	JGT negFunLoop	
	
gotFun
	LDL skokPoint	...reload L register
	RSUB
	
.................	
getCol
	LDA =0	
	STA col
	TD stdin
	RD stdin		...get column where to draw from input: [-5,5]
	COMP =0x2D		...if '-' on input
	JEQ colNeg
	
	....positive x coordinate, normalize input according to size of screen
	SUB =48	
	MUL =10	
	ADD =54
	J koncCol
	
	....negative x coordinate, normalize input according to size of screen
colNeg
	RD stdin
	SUB =48
	STA tempNeg
	LDA =5
	SUB tempNeg
	MUL =10
	ADD =3
	
koncCol
	STA col	...store normalized input to variable
	RSUB
.................

...Same as getCol, except for functions part
getRow 
	LDA =0
	STA row
	RD stdin
	COMP =0x78
	JEQ funkcijaPoz
	COMP =0x2D
	JEQ negRow
	
	....primer pozitivne koordinate y-os
	SUB =48
	STA tempNeg
	LDA =5
	SUB tempNeg
	STA testiram
	MUL =10
	ADD =3	
	J koncRow

negRow	
	....primer negativne koordinate y-os
	RD stdin
	COMP =0x78
	JEQ funkcijaNeg
	SUB =48
	MUL =10
	ADD =54
	J koncRow
	
	....if input is a positive function
funkcijaPoz
	LDA =2
	STA funkcijaSpr
	J koncRow2
	
	....if input is a negative function
funkcijaNeg
	LDA =1
	STA funkcijaSpr
	J koncRow2
	
	...when done, store to varibles
koncRow
	STA row
	LDA =0
	STA funkcijaSpr ...if input function is not dependant on x
koncRow2
	RSUB
.................
drawPoint
	STL skokPoint ...save L register
	JSUB getColour  ... get color
	JSUB calculateAddr ... get address
	LDA colour 
	STCH @address    ... draw point
	LDA krizec     ... check if 'K' was in input (is set in getColour)
	COMP =1        ... if krizec == 0, jump to end of function
	JLT niKrizec
	
	LDA address	   ...draw cross	
	ADD =109	   ...row + 1
	STA address
	LDA colour
	STCH @address
	LDA address
	SUB =108       ...row - 1, col + 1
	STA address
	LDA colour
	STCH @address
	LDA address
	SUB =2         ...col - 2
	STA address
	LDA colour
	STCH @address
	LDA address
	SUB =108       ...row - 1, col + 1
	STA address
	LDA colour
	STCH @address
	
niKrizec
	LDA =0
	STA krizec	  ... reset krizec variable
	LDL skokPoint
	RSUB	
.................

...Function that reads the colour from input
getColour
	STA temp
	
	RD stdin
	COMP =0x67
	JLT krizecJmp	...if 'K' on input, jump (in reality anything that has ASCII < 0x67 will work)
	COMP =0x77		...'w'-> white
	JEQ whiteColour
	COMP =0x72		...'r'-> red	
	JEQ redColour
	COMP =0x67		...'g'-> green
	JEQ greenColour
	COMP =0x79		...'y'-> yellow
	JEQ yellowColour
	
	J gotColour
	
krizecJmp
	LDA =1
	STA krizec		...if 'K' on input, read again to get colour
	RD stdin
	COMP =0x67
	JLT krizec
	COMP =0x77		...'w'-> white
	JEQ whiteColour
	COMP =0x72		...'r'-> red	
	JEQ redColour
	COMP =0x67		...'g'-> green
	JEQ greenColour
	COMP =0x79		...'y'-> yellow
	JEQ yellowColour	
	
...Store colour into colour variable
yellowColour
	LDA yellow
	STA colour 
	J gotColour
	
greenColour
	LDA green
	STA colour
	J gotColour
	
redColour
	LDA red
	STA colour
	J gotColour
	
whiteColour
	LDA white
	STA colour
	J gotColour
	
gotColour
	LDA temp
	RSUB

..................

..Function for calculation of address: row * COLUMNS + col + screenOrg
calculateAddr
	STA temp
	LDA row
	MUL cols
	ADD col
	ADD screenOrg
	STA address
	LDA temp
	RSUB
	
..................

..Function that draws inital graph (x and y axis)
initGraph
	STL skok		..save L register
	STA temp
	LDA =0			..Start in center of the first row
	STA row		
	LDA =54			
	STA col
	
	..draw y axis
navpCrta
		JSUB calculateAddr	
		LDA white
		STCH @address
		LDA row 
		ADD =1
		COMP rows
		STA row
	JLT navpCrta
	
	LDA =54
	STA row
	LDA =0
	STA col
	
	..draw x axis
vodCrta
		JSUB calculateAddr
		LDA white
		STCH @address
		LDA col 
		ADD =1
		COMP cols
		STA col
	JLT vodCrta
	
	LDA =3
	STA row
	
	..draw "flare" on y axis (number indicators (i guess?))
	.. this is a bit awkward, because I didn't use the perfect screen size (row, col)
	.. meaning it is not exactly simmetric, hence so many jumps inside the loop.
	.. Essentially it draws 2 points around the axis and skips 10 rows ahead, 
	.. which normalized translates to 1 row -> it jumps to the next number,
	.. if the next number is 0 (if we are in row 43) it jumps 21 rows,
	.. to maintain "symmetry" of the graph
navpFlare
		LDA =53
		STA col
		JSUB calculateAddr
		LDA white
		STCH @address
		LDA =55
		STA col
		JSUB calculateAddr
		LDA white
		STCH @address
		LDA row 
		COMP =43
		JEQ navpDrugAdd
		ADD =10
		J navpAdd10
navpDrugAdd	
		ADD =21		
navpAdd10	
		COMP rows
		STA row
	JLT navpFlare

	LDA =3
	STA col
	
	...Same thing as y axis flare, just for x axis
vodFlare
		LDA =53
		STA row
		JSUB calculateAddr
		LDA white
		STCH @address
		LDA =55
		STA row
		JSUB calculateAddr
		LDA white
		STCH @address
		LDA col 
		COMP =43
		JEQ vodDrugAdd
		ADD =10
		J vodAdd10
vodDrugAdd	
		ADD =21		
vodAdd10	
		COMP cols
		STA col
	JLT vodFlare
	LDA temp
	LDL skok
	RSUB
...........................Konec initGraph	

. data
stdin		BYTE X'00'
stdout		BYTE X'01'
white		WORD 0x0000FF
red			WORD 0x0000F0
green		WORD 0x0000CC
yellow		WORD 0x0000FC
colour		WORD 0x79
cols		WORD 109
rows		WORD 109
col			WORD 0
row			WORD 0
temp		WORD 0
screenOrg	WORD 0x0A000
screenMax	WORD 0
screenTemp  WORD 0
address		WORD 0
skok		WORD 0
skokPoint	WORD 0
krizec 		WORD 0
x			WORD 0
tempNeg		WORD 0
testiram 	WORD 0
testiram1 	WORD 0
testiram2 	WORD 0
funkcijaSpr	WORD 0 ..... 0 = ni funkcija odvisna od x, 1 => y = x, 2 => y = -x
			END    first