. import with: EXTREF ioinit,cl,cr,cu,cd,crsrnl,ctop,cbtm,cfirst,clast,cprev,rch,pch,map_ch,map_ln,input,shiftr,shiftl,shiftd,drawnp
. import ASCII ch with: EXTREF chnull,chesc,chent,chcrsr,chspac,chback,chshft,wnull,wesc,went,wcrsr,wspace,wback,wshift
. import hidden with: EXTREF output,cursor,scrcol,scrrow
io      START 0
        . uncomment for hidden API
        . EXTDEF output,cursor,scrcol,scrrow
        EXTDEF ioinit,cl,cr,cu,cd,crsrnl,ctop,cbtm,cfirst,clast,cprev,rch,pch,map_ch,map_ln,input,shiftr,shiftl,shiftd,drawnp
        EXTDEF chnull,chesc,chent,chcrsr,chspac,chback,chshft,wnull,wesc,went,wcrsr,wspace,wback,wshift
        EXTREF spush,spop,sp

. IO interface
. -------------------------------------------------------

. init IO - inits screen (clears screen and resets cursor)
ioinit      +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            LDA output   . reset cursor
            STA cursor

            LDA #ioinit_cb
            JSUB map_ch
            JSUB remv_crsr

            LDA output   . reset cursor
            STA cursor
            JSUB draw_crsr

            +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

. callback for map_ch. Writes #0x00 to cell
ioinit_cb   +STL @sp
            +JSUB spush

            LDCH #0x00
            JSUB pch

            +JSUB spop
            +LDL @sp
            RSUB

. Basic movement
. all return if can't move because of edge (SOR, EOR, SOC, EOC) in A. {0=EOL, 1=no EOL}
. =======================================================
. move cursor left
cl          +STL @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            LDA cursor  . if SOC (first column) => end
            SUB output
            LDB scrcol
            JSUB mod
            COMP #0
            JEQ clend

            JSUB remv_crsr

            LDA cursor  . move cursor left
            SUB #1
            STA cursor

            JSUB draw_crsr

            LDA #1
clend       +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDL @sp
            RSUB

. move cursor right
cr          +STL @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            LDA cursor  . if EOC (last column) => end
            SUB output
            ADD #1
            LDB scrcol
            JSUB mod
            COMP #0
            JEQ crend

            JSUB remv_crsr

            LDA cursor  . move cursor right
            ADD #1
            STA cursor

            JSUB draw_crsr

            LDA #1
crend       +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDL @sp
            RSUB

. move cursor up
cu          +STL @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            LDA cursor  . if SOR (first row) => end
            SUB output
            DIV scrcol
            COMP #0
            JEQ cuend

            JSUB remv_crsr

            LDA cursor  . move cursor up
            SUB scrcol
            STA cursor

            JSUB draw_crsr

            LDA #1
cuend       +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDL @sp
            RSUB

. move cursor down
cd          +STL @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            LDA cursor  . if EOR (last row) => end
            SUB output
            DIV scrcol
            ADD #1
            COMP scrrow
            LDA #0
            JEQ cdend

            JSUB remv_crsr

            LDA cursor  . move cursor down
            ADD scrcol
            STA cursor

            JSUB draw_crsr

            LDA #1
cdend       +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDL @sp
            RSUB

. cursor to new line
crsrnl      +STL @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            LDA cursor  . if EOR (last row) => end
            SUB output
            DIV scrcol
            ADD #1
            COMP scrrow
            LDA #0
            JEQ cnlend
    
            JSUB remv_crsr
    
            LDA cursor  . move cursor to new line
            SUB output
            DIV scrcol
            ADD #1
            MUL scrcol
            ADD output
            STA cursor
    
            JSUB draw_crsr
    
            LDA #1
cnlend      +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDL @sp
            RSUB
. =======================================================

. Other movement
. =======================================================
. cursor to top left
ctop        +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            JSUB remv_crsr

            LDA output
            STA cursor

            JSUB draw_crsr

ctop_end    +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

. cursor to bottom left
cbtm        +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            JSUB remv_crsr

            . scrrow * scrcol - 1 + output
            LDA scrrow
            MUL scrcol
            SUB #1
            ADD output
            STA cursor

            JSUB draw_crsr

cbtm_end    +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

. cursor to first in line
cfirst      +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            JSUB remv_crsr

            . res1 = (cursor - output) / scrcol     <- get rows
            . res = res1 * scrcol + output          <- get first column in row
            LDA cursor
            SUB output
            DIV scrcol
            MUL scrcol
            ADD output
            STA cursor

            JSUB draw_crsr

cfirst_end  +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

. cursor to first in line
clast       +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush
            +STB @sp
            +JSUB spush

            JSUB remv_crsr

            . res1 = (cursor - output) / scrcol     <- get rows
            . res2 = (res1 + 1)                     <- get next row
            . res3 = res2 * scrcol - 1 + output     <- get last character in origin row
            LDA cursor
            SUB output
            DIV scrcol
            ADD #1
            MUL scrcol
            SUB #1
            ADD output
            STA cursor

            JSUB draw_crsr

