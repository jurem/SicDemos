stack   START 0
	EXTDEF stinit
	EXTDEF push
	EXTDEF pop
stinit  STA stackptr    . initialize stack at the address from A
	RSUB
push    STA @stackptr   . push value from A to stack
	LDA stackptr
	ADD #3
	STA stackptr
	RSUB
pop     LDA stackptr    . pop value from stack to A
	SUB #3
	STA stackptr
	LDA @stackptr
	RSUB
	
stackptr RESW 1         . stack pointer

