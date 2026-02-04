. tests basic movement 3
. inject 5 words in one line (with multiple spaces between some words and spaces at the end)
. - go 2 words back
. - go 1 word forward
. - go 1 word back
. - go forward till last character (space)
. - go back till first character
test4       START 0
            EXTREF c_i,c_w,c_b
            EXTREF ioinit
            EXTREF sinit

            +JSUB sinit     . init stack

            +JSUB ioinit    . init IO

            . tests
            . -------------------------------------
            . inject
            +JSUB c_i

            +JSUB c_b
            +JSUB c_b
            +JSUB c_w
            +JSUB c_b

            +JSUB c_w
            +JSUB c_w
            +JSUB c_w
            +JSUB c_w
            +JSUB c_w
            +JSUB c_w
            +JSUB c_w
            +JSUB c_w
            +JSUB c_w
            +JSUB c_w

            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b
            +JSUB c_b

halt        J halt
            . -------------------------------------

            END test4
