Hanoi       START   0
first       JSUB    stackinit

            LDA    =10
            LDS    =C'ACB'
            JSUB    hanoi
. death end
death       J       death


. Solves Towers of Hanoi puzzle
. Input: A - disk count, S - pegs conf $1$2$3 (src dest temp)
hanoi       COMP   =0           . if (n>1) then
            JGT     hanoi1      .    goto hanoi1
            RSUB                . else return
hanoi1      STL    @stackptr    . push L
            JSUB    stackpush
            STT    @stackptr    . push T
            JSUB    stackpush
            STS    @stackptr    . push S
            JSUB    stackpush
            SUB    =1           . A=n-1
            RMO     A, T        . save A into T
. manipulate S: $1$2$3 -> $1$3$2
            RMO     S, A        . A = S
            STCH    hanoiS3
            SHIFTR  A, 8
            STCH    hanoiS2
            LDCH    hanoiS3
            SHIFTL  A, 8
            LDCH    hanoiS2
            RMO     A, S        . S = A
. recurse hanoi A=n-1 S=$1$3$2
            RMO     T, A        . restore A from T
            JSUB    hanoi
            JSUB    stackpop    . pop S
            LDS    @stackptr
. echo $1>$2
            RMO     S, A
            SHIFTR  A, 16
            JSUB    echoch
            LDCH   =C'>'
            JSUB    echoch
            RMO     S, A
            SHIFTR  A, 8
            JSUB    echoch
            JSUB    echonl
. manipulate S: $1$2$3 - > $3$2$1
            RMO     S, A        . A = S
            STCH    hanoiS3
            SHIFTR  A, 8
            STCH    hanoiS2
            SHIFTR  A, 8
            STCH    hanoiS1
            LDCH    hanoiS3
            SHIFTL  A, 8
            LDCH    hanoiS2
            SHIFTL  A, 8
            LDCH    hanoiS1
            RMO     A, S        . S = A
. recurse hanoi n-1 $3$2$1
            RMO     T, A        . restore A from T
            JSUB    hanoi
. finish
            JSUB    stackpop    . pop T
            LDT    @stackptr
            JSUB    stackpop    . pop L
            LDL    @stackptr
            RSUB
hanoiS1     RESB    1
hanoiS2     RESB    1
hanoiS3     RESB    1
            
            



. ********* echo ************
echoch      TD     =X'01'
            JEQ     echoch
            WD     =X'01'
            RSUB


. ***************************
echonl      STCH    echonlA 
            LDCH   =X'0A'
            TD     =X'01'
            JEQ     echoch
            WD     =X'01'
            LDCH    echonlA
            RSUB
echonlA     RESB    1


. ********* stack ***********
stackinit   LDA    #stack
            STA     stackptr
            RSUB

stackpush   STA     stacka
            LDA     stackptr
            ADD    =3
            STA     stackptr
            LDA     stacka
            RSUB

stackpop    STA     stacka
            LDA     stackptr
            SUB    =3
            STA     stackptr
            LDA     stacka
            RSUB

stacka      RESW    1
stackptr    RESW    1
stack       RESW    10000

            END     first
