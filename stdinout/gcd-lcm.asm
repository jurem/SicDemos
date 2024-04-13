test	START	0

main
	LDX	#0
	LDT	#41	.the length of the string
	JSUB	print1	.print enter the first number

	LDX	#0
	LDT	#10
	JSUB	clns	.clear the data in ns

	LDX	#0
	JSUB	inputns	.read the first number as string and store in ns

	LDT	#0
	LDX	#0
	LDA	#48
	JSUB	stn	.convert ns to int
	STT	n1	.store the value to n1
	STT	n3	.store the value to n1

	LDA	n3
	LDT	#0
	COMPR	A, T
	JEQ	exit

	LDX	#0
	LDT	#25	.the length of the string
	JSUB	print2	.print enter the second number

	LDX	#0
	LDT	#10
	JSUB	clns	.clear the data in ns

	LDX	#0
	JSUB	inputns	.read the second number and store in ns

	LDT	#0
	LDX	#0
	LDA	#48
	JSUB	stn	.convert ns to int
	STT	n2	.store the value to n2
	STT	n4	.store the value to n2

	LDX	#0
	LDT	#10
	JSUB	clns

	JSUB	gcd
f1
	LDA	n1
	STA	gcdn
	STA	tmp

	JSUB	nl

	LDX	#0
	LDT	#7	.the length of the string
	JSUB	print3	.print gcd is

	LDX	#0
	LDA	gcdn
	JSUB	nts
f2

	JSUB	printns
f3

	JSUB	nl
	LDX	#0
	LDT	#7	.the length of the string
	JSUB	print4	.print lcm is

	JSUB	lcm
	STA	lcmn

	LDX	#0
	LDA	lcmn
	JSUB	nts2
f4
	JSUB	printns2
f5
	JSUB	nl
	JSUB	nl

	J	main


exit	
	LDX	#0
	LDT	#17
	JSUB	print5
	J	halt

nl			.print new line
	TD	stdout
	JEQ	nl
	LDCH	newline
	WD	stdout
	RSUB

print1			.print input the first number
	TD	stdout
	JEQ	print1
	LDCH	str1, X
	WD	stdout
	TIXR	T
	JLT	print1

	RSUB

print2			.print input the second number
	TD	stdout
	JEQ	print2
	LDCH	str2, X
	WD	stdout
	TIXR	T
	JLT	print2

	RSUB

print3			.print gcd is
	TD	stdout
	JEQ	print3
	LDCH	str3, X
	WD	stdout
	TIXR	T
	JLT	print3
	RSUB

print4			.print lcm is
	TD	stdout
	JEQ	print4
	LDCH	str4, X
	WD	stdout
	TIXR	T
	JLT	print4
	RSUB

print5			.print lcm is
	TD	stdout
	JEQ	print5
	LDCH	str5, X
	WD	stdout
	TIXR	T
	JLT	print5
	RSUB

inputns			.read the first number and store in ns
	TD	stdin
	JEQ	inputns
	RD	stdin
	STCH	ns, X
	LDT	#1
	ADDR	T, X
	LDT	#10
	COMPR	T, A
	JLT	inputns
	RSUB

clns			.clear the data in ns
	LDCH	space
	STCH	ns, X
	TIXR	T
	JLT	clns
	RSUB

stn			.convert ns to int and store in n1
	SUB	#48
	LDS	#10
	MULR	S, T
	ADDR	A, T
	LDCH	ns, X
	LDS	#1
	ADDR	S, X
	COMP	#32
	JGT	stn
	RSUB

gcd
	LDT	n1
	STT	tmp
	LDA	n2
	STA	n1
	LDA	tmp
	JSUB	mod
	STA	n2
	COMP	#0
	JLT	gcd
	JGT	gcd
	J	f1

mod
	SUB	n2
	COMP	n2
	JGT	mod
	JEQ	mod
	COMP	#0
	JLT	pn2
	RSUB

pn2			.plus n2
	ADD	n2
	RSUB

mod10
	SUB	#10
	COMP	#10
	JGT	mod10
	JEQ	mod10
	COMP	#0
	JLT	p10
	RSUB

p10			.puls 10
	ADD	#10
	RSUB

nts			.convert number to string
	STA	tmp
	JSUB	mod10
	ADD	#48
	STCH	ns, X
	LDT	#1
	ADDR	T, X
	LDA	tmp
	DIV	#10
	COMP	#0
	JGT	nts
	J	f2


nts2			.convert number to string
	STA	tmp
	JSUB	mod10
	ADD	#48
	STCH	ns, X
	LDT	#1
	ADDR	T, X
	LDA	tmp
	DIV	#10
	COMP	#0
	JGT	nts2
	J	f4

printns			.print ns
	TD	stdout
	JEQ	printns
	LDCH	ns, X
	WD	stdout
	LDT	#1
	SUBR	T, X
	LDT	#0
	COMPR	T, X
	JLT	printns
	JEQ	printns
	J	f3

printns2			.print ns
	TD	stdout
	JEQ	printns
	LDCH	ns, X
	WD	stdout
	LDT	#1
	SUBR	T, X
	LDT	#0
	COMPR	T, X
	JLT	printns2
	JEQ	printns2
	J	f5

lcm
	LDA	n3
	LDT	n4
	MULR	T, A
	LDT	gcdn
	DIVR	T, A
	RSUB

halt	J	halt

str1	BYTE	C'input the first number(input 0 to exit): '
str2	BYTE	C'input the second number: '
str3	BYTE	C'gcd is '
str4	BYTE	C'lcm is '
str5	BYTE	C'exit successfully'
s	RESB	50

ns	RESB	10	.store the first number as string

n1	WORD	0	.store the first number
n2	WORD	0	.store the second number
n3	WORD	0
n4	WORD	0
gcdn	WORD	0	.gcd number
lcmn	WORD	0	.lcm number
tmp	WORD	0

newline	BYTE	10
space	BYTE	32
stdin	BYTE	0
stdout	BYTE	1
