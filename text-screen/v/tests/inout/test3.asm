. tests rch working and printing char to cursor
test3       START 0
            EXTREF ioinit,cl,cr,cu,cd,crsrnl,rch,pch,map_ch
            EXTREF sinit,spush,spop,sp

            +JSUB sinit . init stack

            +STL @sp     . init IO
            +JSUB spush
            +JSUB ioinit
            +JSUB spop
            +LDL @sp

            . tests
            . -------------------------------------
test_loop   +STL @sp    . read input
            +JSUB spush
            +JSUB rch
            +JSUB spop
            +LDL @sp

            +STL @sp    . write to input
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp

            J test_loop
            . -------------------------------------

prevch      BYTE 1

        END test3
