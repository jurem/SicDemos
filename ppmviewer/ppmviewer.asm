.           SIC/XE PPM viewer
.           Displays PPMs from stdin on the graphical screen
.           Supports PPMs of type P6 and color range 255
.           Colors are converted from rgb to nearest irgb (euclidean distance)
.           PPM format spec: http://paulbourke.net/dataformats/ppm/
.           Demo PPMs were generated using https://convertio.co/png-ppm/
.           Blaz Zupancic 17.11.2020

start       START   0
            J       rheader


...............  INPUT DEVICE  .................
in          BYTE    X'00'

.............  SCREEN DIMENSIONS  ..............
scrw        WORD    64
scrh        WORD    64


rheader
            . read and parse PPM header
            LDA     #0
            LDX     #0
            LDS     #0
            LDT     #10

delimiter   RMO     S,  A
            COMP    #0
            JEQ     rheaderlp
            LDS     #0
            STA     type,X
            TIX     #0
            TIX     #0
            TIX     #12
            JEQ     rbody

rheaderlp   TD      in
            JEQ     rheaderlp
            LDA     #0
            RD      in

            . skip comments
            COMP    #35             . 35 = #
            JEQ     skipcomment

            . skip   ' ', \n, \r
            COMP    #32
            JEQ     delimiter
            COMP    #10
            JEQ     delimiter
            COMP    #13
            JEQ     delimiter

            . else interpret char as decimal number
            SUB     #48
            MULR    T,      S
            ADDR    A,      S
            J       rheaderlp

            . skip bytes till \n or \r
skipcomment TD      in
            JEQ     skipcomment
            RD      in
            COMP    #10             . 10 = \n
            JEQ     delimiter
            COMP    #13             . 13 = \r
            JEQ     delimiter
            J       skipcomment


rbody       . read PPM body, convert to irgb and display it
            .calculate size = img w * img h, startx = first px scr x, starty = first px scr y
            LDA     width
            MUL     height
            STA     size

            LDA     #0
            STA     startx
            STA     starty

            LDA     scrw
            SUB     width
            DIV     #2
            COMP    #0
            JLT     negstartx
            STA     startx
negstartx
            LDA     scrh
            SUB     height
            DIV     #2
            COMP    #0
            JLT     negstarty
            STA     starty
negstarty

            LDS     #0          .  S = body byte counter
rbodylp     
            .  calculate X (displacement from scr)
            RMO     S,  A
            DIV     width
            ADD     starty
            MUL     scrw
            RMO     A,  X

            RMO     S,  A
            DIV     width
            MUL     width
            SUBR    S,  A
            MUL     =-1
            ADD     startx
            ADDR    A,  X

            .  read rgb
            TD      in
            JEQ     rbodylp
            RD      in
            SHIFTL  A, 8
rbodylp2     
            TD      in
            JEQ     rbodylp2
            RD      in
            SHIFTL  A, 8
rbodylp3     
            TD      in
            JEQ     rbodylp3
            RD      in

            .  convert to irgb
            JSUB    nearestcol

            .  display
            +STCH    scr,X

            RMO     S,  A
            ADD     #1
            RMO     A,  S

            COMP    size
            JEQ     halt

            J       rbodylp

halt        J       halt


.  PPM header
type        RESW    1
width       RESW    1
height      RESW    1
crange      RESW    1

.  computed
size        RESW    1
startx      RESW    1
starty      RESW    1



.  <<nearestcol>>
.  A(rgb -> irgb)  returns nearest irgb (euclidean distance)
nearestcA   RESW    1
nearestcX   RESW    1
nearestcT   RESW    1
nearestcS   RESW    1

color       RESB    1     .  best color
dist        RESW    1     .  best color distance^2 from original 

innerdist   RESW    1     .  temp for candidate color distance^2

add0        WORD    9
add1        WORD    19
add2        WORD    29
add3        WORD    39

div0        WORD    20
div1        WORD    40
div2        WORD    60
div3        WORD    80

ii          RESW    1
addit       RESW    1
divit       RESW    1


nearestcol
            STA     nearestcA
            STX     nearestcX
            STT     nearestcT
            STS     nearestcS

            LDA     #add0
            STA     addit
            LDA     #div0
            STA     divit
            LDA     #0
            STA     ii

            LDA     #0
            STA     color
            LDA     =X'0FFFFF'
            STA     dist


outerlp     .  iterate over intensities
            LDA     #0
            STA     innerdist

            LDX     #0
            LDS     #0

            .  insert intensity into T
            LDT     ii


innerlp     .  iterate over [r,g,b]
            LDA     #0
            LDCH    nearestcA,X
            RMO     A,  S

            .  compute best fit for component at intensity ii
            ADD     @addit
            DIV     @divit
            COMP    #4
            JLT     nooverflow
            LDA     #3
nooverflow
            
            .  insert component into T
            SHIFTL  T,  2
            ADDR    A,  T

            .  add error^2 to innerdist
            MUL     @divit
            SUBR    S,  A
            MULR    A,  A
            ADD     innerdist
            STA     innerdist

            TIX     #3
            JLT     innerlp
innerlpend
            
            .  compare/replace current best color
            COMP    dist
            JGT     notcloser
            STA     dist
            RMO     T,  A
            STCH    color
notcloser
            

            LDA     addit
            ADD     #3
            STA     addit
            LDA     divit
            ADD     #3
            STA     divit
            LDA     ii
            ADD     #1
            STA     ii

            COMP    #4
            JLT     outerlp
outerlpend

            LDA     #0
            LDCH    color

            LDX     nearestcX
            LDT     nearestcT
            LDS     nearestcS
            RSUB


            LTORG
            ORG     40960
scr         RESB    4096
