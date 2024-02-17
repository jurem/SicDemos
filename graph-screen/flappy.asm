. Uses graphical screen and keyboard input. 200kHz recommended.
. Press space for boost. Don't crash.
. avtor Domen, 2023
. licence WTFPL

flappy	START 0
	J main

main	J gloop


. render rect variables
cend	WORD 0
rcnt	WORD 0
radd	WORD 0
recx	WORD 0
recy	WORD 0
recw	WORD 0
rech	WORD 0
col	BYTE 0

. render rect, A => color
renrect	STCH col
	LDA #0
	STA rcnt
	. check X bounds
	LDA recw
	COMP #1
	JLT le001
	. check complete
	LDA #64
	MUL recy
	ADD recx
	ADD screen
	STA tmp
	LDA #64
	SUB recw
	STA radd
lp001	LDA tmp
	ADD recw
	STA cend
lp002	LDCH col
	STCH @tmp
	LDA tmp
	ADD #1
	STA tmp
	COMP cend
	JEQ le002
	J lp002
le002	LDA rcnt
	ADD #1
	STA rcnt
	COMP rech 
	JEQ le001
	LDA tmp
	ADD radd
	STA tmp
	J lp001
le001	RSUB
	
. exit game
exit	J exit

. update game
update	LDA #0
	. check for input, set velocity if any key pressed
	+LDCH keybd
	COMP #0 
	JEQ colchk
	LDA #0
	+STCH keybd
	LDA jumph
	STA plvy
	. check for collision
colchk	LDA ox
	ADD ow
	SUB #1
	COMP plx
	JLT endkbd
	LDA plx
	ADD plsize
	SUB #1
	COMP ox
	JLT endkbd
	LDA ply
	COMP ouh
	. game over
	JLT exit
	LDA ply
	ADD plsize
	COMP ody
	JGT exit
endkbd	LDA ply
	ADD plvy
	COMP #0
	JGT lab001
	LDA #0
lab001	STA ply
	COMP #63
	JGT exit
	LDA plvy
	ADD plg
	STA plvy
	. move obstacles to the left
	LDA ox
	SUB #1
	STA ox
	. check if off border
	ADD ow
	COMP #0
	JGT updend
	LDA #63
	SUB ow
	STA ox
updend	RSUB



. present game
present	LDA @vsync
	COMP #1
	JEQ present
wait1	LDA @vsync
	COMP #0
	JEQ wait1
	RSUB

gloop	LDA #64
	MUL #64
	ADD screen
	STA vsync
clear	LDA #0
	. clear player
	LDA plx
	STA recx
	LDA ply
	STA recy
	LDA plsize
	STA recw
	STA rech
	LDA #0
	JSUB renrect
	. clear upper obstacle
	LDA ox
	STA recx
	LDA ouy
	STA recy
	LDA ow
	STA recw
	LDA ouh
	STA rech
	LDA #0
	JSUB renrect
	. clear lower obstacle
	LDA ox
	STA recx
	LDA ody
	STA recy
	LDA ow
	STA recw
	LDA odh
	STA rech
	LDA #0
	JSUB renrect
upd	JSUB update
display	LDA #0
	. render player
	LDA plx
	STA recx
	LDA ply
	STA recy
	LDA plsize
	STA recw
	STA rech
	LDA plcolor
	JSUB renrect
	. render upper obstacle
	LDA ox
	STA recx
	LDA ouy
	STA recy
	LDA ow
	STA recw
	LDA ouh
	STA rech
	LDA ocol
	JSUB renrect
	. render lower obstacle
	LDA ox
	STA recx
	LDA ody
	STA recy
	LDA ow
	STA recw
	LDA odh
	STA rech
	LDA ocol
	JSUB renrect
	. JSUB present
	J gloop
	

. other vars
vsync	WORD 0
screen	WORD 0xA000
tmp	WORD 0

. player coords and size
plx	WORD 8
ply	WORD 20
plsize	WORD 6
plvy	WORD -4
plg	WORD 1
plcolor	WORD 0xFF

. obstacles
ocol	WORD 0xCA
ox	WORD 50
ow	WORD 10
ouy	WORD 0
ouh	WORD 24
ody	WORD 48
odh	WORD 16

. constants
. jump height
jumph	WORD -4
. key press location
keybd	EQU 0xC000
