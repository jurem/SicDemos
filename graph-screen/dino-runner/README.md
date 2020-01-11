# SicDemos
This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

## Dino Runner 
Game inspired by Google Chrome's no internet connection game.
Using keyboard and graphical display, you must jump through cacti obstacles which are "randomly" generated.

To run dino-runner-vsync or dino-runner:
```sh
# Using latest SicVM machine with VSync support: 
java -jar sictools.jar -freq 15000000 -graph 128x64 -keyb 0xD000 dino-runner-vsync.asm
```
```sh
# Otherwise use dino-runner.asm, and enable keyboard with address 0xD000
java -jar sictools.jar -freq 15000000 -graph 128x64 dino-runner.asm
```

* Source code: dino-runner.asm, dino-runner-vsync.asm
* Frequency: default (15 MHz - 15000000 Hz); VSync - only affects rendering speed, No VSync - Must be 15MHz, otherwise a change is needed in dino-runner.asm file
* Graphical screen: 128x64 at 0xA000
* Keyboard at 0xD000
* Author: Martin Peterlin, 2019
