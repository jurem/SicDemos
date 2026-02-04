. tests basic movement 2
. inject some data and cursor should:
. - go first character
. - go last character
. - go first character
. - go last character
test3       START 0
            EXTREF c_i,c_g,c_G
            EXTREF ioinit
            EXTREF sinit

            +JSUB sinit     . init stack

            +JSUB ioinit    . init IO

            . tests
            . -------------------------------------
            +JSUB c_g
            +JSUB c_G
            +JSUB c_G
            +JSUB c_g

            . inject
            +JSUB c_i

            +JSUB c_g
            +JSUB c_G
            +JSUB c_g
            +JSUB c_G

halt        J halt
            . -------------------------------------

            END test3
