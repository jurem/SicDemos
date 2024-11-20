.	SPACE_SHOOTERS
.
. Kill all the enemies before they kill you
.
. Frekvenca: 100-150 kHz
. Velikost ekrana: 64 x 64
. Premik A-levo, S-dol, W-gor, D-desno
.
. Avtor: Peter Savron
. For personal use only
. Tutti i diritti sono riservati
. If you want to enhace this game for a homework
. consult with your professor
. 
.TODO enhance graphics
.TODO add start, game over screen

.MAIN
spcsht	START	0	.main ne rabi registrov, tko spodnjim fiìunnkcijam ni treba skrbeti za registre
	JSUB	stkint
	JSUB	init
	JSUB	wait
gmlp	JSUB	getinp
	JSUB	update
	J	gmlp
halt	J	halt

gmover	CLEAR	A
	+LDCH	0xC000
	COMP	#32
	JEQ	spcsht
	J	gmover

.INIT
.inicializira elemente trenutno to naredi ze zbirnik
init	STL	@stkptr
	JSUB	stkpsh
	LDA	#astrTx
	STCH	assx
	LDA	#astrTy
	STCH	assy
	LDA	#3
	STCH	asslf
	JSUB	inite
	JSUB	stkpop
	LDL	@stkptr
	RSUB

inite	STL	@stkptr
	JSUB	stkpsh
	.ustvari vse enemy z odmikom 7 med njimi, odmike naredi z regidtrom B
	+LDB	#emvxtb
	RMO	B,S
	+LDB	#emvytb
	RMO	B,T
	BASE	scrptr
	CLEAR	A
	CLEAR	X
intelp	+LDL	#emvytb
	SUBR	L,B
	RMO	X,L
	LDA	#3
	MULR	A,X
	STB	epstb,X	.BUG, pozabil pomnozit X s 3
	RMO	L,X
	LDL	#enofst	.odmik med enemyiji
	CLEAR	A
	RMO	S,B
	LDCH	scrptr
	STCH	entx,X
	ADDR	L,B
	RMO	B,S
	RMO	T,B
	LDCH	scrptr
	STCH	enty,X
	ADDR	L,B
	RMO	B,T
	LDCH	#3
	STCH	entlfp,X
inteld	TIX	#entdim
	JLT	intelp
	JSUB	stkpop
	LDL	@stkptr
	RSUB

.WAIT -zadnji problem
wait	RSUB
.GETINPUT
	.preberi key in shrani
getinp	CLEAR	A
	+LDCH	0xC000
	STCH	prskey
	RSUB


.UPDATE ne rabi registrov izven L, ostale funkcije lahko prosto svinnjajo, med update se zgodi tudi render
update	STL	@stkptr
	JSUB	stkpsh

	JSUB	mvsass
	JSUB	omv
	JSUB	rndahp
	JSUB	shtass
	JSUB	esht
	JSUB	mvass
	JSUB	mven


	JSUB	stkpop
	LDL	@stkptr
.poveca lpcnt .TODO ce prevelik ga reseta na 0
	LDX	lpcnt
	TIX	#ashttm
	JLT	cntsv
	LDX	#0
cntsv	STX	lpcnt
	RSUB

.ozadje

.premakni main navicello p1 - pazi omejitve -OK
mvass	STL	@stkptr
	JSUB	stkpsh
	CLEAR	A
	LDCH	prskey
	COMP	#lftkey
	JEQ	mvlft
	COMP	#rgtkey
	JEQ	mvrgt
	COMP	#upkey
	JEQ	mvup
	COMP	#dwnkey
	JEQ	mvdwn
	J	mret
	.postavim nazaj v okvir ce gre iz njega
mvlft	LDCH	assx
	SUB	#aspd
	COMP	#lftbrd
	JGT	maxret
	LDCH	#lftbrd
	J	maxret
mvrgt	LDCH	assx
	ADD	#aspd
	COMP	#rgtbrd
	JLT	maxret
	LDCH	#rgtbrd
maxret	STCH	assx
	J	mret
mvup	LDCH	assy
	SUB	#aspd
	COMP	#upbrd
	JGT	mayret
	LDCH	#upbrd
	J	mayret
	J	mret
mvdwn	LDCH	assy
	ADD	#aspd
	COMP	#dwnbrd
	JLT	mayret
	LDCH	#dwnbrd
mayret	STCH	assy
mret	JSUB	rndast
	JSUB	stkpop
	LDL	@stkptr
	RSUB

