
from lib_carotte import *

def z(n): return Constant("0"*n)
def un(n): return Constant("1"*n)

def baton(d):
    odd = d[0]^d[1]^d[2]^d[3]
    even = ~odd

    b1 = ~(d[1] | d[3])
    b5 = ~(d[2] | d[3])
    b7 = ~d[1] | odd
    b3 = ~d[3] & d[2]
    b6 = d[2] | even
    b4 = d[1] ^ d[2]
    b2 = ~b4 | even

    r = b7+b6+b5+b4+b3+b2+b1
    r56 = z(1) + un(5) + d[2]
    r07 = Mux(b7, r56, r047)
    r89 = un(6) + ~d[3]
    r09 = Mux(d[0], r07, r89)
    return r09

dix = Constant("0001010")
vingt = Constant("0010100")
trente = Constant("0011110")
quar = Constant("0101000")
cinq = Constant("0110010")
soix = Constant("0111100")
sept = Constant("1000110")
octt = Constant("1010000")
nont = Constant("1011010")

def geq(x, y):
    b = un(1)
    for i in range(15, 8, -1):
        m = x[i] ^ y[i]
        b = Mux(m, b, x[i])
    return b

def sub(a, b, r):
    t = a^b
    return t^r, Mux(t, r, b)

def sub7(a, b):
    s, r = sub(a[15], b[15], z(1))
    for i in range(14, 8, -1);
        c, r = sub(a[i], b[i], r)
        s = c + s
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
    cu = u[12:16]
    du = d[12:16]
    bu = baton(cu)
    bd =baton(cd)
    return un(2)+bd+bu

