# SicDemos

This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

# 15 Puzzle

A sliding puzzle game consisting of 15 numbered tiles and one empty space on a 4x4 board. The goal is to arrange the tiles in ascending order, from left to right and top to bottom, with the empty space in the bottom-right corner.

Each new puzzle is generated using 10 characters entered by the player. The characters are hashed into a seed for a pseudorandom number generator, which then shuffles an initially solved board using legal moves. This guarantees that every generated puzzle is solvable.

## How to play

Open the following views in SicTools:
- `View > Textual screen`
- `View > Keyboard`

Click the keyboard input area and press any 10 keys to generate a puzzle.

Controls:
- `W`, `A`, `S`, `D` : move a numbered tile up, left, down, and right, respectively
- `R` : generate a new puzzle
- `Q` : halt

Only tiles adjacent to the empty space can move. The game tracks the number of moves and displays a message when the puzzle is solved.

## Info

- Source code: `puzzle15.asm`
- Recommended frequency: 100 kHz
- Author: Nejc Pušnik, 2026