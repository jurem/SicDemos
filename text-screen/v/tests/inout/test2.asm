. tests if printing "HELLO WORLD\n" works
test2       START 0
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
            . print "HELLO WORLD"
            LDCH #0x48   . print 'H'
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp

            LDCH #0x45   . print 'E'
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp

            LDCH #0x4c   . print 'L'
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp

            LDCH #0x4c   . print 'L'
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp

            LDCH #0x4f   . print 'O'
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp

            LDCH #0x20   . print ' '
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp

            LDCH #0x57   . print 'W'
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp

            LDCH #0x4f   . print 'O'
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp

            LDCH #0x52   . print 'R'
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp

            LDCH #0x4c   . print 'L'
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp
            +STL @sp
            +JSUB spush
            +JSUB cr
            +JSUB spop
            +LDL @sp

            LDCH #0x44   . print 'D'
            +STL @sp
            +JSUB spush
            +JSUB pch
            +JSUB spop
            +LDL @sp

            +STL @sp    . go to new line
            +JSUB spush
            +JSUB crsrnl
            +JSUB spop
            +LDL @sp

halt        J halt
            . -------------------------------------

        END test2
