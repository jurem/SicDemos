MRSNCD		START	0
		JSUB	stackinit

CHECK		TD	STDIN
		JEQ	CHECK

		CLEAR	A
		RD	STDIN
		. Shrani znak, ki si ga uporabli za primerjavo
		STCH	PRBZNK
		COMP	NEWLN
		JEQ	BHALT

		. Decoding
		JSUB	BERI
		JSUB	ENCODECHR

		LDA	TEXTTODECODE
		JSUB	CODETOMORSE
		JSUB	OUTPUTMORSE

		JSUB	echoln


		J	CHECK

BHALT		JSUB	echoln
HALT		J	HALT	

		END	MRSNCD

STDIN		BYTE	X'AA'
STDOUT		BYTE	X'BA'
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


. Function OUTPUTMORSE
. Input: MORSEOUT -> Morse signs to output
. Output: STD OUT -> Morse signs
. Registers used: A, X

OUTPUTMORSE	STL	@stackptr
		JSUB	stackpush

		STA	@stackptr
		JSUB	stackpush

		STX	@stackptr
		JSUB	stackpush

		.Set X reg to MORSELEN - 1
		LDX 	MORSELEN
READN		LDA	#1
		SUBR	A, X	

WAITOUTM	TD	STDOUT
		JEQ	WAITOUTM

		LDCH	MORSEOUT,X
		WD	STDOUT

		. Check if we are at the end
		CLEAR	A
		ADDR	X,A
		COMP	#0
		JEQ	KONECR

		J	READN



. Retrive previus stuff and return addres
KONECR		JSUB	stackpop
		LDX	@stackptr
		JSUB	stackpop
		LDA	@stackptr
		JSUB	stackpop
		LDL	@stackptr
		RSUB



. Function CODETOMORSE
. Input: Reg A -> value in Ternari to convert into Morse characters
. Output: STD OUT -> Morse character
. Registers used: A, X

CODETOMORSE	STL	@stackptr
		JSUB	stackpush

		STA	@stackptr
		JSUB	stackpush

		STX	@stackptr
		JSUB	stackpush

		STT	@stackptr
		JSUB	stackpush

		. Preparing for converting from ternary
		CLEAR	T
		CLEAR	X
		STA	TERNNUM


. Evklidov algoritem z bazo 10
CONV		DIV	base
		. Save kvocient for later
		STA	KVOCI
		. Geting modulo
		MUL	base
		STA 	CURR
		LDA	TERNNUM
		SUB	CURR

		. Add index of right character to X
		CLEAR	X
		ADDR	A,X

		. Loading right character for morse sign
		LDCH	MORSESIGN,X

		. Save to right position
		CLEAR	X
		ADDR	T, X
		STCH	MORSEOUT,X
		. increse Counter
		LDA	#1
		ADDR	A, T

		. Load values for new itteration
		LDA	KVOCI
		STA	TERNNUM
		. Check for end of evklid
		COMP #0
		JGT	CONV

		STT	MORSELEN

		JSUB	stackpop
		LDT	@stackptr
		JSUB	stackpop
		LDX	@stackptr
		JSUB	stackpop
		LDA	@stackptr
		JSUB	stackpop
		LDL	@stackptr		
		RSUB

base		WORD	3
KVOCI		RESW	1
TERNNUM		RESW	1
CURR		WORD	0
MORSESIGN	BYTE	C' '
		BYTE	C'.'
		BYTE	C'-'
MORSEOUT	RESB	5
MORSELEN	RESW	1



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


. Function ENCODECHR
. Input: TEXT -> value in HEX to convert into DECIMAL
. Output: STD OUT -> DECIMAL NUMBER
. Registers used: A, X
. Desritption: Read TEXT and save it to DECNUM

ENCODECHR	STL	@stackptr
		JSUB	stackpush

		STA	@stackptr
		JSUB	stackpush

		STX	@stackptr
		JSUB	stackpush	

		CLEAR	X

		. Get position in array
		LDCH	TEXT,X
		SUB	ASCICHR
		ADDR	A,X

		. Get correct offset
		LDA	#3
		MULR	A, X

		. Load binary value for output
		LDA	TEXTTOMORSE,X
		STA	TEXTTODECODE


		JSUB	stackpop
		LDX	@stackptr

		JSUB	stackpop
		LDA	@stackptr

		JSUB	stackpop
		LDL	@stackptr

		RSUB


ASCICHR		WORD	65	. Start of A in ascii table
TEXTTODECODE	RESW	1
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