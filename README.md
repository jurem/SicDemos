# SicDemos
Demo programs for SicTools (SIC/XE hypothetical computer)

### Alphabet
Repeatedly print English alphabet on the standard output. Run from the command line to see the standard output.
* Source code: abc.asm
* Frequency: 100 Hz
* Author: Tomaž Dobravec (adapted by Jurij Mihelič)

### Towers of Hanoi
Solve the famous Towers of Hanoi puzzle. Register A is set up with the initial number of disks (default 10).
* Source code: hanoi.asm
* Frequency: 10000 Hz = 10 kHz
* Author: Jurij Mihelič

### Bouncing balls
Animate moving bouncing balls on the textual screen.
* Source code: balls.asm
* Textual screen: 80x25 at B800
* Frequency: 10000 Hz = 10 kHz
* Author: Tomaž Dobravec

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

### Draw
Draw on textual screen by typing commands to stdin.
* Source code: draw.asm
* Textual screen: 80x25 at 0B800
* Frequency: 10000 Hz = 10kHz
* Author: Nejc Kišek