mven	STL	@stkptr
	JSUB	stkpsh
	.se sprehodis po en tabeli, pogleds lfp, spremenis pozicijo, pogledas pozicijo v mv tabeli renderas
	CLEAR	X
	CLEAR	A

mvelp	CLEAR	A
	LDCH	entlfp,X
	COMP	#0
	JEQ	mvelnD
	COMP	#4
	JGT	mvelnD
	RMO	X,S	.v S je st enemyja
	LDL	#3	.BUGFIX rabil trikratni odmik za word
	MULR	L,X	.BUGFIX
	LDX	epstb,X
	LDL	#1
	ADDR	L,X
	RMO	X,A
	.cekiraj, da ni preevlik
	COMP	#emvtbd
	JLT	mveskp
	CLEAR	X
mveskp	CLEAR	A
	+LDCH	emvxtb,X
	RMO	X,T	.v T je pozicija v epstb
	RMO	S,X
	STCH	entx,X
	LDL	#3
	MULR	L,X
bug	STT	epstb,X	.BUGv epstb se znajdejonneg stevila
	RMO	T,X
	+LDCH	emvytb,X
	RMO	S,X
	STCH	enty,X
	JSUB	rndehp
mvelnd	TIX	#entdim
	JLT	mvelp
	JSUB	stkpop
	LDL	@stkptr
	RSUB
mvelnD	CLEAR	A
	STCH	entlfp,X
	STCH	entx,X
	STCH	enty,X
	J	mvelnd

	.premakni izstrelke ally detection p1
mvsass	STL	@stkptr
	JSUB	stkpsh
	CLEAR	A
	CLEAR	X
	.premakni izstrelek
shtmlp	LDCH	asxtab,X
	STCH	ashtx
	LDCH	asytab,X
	SUB	#ispd
	COMP	#0
	JGT	ascol		.izstrelek obstaja isci collision
	CLEAR	A		.izstrelek je sel cez ekran, ga ni vec
	STCH	asytab,X
	JSUB	rndbst
	STX	asmvX		.temp fix, da se ne reseta x na 0
	J	aslpnd		.izstrelek je izven tabele, se ga ne uposteva
	.collision detection skoyi enemz tabele, A ziher byte
ascol	STCH	asytab,X
	JSUB	rndist
	STX	asmvX
	CLEAR	X
	RMO	A,S	.v S je y pos izstrelka
ascllp	LDCH	enty,X	.prej com y coord, ki je za v A, ce blizu se x coord, za cel loop je S eenak y poziciji izstrellka
	COMP	#0
	JEQ	asclle	.je mrtev
	SUBR	S,A
	COMP	#eofhgh
	JGT	asclle	.je spodaj
	COMP	#eofhgh
	ADD	#eofhgh
	COMP	#0
	JLT	asclle	.je zgoraj
	.ce si tukaj je collision na y
	CLEAR	A	.za vsak slucaj
	LDCH	ashtx
	RMO	A,T	.v T je x pos izstrelka
	CLEAR	A
	LDCH	entx,X
	SUBR	T,A
	COMP	#eofwdt
	JGT	asclle	.je desno
	ADD	#eofwdt	
	COMP	#0
	JLT	asclle	.je levo
	.ce si tukaj je x in y collision
	.zbrisi izstrelek, renderaj crno, renderaj novo ship, tko je manjsi lag in in crnih prog, prej je rablo vec cajta, da se enemy posodobi in izstrelek je letel naprej
	.asmvX st izstrelka
	RMO	X,T
	LDX	asmvX
	JSUB	rndbst
	CLEAR 	A
	STCH	asxtab,X	.unici izstrelek
	STCH	asytab,X
	RMO	T,X
	.X st enemy
	LDCH	entlfp,X
	SUB	#1
	STCH	entlfp,X
	JSUB	rndehp
	LDCH	entlfp,X
	COMP	#0
	JGT	asclle	.je se ziv
	CLEAR	A
	STCH	entlfp,X
	STCH	entx,X
	STCH	enty,X	.poslje enemy v kot, kjer en moti
asclle	CLEAR	A
	TIX	#entdim
	JLT	ascllp
aslpnd	LDX	asmvX
	TIX	#ashtdm
	JLT	shtmlp
	JSUB	stkpop
	LDL	@stkptr
	RSUB
asmvX	RESW	1
ashtx	RESB	1

.PREMIKAJ_ENEMY_IZSTRELKE
omv	STL	@stkptr
	JSUB	stkpsh
	CLEAR	A
	CLEAR	X
	.premakni izstrelek
