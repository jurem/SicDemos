. THIS IS A DEMO OF BFS TRAVERSAL COMBINED WITH BUBBLE SORT
. THE DEFAULT SOURCE VERTEX IS 0
. THE MAXIMUM NUMBER OF VERTEX IS 10
. ADDRESS OF OUTPUT DEVICE IS X'01'

BFS             START           0
                JSUB            SINIT           .INITIALIZE STACK
                JSUB            ARRINIT         .INITIALIZE ARRAY FOR BFS RESULT
                JSUB            ECHOLINE
                LDA             #STR1
                JSUB            ECHOSTR         .PRINT STR1
                JSUB            ECHONL          .PRINT NEW LINE
                JSUB            ECHOLINE
                JSUB            ECHONUM         .PRINT VERTICES AND EDGES
                JSUB            ECHOLINE
                LDA             #STR2
                JSUB            ECHOSTR         .PRINT STR2
                JSUB            ECHONL          .PRINT NEW LINE
                JSUB            ECHOLINE
                LDX             SOURCE          .STARTING SOURCE
                LDA             SOURCE              
                LDS             TRUE
                JSUB            ADDQ

BLOOP	        LDA             QLEN
	            COMP            ZERO
	            JEQ             ENDING          .IF QUEUE IS EMPTY, HALT
	            JSUB            DELQ            .ELSE GET ELEMENT FROM QUEUE
                JSUB            PUTARR          .INSERT VERTEX TO ARRAY FOR SORTING
	            JSUB            PRINT	
	            JSUB            JCALC           .CALCULATE JUMP COUNTER
                LDA             CURR
                MUL             STEP            .MULTIPLY 3 TO GET CORRECT OFFSET
                RMO             A, X            .MOVE VALUE IN A TO X
                LDA             EDGE, X
                MUL             STEP
                STA             FINISH          .LENGTH OF EDGES OF SPECIFIC VERTEX
                COMP            ZERO
                JEQ             BLOOP           .IF ZERO, GO TO BLOOP
                LDA             JUMPC
                MUL             STEP
                RMO             A, X            .STORE START LOCATION OFFSET TO X
                LDA             ZERO
                STA             INDEX           .CLAER INDEX

OLOOP	        LDA             LIST, X         .GET THE CONNECTED EDGE WITH CURRENT VERTEX
	            STX             TEMPX           .STORE INDEX FOR RECOVERY FOR NEXT LOOP
	            MUL             STEP            .MULTIPLY 3 TO GET OFFSET FOR CHECKING BOOLEAN IN VISITED
	            RMO             A, X            .MOVE VALUE IN A TO X
	            DIV             STEP            .RECOVER THE VALUE OF A
	            LDT             VISITED, X      .GET BOOLEAN OF CURRENT VERTEX
	            LDS             TRUE            .LOAD THE TRUE INTO S
	            COMPR           T, S
	            JLT             ADDQ            .IF NOT TRUE, SET TRUE AND PUSH TO QUEUE
BP1	            LDA             INDEX
	            ADD             STEP
	            STA             INDEX           .UPDATE NEXT INDEX POINTER
                LDA             TEMPX
                ADD             STEP
                STA             TEMPX           .UPDATE THE OFFSET OF X
	            LDX             TEMPX           .LOAD NEW OFFSET TO X
                LDA             INDEX           .LOAD INDEX FOR COMPARISON
	            COMP            FINISH
	            JLT             OLOOP           .GO TO NEXT ITERATION IF HAVEN'T LOOPED THOROUGHLY
	            J               BLOOP	        .ELSE ITERATE THE NEXT QUEUE ELEMENT

ENDING          JSUB            ECHONL
                JSUB            ECHOLINE
                LDA             #STR3
                JSUB            ECHOSTR         .PRINT STR3
                JSUB            ECHONL 
                JSUB            ECHOLINE
                LDA             #STR5
                JSUB            ECHOSTR         .PRINT STR5
                JSUB            ECHONL
                JSUB            ECHOLINE
                JSUB            BSORT           .START BUBBLE SORT
                JSUB            ECHOLINE
                LDA             #STR6
                JSUB            ECHOSTR         .PRINT STR6
                JSUB            ECHONL          
                JSUB            ECHOLINE
halt            J               halt

                END             BFS

