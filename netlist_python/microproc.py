# carotte.py by TWal, hbens & more

from lib_carotte import *

from tutorial.utils import full_adder

def main():
    line_incr = Constant("1")
    #b = Input(1)
    #c = Input(1)
    #d = Input(8)

    # We can do logical operations like this, using full names:
    #e2 = Nand(a, b)
    #e3 = Or(a, b)
    #e4 = Xor(a, b)
    #e5 = Mux(c, a, b)
    #e6 = Not(a)
    #e7 = Reg(a)
    #e8 = Constant("0010")


def liseur_code(jump_line, jump_flag, line_incr) :
    line_plus, out_carry = full_adder(curr_line, line_incr)
    curr_line = Mux(jump_flag, lineplus, jump_line)
    return curr_line


