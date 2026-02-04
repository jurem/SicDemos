. tests basic movement 4
. inject text in one line
. - go to first character
. - go to last character
. - go to first character
. - go to last character
test5       START 0
            EXTREF c_i,c_0,c_dlr
            EXTREF ioinit
            EXTREF sinit

            +JSUB sinit     . init stack

            +JSUB ioinit    . init IO

            . tests
            . -------------------------------------
            . inject
            +JSUB c_i

            +JSUB c_0
            +JSUB c_dlr
            +JSUB c_0
            +JSUB c_dlr

halt        J halt
            . -------------------------------------

            END test5
