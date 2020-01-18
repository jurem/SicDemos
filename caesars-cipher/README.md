# Caesars cipher
A decoder for the Caesars cipher over the english alphabet. To use the program, load it, open the keyboard and textual screen and launch the program. The first line of the ciphertext will be displayed (offset 0) and the user should press 'n' if it is incorrectly decoded and 'y' if it is correctly decoded. If 'n' is pressed, the first line of the text will be decoded with offset 1 and displayed again and the user will enter 'n' or 'y' again. This repeats untill the right offset is found and the user presses 'y', then the remaining lines of the ciphertext will be decoded with the current offset. Requirements are:
* A file 'AA.dev' with the ciphertext you want to decode
* An 80x25 textual screen at B800 (the size is important)
* A keyboard at 0xC000
* Frequency set to at least 10000, but can be as high as you want it
* Author: Andrej Gorjan, 2020