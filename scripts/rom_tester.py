#!/usr/bin/python3

from sys import argv

if __name__ == '__main__':
    with open("test.bin", "wb") as f:
        f.write(bytearray([chr(i % 0X100) for i in range (0, 0x200)]))
    
    