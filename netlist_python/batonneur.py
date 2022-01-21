
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
    b6 = d[2] | even
    b4 = d[1] ^ d[2]
    b2 = ~b3 | even

    r = b7+b6+b5+b4+b3+b2+b1
    r56 = z(1) + un(5) + d[2]
    r07 = Mux(b7, r56, r)
    r89 = un(6) + ~d[3]
    r09 = Mux(d[0], r07, r89)
    return r09

dix = Constant("00010100001")
vingt = Constant("00101000010")
trente = Constant("00111100011")
quar = Constant("01010000100")
cinq = Constant("01100100101")
soix = Constant("01111000110")
sept = Constant("10001100111")
octt = Constant("10100001000")
nont = Constant("10110101001")

def geq(x, y):
    b = un(1)
    for i in range(6, -1, -1):
        m = x[i] ^ y[i]
        b = Mux(m, b, x[i])
    return b

def sub(a, b, r):
    t = a^b
    return t^r, Mux(t, r, b)

def sub7(a, b):
    s, r = sub(a[6], b[6], z(1))
    for i in range(5, -1, -1):
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

    d01 = Mux(m1, z(11), dix)
    d23 = Mux(m3, vingt, trente)
    d45 = Mux(m5, quar, cinq)
    d67 = Mux(m7, soix, sept)
    d89 = Mux(m9, octt, nont)
    d25 = Mux(m4, d23, d45)
    d69 = Mux(m8, d67, d89)
    d29 = Mux(m6, d25, d69)
    d = Mux(m2, d01, d29)

    u = sub7(a, d)
    cu = u[3:7]
    cd = d[7:11]
    bu = baton(cu)
    bd = baton(cd)
    return un(16)

