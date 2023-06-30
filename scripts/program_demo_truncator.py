#!/usr/bin/python3

from sys import argv

if __name__ == '__main__':
    if (len(argv) != 3):
        raise ValueError("Improper argument count!")
    
    # with open(argv[1],"rb") as f:
    #     assert len(f.read()) == 0XFFFF

    with open(argv[1], "rb") as f:
        # f.seek(1)
        f.seek(0X7E00)
        out = f.read()
        # assert len(out) == 0X200
    
    with open(argv[2], "w") as f:
        [f.write(f'{byte:X} ') for byte in out]
    
    