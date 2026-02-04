. tests basic movement
. cursor should:
. - stay in the same position after first 4 movement calls
. - (inject 5 chars into top 3 lines)
. - do this movement after injected test text:
.   - 2x left
.   - 1x up
.   - 1x right
.   - 1x down
.   - 2x right
.   - 3x up
.   - 6x left
test2       START 0
            EXTREF c_i,c_h,c_l,c_k,c_j
            EXTREF ioinit
            EXTREF sinit

            +JSUB sinit     . init stack

            +JSUB ioinit    . init IO

            . tests
            . -------------------------------------
            . 1st
            +JSUB c_h
            +JSUB c_l
            +JSUB c_k
            +JSUB c_j

            . inject
            +JSUB c_i

            . 2nd
            +JSUB c_h
            +JSUB c_h

            +JSUB c_k

            +JSUB c_l

            +JSUB c_j

            +JSUB c_l
            +JSUB c_l

            +JSUB c_k
            +JSUB c_k
            +JSUB c_k

            +JSUB c_h
            +JSUB c_h
            +JSUB c_h
            +JSUB c_h
            +JSUB c_h
            +JSUB c_h

halt        J halt
            . -------------------------------------

            END test2
