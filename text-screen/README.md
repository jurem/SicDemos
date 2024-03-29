# SicDemos
This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

## Bouncing balls
Animate moving bouncing balls on the textual screen.
* Source code: balls.asm
* Frequency: 10000 Hz = 10 kHz
* Textual screen: 80x25 at B800
* Author: Tomaž Dobravec

## Text Wall
A demo for SicTools text screen. Creates streams of numbers and scrolls them vertically over the screen in a matrix-like style.

* Source code: txtwal.asm
* Textual screen: 80x25 at B800
* Frequency: 100000 Hz
* Author: Jan Makovecki, 2016

## Maze
A simple maze game made with SicTools text screen. A sample maze is printed to the screen and can be interacted with using the standard input.

* USAGE: The player can use WASD/wasd keys on the standard input to move through the maze. X's are walls and cannot be crossed, P marks the player's position and T marks the position of chests. One of these is the treasure, the rest are traps. If the player finds the treasure, a victory message is displayed, and if a trap is encountered, a loss message is displayed.
* Source code: maze.asm
* Textual screen: 80x25 at B800
* Frequency: 1000 Hz
* Author: Mihael Rajh, 2018

## Game of Life
A simple zero-player game simulating the evolution. User can change which pattern program uses for its initial configuration. Choose wisely: entire "game" is completely determined by its initial state. Three initial patterns are already prepared.
* Source code: game_of_life.asm
* Textual screen: 80x25 at B800
* Frequency: 500000 Hz = 500 kHz
* Author: [Žan Magerl](https://github.com/polhec42), 2019

## Minesweeper
A simple recreation of the classic minesweeper video-game. User can change the number of rows, columns and mines (at the end of the source file). After the screen has been loaded, press random keys while the keyboard window is in focus. The number of required key presses is equal to the number of mines (30 by default). Consecutive key presses of the same key will be registered as a single key press. After that, a `+` should appear on the top-left corner of the field. That is the cursor. Navigate the field using `W, A, S` and `D`, mark covered plots with `J` and uncover plots with `K`. Win the game by uncovering all the plots without a mine.
* Source code: minesweeper.asm
* Textual screen: 17x17 at B800
* Frequency: 100000 Hz
