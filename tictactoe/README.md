# SicDemos
This demo is part of SicDemos: a collection of assembly programs for the SIC/XE computer architecture. SicDemos is a companion project of [SicTools](https://github.com/jurem/SicTools) project (SIC/XE hypothetical computer simulator).

# Tic Tac Toe

SIC/XE text game for two players. Board is presented with ASCII characters. Every turn, players take their moves. A move is simply a number in range 0 - 8. Every move, text screen is refreshed using terminal escape sequences. Game lasts until one player wins or there is a tie.

Game does not check given input so care has to be taken. Wrong input is going to crash the program. Make sure to read all instructions printed on screen!

* Source code: tictactoe.asm
* Frequency: 10000 Hz = 10 kHz
* Standard input
* Author: Jakob Merljak, 2016