ADDQ	        STS             VISITED, X      .SET VISITED TRUE TO CURRENT VERTEX
	            LDX             REAR            .LOAD REAR INTO X
	            STA             QUEUE, X        .PUSH THE VERTEX INTO QUEUE
	            LDA             REAR
	            ADD             STEP
	            STA             REAR            .REAR + 3
	            LDA             QLEN
	            ADD             #1
	            STA             QLEN            .SIZE OF QUEUE + 1
                LDA             ISINIT
                COMP            ZERO            .IF ISINIT = 0, MEANS FIRST TIME TO PUSH TO QUEUE
                JEQ             RET1            .ELSE GO TO RET1
	            J               BP1             .BACK TO BACKPOINT 1 FOR NEXT ITERATION
RET1            LDA             TRUE
                STA             ISINIT
                RSUB                

PRINT	        TD              OUTPUT          .TEST OUTPUT
	            JEQ             PRINT
	            LDA             CURR
	            ADD             GOTO            .ADD ASCII CODE OF 0
	            WD              OUTPUT
	            LDA             HASV
	            COMP            #NUMVER         .COMPARE TO NUMBER OF VERTEX
	            JLT             SUBPRT          .IF NOT FINISH VISIT, PRINT ' -> '
RET2	        RSUB 	                        .ELSE RSUB

SUBPRT	        STL             @STACKPTR       .SUBPRINT ROUTINE
                JSUB            PUSH            .PUSH L
                LDA             #DRA
                JSUB            ECHOSTR
                JSUB            POP             .POP L
                LDL             @STACKPTR       .RESTORE L FROM STACK TO RETURN FROM SUBPRINT ROUTINE
	            J               RET2            .GET READY TO RSUB

DELQ            LDX             FRONT
	            LDA             QUEUE, X
	            STA             CURR            .CURR = QUEUE[FRONT]
	            LDA             HASV            .LOAD HASVISITED
	            ADD             #1
	            STA             HASV            .UPDATE NUMBER OF VISITED VERTEX
	            LDA             FRONT
	            ADD             STEP
	            STA             FRONT           .FRONT + 3
	            LDA             QLEN
	            SUB             #1
	            STA             QLEN            .SIZE OF QUEUE - 1
                RSUB

JCALC	        CLEAR           X
	            STX             JINDEX          .clear JINDEX
	            STX             JUMPC           .clear JUMPC
	            STX             JCOUNT          .clear JCOUNT
                LDA             HASV
                COMP            NUMVER
                JEQ             RET3
	            LDA             CURR
	            COMP            ZERO
	            JGT             JLOOP           .IF VERTEX IS 0, NO NEED FOR CALCULATION
RET3	        RSUB

JLOOP	        LDA             JUMPC           .LOAD JUMP COUNTER
	            LDX             JINDEX          .LOAD JINDEX FOR INDEXING
	            LDT             EDGE, X         .GET NUMBER OF EDGE OF EACH VERTEX
	            ADDR            T, A            .ACCUMULATE IT
	            STA             JUMPC           .ADD TO JUMP COUNTER
	            LDA             JINDEX
	            ADD             STEP
	            STA             JINDEX          .JINDEX + 3 FOR NEXT INDEXING
	            LDA             JCOUNT
	            ADD             #1
	            STA             JCOUNT          .UPDATE THE NUMBER OF ITERATION
	            COMP            CURR
	            JLT             JLOOP           .CONTINUE LOOP IF HAVEN'T REACHED CURR
	            J               RET3	        .ELSE READY FOR RSUB

ECHONUM         CLEAR           X
                LDA             #LIST
                STA             Addr     
TEST1           TD              OUTPUT          .TEST OUTPUT
                JEQ             TEST1
EOLOOP          LDX             EINDEX          .EDGE OUTER LOOP
                LDA             EDGE, X
                STA             EDGENUM
                COMP            ZERO
                JEQ             INCREASE        .IF ZERO, MEANS NO EDGE, GO TO INCREASE
EILOOP          LDA             VERTEX          .EDGE INNER LOOP
                ADD             GOTO            .ADD ASCII CODE OF 0
                WD              OUTPUT
                LDA             #DRA
                STL             @STACKPTR
                JSUB            ECHOSTR         .PRINT DASH + RIGHT ARROW
                LDL             @STACKPTR
                LDA             @Addr
                ADD             GOTO            .ADD ASCII CODE OF 0
                WD              OUTPUT          .PRINT THE VERTEX NUMBER
                LDA             Addr
                ADD             STEP
                STA             Addr            .UPDATE NEXT INDEX POINTER
                STL             @STACKPTR
                JSUB            ECHONL
                LDL             @STACKPTR
                LDA             LOOPCOUNT
                ADD             #1
                STA             LOOPCOUNT       .UPDATE THE NUMBER OF ITERATION
                COMP            EDGENUM
                JLT             EILOOP          .CONTINUE LOOP IF HAVEN'T REACHED EDGENUM

