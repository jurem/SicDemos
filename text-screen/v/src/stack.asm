. import with: EXTREF sinit,spush,spop,sp
stk     START 0
        EXTDEF sinit,spush,spop,sp

. stack interface
. --------------------------------------------
. USAGE:
. PUSHA
.       STA @sp
.       JSUB spush
. POPA
.       JSUB spop
.       LDA @sp

. Always store L at the start of subroutines!
. On paper you only have to if your subroutine calls other subroutines and you want to use the stack
.   for other registers (not only L). But as good practice you should always just store L at the start
.   of subroutines (lost 2h debugging y L gets messed up)

. init stack - sp at the start of the stack
sinit       STA ssaved_a
            LDA #stack
            STA sp
            LDA ssaved_a
            RSUB

. sp += WORD
spush       STA ssaved_a
            LDA sp
            ADD #3
            STA sp
            LDA ssaved_a
            RSUB

. sp -= WORD
spop        STA ssaved_a
            LDA sp
            SUB #3
            STA sp
            LDA ssaved_a
            RSUB

ssaved_a    WORD 0
sp          WORD 0
stack       RESW 1000
. --------------------------------------------

        END stk
