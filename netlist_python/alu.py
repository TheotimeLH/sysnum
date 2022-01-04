
from lib_carotte import *

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

def nul(a):
    b = Constant("1")
    for i in range(16):
        b = ~a[i] & b
    return b

def egal(a, b):
    c = n_Xor(a, b)
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
	z = Constant("0"*16)
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

def neg16(a):
    b = n_Not(a)
    return incr(b)

# Main
    
def main(a, b, op):
	
	c0 = Constant("0"*16)
	c1 = n_adder(a, b)
	c2 = mult(a, b)
	c3 = sub(a, b)
	c4 = neg16(a)
	c5 = not16(a)
	c6 = and16(a, b)
	c7 = or16(a, b)
	c8 = xor16(a, b)
	c9 = incr_mod(a, b)
	
	d0 = Mux(op[0], d1, d8)
	d1 = Mux(op[1], d2, d3)
	d2 = Mux(op[2], d4, d5)
	d3 = Mux(op[2], d6, d7)
	d4 = Mux(op[3], c0, c1)
	d5 = Mux(op[3], c2, c3)
	d6 = Mux(op[3], c4, c5)
	d7 = Mux(op[3], c6, c7)
	d8 = Mux(op[3], c8, c9)
	d9 = nul(d0)
	
	return d0, d9
