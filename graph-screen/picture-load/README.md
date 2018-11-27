# SicDemos
This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

## Picture renderer
Reads from device numbered A0 which contains a picture in the format described below and outputs it to the graphical screen.
Example is given in file A0.dev.

Format:
- Byte 0: pic height (cannot exceed 64)
- Byte 1: pic width  (cannot exceed 64)
- Byte 2 -- (width * height + 1): (iirrggbb) format bytes 

* Source code: picture.asm
* Frequency: default (100 Hz); only affects rendering speed
* Graphical screen: 64x64 at A000
* Author: Klemen Jesenovec, 2018
