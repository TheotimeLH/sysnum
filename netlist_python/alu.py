
from lib_carotte import *
    
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
          c = a[i] & b[i]
          b = b + c
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
        (s, c) = full_adder(a[0], b[0], c)
        for i in range(1, 16):
            (t, c) = full_adder(a[i], b[i], c)
            s = s + t
        return (s, c)

    def neg(a): return incr(~a)

    def sub(a, b):
        c = neg(b)
        return n_adder(a, c)

    def mult(a, b):
        z = zero(16)
        p = Mux(b[0], z, a)
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
    c5 = ~a
    c6 = a & b
    c7 = a | b
    c8 = a ^ b
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
  