INCREASE        LDA             VERTEX
                ADD             #1
                STA             VERTEX          .INCREASE VERTEX BY 1
                LDA             ZERO
                STA             LOOPCOUNT       .CLEAR LOOP COUNTER
                LDA             EINDEX
                ADD             STEP
                STA             EINDEX          .EINDEX + 3 FOR NEXT INDEXING
                COMP            #EDGELEN
                JLT             EOLOOP          .CONTINUE LOOP IF HAVEN'T REACHED EDGELEN
                RSUB

ECHONL          LDA             NEWLINE
TEST2           TD              OUTPUT
                JEQ             TEST2                      
                WD              OUTPUT          .PRINT NEW LINE
                RSUB

ECHOSTR         STA             Addr2
CHAR            LDCH            @Addr2
                AND             #255            .GET THE 8 RIGHT MOST BITS
                COMP            ZERO            .REACH END OF STRING IF ZERO
                JEQ             RET4            
TEST3           TD              OUTPUT
                JEQ             TEST3
                WD              OUTPUT
                LDA             Addr2
                ADD             #1              .ADD 1 FOR NEXT BYTE
                STA             Addr2
                J               CHAR
RET4            RSUB

ECHOARR         LDA             #ARRAY
                STA             ARRPTR
                LDA             ZERO
                RMO             A, T
TEST4           TD              OUTPUT
                JEQ             TEST4
                LDA             PIPE
                WD              OUTPUT
                LDA             SPACE
                WD              OUTPUT
ARRLOOP         LDA             @ARRPTR
                ADD             GOTO            .ADD ASCII CODE OF 0
                WD              OUTPUT
                LDA             SPACE
                WD              OUTPUT
                LDA             PIPE
                WD              OUTPUT
                LDA             SPACE
                WD              OUTPUT          
                LDA             ARRPTR
                ADD             STEP
                STA             ARRPTR          .UPDATE NEXT INDEX POINTER
                LDA             #1
                ADDR            A, T
                RMO             T, A
                COMP            #ARRSIZE        .COMP TO ARRAY SIZE
                JLT             ARRLOOP         .CONTINUE LOOP IF HAVEN'T REACHED ARRAYSIZE
                RSUB

ECHOLINE        LDA             #STR4
                STL             @STACKPTR
                JSUB            ECHOSTR         .PRINT STR4
                JSUB            ECHONL          .PRINT NEW LINE
                LDL             @STACKPTR
                RSUB

PUTARR          LDA             CURR
                STA             @ARRPTR
                LDA             ARRPTR
                ADD             STEP
                STA             ARRPTR
                RSUB

BSORT           LDT             ZERO
BOLOOP          LDA             ZERO
                STA             SWAPPED         .SET SWAPPED TO FALSE
                RMO             T, A
                COMP            #ARRSIZE
                JEQ             RET4            .CONTINUE LOOP IF HAVEN'T REACHED ARRAYSIZE
                LDS             ZERO
BILOOP          RMO             S, A            
                MUL             STEP
                RMO             A, X
                LDA             ARRAY, X        .ARRAY[i]
                STX             SWAP1           .STORE FIRST SWAPPING INDEX
                STT             TEMPT
                RMO             A, T            .TEMPORARILY STORE FIRST VALUE
                RMO             X, A
                ADD             STEP
                RMO             A, X
                LDA             ARRAY, X        .ARRAY[i + 1]
                STX             SWAP2           .STORE SECOND SWAPPING INDEX
                COMPR           T, A
                JGT             SWAP            .IF T > A, ARRAY[i] > ARRAY[i + 1], SWAP
BP2             STL             @STACKPTR       .BACKPOINT 2
                JSUB            ECHOARR         .PRINT SORTING ARRAY
                JSUB            ECHONL
                LDL             @STACKPTR
                LDA             #1                    
                ADDR            A, S
                LDT             TEMPT
                LDA             #ARRSIZE
                SUB             #1              .SUBTRACT 1 TO A FOR ARRAY SIZE - 1
                SUBR            T, A            .SUBTRACT COUNTER OF BOLOOP
                COMPR           A, S
                JGT             BILOOP
                LDA             #1
                ADDR            A, T
                LDA             SWAPPED
                COMP            ZERO
                JEQ             RET5            .IF NOT SWAPPED, MEANS FINISHED, GO TO RET5
                J               BOLOOP     
RET5            RSUB

