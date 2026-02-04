. import with: EXTREF mput,mget,mfun
map     START 0
        EXTDEF mput,mget,mfun
        EXTREF spush,spop,sp

. map interface

. implemented with array:
. - key = char * 3
. - value = map[key]
. --------------------------------------------

. put entry
. parameters: 
.   - A = BYTE char
.   - B = WORD function
. keeps registers the same
mput        +STL @sp
            +JSUB spush
            +STX @sp
            +JSUB spush

            MUL #3  . get key (offset)
            RMO A, X
            STB map_arr, X

            DIV #3  . fix A back
            +JSUB spop
            +LDX @sp
            +JSUB spop
            +LDL @sp
            RSUB

. get entry
. parameters: 
.   - A = BYTE char
. puts function ptr in map_fun 
. keeps registers the same
mget        +STL @sp
            +JSUB spush
            +STX @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            MUL #3  . get key (offset)
            RMO A, X
            LDB map_arr, X
            STB mfun

            DIV #3  . fix A back
            +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDX @sp
            +JSUB spop
            +LDL @sp
            RSUB

mfun        RESW 1
map_arr     RESW 500
. --------------------------------------------

        END map