omlp	LDCH	otabx,X
	STCH	oshtx
	LDCH	otaby,X
	ADD	#ospd
	COMP	#62
	JLT	ocol		.izstrelek obstaja isci collision
	LDA	#62		.izstrelek je sel cez ekran, ga ni vec
	STCH	otaby,X
	JSUB	rndcst
	STX	omvX		.temp fix, da se ne reseta x na 0
	J	olpnd		.izstrelek je izven tabele, se ga ne uposteva
	.collision detection skoyi enemz tabele, A ziher byte
ocol	STCH	otaby,X
	JSUB	rndost
	STX	omvX
	CLEAR	X
	RMO	A,S	.v S je y pos izstrelka
ocllp	LDCH	assy	.prej com y coord, ki je za v A, ce blizu se x coord, za cel loop je S eenak y poziciji izstrellka
	SUBR	S,A
	COMP	#aofhgh
	JGT	oclle	.je spodaj
	ADD	#aofhgh
	COMP	#0
	JLT	oclle	.je zgoraj
	.ce si tukaj je collision na y
	CLEAR	A	.za vsak slucaj
	LDCH	oshtx
	RMO	A,T	.v T je x pos izstrelka
	CLEAR	A
	LDCH	assx
	SUBR	T,A
	COMP	#aofwdt
	JGT	oclle	.je desno
	ADD	#aofwdt	
	COMP	#0
	JLT	oclle	.je levo
	.ce si tukaj je x in y collision
	.zbrisi izstrelek, renderaj crno, renderaj novo ship, tko je manjsi lag in in crnih prog, prej je rablo vec cajta, da se enemy posodobi in izstrelek je letel naprej
	.omvX st izstrelka
	LDX	omvX
	JSUB	rndcst
	CLEAR 	A
	STCH	otabx,X	.unici izstrelek
	STCH	otaby,X
	.X st enemy
	LDCH	asslf
	SUB	#1
	STCH	asslf
	JSUB	rndahp
	LDCH	asslf
	COMP	#0
	JGT	oclle	.je se ziv
	JSUB	gmover
oclle	CLEAR	A
olpnd	LDX	omvX
	TIX	#otabdm
	JLT	omlp
	JSUB	stkpop
	LDL	@stkptr
	RSUB
omvX	RESW	1
oshtx	RESB	1

	.premakni ozadje p4 TODO
	.premakni navicelle 
	.izstreli_ally p1 
shtass	STL	@stkptr
	JSUB	stkpsh
	.preveri ce je moment
	LDA	lpcnt
	COMP	#0
	JGT	astart
	LDX	astptr
	LDCH	assx
	STCH	asxtab,X
	LDCH	assy
	SUB	#iofhgh
	SUB	#aofhgh
	STCH	asytab,X
	TIX	#ashtdm
	JLT	astprt
	CLEAR	X
astprt	STX	astptr
astart	JSUB	stkpop
	LDL	@stkptr
	RSUB
	.X pozicija v tabeli

esht	CLEAR	A
	CLEAR	X
	STL	@stkptr
	JSUB	stkpsh
	.sprehodi se po tabeli, ce trenutek enak strelji, zbrisi prejsnji strel v tabeli
eshtlp	LDCH	entlfp,X
	COMP	#0
	JEQ	eshtld
	LDCH	eshcnt,X
	COMP	eshclk
	JEQ	eshtad	.ce ni enako ni trenutek za streljat
eshtld	TIX	#entdim
	JLT	eshtlp
	.konc zanke
	LDX	eshclk
	TIX	#eshttm
	JLT	eshret
	CLEAR	X
eshret	STX	eshclk
	JSUB	stkpop
	LDL	@stkptr
	RSUB

eshtad	LDCH	entx,X
	RMO	X,S
	LDX	otbptr
	JSUB	rndcst
	STCH	otabx,X
	RMO	S,X
	LDCH	enty,X
	ADD	#eofhgh
	ADD	#oofhgh
	LDX	otbptr
	STCH	otaby,X
	JSUB	rndost
	TIX	#30
	JLT	estadd
	CLEAR	X
estadd	STX	otbptr
	RMO	S,X
	J	eshtld

eshtmv	RSUB

.ENEMY_SHOT_DATA
eshcnt	BYTE	X'00070A1F10011D050A1C150E02101B'	.ksn trenutek strelja .TODO init tega
eshclk	WORD	0	.trenutki
eshttm	EQU	32	.kolko je razlika cajta med streli
otabdm	EQU	30
otabx	RESB	otabdm
otaby	RESB	otabdm
otbptr	WORD	0

	.premakni sovraznike
	.premakni izstrelke feind detection
	.izstreli_feind p3
	
