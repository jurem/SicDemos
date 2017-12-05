.similar to demo hanoy1.py
.SETTINGS: 	before calling hanoy(), set number of rings in variable nrings (up to 15)
.		graphical screen should have 128 columns, 64 rows, pixel size 4	
.		frequency should be 1MHz or higher.
.set speed to 1Mhz 

hanoy1	START	0
	.set number of rings
	LDA	#6
	STA	nrings

	.initiate rods in memory
	LDA	nrings		.set number of rods
	JSUB	rodinit	

	.initiate drawing to graphical screen
	LDA	drcols
	MUL	#30	.30 rows down from start row
	ADD	draddr
	STA	droffs

	.draw
	LDA	#0x0000FF
	STCH	color
	JSUB	draw3
	JSUB	hhhalt
	LDA	#0x000000
	STCH	color
	JSUB	draw3

	.call hanoy()
	LDA	nrings	
	+LDS	#0x001020	.starting permutation (A,B,C)
	JSUB	hanoy

	.draw again
	LDA	#0x0000FF
	STCH	color
	JSUB	draw3

HALT	J	HALT
ERR	J	ERR

.functions

.halts a few loops (variable drhltm).
hhhalt	STA	tmp
	+LDA	drhltm
drhlt	SUB	#1
	COMP	#0
	JGT	drhlt
	LDA	tmp
	RSUB

.initialize rods for hanoy rings, A contains number of rings (max is 15) (16 is a row in memory, at least 1 needs to be 00)
.every ring is represented as 1 byte
.A needs to be 1 or higher
rodinit	LDX	#1
	STA	tmp
	LDT	rodaddr
initlp	STT	rodtmp
	STCH	@rodtmp
	SUB	#1
	COMP	#0
	JEQ	endinit
	ADDR	X, T
	J	initlp
	
endinit	LDA	tmp
	RSUB

.find first empty byte on a rod
.rod address is in A
finfrst	STL	stltmp
	JSUB	pushAll
	
	.subroutine code
	LDX	#1
	STA	rodtmp
loopff	LDA	#0		.always do LDA #0 before LDCH !!!
	LDCH	@rodtmp	
	COMP	#0
	JEQ	endff
	LDT	rodtmp
	ADDR	X, T
	STT	rodtmp
	J	loopff

endff	LDA	rodtmp
	JSUB	popAll
	LDL	stltmp
	RSUB

.hanoy
.A: n
.S: rods permutation (0, 1, 2) - base + 0*16, base + 1*16, base + 2*16
hanoy	COMP	#0 		.if n == 0, return
	JEQ	rquick
	STL	stltmp
	JSUB	pushAll

	.subroutine code
	SUB	#1	.n--
	RMO	A, X	.save A
	RMO	S, T	.save S
	.permute S:abc to S:acb
	RMO	S, A
	AND	maska
	+STA	perma	.0xaa0000
	RMO	S, A
	AND	maskb
	SHIFTR	A, 8
	+STA	permb	.0x0000bb
	RMO	S, A
	AND	maskc
	SHIFTL	A, 8
	+STA 	permc	.0x00cc00
	LDA	perma
	OR	permb
	OR	permc	.0xaaccbb
	.call recursion
	RMO	A, S
	RMO	X, A
	JSUB	hanoy	
	RMO	X, A	.original A
	RMO	T, S 	.original S

	.a -> b 	!!! you need to perform this on the original S
	.access last element on rod a
	RMO	A, X
	RMO	S, A
	AND	maska
	SHIFTR	A, 16	.0x0000aa
	ADD	rodaddr	.we have address of rod a now
	RMO	A, T
	JSUB	finfrst
	.check if we're on first byte (rod empty)
	COMPR	A, T
	JEQ	ERR
	SUB 	#1	.last ring on rod
	STA	tmp	.address of the ring
	LDT	@tmp	.value of the ring
	STT	topring
	LDT 	#0
	STT	@tmp	.removed top ring from a, saved in topring	
	
	.put it onto b
	RMO	S, A	.S is still original here
	AND	maskb
	SHIFTR	A, 8	.0x0000bb	
	ADD	rodaddr	
	JSUB	finfrst	.first empty space on rod b
	STA	tmp	.address of the space
	LDT	topring
	STT	@tmp	.ring moved

	.A = n again
	RMO X, A
	.S is still original
		
	.print
	RMO	A, X	.save A
	LDA	#0x0000FF
	STCH	color
	JSUB	draw3

	JSUB	hhhalt

	LDA	#0x000000
	STCH	color
	JSUB	draw3
	RMO	X, A

	.permute S:abc -> S:cba
	RMO	A, X 	.save A
	RMO	S, T	.save S
	RMO	S, A
	AND	maska
	SHIFTR	A, 16
	+STA	perma	.0x0000aa
	RMO	S, A
	AND	maskb
	+STA	permb	.0x00bb00
	RMO	S, A
	AND	maskc
	SHIFTL	A, 16
	+STA	permc	.0xcc0000	
	+LDA	perma
	OR	permb
	OR	permc	.0xccbbaa

	.call recursion
	RMO	A, S
	RMO	X, A
	JSUB	hanoy
	RMO	X, A
	RMO	T, S
	
endhan	JSUB	popAll
	LDL	stltmp
rquick	RSUB


