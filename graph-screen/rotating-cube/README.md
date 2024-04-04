# SicDemos
This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

## Rotating Cube

A rotating cube that shows on the graph screen.<br>
The size of the screen, cube, and colors are customizable.<br>
Using the keyboard screen, you can press:
* SPACE: to pause/unpause the cube from ratating
* a/s/d: to increase the rotating speed on x/y/z axies
* z/x/c: to decrease the rotating speed
* q: to halt the program

## Usage

To run the rotating cube program:
1. Set the **SCREEN_ROWS** and **SCREEN_COLS** to desire value

2. run the sictools:
```sh
java -jar sictools.jar -freq 55000000 -graph 128x128 -keyb 0xC0000 rotating_cube.asm
```
3. **Then set the address of graph screen to A0000**

### Variations
If you want a Bigger cube:
```bash
java -jar sictools.jar -freq 75000000 -graph 176x176 -keyb 0xC0000 rotating_cube.asm
```

Or multiple cubes:
```sh
java -jar sictools.jar -freq 55000000 -graph 192x96 -keyb 0xC0000 rotating_cube.asm
```

* Source code: rotating_cube.asm
* Frequency: default (55 MHz = 55000000 Hz), affects the rendering speed, higher frequency makes it more smooth
* Graphical screen: 128x128 at 0xA0000
* Keyboard at 0xC0000
* Author: Jorden Huang (黃淯祐) and KaiKuo (郭亮愷), 2024