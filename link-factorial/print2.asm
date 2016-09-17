print START 0
	STA buffer
	LDA screen
	LDT row
	ADDR T, A
	STA cursor
	
prtbuf LDA buffer
	SUB max        . find first power of 10 larger than buffer
	COMP #0
	JLT found
	LDA max
	MUL #10
	STA max
	J prtbuf
found LDA max          . divide max by 10 and print buffer/max
	DIV #10
	STA max
	COMP #0
	JEQ exit
	LDA buffer
	DIV max
	ADD #48        . ASCII 0
	+STCH @cursor  . print to cursor
	SUB #48
	MUL max
	STA tmp
	LDA cursor
	ADD #1
	STA cursor     . increment cursor
	LDA buffer
	SUB tmp
	STA buffer
	J found
exit LDA #1
	STA max        . reset max to 1
	LDA row        . newline
	ADD #80
	STA row
	RSUB
max WORD 1
tmp RESW 1
buffer RESW 1
screen WORD 47104
row WORD 0
cursor RESW 1
gap RESW 64

