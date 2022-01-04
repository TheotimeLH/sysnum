# carotte.py by TWal, hbens & more

from lib_carotte import *

from tutorial.utils import full_adder

#from endroit import decodeur
#from autre endroit import alu

def main():
    #initialisation
    prog_rom_addr_size = 10
    prog_rom_word_size = 32
    line_incr = Constant("1")
    reg_size = 16
    #line_init = Constant("0000000000")    
   

    def liseur_code(jump_line, jump_flag, line_incr) :
        line_plus, out_carry = full_adder(curr_line, line_incr)
        curr_line = Mux(jump_flag, lineplus, jump_line)
        return curr_line
    
    def interf_alu(value_reg1, value_reg2, entier, resultat_nul, resultat_neg operation_brute) :
        def decode_op(operation_brute) :
            return operation_brute[:4], operation_brute[4]

        code_operation, op_entier = decode_op(operation_brute)
        resultat_precedent_nul = Reg(resultat_nul)
        value1 = value_reg1
        value2 = Mux(op_entier, value_reg2, entier)
        return value1, value2, resultat_precedent_nul



    #obtention du code
    curr_line = Reg(Defer(prog_rom_addr_size, lambda:next_line))
    curr_code = ROM(prog_rom_addr_size, prog_rom_word_size, curr_line)
    jump_line, jump_flag_code, operation_brute, entier, read_addr1, read_addr2, write_addr_reg, write_enable_reg, write_enable_ram = decodeur(curr_code)
    #à décaler, on doit utiliser les autres drapeaux de saut conditionnels : 
    #next_line = liseur_code(jump_line, jump_flag, line_incr)

    #registres
    value_reg1, value_reg2 = gestion_registres(read_addr1, read_addr2, write_addr_reg, write_enable_reg, Defer(reg_size, lambda:write_data_reg))

    #calcul
    value1, value2, resultat_precedent_nul, resultat_precedent_neg, operation = interf_alu(value_reg1, value_reg2, entier, Defer(1, lambda:resultat_nul), Defer(1, lambda:resultat_neg), operation_brute)

    resultat, resulat_nul, resultat_neg = alu(value_1, value_2, operation)
    

    #écriture
    write_data_reg = Mux(, Defer(16, lambda:ram_value), resultat)
    
    ram_addr = resultat

    ram_value = RAM(ram_addr_size, ram_word_size, resultat, write_enable_ram)






