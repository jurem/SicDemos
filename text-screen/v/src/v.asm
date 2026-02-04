. import with: EXTREF c_i,c_a,c_o,c_I,c_A,c_h,c_l,c_k,c_j,c_g,c_G,c_w,c_b,c_0,c_dlr,c_y,c_d,c_p,cmd
v       START 0
        EXTDEF vinit
        EXTDEF c_i,c_a,c_o,c_I,c_A,c_h,c_l,c_k,c_j,c_g,c_G,c_w,c_b,c_0,c_dlr,c_y,c_d,c_p,cmd
        EXTREF ioinit
        EXTREF cl,cr,cu,cd,crsrnl,ctop,cbtm,cfirst,clast,cprev,rch,pch,map_ch,map_ln,input,shiftr,shiftl,shiftd,drawnp
        EXTREF chnull,chesc,chent,chcrsr,chspac,chback,chshft,wnull,wesc,went,wcrsr,wspace,wback,wshift
        EXTREF spush,spop,sp

. V interface
. -------------------------------------------------------

. NORMAL mode
. =======================================================
. .......................................................
. i
. enter insert mode
c_i     +STL @sp
        +JSUB spush

        JSUB insert . go to the insert loop

        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. a
. go right and enter insert mode
c_a     +STL @sp
        +JSUB spush

        CLEAR A
        +JSUB rch
        +COMP wnull
        JEQ c_ains
        +JSUB cr    . go right only if current character is non null

c_ains  JSUB insert . go to the insert loop

        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. o
. shift down, go to new line and enter insert mode
c_o     +STL @sp
        +JSUB spush

        +JSUB shiftd
        +JSUB crsrnl
        +LDCH chspac    . add space to first character in new line
        +JSUB pch
        JSUB insert     . go to the insert loop

        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. I
. go to first character and enter insert mode
c_I     +STL @sp
        +JSUB spush

        +JSUB cfirst
        JSUB insert . go to the insert loop

        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. A
. go to last character and enter insert mode
c_A     +STL @sp
        +JSUB spush

        +JSUB c_dlr
        +JSUB cr
        JSUB insert . go to the insert loop

        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. h
. go left (no constraints)
c_h     +STL @sp
        +JSUB spush
        +STA @sp        . store old A
        +JSUB spush

        +JSUB cl

        +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. l
. go right (constraint: if next char == 0 => cannot go right)
c_l     +STL @sp
        +JSUB spush
        +STA @sp        . store old A
        +JSUB spush

        +JSUB cr

        CLEAR A
        +JSUB rch
        +COMP wnull
        JEQ c_lback

        J c_lend

c_lback +JSUB cl

c_lend  +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. k
. go up (no constraints)
c_k     +STL @sp
        +JSUB spush
        +STA @sp        . store old A
        +JSUB spush

        +JSUB cu

        CLEAR A         . if null => get to first character from the right
        +JSUB rch
        +COMP wnull
        JEQ c_kfind

        J c_kend        . else => end

c_kfind +JSUB c_dlr
c_kend  +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. j
. go down (constraint: if bottom char == 0 => cannot go down)
c_j     +STL @sp
        +JSUB spush
        +STA @sp        . store old A
        +JSUB spush

        +JSUB cd

        . if line null (if first character in line == 0) => go back and stop
        +JSUB cfirst
        CLEAR A
        +JSUB rch
        +COMP wnull
        JEQ c_jback

        +JSUB cprev     . else go down or if current null then go to last character in line
        +JSUB rch
        +COMP wnull
        JEQ c_jnull
        J c_jend
c_jnull +JSUB c_dlr
        J c_jend

c_jback +JSUB cprev
        +JSUB cu
c_jend  +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. g
. go to first character
c_g     +STL @sp
        +JSUB spush
        +STA @sp        . store old A
        +JSUB spush

        +JSUB ctop

c_gend  +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. G
. go to last character
c_G     +STL @sp
        +JSUB spush
        +STA @sp        . store old A
        +JSUB spush

c_Gloop +JSUB cd        . go down until EOF
        COMP #0
        JEQ c_Gend      . if at edge => stop

        . if line null (if first character in line == 0) => go back and stop
        +JSUB cfirst
        CLEAR A
        +JSUB rch
        +COMP wnull
        JEQ c_Gback

        J c_Gloop

