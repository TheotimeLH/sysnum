
from lib_carotte import *

def z(n): return Constant("0"*n)
def un(n): return Constant("1"*n)

def baton(d):
    odd = d[0]^d[1]^d[2]^d[3]
    even = ~odd

    b1 = ~(d[1] | d[3])
    b5 = ~(d[2] | d[3])
    b7 = ~d[1] | odd
    b3 = ~d[2] | d[3]
    b6 = d[2] | even
    b4 = d[1] ^ d[2]
    b2 = ~b3 | even

    r = b7+b6+b5+b4+b3+b2+b1
    r56 = z(1) + un(5) + d[2]
    r07 = Mux(b7, r56, r)
    r89 = un(6) + ~d[3]
    r09 = Mux(d[0], r07, r89)
    return r09

dix = Constant("000010100001")
vingt = Constant("000101000010")
trente = Constant("000111100011")
quar = Constant("001010000100")
cinq = Constant("001100100101")
soix = Constant("001111000110")
sept = Constant("010001100111")
octt = Constant("010100001000")
nont = Constant("010110101001")

def geq(x, y):
    b = un(1)
    for i in range(7, -1, -1):
        m = x[i] ^ y[i]
        b = Mux(m, b, x[i])
    return b

def sub(a, b, r):
    t = a^b
    return t^r, Mux(t, r, b)

def sub7(a, b):
    s, r = sub(a[7], b[7], z(1))
    for i in range(6, -1, -1):
        c, r = sub(a[i], b[i], r)
        s = c + s
    return s

def batonneur(a):
    a8 = a[8:16]

    m1 = geq(a8, dix)
    m2 = geq(a8, vingt)
    m3 = geq(a8, trente)
    m4 = geq(a8, quar)
    m5 = geq(a8, cinq)
    m6 = geq(a8, soix)
    m7 = geq(a8, sept)
    m8 = geq(a8, octt)
    m9 = geq(a8, nont)

    d01 = Mux(m1, z(12), dix)
    d23 = Mux(m3, vingt, trente)
    d45 = Mux(m5, quar, cinq)
    d67 = Mux(m7, soix, sept)
    d89 = Mux(m9, octt, nont)
    d25 = Mux(m4, d23, d45)
    d69 = Mux(m8, d67, d89)
    d29 = Mux(m6, d25, d69)
    d = Mux(m2, d01, d29)

    u = sub7(a8, d)
    cu = u[4:8]
    cd = d[8:12]
    bu = baton(cu)
    bd = baton(cd)
    return un(2) + bu + bd

