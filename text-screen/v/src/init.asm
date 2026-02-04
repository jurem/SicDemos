init    START 0
        EXTREF c_i,c_a,c_o,c_I,c_A,c_h,c_l,c_k,c_j,c_g,c_G,c_w,c_b,c_0,c_dlr,c_y,c_d,c_p,cmd
        EXTREF vinit
        EXTREF ioinit
        EXTREF mput
        EXTREF sinit

. initialization
. --------------------------------------------
        +JSUB sinit     . init stack
        +JSUB ioinit    . init IO
        +JSUB vinit     . init V

        LDA #0x49       . init map
        +LDB #c_i
        +JSUB mput

        LDA #0x41
        +LDB #c_a
        +JSUB mput

        LDA #0x4f
        +LDB #c_o
        +JSUB mput

. LDA #0x49
. +LDB #c_I
. +JSUB mput

. LDA #0x41
. +LDB #c_A
. +JSUB mput

        LDA #0x48
        +LDB #c_h
        +JSUB mput

        LDA #0x4c
        +LDB #c_l
        +JSUB mput

        LDA #0x4b
        +LDB #c_k
        +JSUB mput

        LDA #0x4a
        +LDB #c_j
        +JSUB mput

        LDA #0x47
        +LDB #c_g
        +JSUB mput

. LDA #0x47
. +LDB #c_G
. +JSUB mput

        LDA #0x57
        +LDB #c_w
        +JSUB mput

        LDA #0x42
        +LDB #c_b
        +JSUB mput

        LDA #0x30
        +LDB #c_0
        +JSUB mput

        LDA #0x24
        +LDB #c_dlr
        +JSUB mput

        LDA #0x59
        +LDB #c_y
        +JSUB mput

        LDA #0x44
        +LDB #c_d
        +JSUB mput

        LDA #0x50
        +LDB #c_p
        +JSUB mput

        LDA #0x3A
        +LDB #cmd
        +JSUB mput
. --------------------------------------------

        END init
