
from lib_carotte import *

def batonneur(a):

    def z(n): return Constant("0"*n)
    def un(n): return Constant("1"*n)

    def baton(d):
        odd = d[0]^d[1]^d[2]^d[3]

        b1 = ~d[0] & ~d[2]
        b2 = ~d[0] & ~d[1]
        b3 = ~d[2] | odd
        b4 = ~d[0] & d[1]
        b5 = d[1] | ~odd
        b6 = d[1] ^ d[2]
        b7 = ~b4 | ~odd

        r = b1+b2+b3+b4+b5+b6+b7
        r56 = d[1] + un(1) + b3 + un(4)
        r07 = Mux(b3, r56, r047)
        r89 = ~d[0] + un(6)
        r09 = Mux(d[3], r07, r89)
        return r09