c_Gback +JSUB cu
c_Gend  +JSUB cr        . go right until EOR (end of row - fist null character)
        CLEAR A
        +JSUB rch
        +COMP wnull
        JEQ c_Geend
        J c_Gend

c_Geend +JSUB cl

        +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. w
. go to next word in line
c_w     +STL @sp
        +JSUB spush
        +STA @sp        . store old A
        +JSUB spush

c_wloop +JSUB cr

        COMP #0         . if EOF (EOR) then end
        JEQ c_wend

        CLEAR A
        +JSUB rch
        +COMP wnull      . if EOR (because next is null) then go back and end
        JEQ c_wback

        +COMP wspace     . if space try going right and end
        JEQ c_wspac

        J c_wloop       . else try again

c_wspac +JSUB cr
        COMP #0         . if EOF (EOR) then end
        JEQ c_wend
        CLEAR A
        +JSUB rch
        +COMP wnull      . if EOR (because next is null) then go back and end
        JEQ c_wback
        +COMP wspace     . if another space try again
        JEQ c_wspac
        J c_wend        . else end

c_wback +JSUB cl
c_wend  +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. b
. go to previous word in line
c_b     +STL @sp
        +JSUB spush
        +STA @sp        . store old A
        +JSUB spush

c_bloop +JSUB cl

        COMP #0         . if EOF (SOR) then end
        JEQ c_bend

        CLEAR A
        +JSUB rch
        +COMP wspace     . if space try going left and end
        JEQ c_bspac

        J c_bloop       . else try again

c_bspac +JSUB cl
        COMP #0         . if EOF (SOR) then end
        JEQ c_bend
        CLEAR A
        +JSUB rch
        +COMP wspace     . if another space try again
        JEQ c_bspac
        J c_bend        . else end

c_bend  +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. 0
. go to first character in line
c_0     +STL @sp
        +JSUB spush
        +STA @sp        . store old A
        +JSUB spush

        +JSUB cfirst

c_0end  +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. $
. go to last character in line
c_dlr       +STL @sp
            +JSUB spush
            +STA @sp        . store old A
            +JSUB spush

            +JSUB clast     . go till last in line (even if null) and go back until u find a non-null character
            CLEAR A
            +JSUB rch       . if null => find non-null
            +COMP wnull
            JEQ c_dlrloop
            J c_dlrend        . else if non-null end

c_dlrloop   +JSUB cl
            COMP #0         . if EOF (SOR) => end
            JEQ c_dlrend
            CLEAR A
            +JSUB rch       . if still null => try again
            +COMP wnull
            JEQ c_dlrloop
            J c_dlrend      . else end

c_dlrend    +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB
. .......................................................

. .......................................................
. y
. yank line
c_y     +STL @sp
        +JSUB spush
        +STA @sp
        +JSUB spush
        +STX @sp
        +JSUB spush

        LDA #c_ycb
        +JSUB map_ln

        +JSUB cfirst    . go to first character

c_yend  +JSUB spop
        +LDX @sp
        +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB

. yank callback for map_ln. Copies each character into r_manip
. uses **global X**
c_ycb   +STL @sp
        +JSUB spush
        +STA @sp
        +JSUB spush

        CLEAR A
        +JSUB rch
        STCH r_manip, X     . store character into r_manip[X]
        TIX #0              . X++

        +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. d
. delete line
c_d     +STL @sp
        +JSUB spush
        +STA @sp
        +JSUB spush
        +STX @sp
        +JSUB spush

        LDA #c_dcb
        +JSUB map_ln    . copy characters into r_manip and null out the line

        +JSUB cfirst    . go to first character and add space into it to unnull the line
        +LDCH chspac
        +JSUB pch

c_dend  +JSUB spop
        +LDX @sp
        +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB

. delete callback for map_ln. Copies each character into r_manip and deletes it
. uses **global X**
c_dcb   +STL @sp
        +JSUB spush
        +STA @sp
        +JSUB spush

        CLEAR A
        +JSUB rch
        STCH r_manip, X  . store character into r_manip[X]

        +LDCH chnull     . delete the character
        +JSUB pch

        TIX #0          . X++

        +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................

