. This program does the selection sort algorithm.
. Author: Naum Gjorgjeski


ss		START	0
		. initialize stack pointer
		JSUB	init
		. selection sort starts here
		. X = indice of the first unsorted element
		LDX		bound
		. find the minumum element in the unsorted part of the array and return its indice in T
loopmin	JSUB	minind
		. store X and T registers (indices of the first unsorted element and the minimum element in the unsorted part)
		STX		swap1
		STT 	swap2
		JSUB	swap
		. print the array
		JSUB	echotab
		. X = boundary between the sorted and unsorted part of the array
		LDX		bound
		. T = 3 bytes(1 word)
		LDT		#3
		. we have made one iteration of the selection sort algorithm, so we have increased the boundary between the sorted and unsorted 
		. part of the array for 1 byte 
		. X = X + 1 byte (that's the indice of next element in the array)
		ADDR	T, X
		. store the current boundary between the sorted and unsorted part of the array in bound
		STX		bound
		. T = length of the array
		LDT		#len
		COMPR	X, T
		. if the boundary between the sorted and unsorted part of the array is equal to the array length, the algorithm has done its job
		. then we halt the algorithm
		JEQ		halt
		J 		loopmin
halt    J      	halt
		END		ss

. dirties A, S, X
. return the indice of the minumum element in T
. find the minumum element in the unsorted part of array
. in bound we load and store the boundary between the sorted and unsorted part of the array
minind	STA 	olda
		STS 	olds
		STX 	oldx
		. we start searching for the minumum element right of the boundary between the sorted and unsorted part of the array
		LDX		bound
		. A = initialize the current minimum element (it's the first element in the unsorted part of the array)
		LDA		tab, X
		. T = indice of the minimum element
		LDT		bound
		. S = 3 bytes, the length of a word in SIC/XE
minloop	LDS		#3
		. increase the boundary for 1 word (3 bytes)
		ADDR	S, X
		. S = length of array
		LDS		#len
		COMPR	X, S
		. if we have reached the end of the array, jump out of the loop
		JEQ		out4
		. S = the element in the array with index X
		LDS		tab, X
		COMPR	A, S
		. if A < S, jump back to the loop
		JLT		minloop
		.if A > S, correct the minumum element and the indice of the minumum element (S = A and T = X)
		RMO		S, A
		RMO		X, T
		. jump back to the loop
		J 		minloop
out4	LDA		olda
		LDS		olds
		LDX		oldx
		RSUB


. dirties A, S, X
. swap two elements in the array (the indices are in swap1 and swap2)
. we must access an element in the array through the index register X
swap	STA 	olda
		STS 	olds
		STX 	oldx
		LDX		swap1
		. load the first element in A
		LDA		tab, X
		LDX		swap2
		. load the second element in S
		LDS		tab, X
		. store the first element at the second element's indice
		STA 	tab, X
		LDX		swap1
		. store the second element at the first element's indice
		STS		tab, X
		LDA		olda
		LDS		olds
		LDX		oldx
		RSUB

. dirties A, X
. push register L to stack because we are calling the echonum subroutine inside the echotab subroutine
echotab	STL		@stackptr
		JSUB	push
		STA		olda
		STX		oldx
		. X = 0 , start index
		CLEAR	X
		. A = array element (number) at index X
looptab	LDA		tab, X
		. print the number
		JSUB	echonum
		. print space
		LDA 	space
test2	TD		stdout
		JEQ		test2
		WD		stdout
		. A = boundary between the sorted and unsorted part of the array
		LDA		bound
		COMPR	A, X
		. if X = A (the boundary), print vertical line and space after it
		JEQ		dline
		. else jump that part
		J 		noline
dline	LDA 	line
test3	TD		stdout
		JEQ		test3
		WD		stdout
		LDA 	space
test5	TD		stdout
		JEQ		test5
		WD		stdout
		. A = 3 bytes (1 word)
		. ce je konec tabele koncaj z izpisovanjem, ce ne vrni se v zanki in izpisi naslednje stevilo
noline	LDA		#3
		. X = X + 3 bytes (1 word)
		ADDR	A, X
		. A = length of the array
		LDA		#len
		. if X = A, we have reached the end of the array (we have printed the whole array)
		. if X = A, we should print new line and return from the subroutine
		COMPR	X, A
		JEQ		out1
		. else go back to the loop and print the next number
		J 		looptab
		. print newline
out1	LDA 	newline
test1	TD		stdout
		JEQ		test1
		WD		stdout
		. pop register L from the stack
		JSUB	pop
		LDL		@stackptr
		LDA		olda
		LDX		oldx
		RSUB

. dirties A, T, S, X
. print certain number in the array
echonum	STA 	olda
		STS 	olds
		STT 	oldt
		STX 	oldx
		. divide the number with 10 and store the digits in the memory
		CLEAR 	X
calc	LDS		#10
		RMO		A, T
		DIVR	S, A
		. if A / 10 = 0, then go out of the loop
		COMP 	#0
		JEQ		out2
		. calculate the digit and store it in memory
		MULR	A, S
		RMO		T, A
		SUBR	S, A
		STA		memdig, X
		RMO		T, A
		LDS		#10
		DIVR	S, A
		. X = X + 3 bytes (1 word)
		LDT 	#3
		ADDR 	T, X
		J 		calc
		. store in memory the last remaining digit (the actual first digit in the number)
out2 	STT 	memdig, X
		LDT 	#3
		ADDR 	T, X
		. iterate over memory and write the numbers backwards (the last stored digit will be printed first)
print	LDT		#3
		. X = X - 3 bytes(1 word)
		SUBR 	T, X
		LDA		memdig, X
		. add 48 (gonum) to get the ASCII code of the digit
		ADD		gonum
test4	TD		stdout
		JEQ		test4
		WD		stdout
		. subtract 48 to go back
		SUB 	gonum
		LDT		#0
		COMPR	X, T
		. if X = 0, we have printed the number, and we can jump out
		JEQ		out3
		J 		print
out3	LDA		olda
		LDS		olds
		LDT		oldt
		LDX		oldx
		RSUB

. dirties A
. initialize the stack pointer
init	STA 	olda
		LDA		#stack
		STA 	stackptr
		LDA		olda

. dirties A
. push to stack
push	STA 	olda
		LDA		stackptr
		ADD		#3
		STA 	stackptr
		LDA		olda
		RSUB

. dirties A
. pop from stack
pop		STA 	olda
		LDA		stackptr
		SUB		#3
		STA 	stackptr
		LDA		olda
		RSUB

. the array to sort
tab		WORD	23
		WORD	18
		WORD	4
		WORD	63
		WORD	40
		WORD	79
		WORD	2
		WORD	11
		WORD	12
		WORD	1
		WORD	90
		WORD	45
		WORD	22
		WORD	7
		WORD	6
last 	EQU 	*
. length of the array
len    	EQU 	last-tab
. boundary between the sorted and unsorted part of the array
bound 		WORD	0
. ASCII code of newline
newline	WORD	10
. ASCII code of space
space	WORD	32
. ASCII code of vertical line
line	WORD	124
. reserved words for indices of elements we want to swap
swap1	RESW	1
swap2	RESW	1
. reserved words for storing the registers when we start a subroutine 
olda	RESW	1
olds	RESW	1
oldt	RESW	1
oldx	RESW	1
stdout	BYTE	X'01'
. 48 - go to ASCII
gonum	WORD	X'000030'
. memory for the digits of a number
memdig	RESW	10
. reserved memory for stack pointer and stack
stackptr	RESW	1
stack 	RESW	50
