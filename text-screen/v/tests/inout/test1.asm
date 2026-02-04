. tests EOL checks for all movement subroutines of inout.asm
. S = # of passed tests
. T = # of failed tests
. USES hidden API inout.asm variables for testing!
test1       START 0
            EXTREF ioinit,cl,cr,cu,cd,crsrnl,rch,pch,map_ch
            . hidden API
            EXTREF output,cursor,scrcol,scrrow
            EXTREF sinit,spush,spop,sp

            +JSUB sinit . init stack

            +STL @sp     . init IO
            +JSUB spush
            +JSUB ioinit
            +JSUB spop
            +LDL @sp

            . tests
            . -------------------------------------
            +STL @sp     . test cl
            +JSUB spush
            +JSUB cl
            +JSUB spop
            +LDL @sp
            COMP #0
            JEQ test_good1
            JSUB failed
            J test_end1
test_good1  JSUB passed
test_end1   +LDA output
            +STA cursor

            +LDA output  . test cr
            +ADD scrcol
            SUB #1
            +STA cursor
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp
            COMP #0
            JEQ test_good2
            JSUB failed
            J test_end2
test_good2  JSUB passed
test_end2   +LDA output
            +STA cursor

            +STL @sp     . test cu
            +JSUB spush
            +JSUB cu
            +JSUB spop
            +LDL @sp
            COMP #0
            JEQ test_good3
            JSUB failed
            J test_end3
test_good3  JSUB passed
test_end3   +LDA output
            +STA cursor

            +LDA scrcol  . test cd
            +MUL scrrow
            +ADD output
            SUB #1
            +STA cursor
            +STL @sp
            +JSUB spush
            +JSUB cd
            +JSUB spop
            +LDL @sp
            COMP #0
            JEQ test_good4
            JSUB failed
            J test_end4
test_good4  JSUB passed
test_end4   +LDA output
            +STA cursor

            +LDA scrcol  . test crsrnl
            +MUL scrrow
            +ADD output
            SUB #1
            +STA cursor
            +STL @sp
            +JSUB spush
            +JSUB crsrnl
            +JSUB spop
            +LDL @sp
            COMP #0
            JEQ test_good5
            JSUB failed
            J test_end5
test_good5  JSUB passed
test_end5   +LDA output
            +STA cursor

halt        J halt
            . -------------------------------------

passed  LDA #1
        ADDR A, S
        RSUB
failed  LDA #1
        ADDR A, T
        RSUB

        END test1
