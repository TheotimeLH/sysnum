
from lib_carotte import *

def z(n): return Constant("0"*n)
def un(n): return Constant("1"*n)

def baton(d):
    odd = d[0]^d[1]^d[2]^d[3]
    even = ~odd

    b1 = ~(d[0] | d[2])
    b2 = ~(d[0] | d[1])
    b3 = ~d[2] | odd
    b4 = ~d[0] & d[1]
    b5 = d[1] | even
    b6 = d[1] ^ d[2]
    b7 = ~b4 | even

    r = b1+b2+b3+b4+b5+b6+b7
    r56 = d[1] + un(1) + b3 + un(4)
    r07 = Mux(b3, r56, r047)
    r89 = ~d[0] + un(6)
    r09 = Mux(d[3], r07, r89)
    return r09

dix = Constant("0101000")
vingt = Constant("0010100")
trente = Constant("0111100")
quar = Constant("0001010")
cinq = Constant("0100110")
soix = Constant("0011110")
sept = Constant("0110001")
octt = Constant("0000101")
nont = Constant("0101101")

def geq(x, y):
    b = un(1)
    for i in range(7):
        m = x[i] ^ y[i]
        b = Mux(m, b, x[i])
    return b

def sub(a, b, r):
    t = a^b
    return t^r, Mux(t, r, b)

def sub7(a, b):
    s, r = sub(a[0], b[0], z(1))
    for i in range(1, 7);
        c, r = sub(a[i], b[i], r)
        s = s + c
    return s

def batonneur(a):

    m1 = geq(a, dix)
    m2 = geq(a, vingt)
    m3 = geq(a, trente)
    m4 = geq(a, quar)
    m5 = geq(a, cinq)
    m6 = geq(a, soix)
    m7 = geq(a, sept)
    m8 = geq(a, octt)
    m9 = geq(a, nont)

    d01 = Mux(m1, z(7), dix)
    d23 = Mux(m3, vingt, trente)
    d45 = Mux(m5, quar, cinq)
    d67 = Mux(m7, soix, sept)
    d89 = Mux(m9, octt, nont)
    d25 = Mux(m4, d23, d45)
    d69 = Mux(m8, d67, d89)
    d29 = Mux(m6, d25, d69)
    d = Mux(m2, d01, d29)

    u = sub(a, d)
    return baton(d)+baton(u)+un(2)

