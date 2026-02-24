# Calculator

This program accepts an arithmetic expression in prefix notation
on standard input and prints the result on standard output.

Supported operations:

- Addition
- Subtraction
- Multiplication
- Division

All calculations are preformed on Integers in range $[-2^{23}, 2^{23} - 1]$. Negative numbers can be written as `(- 0 n)`, where `n` is the number

Here are some examples:

```{bash}
(* 21 2)
00000042
(/ 6 (* 2 (+ 2 1)))
00000001
(* (/ 6 2) (+ 2 1))
00000009
(- 33 (* 4 25))
-00000067

```

- Source code: calc.asm
- Frequency: any (faster is faster)
- Author: Jakob Jesenko, 2026
