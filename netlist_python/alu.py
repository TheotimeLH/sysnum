
from lib_carotte import *

allow_ribbon_logic_operations(True)

def alu(a, b, op):

    # Clock

    def zero(n): return Constant("0"*n)

    def nul(a):
        b = Constant("1")
        for i in range(16):
            b = ~a[i] & b
        return b

    def egal(a, b): return nul(a^b)

    def incr(a):
        b = Constant("1")
        for i in range(15):
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

    def neg(a): return incr(~a)

    def sub(a, b):
        c = neg(b)
        return n_adder(a, c)

    def mult(a, b):
        z = zero(16)
        p = Mux(b[15], z, a)
        for i in range(1, 15):
            s = a[i:16] + zero(i)
            c, d = n_adder(p, s)
            p = Mux(b[i], p, c)
        return p

    # Main

    #c0 = zero(16)
    c0 = a # l’opération 0000 devient l’identité sur le premier arg
    c1, debordement = n_adder(a, b)
    c2 = mult(a, b)
    c3, debordement_flotant = sub(a, b)
    c4 = neg(a)
    c5 = ~a
    c6 = a & b
    c7 = a | b
    c8 = a ^ b
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
    return (d8, d9, d8[0])

# DEBUG #

def main() :
    a = Input(16)
    b = Input(16)
    op = Input(4)
    (res, nul, neg) = alu(a, b, op)
    res.set_as_output("resultat")
    nul.set_as_output("est_nul")
    neg.set_as_output("est_negatif")