clast_end   +JSUB spop
            +LDB @sp
            +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

cprev       +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush

            LDA crsrprev        . load the cursor position and put it on the stack (because remv_crsr messes with A)
            +STA @sp
            +JSUB spush

            JSUB remv_crsr

            +JSUB spop          . get the cursor position and move cursor there
            +LDA @sp
            STA cursor

            JSUB draw_crsr


cprev_end   +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

. remove cursor indicator
. overwrites A
. overwrites B
remv_crsr   +STL @sp
            +JSUB spush

            LDA cursor      . save current cursor position
            STA crsrprev

            LDA cursor      . move cursor to indicator position
            ADD scrcol
            STA cursor

            LDCH chprev     . get previous character
            JSUB pch

            LDA cursor      . move cursor back
            SUB scrcol
            STA cursor

            +JSUB spop
            +LDL @sp
            RSUB

. draw cursor indicator
. overwrites A
. overwrites B
draw_crsr   +STL @sp
            +JSUB spush

            LDA cursor      . move cursor to indicator position
            ADD scrcol
            STA cursor

            JSUB rch        . load current character and save it
            STCH chprev

            LDCH chcrsr  . get cursor indicator character
            JSUB pch

            LDA cursor      . move cursor back
            SUB scrcol
            STA cursor

            +JSUB spop
            +LDL @sp
            RSUB

. (A % B) = A - (A / B) * B
mod         +STL @sp
            +JSUB spush

            +STA @sp
            +JSUB spush
            DIVR B, A
            MULR A, B
            +JSUB spop
            +LDA @sp
            SUBR B, A

            +JSUB spop
            +LDL @sp
            RSUB
. =======================================================

. Other
. =======================================================
. read character at cursor
. result in A (last BYTE)
rch     +STL @sp
        +JSUB spush

        LDCH @cursor

        +JSUB spop
        +LDL @sp
        RSUB

. print character to cursor
pch     +STL @sp
        +JSUB spush

        STCH @cursor

        +JSUB spop
        +LDL @sp
        RSUB

. execute a callback for each cell on screen
. params:
.   callback in register A
. while (!= 0)
.    while (!= 0)
.        callback();
.        cr();
.    crsrnl();
map_ch      +STL @sp
            +JSUB spush

            STA map_cb

            JSUB ctop

            LDA #1
map_chl1    COMP #0
            JEQ map_chend

map_chl2    COMP #0
            JEQ map_chl1end

            JSUB @map_cb
            JSUB cr
            J map_chl2

map_chl1end JSUB crsrnl
            J map_chl1

map_chend   JSUB ctop
            +JSUB spop
            +LDL @sp
            RSUB

. execute a callback for each cell in line
. params:
.   callback in register A
. i = first
. while (i <= last)
.     callback();
.     cr()
map_ln      +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush

            STA map_cb

            JSUB cfirst     . i = first
map_lnloop  JSUB @map_cb    . do callback() on i

            JSUB cr
            COMP #0         . if EOF (EOR) => end
            JEQ map_lnend

            J map_lnloop    . else i++

map_lnend   +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

map_cb      RESW 1
map_og_crsr RESW 1

. shift characters right in line from cursor (including the cursor character)
. does NOT move the cursor
. writes chspac=0x20 to empty slot
. 1234567 -> 123 4567
.    ^          ^
.               0x20
shiftr      +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush

            CLEAR A         . store cursor position
            LDA cursor
            STA shift_og_crsr

shiftr_l1   JSUB cr         . find EOL (move right until wnull or cr gives EOL)
            COMP #0
            JEQ shiftr_l2
            CLEAR A
            LDCH @cursor
            COMP #0x00
            JEQ shiftr_l2
            J shiftr_l1

shiftr_l2   CLEAR A         . do shift right (cleft, read, cright, print, cleft)
            LDA cursor      . if current cursor == OG cursor => end
            COMP shift_og_crsr
            JEQ shiftr_end

            JSUB cl         . cleft
            COMP #0
            JEQ shiftr_end

            CLEAR A         . read (store char on stack)
            LDCH @cursor
            STCH shift_ch

            JSUB cr         . cright

            CLEAR A         . print
            LDCH shift_ch
            JSUB pch

            JSUB cl         . cleft
            COMP #0
            JEQ shiftr_end

            J shiftr_l2

shiftr_end  JSUB remv_crsr
            LDA shift_og_crsr
            STA cursor
            JSUB draw_crsr
            CLEAR A
            LDCH chspac
            JSUB pch

            +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

. shift characters left in line from cursor (including the cursor character)
. does NOT move the cursor
. 1234567 -> 124567
.    ^          ^
shiftl      +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush

            CLEAR A         . store cursor position
            LDA cursor
            STA shift_og_crsr

