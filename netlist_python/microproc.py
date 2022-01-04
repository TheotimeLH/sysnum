# carotte.py by TWal, hbens & more

from lib_carotte import *

from tutorial.utils import full_adder

#from endroit import decodeur

def main():
    #initialisation
    prog_rom_addr_size = 10
    prog_rom_word_size = 32
    line_incr = Constant("1")
    line_init = Constant("0000000000")
    
    

    #rappel des commandes
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
    
    curr_line = reg(Defer(10, lambda:next_line))
    curr_code = ROM(prog_rom_addr_size, prog_rom_word_size, curr_line)
    jump_line, jump_flag, operation, entier, read_addr1, read_addr2, write_addr_reg, write_addr_ram, write_enable_reg write_enable_ram = decodeur(curr_code)
    next_line = liseur_code(jump_line, jump_flag, line_incr)

    