SWAP            STS             TEMPS 
                LDX             SWAP1
                LDA             ARRAY, X
                LDX             SWAP2
                LDS             ARRAY, X
                STA             ARRAY, X
                LDX             SWAP1
                STS             ARRAY, X
                LDS             TEMPS
                LDA             TRUE
                STA             SWAPPED         .SET SWAPPED TO TRUE
                J               BP2
        
.Initialize stack
SINIT           LDA             #STACK          
                STA             STACKPTR        .Initialize stack pointer (Address of stack)
                RSUB

.Define push
PUSH            STA             TEMPA           .Push the value in A to stack
                LDA             STACKPTR
                ADD             STEP
                STA             STACKPTR
                LDA             TEMPA
                RSUB

.Define pop
POP             STA             TEMPA
                LDA             STACKPTR
                SUB             STEP
                STA             STACKPTR        .Pop the value in A from stack
                LDA             TEMPA
                RSUB

.Initialize array for BFS result
ARRINIT         LDA             #ARRAY
                STA             ARRPTR
                RSUB

. init edge and vertex
LIST            WORD            1
                WORD            7
                WORD            3
                WORD            8
                WORD            0
                WORD            8
                WORD            2
                WORD            8
                WORD            4
                WORD            6
                WORD            7
                WORD            9
                WORD            0
                WORD            5
                WORD            9
                WORD            2
                WORD            5
                WORD            2
LAST            EQU             *
LENGTH          EQU             LAST-LIST

INDEX           RESW            1

EDGE            WORD            2
                WORD            2
                WORD            2
                WORD            0
                WORD            2
                WORD            2
                WORD            2
                WORD            3
                WORD            2
                WORD            1
ENDEDGE         EQU             *
EDGELEN         EQU             ENDEDGE-EDGE

.Is Init, indicate ADDQ RSUB or J
ISINIT          RESW            1

.ARRAY FOR BFS RESULT TO SORT
ARRAY           RESW            10
ARRPTR          RESW            1
SWAPPED         RESW            1

.ARRAY SIZE
ARRSIZE         EQU             10

.STORE INDEX TO SWAP
SWAP1           RESW            1
SWAP2           RESW            1

. Queue for BFS
QUEUE           RESW            20

. Size of the queue
QLEN            RESW            1

. Pointer for queue
FRONT           RESW            1
REAR            RESW            1

. Current vertex
CURR            RESW            1

. Number of vertices
NUMVER          EQU             10

. Visited list
VISITED         RESW            10  .10 vertices

. Has Visited
HASV            RESW            1

. TRUE Flag
TRUE            WORD            1

. Accumulator of edge to jump to right position of list
JUMPC           RESW            1

. Jump index
JINDEX          RESW            1

. Jump count
JCOUNT          RESW            1

. Finish length
FINISH          RESW            1

. Step of the loop
STEP            WORD            3

. Temporary variable for X, A, T, S
TEMPX           RESW            1
TEMPA           RESW            1
TEMPT           RESW            1
TEMPS           RESW            1

. ZERO
ZERO            WORD            0

. ASCII Code of 0
GOTO            WORD            48

. ASCII Code of space
SPACE           WORD            32

. ASCII Code of pipe
PIPE            WORD            124

. ASCII Code of new line
NEWLINE         WORD            10

.stack and stack pointer
STACK           RESW            20
STACKPTR        RESW            1

.Address for indexing
Addr            RESW            1
Addr2           RESW            1
Addr2END        RESW            1

. DASH + RIGHT ARROW
DRA             BYTE            C' -> '
DRAEND          BYTE            0

. String to print
STR1            BYTE            C'          PRINTING ALL VERTICES AND EDGES          '
STR1END         BYTE            0
STR2            BYTE            C'                START BFS TRAVERSAL                '
STR2END         BYTE            0
STR3            BYTE            C'                 END BFS TRAVERSAL                 '
STR3END         BYTE            0
STR4            BYTE            C'+----+----+----+----+----+----+----+----+----+----+'
STR4END         BYTE            0
STR5            BYTE            C'        IMPLEMENT BUBBLE SORT TO BFS RESULT        '
STR5END         BYTE            0
STR6            BYTE            C'                  END BUBBLE SORT                  '
STR6END         BYTE            0

. Variables for echonum
VERTEX          RESW            1      .VERTEX NUMBER
EINDEX          RESW            1      .INDEX FOR EDGE
EDGENUM         RESW            1      .NUMBER OF EDGES OF SPECIFIC VERTEX
LOOPCOUNT       RESW            1      .COUNTER FOR EDGE LOOP

. SOURCE
SOURCE          WORD            0      .SOURCE VERTEX FOR BFS TRAVERSAL

. OUTPUT DEVICE
OUTPUT          BYTE            X'01'