. .......................................................
. p
. paste line
c_p     +STL @sp
        +JSUB spush
        +STA @sp
        +JSUB spush
        +STX @sp
        +JSUB spush

        LDA #c_pcb
        +JSUB map_ln

        +JSUB cfirst    . go to first character

c_pend  +JSUB spop
        +LDX @sp
        +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB

. paste callback for map_ln. Copies each character from r_manip to line
. uses **global X**
c_pcb   +STL @sp
        +JSUB spush
        +STA @sp
        +JSUB spush

        LDCH r_manip, X     . load character from r_manip[X]
        +JSUB pch           . print it
        TIX #0              . X++

        +JSUB spop
        +LDA @sp
        +JSUB spop
        +LDL @sp
        RSUB
. .......................................................
. =======================================================

. INSERT mode
. =======================================================
. writes characters from keyboard to screen
. ESC to break the loop
insert          +STL @sp
                +JSUB spush
                +STA @sp        . store old A
                +JSUB spush
                +STT @sp
                +JSUB spush
                +STX @sp
                +JSUB spush

                LDA #0          . draw insert mode in bottom bar
                LDB #1
                LDT #0x49       . =I
                +JSUB drawnp

                +LDA wnull      . reset input
                +STCH @input

insert_loop     CLEAR A         . get and compare character
                +LDCH @input
                +COMP wnull
                JEQ insert_loop
                +STA @sp        . store current character
                +JSUB spush

                . special characters check
                . ------------------------
                +COMP wesc
                JEQ insert_escape

                +COMP went
                JEQ insert_enter

                +COMP wback
                JEQ insert_back

                +COMP wshift
                JEQ insert_shift

                J insert_main

insert_escape   +JSUB spop      . pop character off the stack to keep stack consistent
                J insert_end

        . ---
insert_enter    CLEAR X
                +JSUB spop      . pop character off the stack to keep stack consistent
                +JSUB shiftd    . shift lines down

insert_enterlp1 +JSUB rch       . copy characters into the general register until null or EOF (EOR)
                +COMP wnull
                JEQ insert_enterpre

                STCH r_general, X
                TIX #0
                LDA #0          . and delete character
                +JSUB pch

                +JSUB cr
                COMP #0
                JEQ insert_enterpre
                J insert_enterlp1

insert_enterpre LDA #0          . mark EOS (end of string) in general register
                STCH r_general, X
                CLEAR X         . reset X
                +JSUB crsrnl    . go line down
insert_enterlp2 CLEAR A         . copy characters from general register to this line
                LDCH r_general, X
                COMP #0
                JEQ insert_enterend
                +JSUB pch
                +JSUB cr
                TIX #0
                J insert_enterlp2

insert_enterend +JSUB cfirst    . go to first character
                +JSUB rch       . if current null => add space to first character in new line
                +COMP wnull
                JEQ insert_enterspc
                J insert_enternsp
insert_enterspc +LDCH chspac
                +JSUB pch
insert_enternsp J insert_reset
        . ---

insert_back     +JSUB spop      . pop character off the stack to keep stack consistent
                +JSUB shiftl
                +JSUB cl
                J insert_reset

insert_shift    +JSUB spop      . pop character off the stack to keep stack consistent
                J insert_reset
                . ------------------------

insert_main     +JSUB shiftr

                +JSUB spop      . get and write character
                +LDA @sp
                +JSUB pch

                +JSUB cr        . try to move cursor right #FIXME if on edge it overwrites char everytime

insert_reset    +LDA wnull      . reset input
                +STCH @input
                J insert_loop
                
insert_end      CLEAR A         . if cursor at null character => move left
                +JSUB rch
                +COMP wnull
                JEQ insert_end_mv
                J insert_end_stack
insert_end_mv   +JSUB cl

insert_end_stack    LDA #0          . draw normal mode in bottom bar
                    LDB #1
                    LDT #0x4E       . =N
                    +JSUB drawnp

                    +JSUB spop
                    +LDX @sp
                    +JSUB spop
                    +LDT @sp
                    +JSUB spop
                    +LDA @sp
                    +JSUB spop
                    +LDL @sp
                    RSUB
. =======================================================

