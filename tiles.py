import sys

with open(sys.argv[1], "rb") as f:
    b = f.read()
    assert len(b) == 65536, len(b)

"""
tiles x:
   0.0 * s + t = 0


"""

def cell(tx, ty, cx, cy):
    ix = (ty * 8 * 256) + (cy * 256) + (tx * 8) + cx
    return ix

l = []

v = 0

for ty in range(32):
    for tx in range(32):
        for cy in range(8):
            for cx in range(8):
                vi = b[cell(tx, ty, cx, cy)]
                if (cx % 2 == 0):
                    v = vi
                else:
                    v |= (vi << 4)
                    l.append(v)

with open("tiles.bin", "wb") as f:
    f.write(bytes(l))
