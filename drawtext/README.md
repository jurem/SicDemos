# SicDemos
This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

## Textual draw
Draw on textual screen by reading the commands from standard input.
* Source code: drawtext.asm
* Textual screen: 80x25 at 0B800
* Frequency: 10000 Hz = 10 kHz
* Author: Nejc Kišek, 2015

### Usage

Type a command (or more commands) to standard input and press enter to execute them.

### Commands
* h : displays help on stdout
* w, a, s, d : up, left, down, right
* f : changes drawing symbol to next typed character
* c : clears the screen and returns to center
* p : fills the screen with drawing symbol
* q : halt

### Examples
* 'aaaa wwww dddd ssss' -> draws a 4x4 square
* 'f.' -> changes drawing symbol to '.'
* 'f-dddf df-dddf df-ddd' -> draws a dashed line '--- --- ---'
