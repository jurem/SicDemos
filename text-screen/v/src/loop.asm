loop    START 0
        EXTREF mget,mfun
        EXTREF input
        EXTREF wnull
        EXTDEF main

. main loop
. --------------------------------------------
main        +LDA wnull      . reset input
            +STCH @input

main_loop   CLEAR A         . get character
            +LDCH @input
            +COMP wnull     . if nothing (null) => try again
            JEQ main_loop
            +JSUB mget      . else get function from map

            +LDA mfun
            +COMP wnull     . if no function (null) => try again (command not found)
            JEQ main_reset
            +JSUB @mfun     . else execute command

main_reset  +LDA wnull      . reset input
            +STCH @input

            J main_loop
. --------------------------------------------

        END loop
