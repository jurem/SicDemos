. ================================================================
. Caesars cipher decryption machine
. ================================================================
.
. Author: Andrej Gorjan
. Requirements:
.     - Device AA.dev that contains ciphertext. This ciphertext is produced
.       with a Caesars cipher (many tools online)
.     - Textual screen (at 0xB800)
.     - Keyboard (at 0xC000)
. Usage:
. The program will display the first line of the ciphertex decrypted with
. an offset of 0, then 1, 2 and so on. The user is expexted to enter 'n'
. when the decryption is wrong and 'y' when it is correct. The program will
. then decrypt the remainder of the message.

subs        START       0
            . Clear X. It will hold the offset to decrypt with
            CLEAR       X
            . Initialize the stack
            JSUB        stackinit
            . Read the first line of the ciphertext
            JSUB        rdLine
            . Show the 'decrypted' line and wait for the users response
loop        JSUB        showLine
read        JSUB        readKB
            COMP        #0
            JEQ         read
            . When the user presses 'y', we found the right offset
            COMP        #89
            JEQ         cont
            . Otherwise print a newline, increase the offset and try again
            JSUB        printNL
            JSUB        clearKB
            TIX         #26
            JLT         loop

            . X now contains the proper offset, finish decrypting the rest of the lines
            . Print a newline
cont        JSUB        printNL
            . Read the next line from the device
            JSUB        rdLine
            . Decrypt and display the line
            JSUB        showLine
            J           cont

            . Finish execution
halt        J           halt

. ================================================================
. Display a line from the line buffer, shifted by the value in X 
. ================================================================
showLine    . store registers on the stack
            STL         @stackptr
            JSUB        stackpush
            STX         @stackptr
            JSUB        stackpush
            STS         @stackptr
            JSUB        stackpush

            . Temporarily store the offset value in S
            CLEAR       S
            ADDR        X,S
            CLEAR       X

            . Loop to read characters from the line buffer, shift
            . them and display them on the screen
rc          CLEAR       A
            LDCH        line,X

            . #10 is the newline character, which ends showLine
            COMP        #10
            JEQ         endSL

            . The shift function shifts the character in the lower most
            . byte of A by the number stored in S
            JSUB        shift

            . Print the shifted character to the screen
            JSUB        printch
            TIX         #0
            J           rc

            . Restore the value of X and return from the loop
endSL       JSUB        stackpop
            LDS         @stackptr
            JSUB        stackpop
            LDX         @stackptr
            JSUB        stackpop
            LDL         @stackptr
            RSUB

. ================================================================
. Read from the keyboard
. ================================================================
readKB      CLEAR       A
            LDCH        @keyboard
            RSUB

. ================================================================
. Clear the keyboard memory
. ================================================================
clearKB     CLEAR       A
            STCH        @keyboard
            RSUB

. ================================================================
. Read a character from the input device into register A
. ================================================================
readch      TD          inputDev
            JEQ         readch
            CLEAR       A
            RD          inputDev
            . Test if EOF
            COMP        #0
            JEQ         halt
            RSUB

. ================================================================
. Convert the character to lowercase
. ================================================================
            . 'A' in ASCII is 65
            . 'Z' in ASCII is 90
            . We are only concerned with these characters
            . Do not shift less than 'A'
lower       COMP        #65
            JLT         noConv
            . Do not shift more than 'Z'
            COMP        #90
            JGT         noConv
            J           convLower
noConv      RSUB
            . In ASCII, the lowercase characters are 32 places after the
            . upper case ones
convLower   ADD         #32
            RSUB

. ================================================================
. Shift the character by the value in S
. ================================================================
            . Shifting is a modulo 26 operation (if we shift Z by 1
            . to the right, it becomes A). We also don't want to shift
            . miscelaneous symbols, just letters.
            . Do not shift less than 'A'
shift       COMP        #65
            JLT         noShift
            . If the value is larger than 'Z', it may be an non usable
            . character or the characters from 'a' to 'z'
            COMP        #90
            JGT         shiftLower

            . Shift uppercase letters
            ADDR        S,A
            COMP        #90
            JGT         wrap

            . If less than 'a' or more than 'z', don's shift,
            . otherwise do shift
shiftLower  COMP        #97
            JLT         noShift
            COMP        #122
            JGT         noShift

            . Shift and check for overflow, then return
            ADDR        S,A
            COMP        #122
            JGT         wrap

noShift     RSUB
wrap        SUB         #26
            RSUB

. ================================================================
. STACK OPERATIONS
. ================================================================
            . Push to the stack