.draws 3 hanoy towers
.variable rodarrd contains address of 1st tower
.variable droffs contains draw address
.variable color contains pixel color (set 0x00 to clean up)
draw3	STL	stltmp
	JSUB	pushAll

	.droffs holds draw address (pixel on graphical screen)
	.put offset in S, call drtow
	LDA	rodaddr
	RMO	A, T	.save A
	LDS	droffs
	RMO	S, A
	ADD 	#16	.offset the first tower 16 pixels to the right (center of first tower)
	RMO	A, S
	RMO	T, A
	JSUB	drtow
	RMO	T, A

	ADD	#0x10	.memory addr of next tower
	RMO	A, T	.save A
	RMO 	S, A
	ADD 	#32	.draw next tower 32 pixels to the right
	RMO	A, S
	RMO	T, A	
	JSUB	drtow
	RMO	T, A
	
	ADD	#0x10	.memory addr of next tower
	RMO	A, T	.save A
	RMO 	S, A
	ADD 	#32	.draw next tower 32 pixels to the right
	RMO	A, S
	RMO	T, A	
	JSUB	drtow
	RMO	T, A

	JSUB	popAll
	LDL	stltmp
	RSUB


.draw a hanoy tower
.A holds address of tower in memory
.S holds bot left draw pixel
drtow	STL	stltmp
	JSUB	pushAll

towlp	RMO	A, T	.save A
	STA	tmp
	LDA 	#0
	LDCH	@tmp
	COMP	#0	.check if we're past the last ring in memory.
	JEQ	towrt
	.draw line of length A to address S
	JSUB	drline

	RMO	S, A
	SUB 	drcols
	RMO	A, S	.S decreases by 1 row

	RMO	T, A
	ADD 	#1	.A increases by 1
	J	towlp	

towrt	JSUB	popAll
	LDL	stltmp
	RSUB


.draw a horizontal line ( ...len-1..0...len... )
.A holds length
.S holds start address
drline	STL	stltmp
	JSUB	pushAll

drloop	STA	tmp

	.draw pixel in (+) direction
	ADDR	S, A
	STA	tmpffs
	LDA	#0
	LDCH	color
	STCH	@tmpffs
	LDA	tmp	

	.draw pixel in (-) direction	
	RMO	S, T	.swap A and S
	RMO	A, S
	RMO	T, A
		
	SUBR	S, A
	ADD	#1
	STA	tmpffs
	LDA	#0
	LDCH	color
	STCH	@tmpffs
	LDA	tmp	

	RMO	T, S	.restore S
	
	SUB 	#1
	COMP	#0
	JGT	drloop

	JSUB	popAll
	LDL	stltmp
	RSUB


.data_for_drawing
drhltm	WORD	0x30000
drloff	RESW	1
draddr	WORD	0xA000
droffs	RESW	1
tmpffs	RESW	1
drcols	WORD	128
drrows	WORD	64
color	BYTE	0xFF

.data
nrings	WORD	15
tmp	RESW	1
topring	RESW	1
perma	RESW	1
permb	RESW	1
permc	RESW	1
maska	WORD	0xFF0000
maskb	WORD	0x00FF00
maskc	WORD	0x0000FF
maskab	WORD	0xFFFF00
rodaddr	WORD	0xA00
rodtmp	RESW	1



.###### STACK ######
.Takes care of subroutines. Protects registers S, T, X. Result is returned in A.

.Template for subroutine
.STL    stltmp
.JSUB   pushAll
.subroutine code
.JSUB   popAll
.LDL    stltmp

.### stack functions ###
.### pushAll ### ... do not save A, it's used as a return register
pushAll J       pushL

pushL   STA     sttmp 
        LDA     stltmp .we take the return addr of the function that called pushAll
        STA     @stptr 
        LDA     sttmp
        STA     sttmp  .increment stptr
        LDA     stptr
        ADD     #3
        STA     stptr
        LDA     sttmp   .end increment stptr

        J       pushS

pushS   STS     @stptr
        STA     sttmp  .increment stptr
        LDA     stptr
        ADD     #3
        STA     stptr
        LDA     sttmp   .end increment stptr

        J       pushT

pushT   STT     @stptr
        STA     sttmp  .increment stptr
        LDA     stptr
        ADD     #3
        STA     stptr
        LDA     sttmp   .end increment stptr

        J       pushX

pushX   STX     @stptr
        STA     sttmp  .increment stptr
        LDA     stptr
        ADD     #3
        STA     stptr
        LDA     sttmp   .end increment stptr

        RSUB

.### popAll ### reverse order from pushAll... do not pop A, save return in there
popAll  J       popX

popX    STA     sttmp  .decrement stptr
        LDA     stptr
        SUB     #3
        STA     stptr
        LDA     sttmp   .end decrement stptr
        LDX     @stptr

        J       popT

popT    STA     sttmp  .decrement stptr
        LDA     stptr
        SUB     #3
        STA     stptr
        LDA     sttmp   .end decrement stptr
        LDT     @stptr

        J       popS

popS    STA     sttmp  .decrement stptr
        LDA     stptr
        SUB     #3
        STA     stptr
        LDA     sttmp   .end decrement stptr
        LDS     @stptr

        J       popL

popL    STA     sttmp  .decrement stptr
        LDA     stptr
        SUB     #3
        STA     stptr
        LDA     sttmp   .end decrement stptr
        STA     sttmp
        LDA     @stptr
        STA     stltmp
        LDA     sttmp

        RSUB
         
.### stack variables ###
staddr  WORD    0xBB80
stptr   WORD    0xBB80
stltmp  RESW    1
sttmp   RESW    1
