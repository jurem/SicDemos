. Repeatedly writes alphabet to stdout device.
. Only SIC instructions.
ABC		START	0

forever CLEAR	A
		STA 	ofs
		. start of alphabet loop
loopabc	LDA		ofs
		ADD		chara
		. write A to stdout device
td1		TD		stdout
		JEQ		td1
		WD		stdout
		. increase offset
		LDA		ofs
		ADD		one
		STA		ofs
		COMP	count
		JLT		loopabc
		. write newline to stdout device
		LDA		newline
td2		TD 		stdout
		JEQ	 	td2
		WD		stdout
		. jump to beginning
		J 		forever

. constants	
stdout	BYTE	X'01'
newline	WORD	10
chara	WORD	65
count	WORD	58

. variables
ofs		WORD	0	
one		WORD	1
		END		loopabc