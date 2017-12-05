# SicDemos
This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

### Towers of Hanoi
Solve the famous Towers of Hanoi puzzle. Register A is set up with the initial number of disks (default 10).
* Source code: hanoi.asm
* Frequency: 10000 Hz = 10 kHz
* Author: Jurij Mihelič

### Game of life
Animate [Conways' Game of Life](https://en.wikipedia.org/wiki/Conway's_Game_of_Life) on the graphical screen. The game is initialized with the glider figure at the top left corner.
* Source code: life.asm
* Graphical screen: 64x64 at A000
* Frequency: 10000000 Hz = 10 MHz
* Author: Jurij Mihelič

### H-tree fractal
Draw an H-tree fractal on the graphical screen.
* Source code: htree.asm
* Graphical screen 333x333 at A000
* Frequency: 10000 Hz = 10 kHz
* Author: Klemen Klanjšček

### Textual draw
Draw on textual screen by typing commands to stdin.
* Source code: drawtext.asm
* Textual screen: 80x25 at 0B800
* Frequency: 10000 Hz = 10 kHz
* Author: Nejc Kišek

### Selection sort
Print trace of the selection sort algorithm.
* Source code: selectsort.asm
* Frequency: 1000 Hz = 1 kHz
* Author: Naum Gjorgjeski

### Link - Factorial
Calculates factorial for numbers from 1 to 10 and writes the result to standard output or on the textual screen. Written in multiple files that have to be assembled and then linked before loading.
If you use print.obj, the results are displayed on stdout. If you use print2.obj instead, they are displayed on textual screen.

Linking order: main.obj, fact.obj, print.obj, stack.obj, ending.obj 
* Source code: .asm files in 'link-factorial/' directory
* Linker commandline flags: -o linked.obj main.obj fact.obj print.obj stack.obj ending.obj
* Textual screen: 80x25 at B800
* Frequency: 10000 Hz = 10kHz
* Author: Nejc Kišek

### The Chaos game Sierpinski triangle
The program draws the sierpinski triangle and is also capabile of drawing other fractals, that can be drawn by the chaos game, with a bit of tweeking.
The triangle is drawn iteratively, one point at a time, on a 200 by 200 window. This is implemented with two nested linear congruential generators.
* Source code: sier.asm
* Frequency: Depending uppon how fast you want the triangle to be rendered. 5000 Hz for medium speed and 10000 Hz for fast speed.
* Graphical screen: 200x200 at A000
* Author: Peter Mlakar
 
### Text Wall
A demo for SicTools text screen. Creates streams of numbers and scrolls them vertically over the screen in a matrix-like style.

* Source code: txtwal.asm
* Textual screen: 80x25 at B800
* Frequency: 10^5Hz to 10^7Hz
* Author: Jan Makovecki