. COMMAND MODE and BOTTOM BAR
. =======================================================
. -------------------------------------------------------------------------------------------------
draw_btm_bar        +STL @sp
                    +JSUB spush
                    +STA @sp
                    +JSUB spush
                    +STB @sp
                    +JSUB spush
                    +STT @sp
                    +JSUB spush
                    +STX @sp
                    +JSUB spush

                    LDA #0
                    LDB #0
                    LDT #0x3D       . ='='
                    +JSUB drawnp    . draw first '='

                    LDA #0
                    LDB #1
                    LDT #0x4E       . =N
                    +JSUB drawnp    . draw mode

                    LDX #2
draw_btm_bar_loop   LDA #0          . draw rest of bottom bar
                    RMO X, B
                    LDT #0x3D
                    +JSUB drawnp
                    COMP #0         . end on EOL (end of line)
                    JEQ draw_btm_bar_end

                    TIX #0
                    J draw_btm_bar_loop

draw_btm_bar_end    +JSUB spop
                    +LDX @sp
                    +JSUB spop
                    +LDT @sp
                    +JSUB spop
                    +LDB @sp
                    +JSUB spop
                    +LDA @sp
                    +JSUB spop
                    +LDL @sp
                    RSUB
. -------------------------------------------------------------------------------------------------

. -------------------------------------------------------------------------------------------------
cmd                 +STL @sp
                    +JSUB spush
                    +STA @sp
                    +JSUB spush
                    +STB @sp
                    +JSUB spush
                    +STT @sp
                    +JSUB spush
                    +STX @sp
                    +JSUB spush

                    LDA #0          . draw command mode in bottom bar
                    LDB #1
                    LDT #0x43       . =C
                    +JSUB drawnp

                    JSUB cmd_clear_buffer

                    LDA #1          . draw ':' to screen
                    LDB #0
                    LDT #0x3A
                    +JSUB drawnp

                    CLEAR X
                    +LDA wnull      . reset input
                    +STCH @input

cmd_read_lp         CLEAR A         . add characters into the buffer (if ur reading this, yes u can buffer overflow this and get code execution, try it. Hint1: you are overflowing inout.asm, Hint2: note the 0x00 that get put at the end)
                    +LDCH @input

                    +COMP wnull     . if no input => try again
                    JEQ cmd_read_lp
                    +COMP went      . if enter => go to processing
                    JEQ cmd_process
                    +COMP wback     . if back => delete char and go back
                    JEQ cmd_back
                    STCH b_cmd, X   . else write to buffer
                    RMO A, T        . and draw to screen
                    LDA #1
                    LDB #1
                    ADDR X, B
                    +JSUB drawnp

                    TIX #0
                    +LDA wnull      . reset input
                    +STCH @input
                    J cmd_read_lp

cmd_back            LDA #0
                    COMPR X, A      . if X <= 0 then dont do anything
                    JEQ cmd_back_end
                    JLT cmd_back_end

                    LDA #1
                    SUBR A, X       . X--
                    LDA #0x00
                    STCH b_cmd, X   . delete character
                    LDA #1          . delete character on screen
                    LDB #1
                    ADDR X, B
                    LDT #0
                    +JSUB drawnp

cmd_back_end        +LDA wnull      . reset input
                    +STCH @input
                    J cmd_read_lp   . read again

cmd_process         LDA #0
                    STCH b_cmd, X

                    CLEAR X         . get command
                    LDCH b_cmd, X
                    COMP #0x57
                    JEQ cmd_w
                    COMP #0x45
                    JEQ cmd_e
                    COMP #0x51
                    JEQ cmd_q
                    J cmd_err

cmd_w               JSUB cmd_process_device
                    LDA #cmd_w_cb
                    +JSUB map_ch

                    LDA #0x03       . write ETX at the end
                    WD cmd_device
                    J cmd_end

cmd_e               JSUB cmd_process_device
                    LDA #cmd_e_cb
                    +JSUB map_ch
                    J cmd_end

cmd_q               JSUB cmd_clear_buffer
                    LDA #1          . draw 'NO'
                    LDB #0
                    LDT #0x4E
                    +JSUB drawnp
                    LDA #1
                    LDB #1
                    LDT #0x4F
                    +JSUB drawnp
                    J cmd_end

cmd_err             JSUB cmd_clear_buffer
                    LDA #1          . draw 'ERR'
                    LDB #0
                    LDT #0x45
                    +JSUB drawnp
                    LDA #1
                    LDB #1
                    LDT #0x52
                    +JSUB drawnp
                    LDA #1
                    LDB #2
                    LDT #0x52
                    +JSUB drawnp
                    J cmd_end

