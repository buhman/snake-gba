import struct
import sys

colors = []
with open(sys.argv[1], 'rb') as f:
    while (color := f.read(3)):
        n, = struct.unpack('>I', b'\x00' + color)
        colors.append(n)

def as_15bit(color: str):
    n = 0
    for i in range(3):
        ni = (color >> (16 - (i * 8))) & 0xff
        #n |= (ni // 8) * 8 << (8 * i)
        n |= (ni // 8) << (5 * i)
    return n


for color in colors:
    print(".short", "0x" + hex(as_15bit(color))[2:])
