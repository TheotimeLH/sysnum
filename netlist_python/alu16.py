
from lib_carotte import *

def alu(a, b, op):

    # Logique

    def not16(a):
        s = ~a[0]
        for i in range(1, 16):
            s = s + ~a[i]
        return s

    def and16(a, b):
        s = a[0] & b[0]
        for i in range(1, 16):
            s = s + (a[i] & b[i])
        return s

    def or16(a, b):
        s = a[0] | b[0]
        for i in range(1, 16):
            s = s + (a[i] | b[i])
        return s

    def xor16(a, b):
        s = a[0] ^ b[0]
        for i in range(1, 16):
            s = s + (a[i] ^ b[i])
        return s

    # Clock

    def zero(n): return Constant("0"*n)

    def nul(a):
        b = Constant("1")
        for i in range(16):
            b = ~a[i] & b
        return b

    def egal(a, b):
        c = xor16(a, b)
        return nul(c)

    def incr(a):
        b = Constant("1")
        for i in range(16):
            c = a[15-i] & b[0]
            b = c + b
        return a ^ b

    def incr_mod(a,b):
        c = incr(a)
        m = egal(b, c)
        z = zero(16)
        return Mux(m, c, z)

    # Arithmétique

    def full_adder(a, b, c):
        t = a ^ b
        return (t ^ c, (t & c) | (a & b))

    def n_adder(a, b):
        c = Constant("0")
        (s, c) = full_adder(a[15], b[15], c)
        for i in range(14, -1, -1):
            (t, c) = full_adder(a[i], b[i], c)
            s = t + s
        return (s, c)

    def neg(a):
        b = not16(a)
        return incr(b)

    def sub(a, b):
        c = neg(b)
        return n_adder(a, c)

    def mult(a, b):
        z = zero(16)
        p = Mux(b[15], z, a)
        for i in range(1, 16):
            s = a[i:16] + zero(i)
            c, d = n_adder(p, s)
            p = Mux(b[i], p, c)
        return p

    # Main

    c0 = zero(16)
    c1, debordement = n_adder(a, b)
    c2 = mult(a, b)
    c3, debordement_flotant = sub(a, b)
    c4 = neg(a)
    c5 = not16(a)
    c6 = and16(a, b)
    c7 = or16(a, b)
    c8 = xor16(a, b)
    c9 = incr_mod(a, b)

    d0 = Mux(op[3], c0, c1)
    d1 = Mux(op[3], c2, c3)
    d2 = Mux(op[3], c4, c5)
    d3 = Mux(op[3], c6, c7)
    d4 = Mux(op[3], c8, c9)
    d5 = Mux(op[2], d0, d1)
    d6 = Mux(op[2], d2, d3)
    d7 = Mux(op[1], d5, d6)
    d8 = Mux(op[0], d7, d4)
    d9 = nul(d8)
    return (d8, d9, d8[15])

# DEBUG #

def main() :
    a = Input(16)
    b = Input(16)
    op = Input(4)
    (res, nul, neg) = alu(a, b, op)
    res.set_as_output("resultat")
    nul.set_as_output("est_nul")
    neg.set_as_output("est_negatif")

