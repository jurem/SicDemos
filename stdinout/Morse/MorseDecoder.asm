MRSDCR		START	0
		JSUB	stackinit

CHECK		TD	STDIN
		JEQ	CHECK

		CLEAR	A
		RD	STDIN
		. Shrani znak, ki si ga uporabli za primerjavo
		STCH	PRBZNK
		COMP	NEWLN
		JEQ	HALT

		. Decoding
		JSUB	BERI
		JSUB	DECODEMORSE

		JSUB	FINDCHAR

		JSUB	echoln


		J	CHECK

HALT		J	HALT	

		END	MRSDCR

STDIN		BYTE	X'BA'
STDOUT		BYTE	1
STDERR		BYTE	2
TEXT		RESB	4096
LENTXT		RESW	1
MAXLEN		WORD	4096
USTZNK		WORD	X'000030'
PRBZNK		RESW	1
REZ		RESW	1
NEWLN		WORD	10
PREVX		RESW	1
PREVA		RESW	1
PREVS		RESW	1

. Function FINDCHAR
. Input: MORSEVALUE -> value in DEC to convert into CHAR
. Output: STD OUT -> CHARACTER
. Registers used: A, X
. Desritption: Read MORSEVALUE and output character

FINDCHAR	STL	@stackptr
		JSUB	stackpush

		STA	@stackptr
		JSUB	stackpush

		STX	@stackptr
		JSUB	stackpush


		CLEAR	X
		LDA	MORSEVALUE
LOOK		LDS	TEXTTOMORSE,X
		COMP	TEXTTOMORSE,X
		JEQ	GETCHAR

		. hACKY
		TIX	LENMORSECODE
		TIX	LENMORSECODE
		TIX	LENMORSECODE
		JLT	LOOK


GETCHAR		CLEAR	A
		ADDR	X,A
		. Because X is addres of words and not bytes
		DIV	#3
		ADD	ASCICHR

WAITOUF		TD	STDOUT
		JEQ	WAITOUF

		WD	STDOUT

		JSUB	stackpop
		LDX	@stackptr

		JSUB	stackpop
		LDA	@stackptr

		JSUB	stackpop
		LDL	@stackptr

		RSUB


ASCICHR		WORD	65	. Start of A in ascii table
TEXTTODECODE	RESW	1
LENMORSECODE	WORD	75
.Ternary morse encoding
TEXTTOMORSE	WORD    5     .A -> .-
		WORD    67     .B -> -...
		WORD    70     .C -> -.-.
		WORD    22     .D -> -..
		WORD    1     .E -> .
		WORD    43     .F -> ..-.
		WORD    25     .G -> --.
		WORD    40     .H -> ....
		WORD    4     .I -> ..
		WORD    53     .J -> .---
		WORD    23     .K -> -.-
		WORD    49     .L -> .-..
		WORD    8     .M -> --
		WORD    7     .N -> -.
		WORD    26     .O -> ---
		WORD    52     .P -> .--.
		WORD    77     .Q -> --.-
		WORD    16     .R -> .-.
		WORD    13     .S -> ...
		WORD    2     .T -> -
		WORD    14     .U -> ..-
		WORD    41     .V -> ...-
		WORD    17     .W -> .--
		WORD    68     .X -> -..-
		WORD    71     .Y -> -.--
		WORD    76     .Z -> --..

. Function DECODEMORSE
. Input: TEXT -> value in HEX to convert into DECIMAL
. Output: STD OUT -> DECIMAL NUMBER
. Registers used: A, X
. Desritption: Read TEXT and save it to DECNUM

DECODEMORSE	STL	@stackptr
		JSUB	stackpush

		STA	@stackptr
		JSUB	stackpush

		STX	@stackptr
		JSUB	stackpush

		STT	@stackptr
		JSUB	stackpush

		STS	@stackptr
		JSUB	stackpush

		CLEAR	X
		CLEAR	T
		. Set T to be used as power of 3
		LDA	#1
		ADDR	A,T
		CLEAR	A
		STA	MORSEVALUE

		.Set X reg to LENTXT - 1
		LDX 	LENTXT
READN		LDA	#1
		SUBR	A, X	

		CLEAR	S
		. Load sign
		CLEAR	A
		LDCH	TEXT,X

		.Compare if equal to first
		COMP	MORSESIGN1
		JEQ	SIGN1


		.Compare if equal to seconf
		COMP	MORSESIGN2
		JEQ	SIGN2

		.Compare if equal to seconf
		COMP	MORSESIGN3
		JEQ	SIGN3



SIGN3		LDA	#1
		ADDR	A, S
SIGN2		LDA	#1
		ADDR	A, S
SIGN1		MULR	T, S

		CLEAR	A
		ADDR	S, A
		ADD	MORSEVALUE
		STA	MORSEVALUE

		. Increase power of base 16
		LDA	#3
		MULR	A, T

		. Check if we are at the end
		CLEAR	A
		ADDR	X,A
		COMP	#0
		JEQ	KONECM

		J	READN


KONECM		JSUB	stackpop
		LDS	@stackptr

		JSUB	stackpop
		LDT	@stackptr

		JSUB	stackpop
		LDX	@stackptr

		JSUB	stackpop
		LDA	@stackptr

		JSUB	stackpop
		LDL	@stackptr

		RSUB

MORSESIGN1	WORD	C' '
MORSESIGN2	WORD	46  . -> .
MORSESIGN3	WORD	45  . -> -
MORSEVALUE	RESW	1



. Function BERI
. Input: Input from device specified in STDIN
. Output: None
. Registers used: A, X
. Desritption: Read text and save it to TEXT 

BERI		STA	PREVA
		STX	PREVX

		CLEAR	X

		. Doda tist znak ki se je pojedel pri preverjanju za konec vrstice
		LDCH	PRBZNK
		STCH	TEXT,X
		TIX	MAXLEN

WAITIN		TD	STDIN
		JEQ	WAITIN

		CLEAR	A
		RD	STDIN
		COMP	NEWLN
		JEQ	KONECB
		STCH	TEXT,X
		TIX	MAXLEN 
		JLT	WAITIN

KONECB		STX	LENTXT
		LDA	PREVA
		LDX	PREVX
		RSUB


. Function echoln
. Input: None
. Output: STD OUT -> new line
. Registers used: A

echoln		STA	PREVA
WAITOU		TD	STDOUT
		JEQ	WAITOU

		LDA	NEWLN
		WD	STDOUT

		. Restore register	
		LDA	PREVA
		RSUB


. Function stackinit
. Input: None
. Output: None
. Registers used: A
. Desritption: Initializes stackpointer to the top of the stack 

stackinit	STA	RESTOR

		LDA	#STACK
		STA	stackptr

		LDA	RESTOR
		RSUB

. Function stackpush
. Input: None
. Output: None
. Registers used: A
. Desritption: Moves stack pointer for one word down

stackpush	STA	RESTOR

		LDA	stackptr
		ADD	#3
		STA	stackptr

		LDA	RESTOR
		RSUB

. Function stackpop
. Input: None
. Output: None
. Registers used: A
. Desritption: Moves stack pointer for one word dup

stackpop	STA	RESTOR

		LDA	stackptr
		SUB	#3
		STA	stackptr

		LDA	RESTOR
		RSUB

RESTOR		RESW	1
stackptr	RESW	1
. THIS IS 2^17 words which is 1/10 of whole addresable memory
STACK		RESW	131072