cmd_end             LDA #0
                    LDB #1
                    LDT #0x4E       . =N
                    +JSUB drawnp    . draw mode

                    +JSUB spop
                    +LDX @sp
                    +JSUB spop
                    +LDT @sp
                    +JSUB spop
                    +LDB @sp
                    +JSUB spop
                    +LDA @sp
                    +JSUB spop
                    +LDL @sp
                    RSUB

. write callback for map_ch. Copy all operational cells into the file (including 0x00).
cmd_w_cb    +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush

            CLEAR A
            +JSUB rch           . read the character
            WD cmd_device       . write character

            +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

. open callback for map_ch. Copy all characters from device onto cells, until ETX (0x03).
cmd_e_cb    +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush

            LDA #1              . if already ended => skip
            COMP cmd_e_cb_bl
            JEQ cmd_e_cbend

            CLEAR A
            RD cmd_device       . read the character from device
            COMP #0x03
            JEQ cmd_e_cbskp     . if just ended => var = true & skip
            J cmd_e_cont

cmd_e_cbskp LDA #1
            STA cmd_e_cb_bl
            J cmd_e_cbend

cmd_e_cont  +JSUB pch

cmd_e_cbend +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

cmd_e_cb_bl RESW 1              . end indicator boolean var
. -------------------------------------------------------------------------------------------------

. -------------------------------------------------------------------------------------------------
cmd_clear_buffer    +STL @sp
                    +JSUB spush
                    +STA @sp
                    +JSUB spush
                    +STT @sp
                    +JSUB spush
                    +STX @sp
                    +JSUB spush

                    CLEAR A
                    CLEAR X
cmd_clear_buffer_lp STCH b_cmd, X   . clear buffer
                    LDA #1          . clear screen buffer
                    RMO X, B
                    LDT #0
                    +JSUB drawnp

                    TIX #r_size
                    JEQ cmd_clear_bufferend
                    J cmd_clear_buffer_lp

cmd_clear_bufferend +JSUB spop
                    +LDX @sp
                    +JSUB spop
                    +LDT @sp
                    +JSUB spop
                    +LDA @sp
                    +JSUB spop
                    +LDL @sp
                    RSUB
. -------------------------------------------------------------------------------------------------

. -------------------------------------------------------------------------------------------------
. allowed devices <0-9><0-9>
. device = de_ascii(first) * 16 + de_ascii(second)
. result in cmd_device
cmd_process_device  +STL @sp
                    +JSUB spush
                    +STA @sp
                    +JSUB spush
                    +STB @sp
                    +JSUB spush
                    +STX @sp
                    +JSUB spush

                    TIX #0          . get first nible
                    TIX #0
                    LDCH b_cmd, X   . get first ascii nible
                    SUB #0x30       . de_ascii == first - '0'
                    MUL #16
                    STCH cmd_device

                    TIX #0
                    LDCH b_cmd, X   . get second nible
                    SUB #0x30       . de_ascii
                    RMO A, B

                    LDCH cmd_device
                    ADDR B, A
                    STCH cmd_device

cmd_process_devicee +JSUB spop
                    +LDX @sp
                    +JSUB spop
                    +LDB @sp
                    +JSUB spop
                    +LDA @sp
                    +JSUB spop
                    +LDL @sp
                    RSUB

cmd_device     RESB 1
. -------------------------------------------------------------------------------------------------

. =======================================================

vinit   +STL @sp
        +JSUB spush

        JSUB draw_btm_bar           . draw bottom bar

        LDA #0xFF                   . draw starter screen
        STCH cmd_device
        LDA #cmd_e_cb
        +JSUB map_ch

vinit_loop  CLEAR A         . wait for character
            +LDCH @input
            +COMP wnull     . if nothing (null) => try again
            JEQ vinit_loop
            +JSUB ioinit    . else reset screen and let the flow continue

            +JSUB spop
            +LDL @sp
            RSUB

. Registers / Buffers
. =======================================================
r_manip     RESB r_size . manipulation register (y, d, p)
r_general   RESB r_size . general register
r_size      EQU 300

b_cmd       RESB b_size . command mode buffer
b_size      EQU 300
. =======================================================
. -------------------------------------------------------

        END v