shiftl_l1   CLEAR A         . do shift left (read, cleft, print, cright, cright). Stop on EOL or 2nd 0x00
            LDCH @cursor    . read
            STCH shift_ch

            JSUB cl         . cleft (no shift if at start: 123 -> 123)
            COMP #0         .                              ^      ^
            JEQ shiftl_end

            CLEAR A         . print
            LDCH shift_ch
            JSUB pch

            JSUB cr         . cright (if second 0x00 end)
            COMP #0
            JEQ shiftl_end
            CLEAR A
            LDCH @cursor
            COMP #0x00
            JEQ shiftl_end

            JSUB cr         . cright
            COMP #0
            JEQ shiftl_end

            J shiftl_l1

shiftl_end  JSUB remv_crsr
            LDA shift_og_crsr
            STA cursor
            JSUB draw_crsr

            +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

. -------------------------------------------------------------------------------------------------
. shift lines down
. does NOT move the cursor
shiftd      +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush
            +STX @sp
            +JSUB spush

            CLEAR X

            CLEAR A         . store cursor position
            LDA cursor
            STA shift_og_crsr

shiftd_l1   +JSUB crsrnl    . find null line
            COMP #0         . if EOF => overwrite last line
            JEQ shiftd_l2

            +JSUB rch       . if null line => go to loop2
            COMP wnull
            JEQ shiftd_l2

            TIX #0
            J shiftd_l1

shiftd_l2   LDA #0          . shift all lines down from starting line to null line
            COMPR A, X
            JEQ shiftd_end

            JSUB cu         . go to above line
            LDA #shiftd_cb  . do the callback for each cell
            JSUB map_ln

            LDA #1
            SUBR A, X
            J shiftd_l2

shiftd_end  JSUB remv_crsr
            LDA shift_og_crsr
            STA cursor
            JSUB draw_crsr

            +JSUB spop
            +LDX @sp
            +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB

. callback for map_ln. Copies each character into the bottom line and deletes it
shiftd_cb   +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush

            CLEAR A
            JSUB rch
            STCH chprev       . store character below cursor indicator

            LDCH chnull       . delete the character
            JSUB pch

            +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB
. -------------------------------------------------------------------------------------------------

shift_ch        RESB 1
shift_og_crsr   RESW 1

. draw to non operational cell
. params:
.   row number in A (0 == firt non operational line - would be 24th line in case of 23 operational lines, 1 == 25th line, ...)
.   col number in B
.   character in T
. return #0 on error:
.   - row out of bounds,
.   - col out of bounds,
. return #1 on good
drawnp      +STL @sp
            +JSUB spush

            ADD scrrow      . get the real line number
            COMP scrrowf    . if rows out of bounds => end
            JGT drawnp_err
            STA draw_np_row

            RMO B, A
            COMP scrcol     . if cols out of bounds => end
            JEQ drawnp_err
            JGT drawnp_err
            STA draw_np_col

            LDA draw_np_row . get the cell
            MUL scrcol
            ADD draw_np_col
            ADD output
            STA draw_np_loc

            RMO T, A
            STCH @draw_np_loc
            LDA #1
            J draw_npend

drawnp_err  LDA #0
draw_npend  +JSUB spop
            +LDL @sp
            RSUB

draw_np_row RESW 1
draw_np_col RESW 1
draw_np_loc RESW 1
. =======================================================


input   WORD 0xc000 . addr of keyboard

output  WORD 0xb800 . addr of screen
cursor  WORD 0xb800 . addr of cursor
scrcol  WORD 80     . screen number of columns
scrrow  WORD 23     . screen number of operational rows
scrrowf WORD 25     . screen number of rows

chprev      RESB 1      . runtime variable that holds the previous character, the cursor indicator replaced
crsrprev    RESW 1      . runtime variable that holds the previous cursor position

chnull      BYTE 0x00   . hex of the null character
chesc       BYTE 0x1B   . hex of the escape character
chent       BYTE 0x0A   . hex of the enter character
chcrsr      BYTE 0x5E   . hex of the cursor indicator character
chspac      BYTE 0x20   . hex of the space character
chback      BYTE 0x08   . hex of the backspace character
chshft      WORD 0xFF   . hex of shift character

wnull       WORD 0x00   . hex of the null character (3 BYTES)
wesc        WORD 0x1B   . hex of the escape character (3 BYTES)
went        WORD 0x0A   . hex of the enter character (3 BYTES)
wcrsr       WORD 0x5E   . hex of the cursor indicator character (3 BYTES)
wspace      WORD 0x20   . hex of the space character (3 BYTES)
wback       WORD 0x08   . hex of the backspace character (3 BYTES)
wshift      WORD 0xFF   . hex of shift character (3 BYTES)
. -------------------------------------------------------

        END io
