. tests c_i, c_a, c_I and c_A
. inject text in first 3 lines
.   - c_i -> u should be able to write infront of last character in 3rd line
.   - c_a -> it should go to 2nd line where u are able to write to the right of where u started the insert loop
.   - c_I -> it should go to 1st line where u are able to write infront of everything
.   - c_A -> u should be able to write at the end in 1st line
test1       START 0
            EXTREF c_i,c_a,c_I,c_A,c_k
            EXTREF ioinit
            EXTREF sinit

            +JSUB sinit     . init stack

            +JSUB ioinit    . init IO

            . tests
            . -------------------------------------
            . inject
            +JSUB c_i

            +JSUB c_i

            +JSUB c_k
            +JSUB c_a

            +JSUB c_k
            +JSUB c_I

            +JSUB c_A

halt        J halt
            . -------------------------------------

            END test1
