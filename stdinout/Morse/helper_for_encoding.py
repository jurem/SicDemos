alphabet = {'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
            'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
            'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
            'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
            'Y': '-.--', 'Z': '--..', '0': '-----', '1': '.----', '2': '..---',
            '3': '...--', '4': '....-', '5': '.....', '6': '-....', '7': '--...',
            '8': '---..', '9': '----.', '.': '.-.-.-', ',': '--..--', '-': '-....-',
            '?': '..--..', '"': '.--..--.', ':': '---...', '@': '.--.-.'}

binary_presentation = {}

for key in alphabet.keys():
    morse_code = alphabet[key]
    print(key, morse_code)
    bin_pre = 0
    base = 3
    mult = 1
    # print(morse_code[::-1])
    for c in morse_code[::-1]:
        if (c == '-'):
            bin_pre += mult * 2
        elif (c == '.'):
            bin_pre += mult
        mult *= base

    binary_presentation[key] = bin_pre

for b in binary_presentation.keys():
    s = "       WORD    {0}     .{1} -> {2}".format(
        binary_presentation[b], b, alphabet[b])
    print(s)
