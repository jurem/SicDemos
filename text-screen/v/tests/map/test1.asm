. tests map
. expected result:
.   - see 0x123 at map[0]
.   - see 0x456 at map[42 * 3 = 126]
.   - see 0x789 at map[69 * 3 = 207]
.   - see 0x456 at mapfun
test1       START 0
            EXTREF sinit
            EXTREF mput,mget,mfun

            +JSUB sinit . init stack

            . tests
            . -------------------------------------
            LDCH #0
            LDB one
            +JSUB mput

            . check that it keeps registers the same
            LDCH #42
            LDB one
            +JSUB mput
            LDB two
            +JSUB mput

            LDCH #69
            LDB three
            +JSUB mput

            LDCH #42
            +JSUB mget

halt        J halt
            . -------------------------------------

one     WORD 0x123
two     WORD 0x456
three   WORD 0x789

            END test1
