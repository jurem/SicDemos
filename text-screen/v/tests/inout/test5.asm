. test ctop, cbtm, cfirst, clast
. expected cursor behavior:
.   - bottom left
.   - top left
.   - last in line
.   - first in line

. USES hidden API inout.asm variables for testing!
test5       START 0
            EXTREF ioinit,cl,cr,cu,cd,crsrnl,ctop,cbtm,cfirst,clast,rch,pch,map_ch,input,shiftr,shiftl
            EXTREF sinit,spush,spop,sp

            +JSUB sinit     . init stack
            +JSUB ioinit    . init IO

            +JSUB cbtm
            +JSUB ctop
            +JSUB clast
            +JSUB cfirst

halt        J halt

            END test5
