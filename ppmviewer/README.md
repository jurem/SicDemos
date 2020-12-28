## SIC/XE PPM viewer
Displays PPMs from stdin on the graphical screen.
Supports PPMs of type P6 and color range 255.

Usage example:
```sh
java -jar sictools.jar -freq 15000000 -graph 64x64 ./ppmviewer.asm < ./pikachu.ppm
```

Colors are converted from rgb to nearest irgb (euclidean distance).

PPM format spec: http://paulbourke.net/dataformats/ppm/

Demo PPMs were generated using https://convertio.co/png-ppm/

Author: Blaž Zupančič, 2020
