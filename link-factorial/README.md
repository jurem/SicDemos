# SicDemos
This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

## Linker Example: factorial

The factorial linker example calculates factorial for numbers 1 to 10 and prints them out. The program consists of 5 parts:
 
 1. main.asm: contains a loop from 1 to 10, that calls 'fact' subroutine
 2. fact.asm: contains a subroutine for calculating a factorial. The algorithm is recursive and uses stack operations
 3. print.asm or print2.asm: contains a subroutine for displaying the result. The first one (print) writes to stdout, the second one (print2) writes to textual screen. Both of them define the same external symbol "print", so either one (but not both) can be used for this example.
 4. stack.asm: contains stack operations (push, pop, stinit = stack initialization)
 5. ending.asm: marks the end of this program. This file should be at the end, because main will initialize the stack there.

The .asm files should be assembled into .obj files and then linked in the order they are listed above. They can be linked with the following command :
 
   'java -cp sictools.jar sic.Link -o linked.obj main.obj fact.obj print.obj stack.obj ending.obj'

 or by selecting the files in graphical linker interface.