.RENDER
render	STL	@stkptr
	JSUB	stkpsh
	JSUB	regpsh
	.B register za pozicijo, kjer se slika, X, st byta, ki se rise, A hrani, S in T pomagajo B registru
	+LDB	#scrptr
	BASE	scrptr
	LDA	#width
	MUL	rndy
	ADD	rndx
	ADDR	A,B	.B kaze zdaj na pravo mesto
	RMO	B,S	.S bo hranil spremenjen screenptr
	CLEAR	A
	CLEAR	X
rndlp	LDB	rndptr
	LDCH	scrptr,X
	RMO	S,B
	STCH	scrptr,X
	LDA	rndA
	ADD	#1
	.poglej, ce nslenji znak je za v naslednjo vrstico
	COMP	rndwdt
	JLT	rndlpe	.samo ko A se	 reseta in se gre v novo vrstico
	LDA	rndjmp
	ADDR	A,B
	RMO	B,S	.tud S more ostat al corrrente
	CLEAR	A
rndlpe	STA	rndA
	TIX	rndsz
	JLT	rndlp
	JSUB	regpop
	JSUB	stkpop
	LDL	@stkptr
	RSUB
	.parametri za funkcijo width, size sprita, pozx, pozy, pozicija sprita(se jo shrani v bazo in naslavlja bazno, ges skoyi dva loopa shranjuj vecji X v eno spremenljivko, pozicijo dobi ze levi kot zgoraj
rndA	RESW	1
rndsz	WORD	0
rndwdt	WORD	0
rndjmp	WORD	0
rndx	WORD	0
rndy	WORD	0
rndptr	WORD	0

.RENDER CALLS
.for ally ship
rndast	STL	@stkptr
	JSUB	stkpsh
	LDA	#asz
	STA	rndsz
	LDA	#awdt
	STA	rndwdt
	LDA	#ajmp
	STA	rndjmp
	CLEAR	A
	LDCH	assx
	SUB	#aofwdt
	STA	rndx
	LDCH	assy
	SUB	#aofhgh
	STA	rndy
	+LDA	#asprt
	STA	rndptr
	JSUB	render
	JSUB	stkpop
	LDL	@stkptr
	RSUB

.for enemy
rndest	STL	@stkptr	.v A je pozicija sprita se da ze vnaprej
	JSUB	stkpsh
	JSUB	regpsh
	STA	rndptr
	LDA	#esz
	STA	rndsz
	LDA	#ewdt
	STA	rndwdt
	LDA	#ejmp
	STA	rndjmp
	CLEAR	A
	LDCH	entx,X
	SUB	#eofwdt
	STA	rndx
	LDCH	enty,X
	SUB	#eofhgh
	STA	rndy
	JSUB	render
	JSUB	regpop
	JSUB	stkpop
	LDL	@stkptr
	RSUB

.for enemy based on hp
rndehp	STL	@stkptr	.enemy render na podlagi lfp shipa
	JSUB	stkpsh
	CLEAR	A
	LDCH	entlfp,X
	COMP	#0
	JEQ	mernd0
	COMP	#1
	JEQ	mernd1
	COMP	#2
	JEQ	mernd2
	COMP	#3
	JEQ	mernd3
rndehd	JSUB	stkpop
	LDL	@stkptr
	RSUB
mernd0	+LDA	#esprt0
	JSUB	rndest
	J	rndehd
mernd1	+LDA	#esprt1
	JSUB	rndest
	J	rndehd
mernd2	+LDA	#esprt2
	JSUB	rndest
	J	rndehd
mernd3	+LDA	#esprt3
	JSUB	rndest
	J	rndehd

.to render ship life
rndahp	STL	@stkptr	.enemy render na podlagi lfp shipa
	JSUB	stkpsh
	CLEAR	A
	LDCH	asslf
	COMP	#0
	JEQ	hprnd0
	COMP	#1
	JEQ	hprnd1
	COMP	#2
	JEQ	hprnd2
	COMP	#3
	JEQ	hprnd3
rndahd	JSUB	stkpop
	LDL	@stkptr
	RSUB
hprnd0	+LDA	#hsprt0
	JSUB	rndhp
	J	rndahd
hprnd1	+LDA	#hsprt1
	JSUB	rndhp
	J	rndahd
hprnd2	+LDA	#hsprt2
	JSUB	rndhp
	J	rndahd
hprnd3	+LDA	#hsprt3
	JSUB	rndhp
	J	rndahd

rndhp	STL	@stkptr
	JSUB	stkpsh
	STA	rndptr
	LDA	#hpsz
	STA	rndsz
	LDA	#hpwdt
	STA	rndwdt
	LDA	#hpjmp
	STA	rndjmp
	LDA	#27
	STA	rndx
	LDA	#61
	STA	rndy
	JSUB	render
	JSUB	stkpop
	LDL	@stkptr
	RSUB

.render ally izstrelek X ga dobi ze iz nadfunkcije?
rndist	STL	@stkptr
	JSUB	stkpsh
	STA	@stkptr
	JSUB	stkpsh
	LDA	#isz
	STA	rndsz
	LDA	#iwdt
	STA	rndwdt
	LDA	#ijmp
	STA	rndjmp
	CLEAR	A
	LDCH	asxtab,X
	STA	rndx
	LDCH	asytab,X
	STA	rndy
	+LDA	#isprt
	STA	rndptr
	JSUB	render
	JSUB	stkpop
	LDA	@stkptr
	JSUB	stkpop
	LDL	@stkptr
	RSUB

rndost	STL	@stkptr
	JSUB	stkpsh
	STA	@stkptr
	JSUB	stkpsh
	LDA	#osz
	STA	rndsz
	LDA	#owdt
	STA	rndwdt
	LDA	#ojmp
	STA	rndjmp
	CLEAR	A
	LDCH	otabx,X
	STA	rndx
	LDCH	otaby,X
	SUB	#oofhgh
	STA	rndy
	+LDA	#osprt
	STA	rndptr
	JSUB	render
	JSUB	stkpop
	LDA	@stkptr
	JSUB	stkpop
	LDL	@stkptr
	RSUB

rndbst	STL	@stkptr
	JSUB	stkpsh
	STA	@stkptr
	JSUB	stkpsh
	LDA	#isz
	STA	rndsz
	LDA	#iwdt
	STA	rndwdt
	LDA	#ijmp
	STA	rndjmp
	CLEAR	A
	LDCH	asxtab,X
	STA	rndx
	LDCH	asytab,X
	STA	rndy
	+LDA	#ibsprt
	STA	rndptr
	JSUB	render
	JSUB	stkpop
	LDA	@stkptr
	JSUB	stkpop
	LDL	@stkptr
	RSUB

rndcst	STL	@stkptr
	JSUB	stkpsh
	STA	@stkptr
	JSUB	stkpsh
	LDA	#osz
	STA	rndsz
	LDA	#owdt
	STA	rndwdt
	LDA	#ojmp
	STA	rndjmp
	CLEAR	A
	LDCH	otabx,X
	STA	rndx
	LDCH	otaby,X
	SUB	#oofhgh
	STA	rndy
	+LDA	#csprt
	STA	rndptr
	JSUB	render
	JSUB	stkpop
	LDA	@stkptr
	JSUB	stkpop
	LDL	@stkptr
	RSUB

.STACK - beri @stackptr, prej ga zmanjsaj, prej nalozii potem pocvecaj
stkint	STA	stkA
	LDA	#stack
	STA	stkptr
	LDA	stkA
	RSUB

stkpsh	STA	stkA
	+LDA	stkptr
	ADD	#3
	STA	stkptr
	LDA	stkA
	RSUB

stkpop	STA	stkA	.zmanjsa stkptr
	+LDA	stkptr
	SUB	#3
	STA	stkptr
	LDA	stkA
	RSUB

regpsh	STL	stkL
	STA	@stkptr
	JSUB	stkpsh
	STB	@stkptr
	JSUB	stkpsh
	STX	@stkptr
	JSUB	stkpsh
	STS	@stkptr
	JSUB	stkpsh
	STT	@stkptr
	JSUB	stkpsh
	LDL	stkL
	RSUB

regpop	STL	stkL
	JSUB	stkpop
	LDT	@stkptr
	JSUB	stkpop
	LDS	@stkptr
	JSUB	stkpop
	LDX	@stkptr
	JSUB	stkpop
	LDB	@stkptr
	JSUB	stkpop
	LDA	@stkptr
	LDL	stkL
	RSUB

..DATA

.PRESSED KEY
prskey	RESB	1

.STACK
stkptr	RESW	1
stkA	RESW	1
stkL	RESW	1

.tick-counter, za znat elapsed time
lpcnt	WORD	0	.za st passage



.INPUT_CONST
lftkey	EQU	0x41
rgtkey	EQU	0x44
upkey	EQU	0x57
dwnkey	EQU	0x53

.GRAPHIC_CONST
.POINTER to screen buffer
scrptr	EQU	0xA000
.screen specs
height	EQU	64
width	EQU	64

.OMEJITVE
.borders of the ally ship movement box	
lftbrd	EQU	aofwdt+1
rgtbrd	EQU	width-aofwdt-2
upbrd	EQU	height*3/4+aofhgh
dwnbrd	EQU	height-3-aofhgh

.ALLY_SHIP_DATA
.life points, x pos, y pos
asslf	BYTE	3
assx	BYTE	0
assy	BYTE	0
.start x and y position
astrTx	EQU	width/2
astrTy	EQU	height*7/8

.ALLY_SHOT
.table dimension
ashtdm	EQU	11
.game loops elapsed between shots
ashttm	EQU	6
.pointer to oldest shot (next to be replaced)
astptr	WORD	0
.array with shots x and y coordinates
asxtab	RESB	ashtdm
asytab	RESB	ashtdm


.ENEMIES
.number of enemies
entdim	EQU	15
.distnace between enemies
enofst	EQU	8
.array with x and y position, life points of enemies
entx	RESB	entdim
enty	RESB	entdim
entlfp	RESB	entdim
.array with position in the movement table of enemies
epstb	RESW	entdim
.MOVEMENT
.one byte in table - one position on the screen, emvtb should be max the number of bytes of the array
.enemy movement table dimension
emvtbd	EQU	120
.movement x coordinates
emvxtb	BYTE X'04040505060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3A3B3B3B3B3A3A393837363534333231302F2E2D2C2B2A292827262524232221201F1E1D1C1B1A191817161514131211100F0E0D0C0B0A0908070605050404'
.movement y coordinates
emvytb	BYTE X'0B0A09080706060505050404040404040404040404040404040404040404040404040404040404040404040404040404040405050506060708090A0B0C0D0E0F101111121212131313131313131313131313131313131313131313131313131313131313131313131313131313131212121111100F0E0D0C'

.STACK_DATA
stack	RESW	1024

.GRAFIKA_SLIKE
.izstrelki glavni v barvah
ihgh	EQU	6
iwdt	EQU	1
isz	EQU	6
iofhgh	EQU	3
iofwdt	EQU	0
ispd	EQU	3
ijmp	EQU	width-iwdt
isprt	BYTE	X'FCFCFC000000'
ibsprt	BYTE	X'000000000000'

.ENEMY
ohgh	EQU	5
owdt	EQU	1
oofhgh	EQU	1
oofwdt	EQU	0
osz	EQU	5
ospd	EQU	2
ojmp	EQU	width-owdt
osprt	BYTE	X'0000F0F0F0'
csprt	BYTE	X'0000000000'

.glavna ladja 7x5
ahgh	EQU	9
awdt	EQU	7
asz	EQU	63
aofhgh	EQU	3
aofwdt	EQU	2
aspd	EQU	1
ajmp	EQU	width-awdt
asprt 	BYTE	X'00000000000000000000CC000000000000CC0000000000CCFCCC00000000CCFCCC000000CCFCCCFCCC000000CCFCCC0000000000CC00000000000000000000'

.nasprotnikove ladje vec barv 5x5
ehgh	EQU	5
ewdt	EQU	5
esz	EQU	25
eofhgh	EQU	2
eofwdt	EQU	2
espd	EQU	1
ejmp	EQU	width-ewdt
esprt1	BYTE	X'000000000000FFFFFF0000FFFFFF0000FFFFFF000000000000'
esprt2	BYTE	X'000000000000CCCCCC0000CCCCCC0000CCCCCC000000000000'
esprt3	BYTE	X'000000000000FCFCFC0000FCFCFC0000FCFCFC000000000000'
esprt0	BYTE	X'00000000000000000000000000000000000000000000000000'

.srcka in ozadje
hphgh	EQU	2
hpwdt	EQU	8
hpsz	EQU	16
hpjmp	EQU	width-hpwdt
hsprt0	BYTE	X'00000000000000000000000000000000'
hsprt1	BYTE	X'000000F0F0000000000000F0F0000000'
hsprt2	BYTE	X'00F0F00000F0F00000F0F00000F0F000'
hsprt3	BYTE	X'F0F000F0F000F0F0F0F000F0F000F0F0'