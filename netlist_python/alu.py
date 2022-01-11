
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
        s = a[0] ^ b
        b = a[0] & b
        for i in range(1, 16):
            s = s + (a[i] ^ b)
            b = a[i] & b
        return s

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
        (s, c) = full_adder(a[0], b[0], c)
        for i in range(1, 16):
            (t, c) = full_adder(a[i], b[i], c)
            s = s + t
        return (s, c)

    def neg(a):
        b = not16(a)
        return incr(b)

    def sub(a, b):
        c = neg(b)
        return n_adder(a, c)

    def mult(a, b):
        z = zero(16)
        p = Mux(b[0], z, a)
        for i in range(1, 16):
            s = a[i:16] + zero(i)
            c, osef = n_adder(p, s)
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

    d0 = Mux(op[0], Defer(16, lambda:d1), Defer(16, lambda:d8))
    d1 = Mux(op[1], Defer(16, lambda:d2), Defer(16, lambda:d3))
    d2 = Mux(op[2], Defer(16, lambda:d4), Defer(16, lambda:d5))
    d3 = Mux(op[2], Defer(16, lambda:d6), Defer(16, lambda:d7))
    d4 = Mux(op[3], c0, c1)
    d5 = Mux(op[3], c2, c3)
    d6 = Mux(op[3], c4, c5)
    d7 = Mux(op[3], c6, c7)
    d8 = Mux(op[3], c8, c9)
    d9 = nul(d0)
    return (d0, d9, d0[15])

#DEBUG#
def main() :
    a = Input(16)
    b = Input(16)
    op = Input(4)
    (res, nul, neg) = alu(a,b,op)
    res.set_as_output("resultat")
    nul.set_as_output("est_nul")
    neg.set_as_output("est_negatif")
