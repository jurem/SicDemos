The classic game of Bejeweled (aka match 3 gems) written in SIC/XE.
Match 3 or more gems to "destroy" them. Destroyed gems are removed from the board, the gems above the destroyed gems "fall" down and new gems get generated to fill the now empty space at the top of columns containing destroyed gems.
Matching 5 or more gems will cause a "hyper cube" to be created. This hyper cube can be matched with any gem color, to destroy all gems of that color currently on the board. Matching two hyper cubes will ||clear the entire board||.

## Setup

- The [`sictools.jar`](https://github.com/jurem/SicTools) is the recommended tool to use for running the game.
- The frequency must be set to at least `100000` for acceptable performance.
- The graphical screen must be at `0A000` with a width and height of `128`.
- The keyboard must be at `0F000` (moved since the graphical screen overlaps it).
- The command `java -jar sictools.jar -freq 100000 -graph 128x128 -keyb 0xF000 bejeweled.asm` can be used to automatically set up the required sictools settings

## Controls

- `a` moves the selection left
- `w` moves the selection up
- `d` moves the selection right
- `s` moves the selection down
- `space` selects the gem or swaps gems if a gem is already selected
- `escape` deselects the currently selected gem
