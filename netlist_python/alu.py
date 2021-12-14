
from lib_carotte import *

def full_adder(a, b, c):
    tmp = a ^ b
    return (tmp ^ c, (tmp & c) | (a & b))

def n_adder(a, b):
    assert(a.bus_size == b.bus_size)
    c = Constant("0")
    (s, c) = full_adder(a[0], b[0], c)
    for i in range(1, a.bus_size):
        (s_i, c) = full_adder(a[i], b[i], c)
        s = s + s_i
    return (s, c)
  
def main(a,b,op):
  
