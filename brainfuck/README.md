# SicDemos
This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

## Brainfuck Language Interpreter
Executes an arbitrary program written in [Brainfuck language](https://en.wikipedia.org/wiki/Brainfuck). Upon starting, program waits for input to standard input (console input). **Paste or type the program as a single line, ending the entry sequence by pressing `Enter`**. Interpreter will read and execute the program.  When/if Brainfuck program finishes, interpreter will wait for next program to be entered. 

Tape size and instruction stack size are limited to 400 Bytes each (400 cells and 400 separate instructions). For more, resize `stackstart` and `tape#` variables. 

**Program has been observed having trouble ending input on UNIX/UNIX-like systems and some IDEs. If you have trouble using the program, try changing the value in line 144 from 0x0D (carriage return) to 0x0A (new line).**

* Source code: brainfuck.asm
* Frequency: Depending on program, generally recommended at least 10000 Hz (10 kHz)
* Author: [Tine Šubic](https://github.com/MikroMan)/MikroMan, 2016

### Example Brainfuck Programs

**Print Hello World! to stdout:**  
`++++++++++[>+>+++>+++++++>++++++++++<<<<-]>>>++.>+.+++++++..+++.<<++.>+++++++++++++++.>.+++.------.--------.<<+.<.`

**Print x^2 for X in range [0,100] to stdout:**    
`++++[>+++++<-]>[<+++++>-]+<+[>[>+>+<<-]++>>[<<+>>-]>>>[-]++>[-]+>>>+[[-]++++++>>>]<<<[[<++++++++<++>>-]+<.<[>----<-]<]<<[>>>>>[>>>[-]+++++++++<[>-<-]+++++++++>[-[<->-]+[<<<]]<[>+<-]>]<<-]<<-]`

**Print powers of two to stdout:**
`>++++++++++>>+<+[[+++++[>++++++++<-]>.<++++++[>--------<-]+<<]>.>[->[<++>-[<++>-[<++>-[<++>-[<-------->>[-]++<-[<++>-]]]]]]<[>+<-]+>>]<<]`

**Copy standard input to standard output (cat):**  
`,[.,]`

**Print ASCII charset to stdout:**  
`.+[.+]`

**Print Sierpinski triangle to stdout:**  
`>++++[<++++++++>-]>++++++++[>++++<-]>>++>>>+>>>+<<<<<<<<<<[-[->+<]>[-<+>>>.<<]>>>[[->++++++++[>++++<-]>.<<[->+<]+>[->++++++++++<<+>]>.[-]>]]+<<<[-[->+<]+>[-<+>>>-[->+<]++>[-<->]<<<]<<<<]++++++++++.+++.[-]<]+++++`
