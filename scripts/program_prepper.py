#!/usr/bin/python3

from sys import argv

PROGRAM_MAX_LENGTH = 0X200
NMI = 0XFE00
RES = 0XFE00
IRQ = 0XFE00

if __name__ == '__main__':
    if (len(argv) != 3):
        raise ValueError("Improper argument count!")
    
    with open(argv[1],"rb") as f:
        assert len(f.read()) <= 0X200 - 6, "Program too large!"

    with open(argv[1], "rb") as f:
        out = f.read()

    out = out.ljust(0X200 - 6, b'\xea') + NMI.to_bytes(2, 'little') + RES.to_bytes(2, 'little') + IRQ.to_bytes(2, 'little')
    
    assert len(out) == PROGRAM_MAX_LENGTH
    with open(argv[2], "w") as f:
        [f.write(f'{byte:X} ') for byte in out]
    
    