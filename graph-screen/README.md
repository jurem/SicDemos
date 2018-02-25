# SicDemos
This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

## Game of life
Animate [Conways' Game of Life](https://en.wikipedia.org/wiki/Conway's_Game_of_Life) on the graphical screen. The game is initialized with the glider figure at the top left corner.
* Source code: life.asm
* Graphical screen: 64x64 at A000
* Frequency: 10000000 Hz = 10 MHz
* Author: Jurij Mihelič

## H-tree fractal
Draw an H-tree fractal on the graphical screen.
* Source code: htree.asm
* Graphical screen 333x333 at A000
* Frequency: 10000 Hz = 10 kHz
* Author: Klemen Klanjšček, 2015

## The Chaos game Sierpinski triangle
The program draws the sierpinski triangle and is also capabile of drawing other fractals, that can be drawn by the chaos game, with a bit of tweeking.
The triangle is drawn iteratively, one point at a time, on a 200 by 200 window. This is implemented with two nested linear congruential generators.
* Source code: sier.asm
* Frequency: Depending uppon how fast you want the triangle to be rendered. 5000 Hz for medium speed and 10000 Hz for fast speed.
* Graphical screen: 200x200 at A000
* Author: Peter Mlakar, 2016