stackpush   STA         subA
            LDA         stackptr
            ADD         #3
            STA         stackptr
            LDA         subA
            RSUB

            . Pop from the stack
stackpop    STA         subA
            LDA         stackptr
            SUB         #3
            STA         stackptr
            LDA         subA
            RSUB

            . Initialize the stack
stackinit   STA         subA
            LDA         #stack
            STA         stackptr
            LDA         subA
            RSUB
subA        RESW        1

. ================================================================
. Read line into the buffer 'line'
. ================================================================
rdLine      STL         @stackptr
            JSUB        stackpush
            STX         @stackptr
            JSUB        stackpush

            . Clear the X register, which we will use to hold the offset
            . in the line buffer. While working, the character is held in
            . the register A
            CLEAR       X
            . Read a character from the device
rdl         JSUB        readch
            . Convert the character to lowercase
            . JSUB        lower
            . Store the character in the line buffer
            STCH        line,X
            TIX         #0
            . Check if the character was a newline, which means that we
            . read the whole line from the device. If so, return from
            . rdLine
            COMP        #10
            JEQ         endRL
            J           rdl

            . Restore the register values
endRL       JSUB        stackpop
            LDX         @stackptr
            JSUB        stackpop
            LDL         @stackptr
            RSUB

. ================================================================
. Print a character at scrX, scrY
. ================================================================
            . sxrX and sxrY represent the 'coordinates' on the screen
            . where the character should be written.
printch     STL         @stackptr
            JSUB        stackpush
            STS         @stackptr
            JSUB        stackpush

            . Temporarily store the character in register S
            CLEAR       S
            ADDR        A,S

            . Calculate the correct offset on the screen based on
            . scrX and scrY
            LDA         scrY
            MUL         #80
            ADD         screen
            ADD         scrX
            . Update the screen pointer
            STA         screenptr

            . Restore the character to register A
            CLEAR       A
            ADDR        S,A

            . Write the character to the screen at the location
            . specified by screenptr
            STCH        @screenptr

            . Increment scrX, as we have written a new character
            LDA         scrX
            ADD         #1
            . Check if we reached the end of the screen (column 80)
            COMP        #80
            . If we have, we must change scrX and scrY to jump in the next line
            JEQ         prNL
            . Store the updated scrX
            STA         scrX
            J           exitprch

            . If we reached the end of the screen. Change scrX and scrY to
            . go into the next line
prNL        JSUB        printNL

exitprch    JSUB        stackpop
            LDS         @stackptr
            JSUB        stackpop
            LDL         @stackptr
            
            RSUB     

. ================================================================
. Print a newline on the screen
. ================================================================
printNL     STL         @stackptr
            JSUB        stackpush
            STA         @stackptr
            JSUB        stackpush

            . A newline is just an incrementation of scrY
            . and reseting scrX to 0
            LDA         scrY
            ADD         #1
            COMP        #25
            JEQ	        cls
            J           clsSkip

cls         JSUB        clearScreen

clsSkip     STA         scrY
            CLEAR       A
            STA         scrX

            JSUB        stackpop
            LDA         @stackptr
            JSUB        stackpop
            LDL         @stackptr
            RSUB

. Clear the screen and reset scrX and scrY
clearScreen STL         @stackptr
            JSUB        stackpush
            STX         @stackptr
            JSUB        stackpush

            CLEAR       A
            STA         scrY
            STA         scrX

            CLEAR       X
contClear   CLEAR       A
            JSUB        printch
            TIX         #1999
            JEQ         endClear
            J	        contClear

endClear    LDA         screenptr
            ADD         #1
            STA         screenptr
            CLEAR       A
            STCH        @screenptr
            CLEAR       A
            STA         scrX
            STA         scrY
            JSUB        stackpop
            LDX         @stackptr
            JSUB        stackpop
            LDL         @stackptr
            RSUB


. ================================================================
. Data
. ================================================================
            . Device to read the ciphertext from
inputDev    BYTE        X'AA'
            . Location of the buffer for the screen
screen      WORD        0x0B800
            . The screenpointer, holds the address where new characters
            . should be written in the screen buffer
screenptr   RESW        1
            . Holds the column of the screen where we should write
scrX        WORD        0
            . Holds the line of the screen where we should write
scrY        WORD        0
            . Location of the keyboard buffer
keyboard    WORD        0xC000
            . Line buffer to hold the line of ciphertext while operations
            . are performed on it
line        RESB        1024
            . Stackpointer and stack
stackptr    RESW        1
stack       RESW        1024