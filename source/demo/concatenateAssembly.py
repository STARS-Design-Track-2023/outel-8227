uglyString = """58
8E FF
9A 
A9 10 
8D 09 80
8D 09 00

A9 0E 
8D 08 80
8D 08 00

A9 01 
8D 07 80
8D 07 00

A9 01 
8D 06 80
8D 06 00

A9 00 
8D 05 80
8D 05 00

A9 11 
8D 04 80
8D 04 00

A9 00 
8D 03 80
8D 03 00

A9 13 
8D 02 80
8D 02 00

A9 01 
8D 01 80
8D 01 00

A9 0D 
8D 00 80
8D 00 00

AC 00 00 
AD 01 00
8D 00 80
8D 00 00

AD 02 00
8D 01 80
8D 01 00

AD 03 00
8D 02 80
8D 02 00

AD 04 00
8D 03 80
8D 03 00

AD 05 00
8D 04 80
8D 04 00

AD 06 00
8D 05 80
8D 05 00

AD 07 00
8D 06 80
8D 06 00

AD 08 00
8D 07 80
8D 07 00

AD 09 00
8D 08 80
8D 08 00

98 
8D 09 00
8D 09 00

4C ?? ??"""

longString = ''
for letter in uglyString:
    if(letter == '\n'):
        longString += ' '
    else:
        longString += letter 
print(longString)