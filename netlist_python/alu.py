
from lib_carotte import *

# Logique
    
def n_Not(a):
    s = ~a[0]
    for i in range(1, 8):
        s = s + ~a[i]
    return s
    
def n_And(a, b):
    s = a[0] & b[0]
    for i in range(1, 8):
        s = s + (a[i] & b[i])
    return s
   
def n_Nand(a, b):
    c = n_And(a, b)
    return n_Not(c)
    
def n_Or(a, b):
    s = a[0] | b[0]
    for i in range(1, 8):
        s = s + (a[i] | b[i])
    return s
    
def n_Xor(a, b):
    s = a[0] ^ b[0]
    for i in range(1, 8):
        s = s + (a[i] ^ b[i])
    return s

# Clock

def nul(a):
    b = Constant("1")
    for i in range(8):
        b = ~a[i] & b
    return b

def egal(a, b):
    c = n_Xor(a, b)
    return nul(c)

def incr(a):
    b = Constant("1")
    s = a[0] ^ b
    b = a[0] & b
    for i in range(1, 8):
        s = s + (a[i] ^ b)
        b = a[i] & b
    return s

def incr_mod(a,b):
    c = incr(a)
    m = egal(b, c)
    return Mux(m, c, Constant("0"*8))

# Arithmétique

def full_adder(a, b, c):
    t = a ^ b
    return (t ^ c, (t & c) | (a & b))

def n_adder(a, b):
    c = Constant("0")
    (s, c) = full_adder(a[0], b[0], c)
    for i in range(1, 8):
        (t, c) = full_adder(a[i], b[i], c)
        s = s + t
    return (s, c)

def n_Neg(a):
    b = n_Not(a)
    return incr(b)

# Main
    
def main(a, b, op):
	
