bouncy  START 0

        +LDX #40960
        +LDT #41024
        LDS #1
        LDA #204
loop0a  STCH 0, X
        STCH 4032, X
        ADDR S, X
        COMPR X, T
        JLT loop0a

        +LDT #44992
        LDS #64
        LDA #252
loop0b  STCH 0, X
        STCH 63, X
        ADDR S, X
        COMPR X, T
        JLT loop0b

        LDB #listb
        LDT #liste
        LDS #7
loop1   BYTE X'074000'
        BYTE X'534006'
        STCH 0, X
        BYTE X'034003'
        ADDR B, A
        ADD #6
        +AND #4095
        BYTE X'0F4003'
        ADDR S, B
        COMPR B, T
        JLT loop1

main    LDB #listb
        LDT #liste
        LDS #7
loop2   BYTE X'074000'
        BYTE X'4A4003'
        BYTE X'134000'
        BYTE X'534006'
        STCH 0, X
        ADDR S, B
        COMPR B, T
        JLT loop2

        J main

movdr   LDCH 1, X
        COMP #0
        JGT movdr1
        LDCH 64, X
        COMP #0
        JGT movdr2
        STCH 0, X
        LDA #65
        ADDR A, X
        RSUB
movdr1  LDCH 64, X
        COMP #0
        JGT movdr3
        LDA #movdl
        BYTE X'0F4003'
        RSUB
movdr2  LDA #movur
        BYTE X'0F4003'
        RSUB
movdr3  LDA #movul
        BYTE X'0F4003'
        RSUB

movdl   LDA #1
        SUBR A, X
        LDCH 0, X
        COMP #0
        JGT movdl1
        LDCH 65, X
        COMP #0
        JGT movdl2
        STCH 1, X
        LDA #64
        ADDR A, X
        RSUB
movdl1  LDCH 65, X
        COMP #0
        JGT movdl3
        LDA #movdr
        BYTE X'0F4003'
        LDA #1
        ADDR A, X
        RSUB
movdl2  LDA #movul
        BYTE X'0F4003'
        LDA #1
        ADDR A, X
        RSUB
movdl3  LDA #movur
        BYTE X'0F4003'
        LDA #1
        ADDR A, X
        RSUB

movur   LDA #64
        SUBR A, X
        LDCH 0, X
        COMP #0
        JGT movur1
        LDCH 65, X
        COMP #0
        JGT movur2
        STCH 64, X
        LDA #1
        ADDR A, X
        RSUB
movur1  LDCH 65, X
        COMP #0
        JGT movur3
        LDA #movdr
        BYTE X'0F4003'
        LDA #64
        ADDR A, X
        RSUB
movur2  LDA #movul
        BYTE X'0F4003'
        LDA #64
        ADDR A, X
        RSUB
movur3  LDA #movdl
        BYTE X'0F4003'
        LDA #64
        ADDR A, X
        RSUB

movul   LDA #64
        SUBR A, X
        LDCH 0, X
        COMP #0
        JGT movul1
        LDCH 63, X
        COMP #0
        JGT movul2
        STCH 64, X
        LDA #1
        SUBR A, X
        RSUB
movul1  LDCH 63, X
        COMP #0
        JGT movul3
        LDA #movdl
        BYTE X'0F4003'
        LDA #64
        ADDR A, X
        RSUB
movul2  LDA #movur
        BYTE X'0F4003'
        LDA #64
        ADDR A, X
        RSUB
movul3  LDA #movdr
        BYTE X'0F4003'
        LDA #64
        ADDR A, X
        RSUB

listb   RESB 0
        WORD X'00A120'
        LDA movdl
        BYTE 231
        WORD X'00ACCC'
        LDA movdr
        BYTE 225
        WORD X'00AC74'
        LDA movul
        BYTE 252
        WORD X'00A0A6'
        LDA movur
        BYTE 221
        WORD X'00A70C'
        LDA movdl
        BYTE 235
        WORD X'00A360'
        LDA movdr
        BYTE 255
        WORD X'00A5C9'
        LDA movul
        BYTE 254
        WORD X'00A21F'
        LDA movur
        BYTE 211
        WORD X'00AD0E'
        LDA movdl
        BYTE 249
        WORD X'00A75A'
        LDA movdr
        BYTE 198
        WORD X'00A36B'
        LDA movul
        BYTE 210
        WORD X'00AAEF'
        LDA movur
        BYTE 195
        WORD X'00A3F7'
        LDA movdl
        BYTE 240
        WORD X'00A930'
        LDA movdr
        BYTE 231
        WORD X'00A737'
        LDA movul
        BYTE 245
        WORD X'00A243'
        LDA movur
        BYTE 224
        WORD X'00A93B'
        LDA movdl
        BYTE 196
        WORD X'00A06B'
        LDA movdr
        BYTE 237
        WORD X'00A1E5'
        LDA movul
        BYTE 241
        WORD X'00A5F5'
        LDA movur
        BYTE 205
liste   RESB 0
