. test shiftr, shiftl, shiftd
. expected output (ignore the cursor indicators, since these are made by using the hidden APIs)
. HELLO W ORLD
. HE LLO W ORL D
. HELLO WORLD
.  HELLO WORLD
. 
. HELLO ORLD
. HLLO WOLD
. HELLO WORL
. HELLO WORLD
.
. HELLO WORLD
.
. HELLO WORLD
. HELLO WORLD
.
. HELLO WORLD

. USES hidden API inout.asm variables for testing!
test2       START 0
            EXTREF ioinit,cl,cr,cu,cd,crsrnl,ctop,cbtm,cfirst,clast,cprev,rch,pch,map_ch,map_ln,input,shiftr,shiftl,shiftd
            . hidden API
            EXTREF output,cursor,scrcol,scrrow
            EXTREF sinit,spush,spop,sp

            +JSUB sinit     . init stack
            +JSUB ioinit    . init IO

            . 1. row
            . --------------------------
            JSUB test_print
            +LDA cursor
            SUB #3
            +STA cursor
            +JSUB shiftr
            +JSUB crsrnl
            . --------------------------

            . 2. row
            . --------------------------
            JSUB test_print
            +LDA cursor
            SUB #8
            +STA cursor
            +JSUB shiftr

            +LDA cursor
            ADD #6
            +STA cursor
            +JSUB shiftr

            +LDA cursor
            ADD #4
            +STA cursor
            +JSUB shiftr

            +JSUB crsrnl
            . --------------------------

            . 3. row
            . --------------------------
            JSUB test_print
            +JSUB cr
            +JSUB shiftr
            +JSUB crsrnl
            . --------------------------

            . 4. row
            . --------------------------
            JSUB test_print
            +LDA cursor
            SUB #10
            +STA cursor
            +JSUB shiftr
            +JSUB crsrnl
            . --------------------------

            . 5. row
            . --------------------------
            +JSUB shiftr
            +JSUB crsrnl
            . --------------------------

            . 6. row
            . --------------------------
            JSUB test_print
            +LDA cursor
            SUB #3
            +STA cursor
            +JSUB shiftl
            +JSUB crsrnl
            . --------------------------

            . 7. row
            . --------------------------
            JSUB test_print
            +LDA cursor
            SUB #8
            +STA cursor
            +JSUB shiftl

            +LDA cursor
            ADD #6
            +STA cursor
            +JSUB shiftl

            +LDA cursor
            ADD #4
            +STA cursor
            +JSUB shiftl

            +JSUB crsrnl
            . --------------------------

            . 8. row
            . --------------------------
            JSUB test_print
            +JSUB cr
            +JSUB shiftl
            +JSUB crsrnl
            . --------------------------

            . 9. row
            . --------------------------
            JSUB test_print
            +LDA cursor
            SUB #10
            +STA cursor
            +JSUB shiftl
            +JSUB crsrnl
            . --------------------------

            . 10. row
            . --------------------------
            +JSUB shiftl
            +JSUB crsrnl
            . --------------------------

            . 11., 12., 13., 14. row
            . --------------------------
            +JSUB test_print
            +JSUB crsrnl
            +JSUB test_print
            +JSUB crsrnl
            +JSUB test_print
            +JSUB crsrnl
            +JSUB test_print

            +JSUB cu
            +JSUB cu
            +JSUB cu

            +JSUB shiftd

            +JSUB cd
            +JSUB cd
            +JSUB cd

            +JSUB shiftd
            . --------------------------

halt        J halt

. print "HELLO WORLD"
test_print  +STL @sp
            +JSUB spush

            LDCH #0x48   . print 'H'
            +JSUB pch
            +JSUB cr

            LDCH #0x45   . print 'E'
            +JSUB pch
            +JSUB cr

            LDCH #0x4c   . print 'L'
            +JSUB pch
            +JSUB cr

            LDCH #0x4c   . print 'L'
            +JSUB pch
            +JSUB cr

            LDCH #0x4f   . print 'O'
            +JSUB pch
            +JSUB cr

            LDCH #0x20   . print ' '
            +JSUB pch
            +JSUB cr

            LDCH #0x57   . print 'W'
            +JSUB pch
            +JSUB cr

            LDCH #0x4f   . print 'O'
            +JSUB pch
            +JSUB cr

            LDCH #0x52   . print 'R'
            +JSUB pch
            +JSUB cr

            LDCH #0x4c   . print 'L'
            +JSUB pch
            +JSUB cr

            LDCH #0x44   . print 'D'
            +JSUB pch

            +JSUB spop
            +LDL @sp
            RSUB

            END test2
