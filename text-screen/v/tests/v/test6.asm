. tests text manipulation (y, d, p)
. inject text in first 3 lines
. - yanks 3nd line
. - pastes to 2nd line
. - deletes 1nd line
. - pastes to 3rd line
. example:
.   ABC     -> 
.   123     -> 456
.   456     -> ABC
test6       START 0
            EXTREF c_i,c_y,c_d,c_p,c_j,c_k
            EXTREF ioinit
            EXTREF sinit

            +JSUB sinit     . init stack

            +JSUB ioinit    . init IO

            . tests
            . -------------------------------------
            . inject
            +JSUB c_i

            +JSUB c_y

            +JSUB c_k
            +JSUB c_p

            +JSUB c_k
            +JSUB c_d

            +JSUB c_j
            +JSUB c_j
            +JSUB c_p

halt        J halt
            . -------------------------------------

            END test6
